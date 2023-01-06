import 'ar_node.dart';

class ARVisibleNodesInfo {
  final List<ARNode> visibleNodes;

  ARVisibleNodesInfo(this.visibleNodes);

  static ARVisibleNodesInfo fromJson(dynamic json) {
    List<ARNode> visibleNodes = [];
    try {
      visibleNodes = List<dynamic>.from(json["visibleNodes"])
          .map((e) => Map<String, dynamic>.from(e))
          .map((e) => ARNode.fromTransformMap(e))
          .toList();
    } catch (e) {
      print(e);
    }
    return ARVisibleNodesInfo(visibleNodes);
  }
}
