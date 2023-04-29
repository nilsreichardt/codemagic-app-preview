import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:codemagic_app_preview/src/builds/artifact_links_parser.dart';
import 'package:codemagic_app_preview/src/comment/comment_builder.dart';
import 'package:codemagic_app_preview/src/comment/comment_poster.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/git/git_provider_repository.dart';
import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:http/http.dart';

class PostCommand extends Command {
  PostCommand({
    Client? httpClient,
    this.environmentVariableAccessor =
        const SystemEnvironmentVariableAccessor(),
    this.gitRepo = const GitRepo(),
  }) : this.httpClient = httpClient ?? Client() {
    argParser
      ..addOption(
        'github_token',
        abbr: 't',
        help: 'Your personal access token to access the GitHub API.',
        aliases: ['gh_token'],
      );
    argParser
      ..addOption(
        'gitlab_token',
        help: 'Your personal access token to access the GitLab API.',
        aliases: ['gl_token'],
      );
    argParser
      ..addOption(
        'message',
        abbr: 'm',
        help: 'A custom message that can be added to the comment.',
      );
  }

  final Client httpClient;
  final EnvironmentVariableAccessor environmentVariableAccessor;
  final GitRepo gitRepo;

  @override
  String get description =>
      'Post a new comment or edits the existing comment with the links to the app previews';

  @override
  String get name => 'post';

  Future<GitProviderRepository?> _getGitProviderRepository(
      GitRepo gitRepo) async {
    // Set to Integer ID of the pull request for the Git provider (Bitbucket,
    // GitHub, etc.) if the current build is building a pull request, unset
    // otherwise.
    //
    // https://docs.codemagic.io/flutter-configuration/built-in-variables/
    final pullRequestId =
        environmentVariableAccessor.get('CM_PULL_REQUEST_NUMBER');

    final String? gitHubToken = argResults?['github_token'];
    final String? gitLabToken = argResults?['gitlab_token'];

    try {
      return await GitProviderRepository.getGitProviderFrom(
        gitRepo: gitRepo,
        pullRequestId: pullRequestId,
        gitLabToken: gitLabToken,
        gitHubToken: gitHubToken,
        httpClient: httpClient,
      );
    } on MissingGitProviderTokenException catch (e) {
      stderr.writeln(e.message);
      exitCode = 1;
      return null;
    }
  }

  Future<void> run() async {
    final String? message = argResults?['message'];
    final builds = ArtifactLinksParser(environmentVariableAccessor).getBuilds();

    final comment = CommentBuilder(environmentVariableAccessor).build(
      builds,
      message: message,
    );

    final gitProviderRepository = await _getGitProviderRepository(gitRepo);
    if (gitProviderRepository == null) {
      // Error message is already printed.
      return;
    }

    await CommentPoster(gitProviderRepository).post(comment: comment);
  }
}
