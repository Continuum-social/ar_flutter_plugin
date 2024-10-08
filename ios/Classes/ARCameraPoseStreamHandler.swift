//
//  ARCameraPoseStreamHandler.swift
//  ar_flutter_plugin
//
//  Created by Nick Kurochkin on 16.09.2022.
//

import Foundation
import Combine
import ARKit
import Flutter

class ARCameraPoseStreamHandler: NSObject,  FlutterStreamHandler {
    var sink: FlutterEventSink?
    
    var lastFrame: ARFrame?
    var lastVisibleNodes: [SCNNode]?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    func updateCameraPose(frame: ARFrame) {
        guard let sink = sink else {
            return
        }
        sink(serializeARCamera(frame.camera))
    }
}
