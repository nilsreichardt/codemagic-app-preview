import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:test/test.dart';

void main() {
  group('GitRepo', () {
    late GitRepo gitRepo;

    setUp(() {
      gitRepo = GitRepo();
    });

    // This test might not pass when you fork this repository, because the
    // remote url will not be same. The test expects a remote url like
    // "https://github.com/nilsreichardt/codemagic-app-preview.git"
    test('.getOwner()', () async {
      final owner = await gitRepo.getOwner();
      expect(owner, 'nilsreichardt');
    });

    test('.getOwner()', () async {
      final owner = await gitRepo.getRepoName();
      expect(owner, 'codemagic-app-preview');
    });
  });
}
