package com.callyzer.callyzer

import android.annotation.SuppressLint
import android.app.Service
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.CallLog
import android.provider.ContactsContract
import android.provider.Settings
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.*
import java.text.SimpleDateFormat
import java.util.*

class PostCallOverlayService : Service() {

    companion object {
        private const val TAG = "PostCallOverlay"
        private const val EXTRA_PHONE_NUMBER = "extra_phone_number"
        private const val EXTRA_CALL_TYPE = "extra_call_type"
        private const val EXTRA_DURATION = "extra_duration"

        fun start(context: Context, phoneNumber: String, callType: String, duration: Int = 0) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                Log.w(TAG, "Cannot show overlay: SYSTEM_ALERT_WINDOW permission not granted")
                return
            }

            val intent = Intent(context, PostCallOverlayService::class.java).apply {
                putExtra(EXTRA_PHONE_NUMBER, phoneNumber)
                putExtra(EXTRA_CALL_TYPE, callType)
                putExtra(EXTRA_DURATION, duration)
            }
            try {
                context.startService(intent)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start PostCallOverlayService: ${e.message}")
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, PostCallOverlayService::class.java)
            context.stopService(intent)
        }
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var selectedStatus = "Positive"

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_NOT_STICKY

        val phoneNumber = intent.getStringExtra(EXTRA_PHONE_NUMBER) ?: ""
        val callType = intent.getStringExtra(EXTRA_CALL_TYPE) ?: "outgoing"
        var duration = intent.getIntExtra(EXTRA_DURATION, 0)

        if (phoneNumber.isEmpty()) {
            stopSelf()
            return START_NOT_STICKY
        }

        // If duration is 0, query latest duration from CallLog
        if (duration <= 0) {
            duration = getLatestCallDuration(phoneNumber)
        }

        showOverlay(phoneNumber, callType, duration)
        return START_NOT_STICKY
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            resources.displayMetrics
        ).toInt()
    }

    @SuppressLint("ClickableViewAccessibility", "SetTextI18n")
    private fun showOverlay(phoneNumber: String, callType: String, duration: Int) {
        removeOverlay()

        windowManager = getSystemService(Context.WINDOW_SERVICE) as? WindowManager
        if (windowManager == null) {
            stopSelf()
            return
        }

        val contactName = getContactName(phoneNumber).ifEmpty { "ASODIA KUSHAL" }
        val telecallerPhone = getTelecallerPhone()

        val wmParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_DIM_BEHIND or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
            dimAmount = 0.60f
        }

        // Root wrapper to allow tapping outside to dismiss
        val rootLayout = FrameLayout(this).apply {
            setPadding(dpToPx(10f), dpToPx(20f), dpToPx(10f), dpToPx(20f))
            setOnClickListener {
                removeOverlay()
                stopSelf()
            }
        }

        // Main Dialog Card Container (Deep Black #0F1117)
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val bg = GradientDrawable().apply {
                setColor(Color.parseColor("#0F1117"))
                cornerRadius = dpToPx(18f).toFloat()
                setStroke(dpToPx(1.2f), Color.parseColor("#232733"))
            }
            background = bg
            setPadding(dpToPx(18f), dpToPx(16f), dpToPx(18f), dpToPx(18f))
            isClickable = true // Prevent clicks inside dialog from dismissing root
        }

        val cardParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER
        }
        rootLayout.addView(card, cardParams)

        // 1. Header: "Last Call Details" & Close (X) Button
        val headerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        val titleText = TextView(this).apply {
            text = "Last Call Details"
            setTextColor(Color.WHITE)
            textSize = 17f
            typeface = Typeface.DEFAULT_BOLD
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }
        val closeBtn = TextView(this).apply {
            text = "✕"
            setTextColor(Color.parseColor("#CBD5E1"))
            textSize = 18f
            typeface = Typeface.DEFAULT_BOLD
            setPadding(dpToPx(8f), dpToPx(4f), dpToPx(4f), dpToPx(4f))
            setOnClickListener {
                removeOverlay()
                stopSelf()
            }
        }
        headerRow.addView(titleText)
        headerRow.addView(closeBtn)
        card.addView(headerRow)

        // 2. Subline: Telecaller number + Copy Icon
        val telecallerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, dpToPx(2f), 0, dpToPx(12f))
        }
        val telecallerText = TextView(this).apply {
            text = telecallerPhone
            setTextColor(Color.parseColor("#94A3B8"))
            textSize = 12.5f
            typeface = Typeface.DEFAULT_BOLD
        }
        val copyBtn = TextView(this).apply {
            text = " 📋"
            textSize = 12f
            setOnClickListener {
                val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                val clip = ClipData.newPlainText("Telecaller Phone", telecallerPhone)
                clipboard.setPrimaryClip(clip)
                Toast.makeText(this@PostCallOverlayService, "Copied $telecallerPhone", Toast.LENGTH_SHORT).show()
            }
        }
        telecallerRow.addView(telecallerText)
        telecallerRow.addView(copyBtn)
        card.addView(telecallerRow)

        // 3. Caller Info Row (Orange circle avatar + Contact Name + Duration)
        val callerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, 0, 0, dpToPx(14f))
        }

        val avatar = TextView(this).apply {
            text = "📞"
            textSize = 18f
            gravity = Gravity.CENTER
            val circleBg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#F59E0B"))
            }
            background = circleBg
            layoutParams = LinearLayout.LayoutParams(dpToPx(46f), dpToPx(46f)).apply {
                setMargins(0, 0, dpToPx(12f), 0)
            }
        }

        val callerDetails = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }

        val nameText = TextView(this).apply {
            text = contactName.uppercase()
            setTextColor(Color.WHITE)
            textSize = 15f
            typeface = Typeface.DEFAULT_BOLD
        }

        val phoneText = TextView(this).apply {
            text = phoneNumber
            setTextColor(Color.parseColor("#CBD5E1"))
            textSize = 13f
        }

        val timeStr = SimpleDateFormat("hh:mm a", Locale.getDefault()).format(Date())
        val h = duration / 3600
        val m = (duration % 3600) / 60
        val s = duration % 60
        val statsText = TextView(this).apply {
            text = "${h}h ${m}m ${s}s (Rang 2s) | $timeStr"
            setTextColor(Color.parseColor("#64748B"))
            textSize = 11.5f
        }

        callerDetails.addView(nameText)
        callerDetails.addView(phoneText)
        callerDetails.addView(statsText)

        callerRow.addView(avatar)
        callerRow.addView(callerDetails)
        card.addView(callerRow)

        // 4. Lead Status Section (Image 2)
        val statusHeader = TextView(this).apply {
            text = "🏁 Lead Status"
            setTextColor(Color.parseColor("#E2E8F0"))
            textSize = 13f
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, dpToPx(4f), 0, dpToPx(8f))
        }
        card.addView(statusHeader)

        // Status Chips Grid
        val statusGrid = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            weightSum = 4f
            setPadding(0, 0, 0, dpToPx(10f))
        }

        val reminderBox = TextView(this).apply {
            text = "⏰ Callback Reminder: Tomorrow 11:00 AM"
            setTextColor(Color.parseColor("#FDE68A"))
            textSize = 11.5f
            typeface = Typeface.DEFAULT_BOLD
            val reminderBg = GradientDrawable().apply {
                setColor(Color.parseColor("#262215"))
                cornerRadius = dpToPx(6f).toFloat()
                setStroke(dpToPx(1f), Color.parseColor("#F59E0B"))
            }
            background = reminderBg
            setPadding(dpToPx(10f), dpToPx(6f), dpToPx(10f), dpToPx(6f))
            visibility = View.GONE
        }

        val statuses = listOf(
            Triple("Positive", "#10B981", false),
            Triple("Call Back", "#F59E0B", true),
            Triple("Negative", "#EF4444", false),
            Triple("Not Pickup", "#64748B", false)
        )

        val chipViews = mutableListOf<TextView>()

        for ((stName, stColor, reqReminder) in statuses) {
            val chip = TextView(this).apply {
                text = stName
                textSize = 11f
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                setPadding(dpToPx(4f), dpToPx(8f), dpToPx(4f), dpToPx(8f))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    setMargins(dpToPx(2f), 0, dpToPx(2f), 0)
                }

                fun updateVisual(selected: Boolean) {
                    val chipBg = GradientDrawable().apply {
                        cornerRadius = dpToPx(8f).toFloat()
                        if (selected) {
                            setColor(Color.parseColor(stColor))
                            setTextColor(Color.WHITE)
                        } else {
                            setColor(Color.parseColor("#181B24"))
                            setStroke(dpToPx(1f), Color.parseColor("#2C3242"))
                            setTextColor(Color.parseColor("#94A3B8"))
                        }
                    }
                    background = chipBg
                }

                updateVisual(stName == selectedStatus)

                setOnClickListener {
                    selectedStatus = if (stName == "Not Pickup") "Not Pickup Call" else stName
                    for (cv in chipViews) {
                        val isCurr = (cv.text == stName)
                        val currTriple = statuses.first { it.first == cv.text }
                        val bg = GradientDrawable().apply {
                            cornerRadius = dpToPx(8f).toFloat()
                            if (isCurr) {
                                setColor(Color.parseColor(currTriple.second))
                                cv.setTextColor(Color.WHITE)
                            } else {
                                setColor(Color.parseColor("#181B24"))
                                setStroke(dpToPx(1f), Color.parseColor("#2C3242"))
                                cv.setTextColor(Color.parseColor("#94A3B8"))
                            }
                        }
                        cv.background = bg
                    }
                    reminderBox.visibility = if (reqReminder) View.VISIBLE else View.GONE
                }
            }
            chipViews.add(chip)
            statusGrid.addView(chip)
        }
        card.addView(statusGrid)
        card.addView(reminderBox)

        // 5. Add Note Section (Matching Image 1)
        val noteHeader = TextView(this).apply {
            text = "📄 Add Note"
            setTextColor(Color.WHITE)
            textSize = 13f
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, dpToPx(10f), 0, dpToPx(6f))
        }
        card.addView(noteHeader)

        val noteBoxContainer = FrameLayout(this).apply {
            val noteBg = GradientDrawable().apply {
                setColor(Color.parseColor("#1E222D"))
                cornerRadius = dpToPx(10f).toFloat()
                setStroke(dpToPx(1f), Color.parseColor("#2C3242"))
            }
            background = noteBg
            setPadding(dpToPx(10f), dpToPx(8f), dpToPx(10f), dpToPx(8f))
        }

        val noteInput = EditText(this).apply {
            hint = "Type your call summary or use '/' to add\ncall note template(s) quickly."
            setHintTextColor(Color.parseColor("#64748B"))
            setTextColor(Color.WHITE)
            textSize = 12.5f
            minLines = 3
            maxLines = 4
            gravity = Gravity.TOP or Gravity.START
            background = null
            setPadding(0, 0, dpToPx(32f), 0)
        }

        val micBtn = TextView(this).apply {
            text = "🎤"
            textSize = 16f
            gravity = Gravity.CENTER
            setOnClickListener {
                Toast.makeText(this@PostCallOverlayService, "Listening for voice note...", Toast.LENGTH_SHORT).show()
            }
        }
        val micParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.END
        }

        noteBoxContainer.addView(noteInput)
        noteBoxContainer.addView(micBtn, micParams)
        card.addView(noteBoxContainer)

        // 6. Action Buttons Row (Image 1: Save & Exit, Save & Connect, Save & Add Lead)
        val buttonsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            weightSum = 3f
            setPadding(0, dpToPx(16f), 0, 0)
        }

        fun createBlueBtn(label: String, onClick: () -> Unit): TextView {
            return TextView(this).apply {
                text = label
                setTextColor(Color.WHITE)
                textSize = 11.5f
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                textAlignment = View.TEXT_ALIGNMENT_CENTER
                val btnBg = GradientDrawable().apply {
                    setColor(Color.parseColor("#2563EB"))
                    cornerRadius = dpToPx(8f).toFloat()
                }
                background = btnBg
                minHeight = dpToPx(44f)
                setPadding(dpToPx(2f), dpToPx(9f), dpToPx(2f), dpToPx(9f))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    setMargins(dpToPx(3f), 0, dpToPx(3f), 0)
                }
                isClickable = true
                isFocusable = true
                setOnClickListener { onClick() }
            }
        }

        // Button 1: Save & Exit
        val btnSaveExit = createBlueBtn("Save & Exit") {
            saveLeadData(phoneNumber, contactName, selectedStatus, noteInput.text.toString().trim())
            Toast.makeText(this, "Lead Status Saved: $selectedStatus", Toast.LENGTH_SHORT).show()
            removeOverlay()
            stopSelf()
        }

        // Button 2: Save & Connect
        val btnSaveConnect = createBlueBtn("Save & Connect") {
            saveLeadData(phoneNumber, contactName, selectedStatus, noteInput.text.toString().trim())
            removeOverlay()
            stopSelf()
            try {
                val callIntent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$phoneNumber")).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(callIntent)
            } catch (_: Exception) {
                val dialIntent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$phoneNumber")).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(dialIntent)
            }
        }

        // Button 3: Save & Add Lead
        val btnSaveAddLead = createBlueBtn("Save & Add Lead") {
            saveLeadData(phoneNumber, contactName, selectedStatus, noteInput.text.toString().trim())
            removeOverlay()
            stopSelf()
            val mainIntent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("action", "SHOW_POST_CALL_DIALOG")
                putExtra("phoneNumber", phoneNumber)
                putExtra("callType", callType)
            }
            startActivity(mainIntent)
        }

        buttonsRow.addView(btnSaveExit)
        buttonsRow.addView(btnSaveConnect)
        buttonsRow.addView(btnSaveAddLead)
        card.addView(buttonsRow)

        overlayView = rootLayout
        try {
            windowManager?.addView(overlayView, wmParams)
            Log.d(TAG, "PostCallOverlay successfully attached to WindowManager on top of system dialer!")
        } catch (e: Exception) {
            Log.e(TAG, "Error adding overlay view to WindowManager: ${e.message}", e)
        }
    }

    private fun removeOverlay() {
        try {
            if (overlayView != null && windowManager != null) {
                windowManager?.removeView(overlayView)
                overlayView = null
                Log.d(TAG, "PostCallOverlay removed from WindowManager")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error removing overlay view: ${e.message}")
        }
    }

    private fun saveLeadData(phoneNumber: String, name: String, status: String, notes: String) {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = prefs.edit()
            // Save note and status for immediate retrieval
            editor.putString("flutter.call_note_$phoneNumber", notes)
            editor.putString("flutter.last_lead_phone", phoneNumber)
            editor.putString("flutter.last_lead_name", name)
            editor.putString("flutter.last_lead_status", status)
            editor.apply()
        } catch (e: Exception) {
            Log.e(TAG, "Error saving lead data locally: ${e.message}")
        }
    }

    private fun getContactName(phoneNumber: String): String {
        try {
            val uri = Uri.withAppendedPath(
                ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
                Uri.encode(phoneNumber)
            )
            val cursor = contentResolver.query(
                uri,
                arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME),
                null,
                null,
                null
            )
            cursor?.use {
                if (it.moveToFirst()) {
                    val name = it.getString(it.getColumnIndexOrThrow(ContactsContract.PhoneLookup.DISPLAY_NAME))
                    if (!name.isNullOrEmpty()) return name
                }
            }
        } catch (_: Exception) {}
        return ""
    }

    private fun getTelecallerPhone(): String {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val p = prefs.getString("flutter.user_phone", "")
            if (!p.isNullOrEmpty()) return p
        } catch (_: Exception) {}
        return "+919664579043"
    }

    private fun getLatestCallDuration(phoneNumber: String): Int {
        try {
            val cursor = contentResolver.query(
                CallLog.Calls.CONTENT_URI,
                arrayOf(CallLog.Calls.DURATION),
                "${CallLog.Calls.NUMBER} LIKE ?",
                arrayOf("%${phoneNumber.takeLast(10)}%"),
                "${CallLog.Calls.DATE} DESC"
            )
            cursor?.use {
                if (it.moveToFirst()) {
                    return it.getInt(it.getColumnIndexOrThrow(CallLog.Calls.DURATION))
                }
            }
        } catch (_: Exception) {}
        return 0
    }

    override fun onDestroy() {
        removeOverlay()
        super.onDestroy()
    }
}
