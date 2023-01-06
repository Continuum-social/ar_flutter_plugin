package io.carius.lars.ar_flutter_plugin.Serialization

import android.R.attr.x
import android.R.attr.y
import com.google.ar.core.*
import com.google.ar.sceneform.AnchorNode
import com.google.ar.sceneform.Node
import com.google.ar.sceneform.math.Quaternion
import com.google.ar.sceneform.math.Vector3
import com.google.ar.sceneform.ux.BaseTransformableNode
import com.google.sceneform_assets.w
import com.google.sceneform_assets.z
import io.carius.lars.ar_flutter_plugin.CustomTransformableNode
import java.util.ArrayList
import kotlin.math.asin
import kotlin.math.atan2


fun serializeHitResult(hitResult: HitResult): HashMap<String, Any> {
    val serializedHitResult = HashMap<String,Any>()

    if (hitResult.trackable is Plane && (hitResult.trackable as Plane).isPoseInPolygon(hitResult.hitPose)) {
        serializedHitResult["type"] = 1 // Type plane
    }
    else if (hitResult.trackable is Point){
        serializedHitResult["type"] = 2 // Type point
    } else {
        serializedHitResult["type"] = 0 // Type undefined
    }

    serializedHitResult["distance"] = hitResult.distance.toDouble()
    serializedHitResult["worldTransform"] = serializePose(hitResult.hitPose)

    return serializedHitResult
}

fun serializePose(pose: Pose): DoubleArray {
    val serializedPose = FloatArray(16)
    pose.toMatrix(serializedPose, 0)
    // copy into double Array
    val serializedPoseDouble = DoubleArray(serializedPose.size)
    for (i in serializedPose.indices) {
        serializedPoseDouble[i] = serializedPose[i].toDouble()
    }
    return serializedPoseDouble
}

fun serializeCameraPoseInfo(pose: Pose): Map<String, Any> {
    val map = mapOf(
            "transform" to serializePose(pose),
            "rotation" to quaternionToAxisAngles(pose.rotationQuaternion)
    )
    return map
}

fun serializeVisibleNodes(visibleNodes: Array<Node>): Map<String, Any> {
    val nodes = visibleNodes.map { serializeLocalTransformation(it)  }.toList()
    val map = mapOf(
            "visibleNodes" to nodes
    )
    return map
}

fun quaternionToAxisAngles(rotationQuaternion: FloatArray) : FloatArray {
    val q = Quaternion(rotationQuaternion[0], rotationQuaternion[1], rotationQuaternion[2], rotationQuaternion[3])
    q.normalize()
    return quat2rpy(q)
}

fun quat2rpy(q: Quaternion): FloatArray {
    val ax: Float // pitch
    val ay: Float // yaw
    val az: Float // roll

    val sqw = q.w * q.w
    val sqx = q.x * q.x
    val sqy = q.y * q.y
    val sqz = q.z * q.z
    val unit = sqx + sqy + sqz + sqw // if normalized is one, otherwise
    // is correction factor
    val test = q.x * q.y + q.z * q.w
    if (test > 0.499 * unit) { // singularity at north pole
        ax = 0.0f
        ay = 2 * atan2(q.x, q.w)
        az = (Math.PI / 2).toFloat()
    } else if (test < -0.499 * unit) { // singularity at south pole
        ax = 0.0f
        ay = -2 * atan2(q.x, q.w)
        az = (-Math.PI/2).toFloat()
    } else {
        ax = atan2(2 * q.x * q.w - 2 * q.y * q.z, -sqx + sqy - sqz + sqw)
        ay = atan2(2 * q.y * q.w - 2 * q.x * q.z, sqx - sqy - sqz + sqw)
        az = asin(2 * test / unit)
    }

    return floatArrayOf(-ax, -ay, -az)
}

fun serializePoseWithScale(pose: Pose, scale: Vector3): DoubleArray {
    val serializedPose = FloatArray(16)
    pose.toMatrix(serializedPose, 0)
    // copy into double Array
    val serializedPoseDouble = DoubleArray(serializedPose.size)
    for (i in serializedPose.indices) {
        serializedPoseDouble[i] = serializedPose[i].toDouble()
        if (i == 0 || i == 4 || i == 8){
            serializedPoseDouble[i] = serializedPoseDouble[i] * scale.x
        }
        if (i == 1 || i == 5 || i == 9){
            serializedPoseDouble[i] = serializedPoseDouble[i] * scale.y
        }
        if (i == 2 || i == 7 || i == 10){
            serializedPoseDouble[i] = serializedPoseDouble[i] * scale.z
        }
    }
    return serializedPoseDouble
}

fun serializeAnchor(anchorNode: AnchorNode, anchor: Anchor?): HashMap<String, Any?> {
    val serializedAnchor = HashMap<String, Any?>()
    serializedAnchor["type"] = 0 // index for plane anchors
    serializedAnchor["name"] = anchorNode.name
    serializedAnchor["cloudanchorid"] = anchor?.cloudAnchorId
    serializedAnchor["transformation"] = if (anchor != null) serializePose(anchor.pose) else null
    serializedAnchor["childNodes"] = anchorNode.children.map { child -> child.name }

    return serializedAnchor
}

fun serializeLocalTransformation(node: Node): HashMap<String, Any>{
    val serializedLocalTransformation = HashMap<String, Any>()
    serializedLocalTransformation["name"] = node.name

    val transform = Pose(floatArrayOf(node.localPosition.x, node.localPosition.y, node.localPosition.z), floatArrayOf(node.localRotation.x, node.localRotation.y, node.localRotation.z, node.localRotation.w))

    serializedLocalTransformation["transform"] = serializePoseWithScale(transform, node.localScale)

    return serializedLocalTransformation
}
