/// A platform for which the build is built for.
enum BuildPlatform {
  /// The build is for the Android platform.
  ///
  /// File formats are `.apk` and `.aab`.
  android,

  /// The build is for the iOS platform.
  ///
  /// File formats are `.ipa`.
  ios,

  /// The build is for the macOS platform.
  ///
  /// File formats are `.app`
  macos,
}

/// Extension methods for [BuildPlatform].
///
/// When using Dart 2.17 as minimum version, should this be refactored to enum
/// class, like: https://github.com/nilsreichardt/codemagic-app-preview/blob/8996c2219af619acfb0a37df83e83041202653e4/packages/codemagic_app_preview/lib/src/builds/build_platform.dart
extension BuildPlatformExtension on BuildPlatform {
  /// Returns the name of the platform, e.g. "iOS" for [ios].
  String get platformName {
    switch (this) {
      case BuildPlatform.android:
        return 'Android';
      case BuildPlatform.ios:
        return 'iOS';
      case BuildPlatform.macos:
        return 'macOS';
    }
  }

  /// Returns the identifier of the platform, e.g. "ios" for [ios].
  ///
  /// Can be removed when using Dart 2.17 as minimum version.
  String get platformIdentifier {
    switch (this) {
      case BuildPlatform.android:
        return 'android';
      case BuildPlatform.ios:
        return 'ios';
      case BuildPlatform.macos:
        return 'macos';
    }
  }
}

/// Returns the [BuildPlatform] for the given [fileExtension].
BuildPlatform getBuildPlatform(String fileExtension) {
  switch (fileExtension) {
    case 'aab':
    case 'apk':
      return BuildPlatform.android;
    case 'ipa':
      return BuildPlatform.ios;
    case 'app':
      return BuildPlatform.macos;
    default:
      throw Exception('Unknown build platform file extension: $fileExtension');
  }
}
