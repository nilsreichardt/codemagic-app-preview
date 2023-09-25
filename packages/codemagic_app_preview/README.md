# Codemagic App Preview

Simplify your pull request reviews by automatically generating QR codes linked to your app builds for Android, iOS, and macOS. This tool allows code reviewers to easily download and test the app in a real-world environment, making the review process more effective and efficient.

| <img width="920" alt="Demo of the app preview pull request comment" src="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/0ea6d53c-fbd0-4742-a1fc-469a05b8d8af"> | <img alt="Demo of scanning the iOS app preview qr code" src="https://user-images.githubusercontent.com/24459435/179368786-c94ce9c2-2129-4c30-8677-b8ebf5633a2e.gif" width=165 /> |
| - | - |

```yaml
artifacts:
  - build/**/outputs/apk/**/*.apk
  - build/ios/ipa/*.ipa
  - build/macos/Build/Products/Release/*.app
publishing:
  scripts:
    - name: Post App Preview
      script: |
         app_preview post \
          --github_token $GITHUB_PAT \
          --codemagic_token $CODEMAGIC_TOKEN
```

## Supported platforms

Currently, you can generate a preview only for the following platforms.

| Android | iOS | macOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✔️     | ✔️   |   ✔️   |     |       |         |

## Supported Git providers

| GitHub | GitLab | Bitbucket |
| :----: | :----: | :-------: |
|   ✔️    |   ✔️    |           |

## Features

* Generates QR codes for Android, iOS, and macOS builds.
* Provides direct download links along with QR codes in pull request comments.
* Update existing comments with new builds to avoid cluttering the pull request.
* Allows custom messages in comments.
* Support for monorepos with multiple apps.
* Easy setup with minimal configuration.

## Options

| Option | Required or Optional? | Description | Example |
|-|-|-|-|
| `--github_token`| **Required**, if using GitHub | Your personal access token to access the GitHub API. | `abc123` |
| `--gitlab_token` | **Required, if using GitLab** | Your personal access token to access the GitLab API.	 | `xyz789` |
| `--codemagic_token` | **Required** | Token to access the Codemagic API. Is available at: Teams > Personal Account > Integrations > Codemagic API > Show. See [Codemagic documentation](https://docs.codemagic.io/rest-api/codemagic-rest-api/). | `pqr456` |
| `--message` | Optional | Custom message to include in the comment	 | "Only team members are able to install the iOS app." |
| `--expires_in` | Optional | Defines the duration for which the URLs to the builds are valid. The maximum duration depends on your account type, see: [Codemagic documentation](https://docs.codemagic.io/billing/pricing/#build-history-and-artifact-storage). The default value is 30 days.	| `2w 5d 23h 59m 59s` or `365d` |
| `--app_name` | Optional | The name of the app. This is helpful if you have multiple apps in the same repository. Using different names for different apps allows you to post multiple comments in the same pull request. | `sharezone` |

## Quick Start Guide

This is a quick guide to get you started with Codemagic App Preview. For more detailed information, see the [step-by-step guide](#step-by-step-guide).

Here is an example for the `codemagic.yaml`.


```yaml
workflows:
  app_preview:
    name: app_preview
    environment:
      flutter: default
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
        script: flutter build ipa
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

This is the detailed and step-by-step guide to get you started with Codemagic App Preview tool.

### 0. Preparation

You need to have a Codemagic account and a repository with a Flutter project. If you don't have a Codemagic account yet, you can create one for free at [codemagic.io](https://codemagic.io).

### 1. Add your Codemagic API token to your Codemagic environment variables

First, you need to get your Codemagic API token to access the Codemagic API. You can find it at: Teams > Personal Account > Integrations > Codemagic API > Show. See [Codemagic documentation](https://docs.codemagic.io/rest-api/codemagic-rest-api/).

When you have your Codemagic API token, you need to add it to your Codemagic environment variables of the repository you want to use the Codemagic App Preview tool with.

1. Go to your repository on Codemagic. 
2. Navigate to "Environment Variables"
2. Enter `CODEMAGIC_TOKEN` as variable name
3. Paste the token into the variable value field
4. Select or create new group, such as "codemagic"
5. Ensure "Secure" is checked

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

<a href="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/a6a4a707-6012-403c-b7c4-55a5b90fa0f9" target="_blank"><img src="https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/1aed0040-5039-416c-9b4a-f5d972290fda"></a>

Video: https://github.com/nilsreichardt/codemagic-app-preview/assets/24459435/a6a4a707-6012-403c-b7c4-55a5b90fa0f9

#### GitLab




## Limits

* To install iOS builds, your device must be registered with a valid Apple Developer account.
* This package only works when has been triggered by a pull request event.

## Disclaimer

This is an unofficial package for [Codemagic](https://codemagic.io). It's *not* maintained by Codemagic.
