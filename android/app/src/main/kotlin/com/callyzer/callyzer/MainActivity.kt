package com.callyzer.callyzer

import android.content.Context
import android.telephony.SubscriptionManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SIM_CHANNEL = "com.callyzer.app/sim_info"
    private val AUTOMATION_CHANNEL = "com.callyzer.app/automation"
    private val POST_CALL_CHANNEL = "com.callyzer.app/post_call"
    private val PREFS_NAME = "com.callyzer.automation_prefs"

    private var postCallChannel: MethodChannel? = null
    private var pendingPostCallData: Map<String, Any?>? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        postCallChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, POST_CALL_CHANNEL)
        postCallChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialCallData" -> {
                    val data = pendingPostCallData
                    pendingPostCallData = null
                    result.success(data)
                }
                "checkOverlayPermission" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                        result.success(android.provider.Settings.canDrawOverlays(this))
                    } else {
                        result.success(true)
                    }
                }
                "requestOverlayPermission" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                        if (!android.provider.Settings.canDrawOverlays(this)) {
                            val intent = android.content.Intent(
                                android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                android.net.Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }
                "showNativeOverlay" -> {
                    val phone = call.argument<String>("phoneNumber") ?: ""
                    val callType = call.argument<String>("callType") ?: "outgoing"
                    val duration = call.argument<Int>("durationSeconds") ?: 0
                    PostCallOverlayService.start(applicationContext, phone, callType, duration)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        handleIntentForPostCall(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SIM_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSimCards") {
                val simCards = getSimCards()
                result.success(simCards)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTOMATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateAutomationPrefs" -> {
                    val autoEnabled = call.argument<Boolean>("auto_response_enabled") ?: true
                    val sendSms = call.argument<Boolean>("send_sms_enabled") ?: true
                    val smsMessage = call.argument<String>("sms_message") ?: ""
                    val sendWa = call.argument<Boolean>("send_whatsapp_enabled") ?: true
                    val waBaseUrl = call.argument<String>("whatsapp_base_url") ?: "https://automate.takse.in/api/v2/whatsapp-business/messages"
                    val waToken = call.argument<String>("whatsapp_access_token") ?: "104805ee6609f510973f6c20997a3a715d5b750386459085cfc14a24064937d2"
                    val waPhoneId = call.argument<String>("whatsapp_phone_number_id") ?: "1191025657429236"
                    val waTemplate = call.argument<String>("whatsapp_template_name") ?: ""
                    val waText = call.argument<String>("whatsapp_custom_text") ?: ""

                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putBoolean("auto_response_enabled", autoEnabled)
                        .putBoolean("send_sms_enabled", sendSms)
                        .putString("sms_message", smsMessage)
                        .putBoolean("send_whatsapp_enabled", sendWa)
                        .putString("whatsapp_base_url", waBaseUrl)
                        .putString("whatsapp_access_token", waToken)
                        .putString("whatsapp_phone_number_id", waPhoneId)
                        .putString("whatsapp_template_name", waTemplate)
                        .putString("whatsapp_custom_text", waText)
                        .apply()

                    result.success(true)
                }
                "getAutomationPrefs" -> {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    val map = mapOf(
                        "auto_response_enabled" to prefs.getBoolean("auto_response_enabled", true),
                        "send_sms_enabled" to prefs.getBoolean("send_sms_enabled", true),
                        "sms_message" to (prefs.getString("sms_message", "Sorry, I am busy right now. I will call you back shortly.") ?: ""),
                        "send_whatsapp_enabled" to prefs.getBoolean("send_whatsapp_enabled", true),
                        "whatsapp_base_url" to (prefs.getString("whatsapp_base_url", "https://automate.takse.in/api/v2/whatsapp-business/messages") ?: "https://automate.takse.in/api/v2/whatsapp-business/messages"),
                        "whatsapp_access_token" to (prefs.getString("whatsapp_access_token", "104805ee6609f510973f6c20997a3a715d5b750386459085cfc14a24064937d2") ?: "104805ee6609f510973f6c20997a3a715d5b750386459085cfc14a24064937d2"),
                        "whatsapp_phone_number_id" to (prefs.getString("whatsapp_phone_number_id", "1191025657429236") ?: "1191025657429236"),
                        "whatsapp_template_name" to (prefs.getString("whatsapp_template_name", "") ?: ""),
                        "whatsapp_custom_text" to (prefs.getString("whatsapp_custom_text", "Sorry, I missed your call. Will get back to you soon.") ?: "")
                    )
                    result.success(map)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getSimCards(): List<Map<String, Any?>> {
        val simList = mutableListOf<Map<String, Any?>>()
        try {
            val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
            if (subscriptionManager != null) {
                val activeList = subscriptionManager.activeSubscriptionInfoList
                if (activeList != null) {
                    for (info in activeList) {
                        val simMap = mapOf(
                            "subscriptionId" to info.subscriptionId.toString(),
                            "simSlotIndex" to info.simSlotIndex,
                            "displayName" to (info.displayName?.toString() ?: "SIM ${info.simSlotIndex + 1}"),
                            "carrierName" to (info.carrierName?.toString() ?: "SIM ${info.simSlotIndex + 1}"),
                            "number" to (info.number ?: "")
                        )
                        simList.add(simMap)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return simList
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        handleIntentForPostCall(intent)
    }

    private fun handleIntentForPostCall(intent: android.content.Intent?) {
        if (intent?.getStringExtra("action") == "SHOW_POST_CALL_DIALOG") {
            val phone = intent.getStringExtra("phoneNumber") ?: ""
            val type = intent.getStringExtra("callType") ?: "outgoing"
            if (phone.isEmpty()) return
            val map = mapOf("phoneNumber" to phone, "callType" to type)
            if (postCallChannel != null) {
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    postCallChannel?.invokeMethod("onCallEnded", map)
                }, 350)
            } else {
                pendingPostCallData = map
            }
        }
    }
}
