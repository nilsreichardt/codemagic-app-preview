import 'package:codemagic_app_preview/src/builds/build.dart';
import 'package:codemagic_app_preview/src/builds/build_platform.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/comment/comment_builder.dart';
import 'package:test/test.dart';

void main() {
  group('CommentBuilder', () {
    late CommentBuilder builder;
    late MockEnvironmentVariableAccessor accessor;

    setUp(() {
      accessor = MockEnvironmentVariableAccessor();
      builder = CommentBuilder(accessor);
    });

    test('returns the expected comment for the given builds', () {
      final builds = [
        Build(
          url:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.apk',
          platform: BuildPlatform.android,
        ),
        Build(
          url:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa',
          platform: BuildPlatform.ios,
        ),
      ];

      final projectId = '6274fcfc87c748ce531c7376';
      accessor.environmentVariables['FCI_PROJECT_ID'] = projectId;
      final buildId = '62877273178d247b70405cb0';
      accessor.environmentVariables['FCI_BUILD_ID'] = buildId;
      final commit = '50b04d910c6b73472f7dfc1fee38a67e7132bf32';
      accessor.environmentVariables['FCI_COMMIT'] = commit;

      expect(builder.build(builds),
          """⬇️ Generated builds by [Codemagic](https://codemagic.io/app/$projectId/build/$buildId) for commit \`$commit\` ⬇️

| ${builds[0].platform.name} | ${builds[1].platform.name} |
|:-:|:-:|
| ![image](https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(builds[0].url)}) <br /> [Download link](${builds[0].url}) | ![image](https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(builds[1].url)}) <br /> [Download link](${builds[1].url}) |
""");
    });

    test('includes the message into the comment', () {
      final builds = [
        Build(
          url:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.apk',
          platform: BuildPlatform.android,
        ),
      ];
      final message = 'this is a custom message';

      expect(builder.build(builds, message: message), contains(message));
    });
  });
}
