//
//  ARPinchConfig.swift
//  ar_flutter_plugin
//
//  Created by Nick Kurochkin on 07.10.2022.
//

import Foundation
import ARKit

class ARPinchConfig {
    let minZoom: SCNVector3?
    let maxZoom: SCNVector3?
    
    init(minZoom: SCNVector3?, maxZoom: SCNVector3?) {
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }
}
