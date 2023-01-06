import 'package:ar_flutter_plugin/utils/json_converters.dart';
import 'package:vector_math/vector_math_64.dart';

import 'ar_node.dart';

class ARCameraPoseInfo {
  /// The position and orientation of the camera in world coordinate space.
  final Matrix4 transform;

  /// The camera’s orientation defined as Euler radians angles.
  final Vector3 rotation;

  ARCameraPoseInfo(this.transform, this.rotation);

  ARCameraPoseInfo copyWith({
    Matrix4? transform,
    Vector3? eulerAgles,
    double? heading,
  }) {
    return ARCameraPoseInfo(
      transform ?? this.transform,
      eulerAgles ?? this.rotation,
    );
  }

  static ARCameraPoseInfo fromJson(dynamic json) {
    return ARCameraPoseInfo(
      MatrixConverter().fromJson(json["transform"] as List<dynamic>),
      Vector3Converter().fromJson(json["rotation"] as List<dynamic>),
    );
  }
}
