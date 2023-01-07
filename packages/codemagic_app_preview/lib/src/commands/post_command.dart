import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:codemagic_app_preview/src/builds/artifact_links_parser.dart';
import 'package:codemagic_app_preview/src/comment/comment_builder.dart';
import 'package:codemagic_app_preview/src/comment/comment_poster.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/git/git_provider.dart';
import 'package:codemagic_app_preview/src/git/git_provider_repository.dart';
import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:codemagic_app_preview/src/git/github_api_repository.dart';
import 'package:codemagic_app_preview/src/git/gitlab_api_repository.dart';
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
        'gh_token',
        abbr: 't',
        help: 'Your personal access token to access the GitHub API.',
      );
    argParser
      ..addOption(
        'gl_token',
        abbr: 't',
        help: 'Your personal access token to access the GitLab API.',
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
    final gitProvider = await gitRepo.getProvider();

    // Set to Integer ID of the pull request for the Git provider (Bitbucket,
    // GitHub, etc.) if the current build is building a pull request, unset
    // otherwise.
    //
    // https://docs.codemagic.io/flutter-configuration/built-in-variables/
    final pullRequestId =
        environmentVariableAccessor.get('CM_PULL_REQUEST_NUMBER');

    switch (gitProvider) {
      case GitProvider.github:
        final String? githubToken = argResults?['gh_token'];
        if (githubToken == null) {
          stderr.writeln(
              'The GitHub access token is not set. Please set the token with the --gh_token option.');
          exitCode = 1;
          return null;
        }

        final owner = await gitRepo.getOwner();
        final repoName = await gitRepo.getRepoName();

        return GitHubApiRepository(
          token: githubToken,
          httpClient: httpClient,
          owner: owner,
          repository: repoName,
          pullRequestId: pullRequestId,
        );
      case GitProvider.gitlab:
        final String? gitlabToken = argResults?['gl_token'];
        if (gitlabToken == null) {
          stderr.writeln(
              'The GitLab access token is not set. Please set the token with the --gl_token option.');
          exitCode = 1;
          return null;
        }

        final projectId = await _getGitLabProjectId(gitRepo, gitlabToken);

        return GitLabApiRepository(
          token: gitlabToken,
          httpClient: httpClient,
          mergeRequestId: pullRequestId,
          projectId: projectId,
        );
    }
  }

  Future<int> _getGitLabProjectId(GitRepo gitRepo, String gitlabToken) async {
    final owner = await gitRepo.getOwner();
    final repoName = await gitRepo.getRepoName();

    final response = await httpClient.get(
      Uri.parse(
        'https://gitlab.com/api/v4/projects/$owner%2F$repoName',
      ),
      headers: {
        'Authorization': 'Bearer $gitlabToken',
      },
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete comment: ${response.body} (${response.statusCode})');
    }

    return jsonDecode(response.body)['id'];
  }

  Future<void> run() async {
    final String? githubToken = argResults?['gh_token'];
    if (githubToken == null) {
      stderr.writeln(
          'The GitHub access token is not set. Please set the token with the --gh_token option.');
      exitCode = 1;
      return;
    }
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
