import 'package:codemagic_app_preview/src/build.dart';
import 'package:codemagic_app_preview/src/build_platform.dart';
import 'package:codemagic_app_preview/src/artifact_links_parser.dart';
import 'package:codemagic_app_preview/src/environment_variable_accessor.dart';
import 'package:test/test.dart';

void main() {
  group('ArtifactLinksParser', () {
    late ArtifactLinksParser parser;
    late MockEnvironmentVariableAccessor accessor;

    setUp(() {
      accessor = MockEnvironmentVariableAccessor();
      parser = ArtifactLinksParser(accessor);
    });

    test('parses a list of builds', () {
      final links = """[
{
  "name": "Codemagic_Release.ipa",
  "type": "ipa",
  "url": "https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa",
  "md5": "d2884be6985dad3ffc4d6f85b3a3642a",
  "versionName": "1.0.2",
  "bundleId": "io.codemagic.app"
}
]""";
      accessor.environmentVariables['CM_ARTIFACT_LINKS'] = links;

      expect(parser.getBuilds(), [
        Build(
          url:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa',
          platform: BuildPlatform.ios,
        )
      ]);
    });

    test('returns a empty list if "CM_ARTIFACT_LINKS" is null', () {
      accessor.environmentVariables['CM_ARTIFACT_LINKS'] = null;
      expect(parser.getBuilds(), isEmpty);
    });
  });
}
