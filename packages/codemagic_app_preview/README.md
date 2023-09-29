Simplify your pull request reviews by automatically generating QR codes linked to your app builds for Android, iOS, and macOS with Codemagic App Preview CLI. This CLI allows code reviewers to easily download and test the app in a real-world environment, making the review process more effective and efficient.

In other words: It's like the Firebase Hosting GitHub Action [`action-hosting-deploy`](https://github.com/FirebaseExtended/action-hosting-deploy) to create web app preview URLs for pull requests but for Android, iOS, and macOS builds.

| <img width="920" alt="Demo of the app preview pull request comment" src="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/0ea6d53c-fbd0-4742-a1fc-469a05b8d8af"> | <img alt="Demo of scanning the iOS app preview qr code" src="https://user-images.githubusercontent.com/24459435/179368786-c94ce9c2-2129-4c30-8677-b8ebf5633a2e.gif" width=165 /> |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

After building your app, you only need to add the `app_preview post` command to the publishing scripts of your `codemagic.yaml` file.

```yaml
workflows:
  app_preview:
    name: app_preview
    environment: ...
    triggering: ...
    scripts: ...
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

## Supported platforms

Currently, you can generate a preview only for the following platforms.

| Android | iOS | macOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✔️    | ✔️  |  ✔️   |     |       |         |

If you are interested in supporting Web, Linux, or Windows, please [upvote the respective issue](https://github.com/nilsreichardt/codemagic-app-preview/issues?q=is%3Aopen+is%3Aissue+label%3Aplatform).

## Supported Git hosts

|  GitHub | GitLab | Self-Hosted GitLab | Bitbucket |
| :-----: | :----: | :----------------: | :-------: |
|   ✔️    |   ✔️   |                    |           |

If you are interested in supporting self-hosted GitLab, Bitbucket or a different Git host, please [upvote the respective issue](https://github.com/nilsreichardt/codemagic-app-preview/issues?q=is%3Aopen+is%3Aissue+label%3Agit-hosts).

## Features

- Generates QR codes for Android, iOS, and macOS builds.
- Provides direct download links along with QR codes in pull request comments.
- Update existing comments with new builds to avoid cluttering the pull request.
- Allows custom messages in comments.
- Support for monorepos with multiple apps
- Easy setup with minimal configuration.
- No need for TestFlight, Firebase App Distribution or other third-party services to distribute your app.

## Options

|  Option             | Required or Optional?          | Description                                                                                                                                                                                                                                                       |  Example                                                                                                                                                    |
| ------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  `--github_token`   | **Required**, if using GitHub  |  Your personal access token to access the GitHub API.                                                                                                                                                                                                             |  `abc123`                                                                                                                                                   |
|  `--gitlab_token`   |  **Required**, if using GitLab |  Your personal access token to access the GitLab API.                                                                                                                                                                                                             |  `xyz789`                                                                                                                                                   |
| `--codemagic_token` | **Required**                   |  Token to access the Codemagic API. Is available at: Teams > Personal Account > Integrations > Codemagic API > Show. See [Codemagic documentation](https://docs.codemagic.io/rest-api/codemagic-rest-api/).                                                       |  `pqr456`                                                                                                                                                   |
|  `--message`        | Optional                       |  Custom message to include in the comment.                                                                                                                                                                                                                        |  "Only team members are able to install the iOS app.", see [this example](https://github.com/SharezoneApp/sharezone-app/pull/1095#issuecomment-1733715519). |
|  `--expires_in`     | Optional                       |  Defines the duration for which the URLs to the builds are valid. The maximum duration depends on your account type, see: [Codemagic documentation](https://docs.codemagic.io/billing/pricing/#build-history-and-artifact-storage). The default value is 30 days. |  `2w 5d 23h 59m 59s` or `365d`                                                                                                                              |
| `--app_name`        | Optional                       |  The name of the app. This is helpful if you have multiple apps in the same repository. Using different names for different apps allows you to post multiple comments in the same pull request.                                                                   |  `sharezone`                                                                                                                                                |

## Quick Start Guide

This is a quick guide to get you started with Codemagic App Preview. For more detailed information, see the [step-by-step guide](#step-by-step-guide).

Here is an example for the `codemagic.yaml`.

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

## Step-by-step guide

This is the detailed and step-by-step guide to get you started with Codemagic App Preview tool. Currently, the docs are only using the `codemagic.yaml` file.

### 0. Preparation

You need to have a Codemagic account and a repository with a Flutter project. If you don't have a Codemagic account yet, you can create one for free at [codemagic.io](https://codemagic.io). For individuals, there is also a [free plan](https://codemagic.io/pricing/). Make sure that your Git repository is [connected to Codemagic](https://docs.codemagic.io/getting-started/adding-apps/).

### 1. Add your Codemagic API token to your Codemagic environment variables

First, you need to get your Codemagic API token to access the Codemagic API. You can find it at: Teams > Personal Account > Integrations > Codemagic API > Show. See [Codemagic documentation](https://docs.codemagic.io/rest-api/codemagic-rest-api/).

When you have your Codemagic API token, you need to add it to your Codemagic environment variables of the repository you want to use the Codemagic App Preview tool with.

1. Go to your repository on Codemagic.
2. Navigate to "Environment Variables"
3. Enter `CODEMAGIC_TOKEN` as variable name
4. Paste the token into the variable value field
5. Select or create new group, such as "codemagic"
6. Ensure "Secure" is checked

### 2. Add your GitHub/GitLab personal access token to your Codemagic environment variables

#### Why is a GitHub/GitLab personal access token required?

The Codemagic App Preview tool uses the GitHub/GitLab API to post comments on pull requests. To do so, it needs a personal access token to authenticate with the GitHub/GitLab API. The token is not stored anywhere and is only used to post comments on pull requests.

#### GitHub

This documentation uses the new fine-grained tokens to follow security best practices. If you are using the old tokens (classic tokens), you need to enable the `repo` scope.

1. Go to [Developer Settings > Personal access tokens > Fine-grained tokens](https://github.com/settings/tokens?type=beta)
2. Click on "Generate new token"
3. Give the token a name, such as "Codemagic App Preview"
4. Select the repository where you want to use the Codemagic App Preview tool
5. Open the repository permissions
6. Add read and write permission for pull requests (and read only permission for metadata)
7. Click "Generate token"
8. If you are using the token of a repository in an organization, make sure that fine-grained personal access tokens are allowed\
   a) Go to the organization settings -> Personal access tokens -> Settings. At "Fine-grained personal access tokens" the option "Allow access via fine-grained personal access tokens" needs be selected\
   b) If personal access token require approval by your organization administrator, make sure that your token is approved.

<a href="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/a6a4a707-6012-403c-b7c4-55a5b90fa0f9" target="_blank"><img src="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/1aed0040-5039-416c-9b4a-f5d972290fda"/></a>

#### GitLab

1. Open Settings
2. Select "CI/CD"
3. Expand the "Variables" section
4. Click on "Add variable"

<a href="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/c7186275-b71d-49b2-ada0-01f354bd42f0" target="_blank"><img src="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/fb55183d-f450-417a-b061-e35db01c4154"/></a>

### 3. Set up the `codemagic.yaml`

Now, we need to set up the `codemagic.yaml` file to build the app and post the app preview comment.

#### 3.1. Define a basic workflow with the environment variables

First, we need to define a basic workflow with the environment variables. The environment variables are required to access the GitHub/GitLab API and the Codemagic API. Additionally, you need to add `ios_signing` if you want to build iOS apps. Checkout the Codemagic docs, if you need more information about [iOS code signing](https://docs.codemagic.io/yaml-code-signing/signing-ios/).

```yaml
workflows:
  app_preview:
    name: app_preview
    environment:
      # Docs for setting up signing: https://docs.codemagic.io/yaml-code-signing/signing-ios/
      ios_signing:
        # Use the type "ad_hoc" to sign iOS apps in order to install them on your device.
        distribution_type: ad_hoc
        bundle_identifier: YOUR_BUNDLE_IDENTIFIER
      groups:
        # Adding environment group "github" which includes the GITHUB_PAT
        # variable.
        - "github"
        # Adding environment group "codemagic" which includes the CODEMAGIC_TOKEN
        # variable.
        - "codemagic"
```

Now, we need to add the `triggering` section to define when the workflow should be triggered. If you want to trigger the workflow on every pull request, you can use the following configuration.

```yaml
workflows:
  app_preview:
    name: app_preview
    environment: ...
    triggering:
      events:
        - pull_request
```

If you don't want to trigger the workflow on every pull request, you use the option to only trigger the workflow on pull requests with a specific label. For example, you can use the label `build-app-preview` to trigger the workflow only on pull requests with the label `build-app-preview`.

To do so, please check out the "Only trigger the workflow on pull requests with a specific label" section in at the bottom of this README.

#### 3.2. Build the app

Next, we need to build the app. You can use the following scripts to build the app for Android, iOS, and macOS. You can leave out the scripts for the platforms you don't need.

```yaml
workflows:
  app_preview:
    name: app_preview
    environment: ...
    triggering: ...
    scripts:
      - name: Build APK (Android)
        script: flutter build apk
      - name: Build macOS
        script: flutter build macos
      - name: Build IPA (iOS)
        # Don't forget the "export-options" argument.
        script: |
          flutter build ipa \
            --export-options-plist=/Users/builder/export_options.plist
```

#### 3.3. Add the artifacts

In order to post the app preview comment, we need to make the build artifacts available. You can use the following configuration to add the build artifacts for Android, iOS, and macOS.

```yaml
workflows:
  app_preview:
    name: app_preview
    environment: ...
    triggering: ...
    scripts: ...
    artifacts:
      - build/**/outputs/apk/**/*.apk
      - build/ios/ipa/*.ipa
      - build/macos/Build/Products/Release/*.app
```

If you don't need all platforms, you can leave out the artifacts for the platforms you don't need.

### 4. Add the publishing script

As the last step, we need to add the publishing script to post the app preview comment.

```yaml
workflows:
  app_preview:
    name: app_preview
    environment: ...
    triggering: ...
    scripts: ...
    artifacts: ...
    publishing:
      scripts:
        - name: Post App Preview
          script: |
            dart pub global activate codemagic_app_preview
            app_preview post \
              --github_token $GITHUB_PAT \
              --codemagic_token $CODEMAGIC_TOKEN
```

In this script, we first install the Codemagic App Preview tool. Then, we use the `app_preview post` command to post the app preview comment. The `app_preview post` command requires a few options to work. You can find more information about the options in the [options section](#options).

```yaml
artifacts:
  - build/**/outputs/apk/**/*.apk # Build output for Android
  - build/ios/ipa/*.ipa # Build output for iOS
  - build/macos/Build/Products/Release/*.app # Build output for macOS
publishing:
  scripts:
    - name: Post App Preview
      script: |
        # You should use for app the following line instead of "dart pub
        # global activate  -s path...":
        # dart pub global activate codemagic_app_preview

        # Using local path to test changes and ensure everything is working
        # when someone opens PR.
        dart pub global activate -s path ../codemagic_app_preview
        app_preview post \
          --github_token $GITHUB_PAT \
          --codemagic_token $CODEMAGIC_TOKEN \
          --message "This is a custom message."
```

## Only trigger the workflow on pull requests with a specific label

The easiest way to use this CLI is to trigger the workflow on every pull request. Especially, if you have the [Codemagic unlimited plan](https://codemagic.io/pricing/), this is the recommended way to use this CLI. However, if you don't have the unlimited plan, you might want to only trigger the workflow on pull requests with a specific label to avoid unnecessary builds.

In order to do so, you need to trigger the workflow with the [Codemagic Build API](https://docs.codemagic.io/rest-api/builds/) via [GitHub Actions](https://github.com/features/actions):

```yaml
name: App Preview

on:
  pull_request:
    types:
      # Trigger the workflow when a label is added or removed.
      - labeled
      # Trigger the workflow when a pull request is opened or synchronized.
      - synchronize

jobs:
  label_app_preview:
    # Only run this job if the PR is labeled with "build-app-preview".
    #
    # Keep in mind that a new build will be triggered when the PR is labeled
    # with any lable as long as the label "build-app-preview" is included in the
    # list of labels. For example, if the PR is labeled with "build-app-preview"
    # and "bug", the job will be triggered when the label "bug" is removed.
    if: contains(github.event.pull_request.labels.*.name, 'build-app-preview')
    runs-on: ubuntu-22.04
    env:
      CODEMAGIC_TOKEN: ${{ secrets.CODEMAGIC_TOKEN }}
      CODEMAGIC_APP_ID: ${{ secrets.CODEMAGIC_APP_ID }}
      # From "codemagic.yaml"
      CODEMAGIC_WORKFLOW_ID: "app_preview"
    steps:
      - name: Start Codemagic Build
        run: |
          # Get the pull request number from the GITHUB_REF.
          PULL_REQUEST_NUMBER=$(echo $GITHUB_REF | cut -d / -f 3)

          curl --request POST 'https://api.codemagic.io/builds' \
            -f \
            --header 'x-auth-token: '"$CODEMAGIC_TOKEN" \
            --header 'Content-Type: application/json' \
            --data-raw "{
                \"appId\": \"$CODEMAGIC_APP_ID\",
                \"branch\": \"$GITHUB_HEAD_REF\",
                \"workflowId\": \"$CODEMAGIC_WORKFLOW_ID\",
                \"environment\": {
                    \"variables\": {
                        \"CM_PULL_REQUEST_NUMBER\": $PULL_REQUEST_NUMBER
                    }
                }
            }"
```

Under [this link](https://github.com/SharezoneApp/sharezone-app/blob/main/.github/workflows/label_app_preview.yaml), you can find an example repository with the GitHub Action. If you need an example pull request, checkout [this pull request](https://github.com/SharezoneApp/sharezone-app/pull/1095) where the GitHub Action and the label `build-app-preview` has been used.

If you are not using GitHub, you can create a similar workflow for your Git host. Feel free, to open a pull request to add an example for your Git host.

## Monorepos

In case you are using a monorepo, you might have the situation that multiple apps are built in the same pull request. In this case, you can use the `--app_name` option to post multiple comments in the same pull request.

```yaml
workflows:
  app_1_app_preview:
    name: app_1_app_preview
    scripts: ...
    artifacts: ...
    publishing:
      scripts:
        - name: Post App Preview
          script: |
            dart pub global activate codemagic_app_preview
            app_preview post \
              --github_token $GITHUB_PAT \
              --codemagic_token $CODEMAGIC_TOKEN \
              --app_name "App 1"

  app_2_app_preview:
    name: app_2_app_preview
    scripts: ...
    artifacts: ...
    publishing:
      scripts:
        - name: Post App Preview
          script: |
            dart pub global activate codemagic_app_preview
            app_preview post \
              --github_token $GITHUB_PAT \
              --codemagic_token $CODEMAGIC_TOKEN \
              --app_name "App 2"
```

## FAQ

### How is it possible to install the iOS app without TestFlight?

The iOS app is signed with an ad hoc provisioning profile. This allows you to install the app on your device without TestFlight. However, you need to register your device with a valid Apple Developer account. When you are using XCode to run the app on your device, XCode will automatically register your device. Your registered devices are listed in the [Apple Developer portal](https://developer.apple.com/account/resources/devices/list) under "Certificates, Identifiers & Profiles" > "Devices".

If your repository is open source, it might be helpful, to add a note with the `--message` option to inform users that only team members are able to install the iOS app.

## Limits

- To install iOS builds, your device must be registered with a valid Apple Developer account.
- This package only works when has been triggered by a pull request event.

## Disclaimer

This is an unofficial package for [Codemagic](https://codemagic.io). It's _not_ maintained by Codemagic.

If you have any feedback about the CLI or the documentation, feel free to open an [issue](https://github.com/nilsreichardt/codemagic-app-preview/issues) or a [pull request](https://github.com/nilsreichardt/codemagic-app-preview/pulls).
