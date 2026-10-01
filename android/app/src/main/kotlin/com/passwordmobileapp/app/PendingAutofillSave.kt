package com.passwordmobileapp.app

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import org.json.JSONObject

data class PendingSave(val domain: String, val password: String)

/**
 * Holds at most one generated password awaiting confirmation in the Flutter app
 * (see ANDROID_AUTOFILL_SUGGESTION.md): onSaveRequest only queues it here - the
 * real network write to the vault happens later, from the running app, once the
 * vault is unlocked, reusing VaultService.addToServer as-is.
 *
 * Same encryption-at-rest mechanism as AutofillCache.kt, separate file/key: this
 * is a different concern (one pending write, not a read cache of the vault).
 */
object PendingAutofillSave {
    private const val PREFS_NAME = "autofill_pending_save"
    private const val KEY        = "entry"

    private fun prefs(context: Context) = EncryptedSharedPreferences.create(
        context,
        PREFS_NAME,
        MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun queue(context: Context, domain: String, password: String) {
        val json = JSONObject().apply {
            put("domain",   domain)
            put("password", password)
        }
        prefs(context).edit().putString(KEY, json.toString()).apply()
    }

    /** Returns the pending entry and clears it in the same call: consumed at most once. */
    fun consume(context: Context): PendingSave? {
        val p = prefs(context)
        val json = p.getString(KEY, null) ?: return null
        p.edit().remove(KEY).apply()
        return runCatching {
            val o = JSONObject(json)
            PendingSave(domain = o.getString("domain"), password = o.getString("password"))
        }.getOrNull()
    }
}
