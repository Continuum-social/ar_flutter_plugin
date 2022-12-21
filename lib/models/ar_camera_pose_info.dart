import 'package:ar_flutter_plugin/utils/json_converters.dart';
import 'package:vector_math/vector_math_64.dart';

import 'ar_node.dart';

class ARCameraPoseInfo {
  /// The position and orientation of the camera in world coordinate space.
  final Matrix4 transform;

  /// The camera’s orientation defined as Euler radians angles.
  final Vector3 rotation;

  final List<ARNode> visibleNodes;

  ARCameraPoseInfo(this.transform, this.rotation, this.visibleNodes);

  ARCameraPoseInfo copyWith({
    Matrix4? transform,
    Vector3? eulerAgles,
    double? heading,
    List<ARNode>? visibleNodes,
  }) {
    return ARCameraPoseInfo(transform ?? this.transform,
        eulerAgles ?? this.rotation, visibleNodes ?? this.visibleNodes);
  }

  static ARCameraPoseInfo fromJson(dynamic json) {
    List<ARNode> visibleNodes = [];
    try {
      visibleNodes = List<dynamic>.from(json["visibleNodes"])
          .map((e) => Map<String, dynamic>.from(e))
          .map((e) => ARNode.fromTransformMap(e))
          .toList();
    } catch (e) {
      print(e);
    }
    return ARCameraPoseInfo(
      MatrixConverter().fromJson(json["transform"] as List<dynamic>),
      Vector3Converter().fromJson(json["rotation"] as List<dynamic>),
      visibleNodes,
    );
  }
}
