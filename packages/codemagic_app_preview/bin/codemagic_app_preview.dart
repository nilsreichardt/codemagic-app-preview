import 'package:args/command_runner.dart';
import 'package:clock/clock.dart';
import 'package:codemagic_app_preview/src/commands/post_command.dart';
import 'package:http/http.dart';

Future<void> main(List<String> args) async {
  final httpClient = Client();
  final clock = Clock();
  CommandRunner("app-preview",
      "A command line tool to post a comment to the pull request with links to the app previews")
    ..addCommand(PostCommand(
      httpClient: httpClient,
      clock: clock,
    ))
    ..run(args);
}
