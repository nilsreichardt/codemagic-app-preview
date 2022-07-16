import 'dart:io';

/// An accessor for the environment variables.
abstract class EnvironmentVariableAccessor {
  /// Returns the value of the environment variable [name].
  dynamic get(String name);
}

/// An implementation of [EnvironmentVariableAccessor] that reads the
/// environment variables from the current process.
class SystemEnvironmentVariableAccessor implements EnvironmentVariableAccessor {
  const SystemEnvironmentVariableAccessor();

  dynamic get(String name) => Platform.environment[name];
}

/// A [EnvironmentVariableAccessor] that reads environment variables from a
/// [Map].
///
/// This implementation should be used for testing instead of
/// [SystemEnvironmentVariableAccessor].
class MockEnvironmentVariableAccessor implements EnvironmentVariableAccessor {
  MockEnvironmentVariableAccessor();

  final Map<String, dynamic> environmentVariables = <String, dynamic>{};

  dynamic get(String name) => environmentVariables[name];
}
