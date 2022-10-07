// The code in this file is adapted from Oleksandr Leuschenko' ARKit Flutter Plugin (https://github.com/olexale/arkit_flutter_plugin)

import ARKit

func deserializeVector3(_ coords: Array<Double>) -> SCNVector3 {
    let point = SCNVector3(coords[0], coords[1], coords[2])
    return point
}

func deserializeVector4(_ coords: Array<Double>) -> SCNVector4 {
    let point = SCNVector4(coords[0], coords[1], coords[2], coords[3])
    return point
}

func deserializeMatrix4(_ c: Array<NSNumber>) -> SCNMatrix4 {
    let coords = c.map({ Float(truncating: $0 )})
    let matrix = SCNMatrix4(m11: coords[0], m12: coords[1],m13: coords[2], m14: coords[3], m21: coords[4], m22: coords[5], m23: coords[6], m24: coords[7], m31: coords[8], m32: coords[9], m33: coords[10], m34: coords[11], m41: coords[12], m42: coords[13], m43: coords[14], m44: coords[15])
    return matrix
}

func deserializeCoachingConfig(_ arguments: Dictionary<String,Any>) -> ArCoachingConfig? {
    guard
        let config = arguments["animatedGuideConfig"] as? Dictionary<String,Any>,
        let configShowAnimatedGuide = config["showAnimatedGuide"] as? Bool,
        let goalData = config["animatedGuideGoal"] as? Int else {
        return nil
    }
    
    let goal: ARCoachingOverlayView.Goal
    switch(goalData){
        case 0:
            goal = .tracking
            break
        case 1:
            goal = .horizontalPlane
            break
        case 2:
            goal = .verticalPlane
            break
        case 3:
            goal = .anyPlane
            break
        case 4:
            goal = .geoTracking
            break
        default:
            goal = .anyPlane
            break
    }
    return ArCoachingConfig(showAnimatedGuide: configShowAnimatedGuide, goal: goal)
}

func deserealizePinchConfig(_ arguments: Dictionary<String,Any>) -> ARPinchConfig? {
    guard let config = arguments["pinchConfig"] as? Dictionary<String,Any> else {
        return nil
    }
    
    var minZoom: SCNVector3?
    var maxZoom: SCNVector3?
    if let minZoomArr = config["minZoom"] as? Array<Double> {
        minZoom = deserializeVector3(minZoomArr)
    }
    if let maxZoomArr = config["maxZoom"] as? Array<Double> {
        maxZoom = deserializeVector3(maxZoomArr)
    }
    return ARPinchConfig(minZoom: minZoom, maxZoom: maxZoom)
}
