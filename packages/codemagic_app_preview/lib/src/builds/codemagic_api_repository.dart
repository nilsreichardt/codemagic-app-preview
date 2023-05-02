import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:http/http.dart';

class CodemagicApiRepository {
  /// API Token of Codemagic.
  ///
  /// Can be accessed via Codemagic UI -> Team -> Integration -> API.
  final String apiToken;

  final Client httpClient;

  const CodemagicApiRepository({
    required this.httpClient,
    required this.apiToken,
  });

  /// Returns the public URL for an artifact.
  ///
  /// [privateUrl] is the private URL for the artifact. [expiresIn] is the
  /// duration for which the public URL is valid.
  ///
  /// [now] is the current time. If it is not provided, [DateTime.now()] is
  /// used. This is useful for testing.
  ///
  /// Codemagic API documentation:
  /// https://docs.codemagic.io/rest-api/artifacts/#step-2-create-a-public-download-url-using-the-url-obtained-in-step-1
  Future<PublicArtifactResponse> getPublicArtifactUrl({
    required String privateUrl,
    required Duration expiresIn,
    DateTime? now,
  }) async {
    if (now == null) {
      now = DateTime.now();
    }

    final response = await httpClient.post(
      Uri.parse('$privateUrl/public-url'),
      body: jsonEncode({
        // Convert DateTime to seconds since epoch (Unix timestamp).
        'expiresAt': now.add(expiresIn).millisecondsSinceEpoch ~/ 1000,
      }),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': apiToken,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get public artifact URL for artifact $privateUrl: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final url = json['url'] as String;
    final expiresAt = DateTime.parse(json['expiresAt']);

    return PublicArtifactResponse(
      url: url,
      expiresAt: expiresAt,
    );
  }
}

class PublicArtifactResponse {
  final DateTime expiresAt;
  final String url;

  const PublicArtifactResponse({
    required this.url,
    required this.expiresAt,
  });
}
