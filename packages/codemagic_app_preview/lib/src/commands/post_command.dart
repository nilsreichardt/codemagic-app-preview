import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:clock/clock.dart';
import 'package:codemagic_app_preview/src/builds/artifact_links_parser.dart';
import 'package:codemagic_app_preview/src/builds/build.dart';
import 'package:codemagic_app_preview/src/builds/codemagic_api_repository.dart';
import 'package:codemagic_app_preview/src/comment/comment_builder.dart';
import 'package:codemagic_app_preview/src/comment/comment_poster.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/git/git_host_repository.dart';
import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:http/http.dart';

/// Command to post the app preview comment on a pull request.
///
/// Handles fetching the build artifacts from Codemagic, generating the comment
/// with QR codes and links, and posting or updating the comment on the pull
/// request via the Git host API.
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
            'Defines the duration for which the URLs to the artifacts are valid. The maximum duration depends on your account type, see https://docs.codemagic.io/billing/pricing/#build-history-and-artifact-storage. The default value is 30 days. Example values: "1w 4d 23h 59m 59s 999ms" or "365d"',
        defaultsTo: '30d',
      )
      ..addOption(
        'app-name',
        help:
            'The name of the app. This is helpful if you have multiple apps in the same repository. If not provided, the name "default" is used. Using different names for different apps allows you to post multiple comments in the same pull request.',
      )
      ..addOption(
        'qr-code-size',
        help:
            'The size of the QR code in pixels as an integer. The default value is 200. Example values: "100" or "500"',
        defaultsTo: '200',
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

  Future<void> run({DateTime? now}) async {
    if (!_isPullRequest()) {
      stderr.writeln(
          '"CM_PULL_REQUEST_NUMBER" is not set. Seems like the current build is not building a pull request. Aborting.');
      exitCode = 1;
      return;
    }

    final builds = await _parseBuilds(now: now);
    if (builds == null) {
      // Error message is already printed.
      return;
    }

    final comment = CommentBuilder(environmentVariableAccessor).build(
      builds,
      message: argResults?['message'],
      qrCodeSize: int.parse(argResults?['qr-code-size']!),
    );

    final gitHostRepository = await _getGitHostRepository(gitRepo);
    if (gitHostRepository == null) {
      // Error message is already printed.
      return;
    }

    await CommentPoster(gitHostRepository).post(
      comment: comment,
      appName: argResults?['app-name'],
    );
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
    if (builds.isEmpty) {
      stderr.writeln(
          'No artifacts found. Make sure to set the "artifacts" option in your codemagic.yaml file.');
      exitCode = 1;
      return null;
    }

    return builds;
  }

  /// Returns `true` if the current build is building a pull request, `false`
  /// otherwise.
  bool _isPullRequest() {
    // We don't use CM_PULL_REQUEST here because this would require to set
    // an additional environment variable in the workflow to trigger the
    // build when using a label.
    final pullRequestId =
        environmentVariableAccessor.get('CM_PULL_REQUEST_NUMBER') as String?;
    return pullRequestId != null && pullRequestId.isNotEmpty;
  }

  Future<GitHostRepository?> _getGitHostRepository(GitRepo gitRepo) async {
    // Set to Integer ID of the pull request for the Git host (Bitbucket,
    // GitHub, etc.) if the current build is building a pull request, unset
    // otherwise.
    //
    // https://docs.codemagic.io/flutter-configuration/built-in-variables/
    final pullRequestId =
        environmentVariableAccessor.get('CM_PULL_REQUEST_NUMBER');

    final String? gitHubToken = argResults?['github_token'];
    final String? gitLabToken = argResults?['gitlab_token'];

    try {
      return await GitHostRepository.getGitHostFrom(
        gitRepo: gitRepo,
        pullRequestId: pullRequestId,
        gitLabToken: gitLabToken,
        gitHubToken: gitHubToken,
        httpClient: httpClient,
      );
    } on MissingGitHostTokenException catch (e) {
      stderr.writeln(e.message);
      exitCode = 1;
      return null;
    }
  }
}

/// Parses duration string into [Duration]. [separator] defines the string
/// that splits duration components in the string.
///
/// Example:
/// ```dart
/// parseDuration('2w 5d 23h 59m 59s 999ms');
/// ```
Duration parseDuration(String input, {String separator = ','}) {
  final parts = input.split(separator).map((t) => t.trim()).toList();

  int? weeks;
  int? days;
  int? hours;
  int? minutes;
  int? seconds;
  int? milliseconds;

  for (String part in parts) {
    final match = RegExp(r'^(\d+)(w|d|h|min|m|s|ms)$').matchAsPrefix(part);
    if (match == null) throw FormatException('Invalid duration format');

    int value = int.parse(match.group(1)!);
    String? unit = match.group(2);

    switch (unit) {
      case 'w':
        if (weeks != null) {
          throw FormatException('Weeks specified multiple times');
        }
        weeks = value;
        break;
      case 'd':
        if (days != null) {
          throw FormatException('Days specified multiple times');
        }
        days = value;
        break;
      case 'h':
        if (hours != null) {
          throw FormatException('Hours specified multiple times');
        }
        hours = value;
        break;
      case 'min':
      case 'm':
        if (minutes != null) {
          throw FormatException('Minutes specified multiple times');
        }
        minutes = value;
        break;
      case 's':
        if (seconds != null) {
          throw FormatException('Seconds specified multiple times');
        }
        seconds = value;
        break;
      case 'ms':
        if (milliseconds != null) {
          throw FormatException('Milliseconds specified multiple times');
        }
        milliseconds = value;
        break;
      default:
        throw FormatException('Invalid duration unit $unit');
    }
  }

  return Duration(
    days: (days ?? 0) + (weeks ?? 0) * 7,
    hours: hours ?? 0,
    minutes: minutes ?? 0,
    seconds: seconds ?? 0,
    milliseconds: milliseconds ?? 0,
  );
}
