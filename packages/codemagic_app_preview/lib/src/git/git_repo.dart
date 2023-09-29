import 'dart:io';

import 'package:codemagic_app_preview/src/git/git_host.dart';

class GitRepo {
  const GitRepo();

  /// Returns the owner of the repository.
  ///
  /// When you fork a repository, the owner of the fork is returned.
  ///
  /// The owner is parsed from the remote url.
  Future<String> getOwner() async {
    final result =
        await _runGitCommand(['config', '--get', 'remote.origin.url']);
    final parts = result.split('/');
    return parts[parts.length - 2];
  }

  /// Returns the name of the repository.
  ///
  /// The name of the repository is parsed from the remote url.
  Future<String> getRepoName() async {
    final result =
        await _runGitCommand(['config', '--get', 'remote.origin.url']);
    final parts = result.split('/');
    return parts.last.replaceAll('.git', '');
  }

  Future<String> _runGitCommand(List<String> args) async {
    final result = await Process.run('git', args);
    if (result.exitCode != 0) {
      throw Exception('Failed to run git command: ${result.stderr}');
    }
    return (result.stdout as String).trim();
  }

  /// Returns the [GitHost] of the Git repo.
  ///
  /// Throws an [UnsupportedGitHostException] when the Git repo is not
  /// supported as [GitHost].
  Future<GitHost> getHost() async {
    final result =
        await _runGitCommand(['config', '--get', 'remote.origin.url']);

    if (result.toLowerCase().contains('github.com')) {
      return GitHost.github;
    }

    if (result.toLowerCase().contains('gitlab.com')) {
      return GitHost.gitlab;
    }

    throw UnsupportedGitHostException();
  }
}

class UnsupportedGitHostException implements Exception {
  UnsupportedGitHostException();

  @override
  String toString() =>
      'Unsupported git host! Currently only ${GitHost.values.map((e) => e.toString()).join(', ')} are supported.}';
}
