import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:codemagic_app_preview/src/commands/post_command.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/github/git_repo.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements Client {}

class MockGitRepo extends Mock implements GitRepo {}

void main() {
  group('PostCommand', () {
    late PostCommand postCommand;
    late MockEnvironmentVariableAccessor environmentVariableAccessor;
    late MockHttpClient httpClient;
    late MockGitRepo gitRepo;

    const repoOwner = 'nilsreichardt';
    const repoName = 'codemagic-app-preview';

    setUp(() {
      environmentVariableAccessor = MockEnvironmentVariableAccessor();
      httpClient = MockHttpClient();
      gitRepo = MockGitRepo();
      postCommand = PostCommand(
        httpClient: httpClient,
        environmentVariableAccessor: environmentVariableAccessor,
        gitRepo: gitRepo,
      );

      when(() => gitRepo.getOwner()).thenAnswer((_) async => repoOwner);
      when(() => gitRepo.getRepoName()).thenAnswer((_) async => repoName);
    });

    test('sets exit code to 1 when not setting the token', () async {
      final runner = CommandRunner('test', 'A test command runner.');
      runner.addCommand(postCommand);

      await runner.run(['post']);

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
      environmentVariableAccessor.environmentVariables['CM_ARTIFACT_LINKS'] =
          '[{"name": "Codemagic_Release.ipa","type": "ipa","url": "https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa","md5": "d2884be6985dad3ffc4d6f85b3a3642a","versionName": "1.0.2","bundleId": "io.codemagic.app"}]';

      when(
        () => httpClient.get(
          Uri.parse(
              'https://api.github.com/repos/$repoOwner/$repoName/issues/$pullRequestId/comments'),
          headers: {
            'Authorization': 'Bearer token',
          },
        ),
      ).thenAnswer((_) async => Response('[]', 200));
      when(
        () => httpClient.post(
          Uri.parse(
              'https://api.github.com/repos/$repoOwner/$repoName/issues/$pullRequestId/comments'),
          headers: {
            'Authorization': 'Bearer token',
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

      final runner = CommandRunner('test', 'A test command runner.');
      runner.addCommand(postCommand);

      await runner.run([
        'post',
        '--gh_token',
        'token',
      ]);

      verify(
        () => httpClient.post(
          Uri.parse(
              'https://api.github.com/repos/$repoOwner/$repoName/issues/$pullRequestId/comments'),
          headers: {
            'Authorization': 'Bearer token',
            'Content-Type': 'application/json',
          },
          body: any(named: 'body'),
        ),
      ).called(1);
    });
  });
}
