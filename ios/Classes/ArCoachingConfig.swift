//
//  ArCoachingConfig.swift
//  ar_flutter_plugin
//
//  Created by Nick Kurochkin on 23.09.2022.
//

import Foundation
import ARKit

class ArCoachingConfig {
    var showAnimatedGuide: Bool
    var goal: ARCoachingOverlayView.Goal
    
    init(showAnimatedGuide: Bool, goal: ARCoachingOverlayView.Goal) {
        self.showAnimatedGuide = showAnimatedGuide
        self.goal = goal
    }
}
