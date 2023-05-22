import 'package:codemagic_app_preview/src/builds/codemagic_api_repository.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  /// Set CODEMAGIC_TOKEN environment variable to run tests.
  ///
  /// Use the following command to use the environment variable:
  /// ```sh
  /// CODEMAGIC_TOKEN=...
  /// dart --define=CODEMAGIC_TOKEN=$CODEMAGIC_TOKEN test integration_test/codemagic_api_repository_test.dart --use-data-isolate-strategy
  /// ```
  ///
  /// At the moment, we need to use the `--use-data-isolate-strategy` flag
  /// because of https://github.com/dart-lang/test/issues/1794.
  const codemagicToken = String.fromEnvironment('CODEMAGIC_TOKEN');

  late Client httpClient;
  late CodemagicApiRepository codemagicApiRepository;

  setUpAll(() {
    if (codemagicToken.isEmpty) {
      print("⚠️  CODEMAGIC_TOKEN is not set. Skipping tests. ⚠️");
      throw Exception('CODEMAGIC_TOKEN is not set.');
    }
  });

  setUp(() {
    httpClient = Client();
    codemagicApiRepository = CodemagicApiRepository(
      apiToken: codemagicToken,
      httpClient: httpClient,
    );
  });

  group('.getPublicArtifactUrl()', () {
    test('response a public url', () async {
      final privateUrl =
          'https://api.codemagic.io/artifacts/97f7f910-df52-4adc-8762-c110698ab6ca/e3fada79-c349-4852-89bd-568c2490ac92/app_preview_example.ipa';

      final now = DateTime.now();
      final expiresAt = now.add(Duration(minutes: 5));

      final publicUrl = await codemagicApiRepository.getPublicArtifactUrl(
        privateUrl: privateUrl,
        expiresAt: expiresAt,
      );

      expect(publicUrl, startsWith('https://api.codemagic.io/artifacts/'));
    });
  });
}
