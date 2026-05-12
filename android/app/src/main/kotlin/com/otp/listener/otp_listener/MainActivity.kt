package com.otp.listener.otp_listener

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class MainActivity : FlutterActivity() {
    companion object {
        private const val SMS_CHANNEL = "com.otp.listener/sms"
        private var eventSink: EventSink? = null

        fun broadcastSmsReceived(sender: String, message: String, timestamp: Long) {
            val smsData = mapOf(
                "sender" to sender,
                "message" to message,
                "timestamp" to timestamp
            )
            eventSink?.success(smsData)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }
}
