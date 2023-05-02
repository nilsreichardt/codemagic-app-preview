import 'dart:convert';

import 'package:codemagic_app_preview/src/builds/build_platform.dart';
import 'package:codemagic_app_preview/src/builds/codemagic_api_repository.dart';

import '../environment_variable/environment_variable_accessor.dart';
import 'build.dart';

class ArtifactLinksParser {
  const ArtifactLinksParser({
    required this.environmentVariableAccessor,
    required this.codemagicRepository,
  });

  final EnvironmentVariableAccessor environmentVariableAccessor;
  final CodemagicApiRepository codemagicRepository;

  /// Returns the builds from the environment variable "CM_ARTIFACT_LINKS" and
  /// gets the public URL for the artifacts.
  ///
  /// [expiresIn] is the duration for which the public URL is valid.
  Future<List<Build>> getBuilds({
    required Duration expiresIn,
    DateTime? now,
  }) async {
    final json = environmentVariableAccessor.get('CM_ARTIFACT_LINKS');
    if (json == null) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(json);
    final builds = <Build>[];

    for (final dynamic json in jsonList) {
      // Parses an item in the list of the environment variable
      // "CM_ARTIFACT_LINKS".
      //
      // Example for a single item in the json:
      // ```json
      // {
      //  "name": "Codemagic_Release.ipa",
      //  "type": "ipa",
      //  "url": "https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa",
      //  "md5": "d2884be6985dad3ffc4d6f85b3a3642a",
      //  "versionName": "1.0.2",
      //  "bundleId": "io.codemagic.app"
      // }
      // ```
      // From https://docs.codemagic.io/variables/environment-variables/
      final privateUrl = json['url'];
      final platform = getBuildPlatform(json['type']);

      final publicArtifact = await codemagicRepository.getPublicArtifactUrl(
        privateUrl: privateUrl,
        expiresIn: expiresIn,
        now: now,
      );

      final build = Build(
        platform: platform,
        privateUrl: privateUrl,
        publicUrl: publicArtifact.url,
        expiresAt: publicArtifact.expiresAt,
      );
      builds.add(build);
    }

    return builds;
  }
}
