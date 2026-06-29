package com.example.comfy_reader

import android.content.Intent
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "comfy_reader/tts"

    // The system Text-to-speech settings screen. There is no public SDK constant
    // for this action, so use the well-known implicit action string.
    private val actionTtsSettings = "com.android.settings.TTS_SETTINGS"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Ask the active engine to download missing voice data; fall
                    // back to the system TTS settings page if it isn't handled.
                    "installTtsData" -> result.success(
                        launch(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA) ||
                            launch(actionTtsSettings)
                    )
                    // Open system TTS settings (engine picker + "Install voice data").
                    "openTtsSettings" -> result.success(launch(actionTtsSettings))
                    else -> result.notImplemented()
                }
            }
    }

    private fun launch(action: String): Boolean {
        return try {
            startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (e: Exception) {
            false
        }
    }
}
