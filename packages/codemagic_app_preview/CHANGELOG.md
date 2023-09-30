## 0.2.1

- **FEAT:** Removes the need for `CM_PULL_REQUEST` environment variable to match the `README.md` on triggering builds just by labels.

## 0.2.0

- **DOCS:** Adds very detailed docs on how to use this CLI.
- **FEAT:** Adds spacing between each platform column in the PR comment to avoid accidentally scanning the wrong qr code.
- **FEAT:** Adds support for mono-repo projects.
- **FEAT:** Adds expires at date to the PR comment.
- **FEAT:** Replaces third-party qr code generator with a self-hosted one.
- **FEAT:** Replaces qr codes for macOS with a download icon.
- **FEAT:** Adds check if the CLI is executed in a build for a pull request.
- **FEAT:** Adds check if there are artifacts available for the current build.
- **CHORE:** Adds pub.dev topics.

## 0.1.0

- **BREAKING FIX:** Makes build links accessible by using Codemagic Build API.

## 0.0.4

- **FEAT**: Add option parameter (`--message`).
- **FEAT**: Adds platform support for macOS.
- **FEAT**: Decreases Dart SDK minimum from 2.17 to 2.14.
- **DOCS**: Improves width for gif demo in `README.md`.

## 0.0.3

- **FEAT:** Add `--message` parameter to specify a custom message in the PR comment.
- **DOCS**: Add steps on how to add Dart SDK to PATH for Codemagic in `README.md`.

## 0.0.2

- **CHORE**: Improves pub.dev score.

## 0.0.1

- **FEAT**: Initials release of an early preview version.
