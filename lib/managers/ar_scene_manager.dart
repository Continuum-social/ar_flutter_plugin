import 'dart:math';

import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/utils/json_converters.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/services.dart';

class ARSceneManager {
  /// Platform channel used for communication from and to [ARSceneManager]
  late MethodChannel _channel;

  /// The event channel used to receive camera pose [Matrix4] updates from the native
  /// platform.
  late EventChannel _cameraPoseChannel;
  Stream<Matrix4>? _cameraPoseStream;

  /// Debugging status flag. If true, all platform calls are printed. Defaults to false.
  final bool debug;

  ARSceneManager(int id, {this.debug = false}) {
    _channel = MethodChannel('arscene_$id');
    _channel.setMethodCallHandler(_platformCallHandler);

    _cameraPoseChannel = EventChannel('camera_pose_updates_$id');

    if (debug) {
      print("ARSceneManager initialized");
    }
  }

  Future<void> _platformCallHandler(MethodCall call) {
    if (debug) {
      print('_platformCallHandler call ${call.method} ${call.arguments}');
    }
    try {
      switch (call.method) {
        case 'onError':
          print(call.arguments);
          break;
        default:
          if (debug) {
            print('Unimplemented method ${call.method} ');
          }
      }
    } catch (e) {
      print('Error caught: ' + e.toString());
    }
    return Future.value();
  }

  /// Dispose all [ARSceneManager] streams.
  /// You should call this before removing the AR view to prevent out of memory erros
  void dispose() async {
    try {
      _cameraPoseStream = null;
      await _channel.invokeMethod<void>("dispose");
    } catch (e) {
      print(e);
    }
  }

  Stream<Matrix4> getCameraPoseStream() {
    if (_cameraPoseStream != null) {
      return _cameraPoseStream!;
    }

    var originalStream = _cameraPoseChannel.receiveBroadcastStream();

    var cameraPoseStream = originalStream.asBroadcastStream(
      onCancel: (subscription) {
        subscription.cancel();
        _cameraPoseStream = null;
      },
    );

    _cameraPoseStream = cameraPoseStream
        .map<Matrix4>((dynamic element) =>
            MatrixConverter().fromJson(element as List<dynamic>))
        .handleError(
      (error) {
        _cameraPoseStream = null;
        if (error is PlatformException) {
          print('Error caught: ' + error.toString());
        }
        throw error;
      },
    );
    return _cameraPoseStream!;
  }

  /// Returns the camera pose in Matrix4 format with respect to the world coordinate system of the [ARView]
  Future<Matrix4?> getCameraPose() async {
    try {
      final serializedCameraPose =
          await _channel.invokeMethod<List<dynamic>>('getCameraPose', {});
      return MatrixConverter().fromJson(serializedCameraPose!);
    } catch (e) {
      print('Error caught: ' + e.toString());
      return null;
    }
  }

  /// Returns the given anchor pose in Matrix4 format with respect to the world coordinate system of the [ARView]
  Future<Matrix4?> getPose(ARAnchor anchor) async {
    try {
      if (anchor.name.isEmpty) {
        throw Exception("Anchor can not be resolved. Anchor name is empty.");
      }
      final serializedCameraPose =
          await _channel.invokeMethod<List<dynamic>>('getAnchorPose', {
        "anchorId": anchor.name,
      });
      return MatrixConverter().fromJson(serializedCameraPose!);
    } catch (e) {
      print('Error caught: ' + e.toString());
      return null;
    }
  }

  /// Returns the distance in meters between @anchor1 and @anchor2.
  Future<double?> getDistanceBetweenAnchors(
      ARAnchor anchor1, ARAnchor anchor2) async {
    var anchor1Pose = await getPose(anchor1);
    var anchor2Pose = await getPose(anchor2);
    var anchor1Translation = anchor1Pose?.getTranslation();
    var anchor2Translation = anchor2Pose?.getTranslation();
    if (anchor1Translation != null && anchor2Translation != null) {
      return getDistanceBetweenVectors(anchor1Translation, anchor2Translation);
    } else {
      return null;
    }
  }

  /// Returns the distance in meters between @anchor and device's camera.
  Future<double?> getDistanceFromAnchor(ARAnchor anchor) async {
    Matrix4? cameraPose = await getCameraPose();
    Matrix4? anchorPose = await getPose(anchor);
    Vector3? cameraTranslation = cameraPose?.getTranslation();
    Vector3? anchorTranslation = anchorPose?.getTranslation();
    if (anchorTranslation != null && cameraTranslation != null) {
      return getDistanceBetweenVectors(anchorTranslation, cameraTranslation);
    } else {
      return null;
    }
  }

  /// Returns the distance in meters between @vector1 and @vector2.
  double getDistanceBetweenVectors(Vector3 vector1, Vector3 vector2) {
    num dx = vector1.x - vector2.x;
    num dy = vector1.y - vector2.y;
    num dz = vector1.z - vector2.z;
    double distance = sqrt(dx * dx + dy * dy + dz * dz);
    return distance;
  }
}
