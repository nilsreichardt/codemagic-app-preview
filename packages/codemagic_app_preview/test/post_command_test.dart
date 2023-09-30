import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:clock/clock.dart';
import 'package:codemagic_app_preview/src/commands/post_command.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/git/git_host.dart';
import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements Client {}

class MockGitRepo extends Mock implements GitRepo {}

class MockClock extends Mock implements Clock {}

void main() {
  group('PostCommand', () {
    late PostCommand postCommand;
    late MockEnvironmentVariableAccessor environmentVariableAccessor;
    late MockHttpClient httpClient;
    late MockGitRepo gitRepo;
    late Clock clock;

    const repoOwner = 'nilsreichardt';
    const repoName = 'codemagic-app-preview';

    setUp(() {
      environmentVariableAccessor = MockEnvironmentVariableAccessor();
      httpClient = MockHttpClient();
      gitRepo = MockGitRepo();
      clock = Clock();
      postCommand = PostCommand(
        clock: clock,
        httpClient: httpClient,
        environmentVariableAccessor: environmentVariableAccessor,
        gitRepo: gitRepo,
      );

      when(() => gitRepo.getOwner()).thenAnswer((_) async => repoOwner);
      when(() => gitRepo.getRepoName()).thenAnswer((_) async => repoName);
    });

    test('sets exit code to 1 when not setting the token', () async {
      const pullRequestId = '24';
      environmentVariableAccessor
          .environmentVariables['CM_PULL_REQUEST_NUMBER'] = pullRequestId;
      when(() => gitRepo.getHost()).thenAnswer((_) async => GitHost.github);

      final runner = CommandRunner('test', 'A test command runner.');
      runner.addCommand(postCommand);

      await runner.run(['post']);

      expect(exitCode, 1);
    });

    test('sets exit code to 1 when there no artifacts are available', () async {
      const pullRequestId = '24';
      environmentVariableAccessor
          .environmentVariables['CM_PULL_REQUEST_NUMBER'] = pullRequestId;
      when(() => gitRepo.getHost()).thenAnswer((_) async => GitHost.github);
      environmentVariableAccessor.environmentVariables['FCI_PROJECT_ID'] =
          '6274fcfc87c748ce531c7376';
      environmentVariableAccessor.environmentVariables['FCI_BUILD_ID'] =
          '62877273178d247b70405cb0';
      environmentVariableAccessor.environmentVariables['FCI_COMMIT'] =
          '50b04d910c6b73472f7dfc1fee38a67e7132bf32';
      environmentVariableAccessor.environmentVariables['CM_ARTIFACT_LINKS'] =
          '[]'; // no artifacts

      final runner = CommandRunner('test', 'A test command runner.');
      runner.addCommand(postCommand);

      await runner.run([
        'post',
        '--github_token',
        'GITHUB_TOKEN',
        '--codemagic_token',
        'CODEMAGIC_TOKEN',
      ]);

      expect(exitCode, 1);
    });

    test('sets exit code to 1 when build is not executed in pull request',
        () async {
      when(() => gitRepo.getHost()).thenAnswer((_) async => GitHost.github);
      environmentVariableAccessor.environmentVariables['FCI_PROJECT_ID'] =
          '6274fcfc87c748ce531c7376';
      environmentVariableAccessor.environmentVariables['FCI_BUILD_ID'] =
          '62877273178d247b70405cb0';
      environmentVariableAccessor.environmentVariables['FCI_COMMIT'] =
          '50b04d910c6b73472f7dfc1fee38a67e7132bf32';
      environmentVariableAccessor
          .environmentVariables['CM_PULL_REQUEST_NUMBER'] = null;
      environmentVariableAccessor.environmentVariables['CM_ARTIFACT_LINKS'] =
          '[]'; // no artifacts

      final runner = CommandRunner('test', 'A test command runner.');
      runner.addCommand(postCommand);

      await runner.run([
        'post',
        '--github_token',
        'GITHUB_TOKEN',
        '--codemagic_token',
        'CODEMAGIC_TOKEN',
      ]);

      expect(exitCode, 1);
    });

    test('posts comment with the builds', () async {
      const pullRequestId = '24';
      environmentVariableAccessor.environmentVariables['FCI_PROJECT_ID'] =
          '6274fcfc87c748ce531c7376';
      environmentVariableAccessor.environmentVariables['FCI_BUILD_ID'] =
          '62877273178d247b70405cb0';
      environmentVariableAccessor.environmentVariables['FCI_COMMIT'] =
          '50b04d910c6b73472f7dfc1fee38a67e7132bf32';
      environmentVariableAccessor
          .environmentVariables['CM_PULL_REQUEST_NUMBER'] = pullRequestId;
      environmentVariableAccessor.environmentVariables['CM_PULL_REQUEST'] =
          'true';
      final privateUrl =
          'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa';
      environmentVariableAccessor.environmentVariables['CM_ARTIFACT_LINKS'] =
          '[{"name": "Codemagic_Release.ipa","type": "ipa","url": "$privateUrl","md5": "d2884be6985dad3ffc4d6f85b3a3642a","versionName": "1.0.2","bundleId": "io.codemagic.app"}]';

      final gitHubToken = "GITHUB_TOKEN";
      final codemagicToken = "CODEMAGIC_TOKEN";

      when(
        () => httpClient.post(
          Uri.parse('$privateUrl/public-url'),
          body: any(named: 'body'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': codemagicToken,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
            jsonEncode(
              {
                'url':
                    'https://api.codemagic.io/artifacts/.eJwVwcuyQzAAANB_6d4MwqhFF15N03oEtyk2d1BNES2qhK-_c8_ZUeOf2f6Q03BqbHwTOTI0zad4Oi909c7GNgCZETEJq6e6RZkzRE47rOz9YaaAEMDG7cTG7qLYEbTx0cOBPoKiufcBoeqncKU5iOejsyLlC0F4rdkjhgsoM2UJ7Jcz83Xop0wUmoAb_EuWUva9_B37sJEGPTsjSV_V8KkUKLm8YNWS2NcsO_X0Dlu2qeGCTXtPc5G95TIIR1pzp3-1aJ8KYnJVVMCrzgnD6OGNRLi77_LaR5NcLxTT2szVy5fdchi1hEs-_U1drVHmh5XoktWN2lpO0E8rejjs_gANHmGQ.uhTyoMdEjaLVwyJr_1GWP-oMqQI',
                'expiresAt': '2024-04-29T13:59:09+00:00'
              },
            ),
            200),
      );
      when(
        () => httpClient.get(
          Uri.parse(
              'https://api.github.com/repos/$repoOwner/$repoName/issues/$pullRequestId/comments'),
          headers: {
            'Authorization': 'Bearer $gitHubToken',
          },
        ),
      ).thenAnswer((_) async => Response('[]', 200));
      when(
        () => httpClient.post(
          Uri.parse(
              'https://api.github.com/repos/$repoOwner/$repoName/issues/$pullRequestId/comments'),
          headers: {
            'Authorization': 'Bearer $gitHubToken',
            'Content-Type': 'application/json',
          },
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode(
            {
              "id": 123,
              "body": "comment",
            },
          ),
          201,
        ),
      );
      when(() => gitRepo.getHost()).thenAnswer((_) async => GitHost.github);

      final runner = CommandRunner('test', 'A test command runner.');
      runner.addCommand(postCommand);

      await runner.run([
        'post',
        '--github_token',
        gitHubToken,
        '--codemagic_token',
        codemagicToken,
        '--expires_in',
        '1d',
      ]);

      verify(
        () => httpClient.post(
          Uri.parse(
              'https://api.github.com/repos/$repoOwner/$repoName/issues/$pullRequestId/comments'),
          headers: {
            'Authorization': 'Bearer $gitHubToken',
            'Content-Type': 'application/json',
          },
          body: any(named: 'body'),
        ),
      ).called(1);
    });
  });

  group('parseDuration', () {
    test('parses duration with all components', () {
      final result = parseDuration('2w 5d 23h 59m 59s 999ms', separator: ' ');
      expect(
        result,
        Duration(
          days: 19,
          hours: 23,
          minutes: 59,
          seconds: 59,
          milliseconds: 999,
        ),
      );
    });

    test('parses duration with single component', () {
      final result = parseDuration('2w');
      expect(result, Duration(days: 14));
    });

    test('throws for invalid format', () {
      expect(() => parseDuration('2x'), throwsFormatException);
    });

    test('throws for invalid unit', () {
      expect(() => parseDuration('5x', separator: ' '), throwsFormatException);
    });

    test('throws for multiple specifications of the same unit', () {
      expect(
          () => parseDuration('2w 3w', separator: ' '), throwsFormatException);
    });

    test('parses duration with comma separator', () {
      final result = parseDuration('2w,5d,23h,59m,59s,999ms');
      expect(
        result,
        Duration(
          days: 19,
          hours: 23,
          minutes: 59,
          seconds: 59,
          milliseconds: 999,
        ),
      );
    });

    test('parses duration with space separator and min for minutes', () {
      final result = parseDuration('23h 59min', separator: ' ');
      expect(
        result,
        Duration(
          hours: 23,
          minutes: 59,
        ),
      );
    });

    test('parses duration with missing components', () {
      final result = parseDuration('2w 59m', separator: ' ');
      expect(
        result,
        Duration(
          days: 14,
          minutes: 59,
        ),
      );
    });
  });
}
