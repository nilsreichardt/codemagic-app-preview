import 'package:codemagic_app_preview/src/builds/build.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';

class CommentBuilder {
  const CommentBuilder(this._environmentVariableAccessor);

  final EnvironmentVariableAccessor _environmentVariableAccessor;

  /// Builds a message that can be used a comment on a pull request.
  String build(List<Build> builds, {String? message}) {
    final comment = StringBuffer();

    final projectId = _environmentVariableAccessor.get('FCI_PROJECT_ID');
    final buildId = _environmentVariableAccessor.get('FCI_BUILD_ID');
    final codemagicBuildUrl =
        'https://codemagic.io/app/$projectId/build/$buildId';

    final commit = _environmentVariableAccessor.get('FCI_COMMIT');
    final table = _buildTable(builds);

    comment.write(
        '⬇️ Generated builds by [Codemagic]($codemagicBuildUrl) for commit \`$commit\` ⬇️');

    if (message != null) {
      comment.write('\n\n$message');
    }

    comment.writeln('\n\n$table');

    return '$comment';
  }

  /// Returns the Markdown table with the build qr codes and links.
  ///
  /// Example for a table with two builds:
  /// ```
  /// | Android | iOS |
  /// |:-:|:-:|
  /// | ![image](https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$LINK) <br /> [Download link]($LINK) | ![image](https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$ENCODED_IPA_LINK) <br /> [Download link]($LINK)
  /// ```
  String _buildTable(List<Build> builds) {
    final table = StringBuffer();

    table.write('|');
    for (final build in builds) {
      table.write(' ${build.platform.name} |');
    }

    table.write('\n|');
    for (var i = 0; i < builds.length; i++) {
      table.write(':-:|');
    }

    table.write('\n|');
    for (final build in builds) {
      final qrCodeUrl = _getQrCodeUrl(build.url);
      table.write(
          ' ![image]($qrCodeUrl) <br /> [Download link](${build.url}) |');
    }

    return '$table';
  }

  /// Returns a url that renders the [url] as a qr code when using this as a
  /// image for a GitHub comment.
  ///
  /// Encodes the url to make it safe to use as a url component.
  ///
  /// Example when using the url
  /// `https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa`:
  /// `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=https%3A%2F%2Fapi.codemagic.io%2Fartifacts%2F2e7564b2-9ffa-40c2-b9e0-8980436ac717%2F81c5a723-b162-488a-854e-3f5f7fdfb22f%2FCodemagic_Release.ipa`
  String _getQrCodeUrl(String url) {
    // The url needs to be encoded to make it safe to use as a url component.
    final encodedUrl = Uri.encodeComponent(url);
    return 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$encodedUrl';
  }
}
