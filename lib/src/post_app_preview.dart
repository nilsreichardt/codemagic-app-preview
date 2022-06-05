import 'dart:io';

// ## Open questions
// - What if there are multiple links for the same platform?
//   Idea: post something like: iOS (1) and iOS (2)
// - Monorepo support by allow to pass custom text to the comment

void main() {
  print("Hello world!");

  // What do I want?
  // - A list of links to the build artifacts

  // 1. Generate text for comment
  //    - Extract links from CM_ARTIFACT_LINKS
  // 1. Get comments on PR
  // 2. Check if there is already an app preview comment
  //    - Get the comments for a pull request
  //    - Find the app preview comment by looking for a workflow id (can be set
  //      by the user for mono-repos support)
  //  3. Post comment or update existing comment
}
