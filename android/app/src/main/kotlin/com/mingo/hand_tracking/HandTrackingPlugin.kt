package com.mingo.hand_tracking

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Plugin de Flutter para MediaPipe Hand Tracking
 * 
 * Este plugin proporciona detección de manos en tiempo real
 * usando MediaPipe Hand Landmarker.
 */
class HandTrackingPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    
    private var handLandmarker: HandLandmarker? = null
    private var eventSink: EventChannel.EventSink? = null
    private var backgroundExecutor: ExecutorService? = null
    private var isTracking = false
    private var frameNumber = 0
    
    private val mainHandler = Handler(Looper.getMainLooper())
    
    // Configuración por defecto
    private var maxHands = 2
    private var minDetectionConfidence = 0.5f
    private var minTrackingConfidence = 0.5f

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        
        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "com.mingo.hand_tracking/methods"
        )
        methodChannel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "com.mingo.hand_tracking/stream"
        )
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isAvailable" -> {
                result.success(checkMediaPipeAvailability())
            }
            "initialize" -> {
                val maxHands = call.argument<Int>("maxHands") ?: 2
                val minDetection = call.argument<Double>("minDetectionConfidence") ?: 0.5
                val minTracking = call.argument<Double>("minTrackingConfidence") ?: 0.5
                
                initializeHandLandmarker(
                    maxHands,
                    minDetection.toFloat(),
                    minTracking.toFloat(),
                    result
                )
            }
            "startTracking" -> {
                startTracking(result)
            }
            "stopTracking" -> {
                stopTracking(result)
            }
            "processImage" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                if (imageBytes != null) {
                    processImage(imageBytes, result)
                } else {
                    result.error("INVALID_ARGUMENT", "imageBytes is required", null)
                }
            }
            "getDeviceInfo" -> {
                result.success(getDeviceInfo())
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun checkMediaPipeAvailability(): Boolean {
        return try {
            // Verificar si las clases de MediaPipe están disponibles
            Class.forName("com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker")
            true
        } catch (e: ClassNotFoundException) {
            false
        }
    }

    private fun initializeHandLandmarker(
        maxHands: Int,
        minDetection: Float,
        minTracking: Float,
        result: Result
    ) {
        this.maxHands = maxHands
        this.minDetectionConfidence = minDetection
        this.minTrackingConfidence = minTracking
        
        backgroundExecutor = Executors.newSingleThreadExecutor()
        
        backgroundExecutor?.execute {
            try {
                val baseOptions = BaseOptions.builder()
                    .setModelAssetPath("hand_landmarker.task")
                    .build()

                val options = HandLandmarker.HandLandmarkerOptions.builder()
                    .setBaseOptions(baseOptions)
                    .setNumHands(maxHands)
                    .setMinHandDetectionConfidence(minDetection)
                    .setMinTrackingConfidence(minTracking)
                    .setMinHandPresenceConfidence(minDetection)
                    .setRunningMode(RunningMode.LIVE_STREAM)
                    .setResultListener { landmarkerResult, _ ->
                        onHandLandmarkerResult(landmarkerResult)
                    }
                    .setErrorListener { error ->
                        mainHandler.post {
                            eventSink?.error("DETECTION_ERROR", error.message, null)
                        }
                    }
                    .build()

                handLandmarker = HandLandmarker.createFromOptions(context, options)
                
                mainHandler.post {
                    result.success(true)
                }
            } catch (e: Exception) {
                mainHandler.post {
                    result.error("INIT_ERROR", e.message, null)
                }
            }
        }
    }

    private fun startTracking(result: Result) {
        if (handLandmarker == null) {
            result.error("NOT_INITIALIZED", "HandLandmarker not initialized", null)
            return
        }
        
        isTracking = true
        frameNumber = 0
        result.success(null)
    }

    private fun stopTracking(result: Result) {
        isTracking = false
        result.success(null)
    }

    private fun processImage(imageBytes: ByteArray, result: Result) {
        backgroundExecutor?.execute {
            try {
                val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                val mpImage = BitmapImageBuilder(bitmap).build()
                
                // Procesar imagen (modo IMAGE, no LIVE_STREAM)
                val imageResult = handLandmarker?.detect(mpImage)
                
                val jsonResult = convertResultToJson(imageResult, frameNumber++)
                
                mainHandler.post {
                    result.success(jsonResult.toString())
                }
            } catch (e: Exception) {
                mainHandler.post {
                    result.error("PROCESS_ERROR", e.message, null)
                }
            }
        }
    }

    /**
     * Callback cuando se detecta una mano
     */
    private fun onHandLandmarkerResult(result: HandLandmarkerResult) {
        if (!isTracking) return
        
        val jsonResult = convertResultToJson(result, frameNumber++)
        
        mainHandler.post {
            eventSink?.success(jsonResult.toString())
        }
    }

    /**
     * Convertir resultado de MediaPipe a JSON para Flutter
     */
    private fun convertResultToJson(result: HandLandmarkerResult?, frameNum: Int): JSONObject {
        val json = JSONObject()
        val handsArray = JSONArray()
        
        result?.let { r ->
            r.landmarks().forEachIndexed { handIndex, handLandmarks ->
                val handJson = JSONObject()
                val landmarksArray = JSONArray()
                
                handLandmarks.forEachIndexed { landmarkIndex, landmark ->
                    val landmarkJson = JSONObject()
                    landmarkJson.put("index", landmarkIndex)
                    landmarkJson.put("x", landmark.x())
                    landmarkJson.put("y", landmark.y())
                    landmarkJson.put("z", landmark.z())
                    landmarkJson.put("visibility", landmark.visibility().orElse(1.0f))
                    landmarksArray.put(landmarkJson)
                }
                
                handJson.put("landmarks", landmarksArray)
                
                // Determinar lateralidad (izquierda/derecha)
                val handedness = if (r.handednesses().size > handIndex) {
                    val categories = r.handednesses()[handIndex]
                    if (categories.isNotEmpty()) {
                        categories[0].categoryName().lowercase()
                    } else "right"
                } else "right"
                
                handJson.put("handedness", handedness)
                
                // Confianza
                val confidence = if (r.handednesses().size > handIndex) {
                    val categories = r.handednesses()[handIndex]
                    if (categories.isNotEmpty()) categories[0].score() else 0.0f
                } else 0.0f
                
                handJson.put("confidence", confidence)
                handJson.put("timestamp", System.currentTimeMillis())
                
                handsArray.put(handJson)
            }
        }
        
        json.put("hands", handsArray)
        json.put("frame_number", frameNum)
        json.put("timestamp", System.currentTimeMillis())
        json.put("processing_time_ms", 0) // TODO: calcular tiempo real
        
        return json
    }

    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "model" to android.os.Build.MODEL,
            "manufacturer" to android.os.Build.MANUFACTURER,
            "sdkVersion" to android.os.Build.VERSION.SDK_INT,
            "mediaPipeAvailable" to checkMediaPipeAvailability()
        )
    }

    private fun dispose() {
        isTracking = false
        handLandmarker?.close()
        handLandmarker = null
        backgroundExecutor?.shutdown()
        backgroundExecutor = null
    }

    // EventChannel.StreamHandler
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        dispose()
    }
}
