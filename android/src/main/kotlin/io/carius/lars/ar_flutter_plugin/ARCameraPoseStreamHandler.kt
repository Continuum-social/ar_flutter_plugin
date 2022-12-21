package io.carius.lars.ar_flutter_plugin
import com.google.ar.core.Pose
import com.google.ar.sceneform.Node
import com.google.ar.sceneform.ux.BaseTransformableNode
import io.carius.lars.ar_flutter_plugin.Serialization.serializeCameraPoseInfo
import io.flutter.plugin.common.EventChannel
import java.util.*

class ARCameraPoseStreamHandler: EventChannel.StreamHandler {
    var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun updateCameraPose(pose: Pose, visibleNodes: Array<Node>) {
        sink?.success(serializeCameraPoseInfo(pose, visibleNodes))
    }
}