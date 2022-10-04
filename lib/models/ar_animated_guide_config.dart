import 'package:flutter/material.dart';

class ARAnimatedGuideConfig {
  final bool showAnimatedGuide;
  final ARAnimatedGuideGoal goal;
  final VoidCallback? onDone;

  ARAnimatedGuideConfig({
    required this.showAnimatedGuide,
    required this.goal,
    this.onDone,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showAnimatedGuide': showAnimatedGuide,
      'animatedGuideGoal': goal.toMap(),
    };
  }
}

enum ARAnimatedGuideGoal {
  /// Session requires normal tracking
  tracking,

  /// Session requires a horizontal plane
  horizontalPlane,

  /// Session requires a vertical plane
  verticalPlane,

  /// Session requires one plane of any type
  anyPlane,

  /// Session requires geo tracking
  geoTracking
}

extension ARAnimatedGuideGoalSerializer on ARAnimatedGuideGoal {
  int toMap() {
    switch (this) {
      case ARAnimatedGuideGoal.tracking:
        return 0;
      case ARAnimatedGuideGoal.horizontalPlane:
        return 1;
      case ARAnimatedGuideGoal.verticalPlane:
        return 2;
      case ARAnimatedGuideGoal.anyPlane:
        return 3;
      case ARAnimatedGuideGoal.geoTracking:
        return 4;
    }
  }
}
