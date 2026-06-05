package com.passwordmobileapp.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterFragmentActivity() {

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
    }
}
