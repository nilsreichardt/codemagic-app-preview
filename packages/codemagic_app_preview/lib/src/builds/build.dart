import 'build_platform.dart';

/// A successful Codemagic build from the artifacts.
class Build {
  const Build({
    required this.privateUrl,
    required this.platform,
    required this.publicUrl,
    required this.expiresAt,
  });

  /// The protected url to the build.
  ///
  /// Can only be accessed when passing some kind of authentication to Codemagic
  /// when accessing the url.
  final String privateUrl;

  /// The public url to the build.
  ///
  /// URL can be accessed without any authentication. The url is valid for a
  /// limited time.
  final String publicUrl;

  /// The time when the public url expires.
  final DateTime expiresAt;

  /// The platform for which the build is built for.
  final BuildPlatform platform;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Build &&
        other.privateUrl == privateUrl &&
        other.platform == platform;
  }

  @override
  int get hashCode => privateUrl.hashCode ^ platform.hashCode;
}
