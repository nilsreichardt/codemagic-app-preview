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

  factory BuildPlatform.fromType(String type) {
    switch (type) {
      // todo: is this really aab or something else?
      case 'aab':
      case 'apk':
        return android;
      case 'ipa':
        return ios;
      default:
        throw Exception('Unknown build platform type: $type');
    }
  }
}
