package com.passwordmobileapp.app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.service.autofill.Dataset
import android.view.autofill.AutofillId
import android.view.autofill.AutofillManager
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterFragmentActivity() {

    // Set only when this Activity is launched by VaultAutofillService as the
    // authentication step for a "generate a new password" suggestion (see
    // ANDROID_AUTOFILL_SUGGESTION.md). Lives only for this Activity instance:
    // completeGenerate/cancelGenerate always finish() it, so a later, normal
    // reopen of the app starts a fresh instance with this field null again.
    private var activeGenerateIds: Array<AutofillId>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureGenerateModeExtras(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureGenerateModeExtras(intent)
    }

    private fun captureGenerateModeExtras(intent: Intent?) {
        if (intent?.action != VaultAutofillService.ACTION_AUTOFILL_GENERATE) return
        @Suppress("DEPRECATION")
        val ids = intent.getParcelableArrayExtra(VaultAutofillService.EXTRA_NEW_PASSWORD_IDS)
            ?.filterIsInstance<AutofillId>()
            ?.toTypedArray()
        if (ids != null && ids.isNotEmpty()) activeGenerateIds = ids
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "autofill_cache")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        val json = call.argument<String>("entries") ?: ""
                        runCatching {
                            val arr = JSONArray(json)
                            val entries = (0 until arr.length()).map { i ->
                                val o = arr.getJSONObject(i)
                                AutofillEntry(
                                    url      = o.optString("url"),
                                    login    = o.optString("login"),
                                    password = o.optString("password")
                                )
                            }
                            AutofillCache.update(this, entries)
                            result.success(null)
                        }.onFailure { e -> result.error("PARSE_ERROR", e.message, null) }
                    }
                    "clear" -> {
                        AutofillCache.clear(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Bridges VaultAutofillService's "generate new password" flow (see
        // ANDROID_AUTOFILL_SUGGESTION.md) to Dart: a dedicated channel, separate
        // from autofill_cache above, since it is a different concern (driving this
        // Activity's own result, not reading/writing the existing-credential cache).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "autofill_bridge")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkGenerateMode" -> result.success(activeGenerateIds != null)
                    "completeGenerate" -> {
                        val password = call.argument<String>("password")
                        val ids = activeGenerateIds
                        if (password.isNullOrEmpty() || ids == null) {
                            result.success(false)
                        } else {
                            result.success(true)
                            finishGenerate(ids, password)
                        }
                    }
                    "cancelGenerate" -> {
                        result.success(null)
                        setResult(Activity.RESULT_CANCELED)
                        finish()
                    }
                    "consumePendingSave" -> {
                        val entry = PendingAutofillSave.consume(this)
                        result.success(entry?.let { mapOf("domain" to it.domain, "password" to it.password) })
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Hands the generated value back to the Autofill framework and closes this
     *  Activity, returning the user to the third-party app's form, now filled. */
    private fun finishGenerate(ids: Array<AutofillId>, password: String) {
        val noPresentation = RemoteViews(packageName, android.R.layout.simple_list_item_1)
        val dataset = Dataset.Builder().apply {
            ids.forEach { id -> setValue(id, AutofillValue.forText(password), noPresentation) }
        }.build()

        val replyIntent = Intent().apply {
            putExtra(AutofillManager.EXTRA_AUTHENTICATION_RESULT, dataset)
        }
        setResult(Activity.RESULT_OK, replyIntent)
        finish()
    }
}
