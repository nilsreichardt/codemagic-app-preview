import 'dart:io';

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
}
