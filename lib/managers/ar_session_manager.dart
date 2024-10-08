import 'package:ar_flutter_plugin/models/ar_animated_guide_config.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_pinch_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';

// Type definitions to enforce a consistent use of the API
typedef ARHitResultHandler = void Function(List<ARHitTestResult> hits);

/// Manages the session configuration, parameters and events of an [ARView]
class ARSessionManager {
  /// Platform channel used for communication from and to [ARSessionManager]
  late MethodChannel _channel;

  /// Debugging status flag. If true, all platform calls are printed. Defaults to false.
  final bool debug;

  /// Context of the [ARView] widget that this manager is attributed to
  final BuildContext buildContext;

  /// Determines the types of planes ARCore and ARKit should show
  final PlaneDetectionConfig planeDetectionConfig;

  /// Receives hit results from user taps with tracked planes or feature points
  late ARHitResultHandler onPlaneOrPointTap;

  VoidCallback? _onAnimatedGuideDoneCallback;

  final List<void Function(dynamic)> _errorListeners = [];

  ARSessionManager(int id, this.buildContext, this.planeDetectionConfig,
      {this.debug = false}) {
    _channel = MethodChannel('arsession_$id');
    _channel.setMethodCallHandler(_platformCallHandler);
    if (debug) {
      print("ARSessionManager initialized");
    }
  }

  Future<void> _platformCallHandler(MethodCall call) {
    if (debug) {
      print('_platformCallHandler call ${call.method} ${call.arguments}');
    }
    try {
      switch (call.method) {
        case 'onError':
          if (_errorListeners.isEmpty) {
            onError(call.arguments[0]);
          }
          for (var callback in _errorListeners) {
            callback(call.arguments);
          }
          print(call.arguments);
          break;
        case 'onPlaneOrPointTap':
          final rawHitTestResults = call.arguments as List<dynamic>;
          final serializedHitTestResults = rawHitTestResults
              .map((hitTestResult) => Map<String, dynamic>.from(hitTestResult))
              .toList();
          final hitTestResults = serializedHitTestResults.map((e) {
            return ARHitTestResult.fromJson(e);
          }).toList();
          onPlaneOrPointTap(hitTestResults);
          break;
        case 'onAnimatedGuideDone':
          _onAnimatedGuideDoneCallback?.call();
          _onAnimatedGuideDoneCallback = null;
          break;
        case 'dispose':
          _channel.invokeMethod<void>("dispose");
          _errorListeners.clear();
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

  /// Function to initialize the platform-specific AR view. Can be used to initially set or update session settings.
  /// [customPlaneTexturePath] refers to flutter assets from the app that is calling this function, NOT to assets within this plugin. Make sure
  /// the assets are correctly registered in the pubspec.yaml of the parent app (e.g. the ./example app in this plugin's repo)
  onInitialize({
    ARAnimatedGuideConfig? animatedGuideConfig,
    bool showFeaturePoints = false,
    bool showPlanes = true,
    String? customPlaneTexturePath,
    bool showWorldOrigin = false,
    bool handleTaps = true,
    bool handlePans = false, // nodes are not draggable by default
    bool handleRotation = false, // nodes can not be rotated by default
    bool handlePinch = false, // nodes can not be pinched by default
    ARPinchConfig? pinchConfig,
  }) {
    _onAnimatedGuideDoneCallback = animatedGuideConfig?.onDone;
    _channel.invokeMethod<void>('init', {
      'animatedGuideConfig': animatedGuideConfig?.toMap(),
      'showFeaturePoints': showFeaturePoints,
      'planeDetectionConfig': planeDetectionConfig.index,
      'showPlanes': showPlanes,
      'customPlaneTexturePath': customPlaneTexturePath,
      'showWorldOrigin': showWorldOrigin,
      'handleTaps': handleTaps,
      'handlePans': handlePans,
      'handleRotation': handleRotation,
      'handlePinch': handlePinch,
      'pinchConfig': pinchConfig?.toMap()
    });
  }

  void addErrorListener(void Function(dynamic) callback) {
    _errorListeners.add(callback);
  }

  void removeErrorListener(void Function(dynamic) callback) {
    _errorListeners.remove(callback);
  }

  /// Displays the [errorMessage] in a snackbar of the parent widget
  void onError(String errorMessage) {
    ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
        content: Text(errorMessage),
        action: SnackBarAction(
            label: 'HIDE',
            onPressed:
                ScaffoldMessenger.of(buildContext).hideCurrentSnackBar)));
  }

  /// Dispose the AR view on the platforms to pause the scenes and disconnect the platform handlers.
  /// You should call this before removing the AR view to prevent out of memory erros
  dispose() async {
    try {
      await _channel.invokeMethod<void>("dispose");
    } catch (e) {
      print(e);
    }
  }

  /// Returns a future ImageProvider that contains a screenshot of the current AR Scene
  Future<ImageProvider> snapshot() async {
    final result = await _channel.invokeMethod<Uint8List>('snapshot');
    return MemoryImage(result!);
  }
}
