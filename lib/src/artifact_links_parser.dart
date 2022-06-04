import 'dart:convert';

import 'build.dart';
import 'environment_variable_accessor.dart';

class ArtifactLinksParser {
  ArtifactLinksParser(this._environmentVariableAccessor);

  final EnvironmentVariableAccessor _environmentVariableAccessor;

  List<Build> getBuilds() {
    final json = _environmentVariableAccessor.get('CM_ARTIFACT_LINKS');
    if (json == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((dynamic json) => Build.fromJson(json)).toList();
  }
}
