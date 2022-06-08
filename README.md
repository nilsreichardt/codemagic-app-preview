## Codemagic App Preview
We all know testing manually the changes of a pull request is hard. With this package you only need to add 2 lines to your Codemagic configurations and you will get for every pull request QR codes. You can just scan these QR codes with your smartphone and test the changes.

| <img src="https://user-images.githubusercontent.com/24459435/172502560-4948c727-af65-4e46-bb8f-9c8857f7a646.png" /> | <img src="https://user-images.githubusercontent.com/24459435/172503726-38b1ed63-0c93-4edc-8e5f-19a299cd93ad.gif" width=175 /> |
| - | - |

```yaml
artifacts:
  - build/**/outputs/apk/**/*.apk
  - build/ios/ipa/*.ipa
publishing:
  scripts:
     - name: Post App Preview
       script: |
         dart pub global activate codemagic_app_preview
         app_preview post --token $GITHUB_PAT
```