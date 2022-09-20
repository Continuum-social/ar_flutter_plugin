import 'package:vector_math/vector_math_64.dart';

class ARCameraPoseInfo {
  /// The position and orientation of the camera in world coordinate space.
  final Matrix4 transform;

  /// The heading, in degrees, of the device around its Y
  /// axis, or where the top of the device is pointing.
  final double heading;

  ARCameraPoseInfo(this.transform, this.heading);

  ARCameraPoseInfo copyWith({
    Matrix4? transform,
    double? heading,
  }) {
    return ARCameraPoseInfo(
      transform ?? this.transform,
      heading ?? this.heading,
    );
  }
}
