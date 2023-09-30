Run `app_preview post --github_token $GITHUB_PAT --codemagic $CODEMAGIC_TOKEN` after building your apps.

Here is a full `codemagic.yaml` as an example:

```yaml
workflows:
  app_preview:
    name: app_preview
    environment:
      ios_signing:
        distribution_type: ad_hoc
        bundle_identifier: YOUR_BUNDLE_IDENTIFIER
      groups:
        # Adding environment group "github" which includes the GITHUB_PAT
        # variable. GITHUB_PAT is required for posting / editing comments on the pull request
        - "github"
        # Adding environment group "codemagic" which includes the CODEMAGIC_TOKEN
        # variable. Required to make the builds accessible for the app preview tool.
        - "codemagic"
    triggering:
      events:
        - pull_request
    scripts:
      # If you are not using Flutter, you need to add the build scripts for your
      # platform.
      - name: Build APK (Android)
        script: flutter build apk
      - name: Build macOS
        script: flutter build macos
      - name: Build IPA (iOS)
        script: |
          flutter build ipa \
            --export-options-plist=/Users/builder/export_options.plist
    # Adding artifacts for Android, iOS, and macOS builds.
    artifacts:
      - build/**/outputs/apk/**/*.apk
      - build/ios/ipa/*.ipa
      - build/macos/Build/Products/Release/*.app
    publishing:
      scripts:
        - name: Post App Preview
          script: |
            dart pub global activate codemagic_app_preview
            app_preview post \
              --github_token $GITHUB_PAT \
              --codemagic_token $CODEMAGIC_TOKEN
```
