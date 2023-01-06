//
//  ARVisibleNodesStreamHandler.swift
//  ar_flutter_plugin
//
//  Created by Nick Kurochkin on 05.01.23.
//


import Foundation
import Combine
import ARKit
import Flutter

class ARVisibleNodesStreamHandler: NSObject,  FlutterStreamHandler {
    var sink: FlutterEventSink?
    
    private var lastUpdateTime: Date?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    func onFrameUpdate(sceneView: ARSCNView) {
        let now = Date()
        
        guard lastUpdateTime == nil || now.timeIntervalSince(lastUpdateTime!) > 0.25
        else { return }
        
        lastUpdateTime = now
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            let nodes = self.calculateVisibleNodes(sceneView: sceneView)
            guard let sink = self.sink else { return }
            sink(serializeVisibleNodes(visibleNodes: nodes))
        }        
    }
    
    private func calculateVisibleNodes(sceneView: ARSCNView) -> [SCNNode] {
        guard let pointOfView = sceneView.pointOfView else {
            return []
        }
        var visibleNodes: [SCNNode] = []
        for node in sceneView.scene.rootNode.childNodes {
            if sceneView.isNode(node, insideFrustumOf: pointOfView) {
                visibleNodes.append(node)
            }
        }
        return visibleNodes
    }
}
