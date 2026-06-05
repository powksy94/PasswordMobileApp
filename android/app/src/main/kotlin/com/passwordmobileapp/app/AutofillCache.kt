package com.passwordmobileapp.app

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import org.json.JSONArray
import org.json.JSONObject

data class AutofillEntry(val url: String, val login: String, val password: String)

object AutofillCache {
    private const val PREFS_NAME = "autofill_cache"
    private const val KEY        = "entries"

    private fun prefs(context: Context) = EncryptedSharedPreferences.create(
        context,
        PREFS_NAME,
        MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun update(context: Context, entries: List<AutofillEntry>) {
        val arr = JSONArray()
        entries.forEach { e ->
            arr.put(JSONObject().apply {
                put("url",      e.url)
                put("login",    e.login)
                put("password", e.password)
            })
        }
        prefs(context).edit().putString(KEY, arr.toString()).apply()
    }

    fun clear(context: Context) {
        prefs(context).edit().remove(KEY).apply()
    }

    fun getEntries(context: Context): List<AutofillEntry> {
        val json = prefs(context).getString(KEY, null) ?: return emptyList()
        return runCatching {
            val arr = JSONArray(json)
            (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                AutofillEntry(
                    url      = o.optString("url"),
                    login    = o.optString("login"),
                    password = o.optString("password")
                )
            }
        }.getOrDefault(emptyList())
    }
}
