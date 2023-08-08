import 'dart:convert';

import 'package:http/http.dart';

class CodemagicApiRepository {
  /// API Token of Codemagic.
  ///
  /// Can be accessed via Codemagic UI -> Team -> Integration -> API.
  final String apiToken;

  /// The HTTP client for making requests.
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
  /// Codemagic API documentation:
  /// https://docs.codemagic.io/rest-api/artifacts/#step-2-create-a-public-download-url-using-the-url-obtained-in-step-1
  Future<PublicArtifactResponse> getPublicArtifactUrl({
    required String privateUrl,
    required DateTime expiresAt,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$privateUrl/public-url'),
      body: jsonEncode({
        // Convert DateTime to seconds since epoch (Unix timestamp).
        'expiresAt': expiresAt.millisecondsSinceEpoch ~/ 1000,
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
    // The expire date that is set by Codemagic. Technically, it could be a
    // slightly different date than [expiresAt] is.
    final actualExpiresAt = DateTime.parse(json['expiresAt']);

    return PublicArtifactResponse(
      url: url,
      expiresAt: actualExpiresAt,
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
