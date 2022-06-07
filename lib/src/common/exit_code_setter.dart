import 'dart:io';

class ExitCodeSetter {
  /// Set the global exit code for the Dart VM.
  ///
  /// The exit code is global for the Dart VM and the last assignment to
  /// exitCode from any isolate determines the exit code of the Dart VM on
  /// normal termination.
  ///
  /// See [exit] for more information on how to chose a value for the exit code.
  static void setExitCode(int code) {
    exitCode = code;
  }
}

// class MockExitCodeSetter implements ExitCodeSetter {
//   int? exitCode;

//   @override
//   void setExitCode(int code) {
//     exitCode = 
//   }
// }
