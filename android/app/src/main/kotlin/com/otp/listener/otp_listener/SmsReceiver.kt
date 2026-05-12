package com.otp.listener.otp_listener

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        try {
            if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION == intent.action) {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)

                for (message in messages) {
                    val sender = message.originatingAddress ?: continue
                    val messageBody = message.messageBody
                    val timestamp = message.timestampMillis

                    Log.d(TAG, "SMS received from: $sender")

                    // Must run on main thread for Flutter EventChannel
                    Handler(Looper.getMainLooper()).post {
                        MainActivity.broadcastSmsReceived(
                            sender = sender,
                            message = messageBody,
                            timestamp = timestamp
                        )
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error receiving SMS", e)
        }
    }
}