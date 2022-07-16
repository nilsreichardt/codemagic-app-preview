/// A platform for which the build is built for.
enum BuildPlatform {
  /// The build is for the Android platform.
  ///
  /// File formats are `.apk` and `.aab`.
  android,

  /// The build is for the iOS platform.
  ///
  /// File formats are `.ipa`.
  ios;
}

/// Extension methods for [BuildPlatform].
///
/// When using Dart 2.17 as minimum version, should this be refactored to enum
/// class, like: https://github.com/nilsreichardt/codemagic-app-preview/blob/8996c2219af619acfb0a37df83e83041202653e4/packages/codemagic_app_preview/lib/src/builds/build_platform.dart
extension BuildPlatformExtension on BuildPlatform {
  /// Returns the name of the platform, e.g. "iOS" for [ios].
  String get name {
    switch (this) {
      case BuildPlatform.android:
        return 'Android';
      case BuildPlatform.ios:
        return 'iOS';
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
    default:
      throw Exception('Unknown build platform file extension: $fileExtension');
  }
}
