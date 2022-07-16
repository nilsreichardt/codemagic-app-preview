import 'build_platform.dart';

/// A successful Codemagic build from the artifacts.
class Build {
  /// Creates a [Build].
  ///
  /// Use [Build.fromJson] to parse it from the json.
  const Build({
    required this.url,
    required this.platform,
  });

  /// Parses an item in the list of the environment variable
  /// "CM_ARTIFACT_LINKS".
  ///
  /// Example for a single item in the json:
  /// ```json
  /// {
  ///  "name": "Codemagic_Release.ipa",
  ///  "type": "ipa",
  ///  "url": "https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa",
  ///  "md5": "d2884be6985dad3ffc4d6f85b3a3642a",
  ///  "versionName": "1.0.2",
  ///  "bundleId": "io.codemagic.app"
  /// }
  /// ```
  /// From https://docs.codemagic.io/variables/environment-variables/
  factory Build.fromJson(Map<String, dynamic> json) {
    return Build(
      url: json['url'],
      platform: BuildPlatform.fromType(json['type']),
    );
  }

  /// The public url to the build.
  final String url;

  /// The platform for which the build is built for.
  final BuildPlatform platform;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Build && other.url == url && other.platform == platform;
  }

  @override
  int get hashCode => url.hashCode ^ platform.hashCode;
}
