import 'package:ar_flutter_plugin/utils/json_converters.dart';
import 'package:vector_math/vector_math_64.dart';

class ARPinchConfig {
  final Vector3? minZoom;
  final Vector3? maxZoom;

  ARPinchConfig({this.minZoom, this.maxZoom});

  Map<String, dynamic> toMap() {
    final converter = Vector3Converter();
    final map = <String, dynamic>{};
    if (minZoom != null) {
      map["minZoom"] = converter.toJson(minZoom!);
    }
    if (maxZoom != null) {
      map["maxZoom"] = converter.toJson(maxZoom!);
    }
    return map;
  }
}
