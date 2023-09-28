import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:clock/clock.dart';
import 'package:codemagic_app_preview/src/builds/artifact_links_parser.dart';
import 'package:codemagic_app_preview/src/builds/build.dart';
import 'package:codemagic_app_preview/src/builds/codemagic_api_repository.dart';
import 'package:codemagic_app_preview/src/comment/comment_builder.dart';
import 'package:codemagic_app_preview/src/comment/comment_poster.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/git/git_provider_repository.dart';
import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:http/http.dart';
import 'package:duration/duration.dart';

class PostCommand extends Command {
  PostCommand({
    required this.httpClient,
    required this.clock,
    this.environmentVariableAccessor =
        const SystemEnvironmentVariableAccessor(),
    this.gitRepo = const GitRepo(),
  }) {
    argParser
      ..addOption(
        'github_token',
        abbr: 't',
        help: 'Your personal access token to access the GitHub API.',
        aliases: ['gh_token'],
      )
      ..addOption(
        'gitlab_token',
        help: 'Your personal access token to access the GitLab API.',
        aliases: ['gl_token'],
      )
      ..addOption(
        'codemagic_token',
        help:
            'Token to access the Codemagic API. Is available at: Teams > Personal Account > Integrations > Codemagic API > Show. See https://docs.codemagic.io/rest-api/codemagic-rest-api/.',
      )
      ..addOption(
        'message',
        abbr: 'm',
        help: 'A custom message that can be added to the comment.',
      )
      ..addOption(
        'expires_in',
        help:
            'Defines the duration for which the URLs to the builds are valid. The maximum duration depends on your account type, see: https://docs.codemagic.io/billing/pricing/#build-history-and-artifact-storage. The default value is 30 days. Example values: "2w 5d 23h 59m 59s 999ms 999us" or "365d"',
        defaultsTo: '30d',
      )
      ..addOption(
        'app-name',
        help:
            'The name of the app. This is helpful if you have multiple apps in the same repository. If not provided, the name "default" is used. Using different names for different apps allows you to post multiple comments in the same pull request.',
      );
  }

  final Client httpClient;
  final EnvironmentVariableAccessor environmentVariableAccessor;
  final GitRepo gitRepo;
  final Clock clock;

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

  Future<List<Build>?> _parseBuilds({DateTime? now}) async {
    final String? apiToken = argResults?['codemagic_token'];
    if (apiToken == null) {
      stderr.writeln(
          'Codemagic API token is not provided. Please set the token with the --codemagic_token option.');
      exitCode = 1;
      return null;
    }

    final codemagicRepository = CodemagicApiRepository(
      httpClient: httpClient,
      apiToken: apiToken,
    );
    final parser = ArtifactLinksParser(
      codemagicRepository: codemagicRepository,
      environmentVariableAccessor: environmentVariableAccessor,
      clock: clock,
    );

    final expiresIn = parseDuration(argResults?['expires_in']);

    final builds = await parser.getBuilds(expiresIn: expiresIn);
    return builds;
  }

  Future<void> run({DateTime? now}) async {
    final builds = await _parseBuilds(now: now);
    if (builds == null) {
      // Error message is already printed.
      return;
    }

    final String? message = argResults?['message'];
    final comment = CommentBuilder(environmentVariableAccessor).build(
      builds,
      message: message,
    );

    final gitProviderRepository = await _getGitProviderRepository(gitRepo);
    if (gitProviderRepository == null) {
      // Error message is already printed.
      return;
    }

    await CommentPoster(gitProviderRepository).post(
      comment: comment,
      appName: argResults?['app-name'],
    );
  }
}
