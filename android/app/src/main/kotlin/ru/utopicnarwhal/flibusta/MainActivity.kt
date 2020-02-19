package ru.utopicnarwhal.flibusta

import android.content.Context
import android.media.MediaScannerConnection
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "ru.utopicnarwhal.flibusta/native_methods_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "rescan_folder") {
                val response = rescanFolder(call.arguments.toString())

                if (response != -1) {
                    result.success(response)
                } else {
                    result.error("UNAVAILABLE", "Not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun rescanFolder(dir: String): Int {
        try {
            MediaScannerConnection.scanFile(this, arrayOf(dir), null, null)
        } catch (e: Exception) {
            return -1
        }
        return 1
    }
}
