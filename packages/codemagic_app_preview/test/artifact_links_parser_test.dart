import 'package:clock/clock.dart';
import 'package:codemagic_app_preview/src/builds/artifact_links_parser.dart';
import 'package:codemagic_app_preview/src/builds/build.dart';
import 'package:codemagic_app_preview/src/builds/build_platform.dart';
import 'package:codemagic_app_preview/src/builds/codemagic_api_repository.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCodemagicApiRepository extends Mock
    implements CodemagicApiRepository {}

class MockClock extends Mock implements Clock {}

void main() {
  group('ArtifactLinksParser', () {
    late ArtifactLinksParser parser;
    late MockEnvironmentVariableAccessor accessor;
    late MockCodemagicApiRepository codemagicRepository;
    late MockClock clock;

    setUp(() {
      codemagicRepository = MockCodemagicApiRepository();
      accessor = MockEnvironmentVariableAccessor();
      clock = MockClock();
      parser = ArtifactLinksParser(
        environmentVariableAccessor: accessor,
        codemagicRepository: codemagicRepository,
        clock: clock,
      );
    });

    test('parses a list of builds and gets the public urls', () async {
      final now = DateTime.now();
      when(() => clock.now()).thenAnswer((_) => now);

      final privateUrl =
          'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa';
      final expiresIn = Duration(minutes: 1);
      final expiresAt = clock.now().add(expiresIn);

      when(() => codemagicRepository.getPublicArtifactUrl(
            privateUrl: privateUrl,
            expiresAt: expiresAt,
          )).thenAnswer((_) async => PublicArtifactResponse(
            url:
                'https://api.codemagic.io/artifacts/.eJwVwclygjAAANB_6d0ZCMaYgweNIiA7RAgXRtayGEzBGv6-0_e-2uO_0xDHKHPPKUZUipUTp0IajU8P-JPMRJnxqy3kG2X268VZjBz8zKqFSzHtTxG79ngEaFI4k4kso8VYrrC3OlM3pi2p6zkCa6xnuuVWuBIV6bAz253m5foFNbm6gbuS8n57MwB1JCuay9j0-YKP-RpClrVq-G7eJlSN86cAoxfWSR0C-Bs4vqLoN7d87kTRFQG9R8NG1WKMqbV31NSmU8jtIeXQk4zjRCVCy2awT_zIRsW3SY7ump6roC3Bh3wsvxu8RygFgOaIdpdbe19SNvlTINrD4esPvxBgaQ.b3oiUFXA3GHsUEEPj5VINUO-7x4',
            expiresAt: expiresAt,
          ));

      final links = """[
{
  "name": "Codemagic_Release.ipa",
  "type": "ipa",
  "url": "$privateUrl",
  "md5": "d2884be6985dad3ffc4d6f85b3a3642a",
  "versionName": "1.0.2",
  "bundleId": "io.codemagic.app"
}
]""";
      accessor.environmentVariables['CM_ARTIFACT_LINKS'] = links;

      final builds = await parser.getBuilds(
        expiresIn: expiresIn,
      );
      expect(builds, [
        Build(
          privateUrl:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa',
          publicUrl:
              'https://api.codemagic.io/artifacts/.eJwVwclygjAAANB_6d0ZCMaYgweNIiA7RAgXRtayGEzBGv6-0_e-2uO_0xDHKHPPKUZUipUTp0IajU8P-JPMRJnxqy3kG2X268VZjBz8zKqFSzHtTxG79ngEaFI4k4kso8VYrrC3OlM3pi2p6zkCa6xnuuVWuBIV6bAz253m5foFNbm6gbuS8n57MwB1JCuay9j0-YKP-RpClrVq-G7eJlSN86cAoxfWSR0C-Bs4vqLoN7d87kTRFQG9R8NG1WKMqbV31NSmU8jtIeXQk4zjRCVCy2awT_zIRsW3SY7ump6roC3Bh3wsvxu8RygFgOaIdpdbe19SNvlTINrD4esPvxBgaQ.b3oiUFXA3GHsUEEPj5VINUO-7x4',
          platform: BuildPlatform.ios,
          expiresAt: expiresAt,
        )
      ]);
    });

    test('returns a empty list if "CM_ARTIFACT_LINKS" is null', () async {
      accessor.environmentVariables['CM_ARTIFACT_LINKS'] = null;

      final builds = await parser.getBuilds(expiresIn: Duration.zero);
      expect(builds, isEmpty);
    });
  });
}
