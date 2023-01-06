package io.carius.lars.ar_flutter_plugin

import android.os.Build
import androidx.annotation.RequiresApi
import com.google.ar.sceneform.ArSceneView
import com.google.ar.sceneform.Node
import com.google.ar.sceneform.collision.Ray
import io.carius.lars.ar_flutter_plugin.Serialization.serializeCameraPoseInfo
import io.carius.lars.ar_flutter_plugin.Serialization.serializeVisibleNodes
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.util.*

class ARVisibleNodesStreamHandler: EventChannel.StreamHandler {
    var sink: EventChannel.EventSink? = null

    private var lastUpdateTime: LocalDateTime? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun onFrameUpdate(arSceneView: ArSceneView) {
        val now = LocalDateTime.now()
        if(lastUpdateTime == null || ChronoUnit.MILLIS.between(now, lastUpdateTime) > 250) {
            runBlocking {
                GlobalScope.async { // Kotlin sample
                    val nodes = calculateVisibleNodes(arSceneView)
                    GlobalScope.async(context = Dispatchers.Main) {
                        sink?.success(serializeVisibleNodes(nodes))
                    }
                }
            }
        }
    }

    private fun calculateVisibleNodes(arSceneView: ArSceneView): Array<Node> {
        var visibleNodes = mutableListOf<Node>()

        val camera = arSceneView.scene.camera
        val ray = Ray(camera.worldPosition, camera.forward)

        val results = arSceneView.scene.hitTestAll(ray)
        for( result in results){
            val node = result.node
            if (node != null) {
                visibleNodes.add(node)
            }
        }
        return visibleNodes.toTypedArray()
    }
}