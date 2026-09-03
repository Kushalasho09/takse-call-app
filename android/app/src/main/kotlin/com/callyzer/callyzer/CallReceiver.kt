package com.callyzer.callyzer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telephony.SmsManager
import android.telephony.TelephonyManager
import android.util.Log
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

class CallReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "CallReceiver"
        private const val PREFS_NAME = "com.callyzer.automation_prefs"

        private const val DEFAULT_BASE_URL = "https://automate.takse.in/api/v2/whatsapp-business/messages"
        private const val DEFAULT_PHONE_ID = "1191025657429236"
        private const val DEFAULT_TOKEN = "104805ee6609f510973f6c20997a3a715d5b750386459085cfc14a24064937d2"

        private var lastState = TelephonyManager.EXTRA_STATE_IDLE
        private var isIncoming = false
        private var wasAnswered = false
        private var savedNumber: String? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            if (stateStr != null) {
                onCallStateChanged(context, stateStr, number)
            }
        }
    }

    private fun onCallStateChanged(context: Context, stateStr: String, number: String?) {
        if (stateStr == lastState) {
            return
        }

        if (!number.isNullOrEmpty()) {
            savedNumber = number
        }

        when (stateStr) {
            TelephonyManager.EXTRA_STATE_RINGING -> {
                isIncoming = true
                wasAnswered = false
                Log.d(TAG, "Incoming call ringing from: $savedNumber")
            }
            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                if (isIncoming) {
                    wasAnswered = true
                    Log.d(TAG, "Incoming call answered")
                }
            }
            TelephonyManager.EXTRA_STATE_IDLE -> {
                if (isIncoming) {
                    if (!wasAnswered) {
                        Log.d(TAG, "Call CUT / DECLINED / MISSED from: $savedNumber")
                        savedNumber?.let { callerNo ->
                            triggerAutomatedActions(context, callerNo)
                        }
                    } else {
                        Log.d(TAG, "Call ended after answer")
                    }
                    isIncoming = false
                    wasAnswered = false
                }
            }
        }

        lastState = stateStr
    }

    private fun triggerAutomatedActions(context: Context, incomingNumber: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val autoEnabled = prefs.getBoolean("auto_response_enabled", true)
        if (!autoEnabled) {
            Log.d(TAG, "Auto-response is disabled in settings.")
            return
        }

        val sendSmsEnabled = prefs.getBoolean("send_sms_enabled", true)
        val smsMessage = prefs.getString("sms_message", "Sorry, I am busy right now. I will call you back shortly.") ?: ""

        val sendWhatsAppEnabled = prefs.getBoolean("send_whatsapp_enabled", true)
        val waBaseUrl = prefs.getString("whatsapp_base_url", DEFAULT_BASE_URL) ?: DEFAULT_BASE_URL
        val waAccessToken = prefs.getString("whatsapp_access_token", DEFAULT_TOKEN) ?: DEFAULT_TOKEN
        val waPhoneNumberId = prefs.getString("whatsapp_phone_number_id", DEFAULT_PHONE_ID) ?: DEFAULT_PHONE_ID
        val waTemplateName = prefs.getString("whatsapp_template_name", "") ?: ""
        val waCustomText = prefs.getString("whatsapp_custom_text", "Sorry, I missed your call. Will get back to you soon.") ?: ""

        // 1. Send SMS natively
        if (sendSmsEnabled && smsMessage.isNotEmpty()) {
            try {
                sendDirectSms(incomingNumber, smsMessage)
                Log.d(TAG, "SMS sent to $incomingNumber")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to send SMS: ${e.message}", e)
            }
        }

        // 2. Send WhatsApp Message via API
        if (sendWhatsAppEnabled && waAccessToken.isNotEmpty()) {
            Thread {
                sendWhatsAppMessage(
                    baseUrl = waBaseUrl,
                    phoneNumberId = waPhoneNumberId,
                    accessToken = waAccessToken,
                    recipientNumber = incomingNumber,
                    templateName = waTemplateName,
                    messageText = waCustomText
                )
            }.start()
        }
    }

    private fun sendDirectSms(phoneNumber: String, message: String) {
        val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            SmsManager.getDefault()
        } else {
            @Suppress("DEPRECATION")
            SmsManager.getDefault()
        }

        val parts = smsManager.divideMessage(message)
        if (parts.size > 1) {
            smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
        } else {
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        }
    }

    private fun sendWhatsAppMessage(
        baseUrl: String,
        phoneNumberId: String,
        accessToken: String,
        recipientNumber: String,
        templateName: String,
        messageText: String
    ) {
        try {
            // Format phone number to E.164 without plus sign
            var formattedNumber = recipientNumber.replace("[^0-9]".toRegex(), "")
            if (formattedNumber.length == 10) {
                formattedNumber = "91$formattedNumber"
            }

            val targetUrl: String = if (baseUrl.contains("graph.facebook.com")) {
                "https://graph.facebook.com/v18.0/$phoneNumberId/messages"
            } else {
                baseUrl
            }

            val url = URL(targetUrl)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Authorization", "Bearer $accessToken")
            conn.setRequestProperty("x-api-key", accessToken)
            conn.setRequestProperty("api-key", accessToken)
            conn.setRequestProperty("Content-Type", "application/json; utf-8")
            conn.doOutput = true

            val jsonBody = JSONObject()
            jsonBody.put("phone_number_id", phoneNumberId)
            jsonBody.put("phone_id", phoneNumberId)
            jsonBody.put("messaging_product", "whatsapp")
            jsonBody.put("to", formattedNumber)

            if (templateName.isNotEmpty()) {
                jsonBody.put("type", "template")
                val templateObj = JSONObject()
                templateObj.put("name", templateName)
                val langObj = JSONObject()
                langObj.put("code", "en_US")
                templateObj.put("language", langObj)
                jsonBody.put("template", templateObj)
            } else {
                jsonBody.put("type", "text")
                val textObj = JSONObject()
                textObj.put("body", messageText)
                jsonBody.put("text", textObj)
            }

            OutputStreamWriter(conn.outputStream).use { os ->
                os.write(jsonBody.toString())
                os.flush()
            }

            val responseCode = conn.responseCode
            if (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_CREATED) {
                Log.d(TAG, "WhatsApp message sent successfully to $formattedNumber (Code: $responseCode)")
            } else {
                val errorStream = conn.errorStream?.bufferedReader()?.use { it.readText() } ?: ""
                Log.e(TAG, "WhatsApp API Error [$responseCode]: $errorStream")
            }
            conn.disconnect()
        } catch (e: Exception) {
            Log.e(TAG, "Exception sending WhatsApp message: ${e.message}", e)
        }
    }
}
