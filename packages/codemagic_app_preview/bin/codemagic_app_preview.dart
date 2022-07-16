import 'package:args/command_runner.dart';
import 'package:codemagic_app_preview/src/commands/post_command.dart';

Future<void> main(List<String> args) async {
  await CommandRunner("app-preview",
      "A command line tool to post a comment to the GitHub PR with links to the app previews")
    ..addCommand(PostCommand())
    ..run(args);
}
