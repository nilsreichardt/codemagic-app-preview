import 'dart:math';

import 'package:codemagic_app_preview/src/builds/build.dart';
import 'package:codemagic_app_preview/src/builds/build_platform.dart';
import 'package:codemagic_app_preview/src/environment_variable/environment_variable_accessor.dart';
import 'package:codemagic_app_preview/src/comment/comment_builder.dart';
import 'package:test/test.dart';

void main() {
  group('CommentBuilder', () {
    late CommentBuilder builder;
    late MockEnvironmentVariableAccessor accessor;

    setUp(() {
      accessor = MockEnvironmentVariableAccessor();
      builder = CommentBuilder(accessor, random: Random(42));
    });

    test('returns the expected comment for the given builds', () {
      final builds = [
        Build(
          privateUrl:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.apk',
          publicUrl:
              'https://api.codemagic.io/artifacts/.eJwVwclygjAAANB_6d0ZCMaYgweNIiA7RAgXRtayGEzBGv6-0_e-2uO_0xDHKHPPKUZUipUTp0IajU8P-JPMRJnxqy3kG2X268VZjBz8zKqFSzHtTxG79ngEaFI4k4kso8VYrrC3OlM3pi2p6zkCa6xnuuVWuBIV6bAz253m5foFNbm6gbuS8n57MwB1JCuay9j0-YKP-RpClrVq-G7eJlSN86cAoxfWSR0C-Bs4vqLoN7d87kTRFQG9R8NG1WKMqbV31NSmU8jtIeXQk4zjRCVCy2awT_zIRsW3SY7ump6roC3Bh3wsvxu8RygFgOaIdpdbe19SNvlTINrD4esPvxBgaQ.b3oiUFXA3GHsUEEPj5VINUO-7x4',
          platform: BuildPlatform.android,
          expiresAt: DateTime.now(),
        ),
        Build(
          privateUrl:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.ipa',
          publicUrl:
              'https://api.codemagic.io/artifacts/.eJwVwcuyQzAAANB_6d4MwqhFF15N03oEtyk2d1BNES2qhK-_c8_ZUeOf2f6Q03BqbHwTOTI0zad4Oi909c7GNgCZETEJq6e6RZkzRE47rOz9YaaAEMDG7cTG7qLYEbTx0cOBPoKiufcBoeqncKU5iOejsyLlC0F4rdkjhgsoM2UJ7Jcz83Xop0wUmoAb_EuWUva9_B37sJEGPTsjSV_V8KkUKLm8YNWS2NcsO_X0Dlu2qeGCTXtPc5G95TIIR1pzp3-1aJ8KYnJVVMCrzgnD6OGNRLi77_LaR5NcLxTT2szVy5fdchi1hEs-_U1drVHmh5XoktWN2lpO0E8rejjs_gANHmGQ.uhTyoMdEjaLVwyJr_1GWP-oMqQI',
          platform: BuildPlatform.ios,
          expiresAt: DateTime.now(),
        ),
        Build(
          privateUrl:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.zip',
          publicUrl:
              'https://api.codemagic.io/artifacts/.eJwVwUmSgjAAAMC_eLdKJYPMYQ4sgspODAiXlKISDJAoASKvt6Z7Uen_DHpK97YmirWd8Rtawq1NpiVLEeNPLorcxmwYtg80d58Hx2osxLjjHmYnaBSeScHYVEqfHXuzjBsEz-Fr1fpBBA_O7OzlriVpeLVW9_pdR6HkJDz6Zq5hIUTJDCXRpCcCxb989tSJfX8titMYdhaYzW5Q2b1ryaS5VnYv6K9nb245qzKbgCWFicG98jY0eXKgV6RIl55lx0SuRnKT6GkAscrKAllUVk4wywRPYHg1bTaK5wbUCIBJn-Eaj2UgnuJ6cX-QB_u3jqa8oiNPIodJzUMuCYtA1AQTJ26ivpoudcP-Fl_c8m33.PYYoVvVlhhyKci-G_61hxCmaccE',
          platform: BuildPlatform.macos,
          expiresAt: DateTime.now(),
        ),
      ];

      final projectId = '6274fcfc87c748ce531c7376';
      accessor.environmentVariables['FCI_PROJECT_ID'] = projectId;
      final buildId = '62877273178d247b70405cb0';
      accessor.environmentVariables['FCI_BUILD_ID'] = buildId;
      final commit = '50b04d910c6b73472f7dfc1fee38a67e7132bf32';
      accessor.environmentVariables['FCI_COMMIT'] = commit;

      // The group id that is generated when using 42 as seed.
      const groupId = "33aec45d";

      expect(builder.build(builds),
          """⬇️ Generated builds by [Codemagic](https://codemagic.io/app/$projectId/build/$buildId) for commit $commit ⬇️

| ${builds[0].platform.platformName} | ${builds[1].platform.platformName} | ${builds[2].platform.platformName} |
|:-:|:-:|:-:|
| ![image](https://app-preview-qr.nils.re/?size=150x150&data=${Uri.encodeComponent(builds[0].publicUrl)}&platform=android&groupId=$groupId) <br /> [Download link](${builds[0].publicUrl}) | ![image](https://app-preview-qr.nils.re/?size=150x150&data=${Uri.encodeComponent(builds[1].publicUrl)}&platform=ios&groupId=$groupId) <br /> [Download link](${builds[1].publicUrl}) | ![image](https://app-preview-qr.nils.re/?size=150x150&data=${Uri.encodeComponent(builds[2].publicUrl)}&platform=macos&groupId=$groupId) <br /> [Download link](${builds[2].publicUrl}) |

<!-- Codemagic App Preview; appName: default -->
""");
    });

    test('includes the message into the comment', () {
      final builds = [
        Build(
          privateUrl:
              'https://api.codemagic.io/artifacts/2e7564b2-9ffa-40c2-b9e0-8980436ac717/81c5a723-b162-488a-854e-3f5f7fdfb22f/Codemagic_Release.apk',
          publicUrl:
              'https://api.codemagic.io/artifacts/.eJwVwcuyQzAAANB_6d4MwqhFF15N03oEtyk2d1BNES2qhK-_c8_ZUeOf2f6Q03BqbHwTOTI0zad4Oi909c7GNgCZETEJq6e6RZkzRE47rOz9YaaAEMDG7cTG7qLYEbTx0cOBPoKiufcBoeqncKU5iOejsyLlC0F4rdkjhgsoM2UJ7Jcz83Xop0wUmoAb_EuWUva9_B37sJEGPTsjSV_V8KkUKLm8YNWS2NcsO_X0Dlu2qeGCTXtPc5G95TIIR1pzp3-1aJ8KYnJVVMCrzgnD6OGNRLi77_LaR5NcLxTT2szVy5fdchi1hEs-_U1drVHmh5XoktWN2lpO0E8rejjs_gANHmGQ.uhTyoMdEjaLVwyJr_1GWP-oMqQI',
          platform: BuildPlatform.android,
          expiresAt: DateTime.now(),
        ),
      ];
      final message = 'this is a custom message';

      expect(builder.build(builds, message: message), contains(message));
    });
  });
}
