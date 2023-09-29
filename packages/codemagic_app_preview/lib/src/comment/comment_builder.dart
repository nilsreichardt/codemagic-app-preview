import 'dart:math';

import 'package:codemagic_app_preview/src/builds/build.dart';
import 'package:codemagic_app_preview/src/builds/build_platform.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';

class CommentBuilder {
  CommentBuilder(this._environmentVariableAccessor, {Random? random})
      : _random = random ?? Random();

  final EnvironmentVariableAccessor _environmentVariableAccessor;

  /// Used to generate a random group id for the builds.
  final Random _random;

  /// Builds a message that can be used a comment on a pull request.
  String build(
    List<Build> builds, {
    String? appName,
    String? message,
  }) {
    final comment = StringBuffer();

    final projectId = _environmentVariableAccessor.get('FCI_PROJECT_ID');
    final buildId = _environmentVariableAccessor.get('FCI_BUILD_ID');
    final codemagicBuildUrl =
        'https://codemagic.io/app/$projectId/build/$buildId';

    final commit = _environmentVariableAccessor.get('FCI_COMMIT');
    final table = _buildTable(builds);

    comment.write(
        '⬇️ Generated builds by [Codemagic]($codemagicBuildUrl) for commit $commit ⬇️');

    if (message != null) {
      comment.write('\n\n$message');
    }

    comment.writeln('\n\n$table');

    comment.writeln(
        '\n<!-- Codemagic App Preview; appName: ${appName ?? 'default'} -->');

    return '$comment';
  }

  /// Returns the Markdown table with the build qr codes and links.
  ///
  /// Example for a table with two builds:
  /// ```
  /// | Android | iOS |
  /// |:-:|:-:|
  /// | ![image](https://app-preview-qr.nils.re/?size=150x150&data=$LINK) <br /> [Download link]($LINK) | ![image](https://app-preview-qr.nils.re/?size=150x150&data=$ENCODED_IPA_LINK) <br /> [Download link]($LINK)
  /// ```
  String _buildTable(List<Build> builds) {
    final table = StringBuffer();

    table.write('|');
    for (final build in builds) {
      table.write(' ${build.platform.platformName} |');
    }

    table.write('\n|');
    for (var i = 0; i < builds.length; i++) {
      table.write(':-:|');
    }

    table.write('\n|');
    final groupId = _generateGroupId();
    for (final build in builds) {
      final qrCodeUrl = _getQrCodeUrl(
        url: build.publicUrl,
        groupId: groupId,
        platform: build.platform,
      );
      if (build.platform == BuildPlatform.macos) {
        table.write(
            ' <a href="${build.publicUrl}"><picture><source media="(prefers-color-scheme: dark)" srcset="https://app-preview.nils.re/download-icon-white"><img alt="Download icon" src="https://app-preview.nils.re/download-icon-black"></picture></a> <br /> [Download link](${build.publicUrl}) |');
      } else {
        table.write(
            ' ![image]($qrCodeUrl) <br /> [Download link](${build.publicUrl}) |');
      }
    }

    return '$table';
  }

  /// Generates a random group id for the builds.
  ///
  /// The group id is used for analytics to identify which qr codes belong to
  /// the same build. We don't use the build id for this because the build id
  /// not fully anonymous (in case you would have access to Codemagic database
  /// you could query by the build id).
  ///
  /// The group id is a random 4 byte hex string. Example: `2e7564b2`.
  String _generateGroupId() {
    final bytes = List<int>.generate(4, (i) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Returns a url that renders the [url] as a qr code when using this as a
  /// image for a pull request comment.
  ///
  /// Encodes the url to make it safe to use as a url component and adds the
  /// [groupId] and [platform] as query parameters. The [groupId] and [platform]
  /// are used for analytics.
  ///
  /// Example when using the url
  /// `https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa`:
  /// `https://app-preview-qr.nils.re/?size=150x150&data=https%3A%2F%2Fapi.codemagic.io%2Fartifacts%2F2e7564b2-9ffa-40c2-b9e0-8980436ac717%2F81c5a723-b162-488a-854e-3f5f7fdfb22f%2FCodemagic_Release.ipa&groupId=2e7564b2&platform=ios`
  String _getQrCodeUrl({
    required String url,
    required String groupId,
    required BuildPlatform platform,
  }) {
    // The url needs to be encoded to make it safe to use as a url component.
    final encodedUrl = Uri.encodeComponent(url);
    return 'https://app-preview-qr.nils.re/?size=150x150&data=$encodedUrl&platform=${platform.platformIdentifier}&groupId=$groupId';
  }
}
