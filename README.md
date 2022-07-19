# Codemagic App Preview
We all know testing manually the changes of a pull request is hard. With this package you only need to add 2 lines to your Codemagic configurations and you will get for every pull request QR codes. You can just scan these QR codes with your smartphone and test the changes.

| <img width="920" alt="Demo of the app preview pull request comment" src="https://user-images.githubusercontent.com/24459435/179368696-87fe65e6-aba5-4a3d-be64-3eff5df8d309.png"> | <img alt="Demo of scanning the iOS app preview qr code" src="https://user-images.githubusercontent.com/24459435/179368786-c94ce9c2-2129-4c30-8677-b8ebf5633a2e.gif" width=165 /> |
| - | - |

```yaml
artifacts:
  - build/**/outputs/apk/**/*.apk
  - build/ios/ipa/*.ipa
  - build/macos/Build/Products/Release/*.app
publishing:
  scripts:
    - name: Add Dart SDK to PATH
      script: |
        echo PATH="$PATH":"$FLUTTER_ROOT/.pub-cache/bin" >> $CM_ENV
        echo PATH="$PATH":"$FLUTTER_ROOT/bin" >> $CM_ENV
    - name: Post App Preview
      script: |
        dart pub global activate codemagic_app_preview
        app_preview post --gh_token $GITHUB_PAT
```

## Supported platforms
Currently, you can generate a preview only for the following platforms.

| Android | iOS | macOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✔️     | ✔️   |   ✔️   |     |       |         |

## Disclaimer
This is an unofficial package for [Codemagic](https://codemagic.io). It's *not* maintained by Codemagic.
