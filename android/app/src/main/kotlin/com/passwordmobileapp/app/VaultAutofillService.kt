package com.passwordmobileapp.app

import android.app.PendingIntent
import android.app.assist.AssistStructure
import android.content.Intent
import android.os.CancellationSignal
import android.service.autofill.*
import android.util.Log
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews

class VaultAutofillService : AutofillService() {

    companion object {
        private const val TAG = "VaultAutofillService"

        /** Shared with [MainActivity]: marks the intent that launches it as an
         *  autofill authentication/generation request rather than a normal app open. */
        const val ACTION_AUTOFILL_GENERATE = "com.passwordmobileapp.app.ACTION_AUTOFILL_GENERATE"
        const val EXTRA_NEW_PASSWORD_IDS   = "new_password_ids"
    }

    override fun onFillRequest(
        request:            FillRequest,
        cancellationSignal: CancellationSignal,
        callback:           FillCallback
    ) {
        val structure = request.fillContexts.lastOrNull()?.structure
            ?: return callback.onSuccess(null)

        val parser = StructureParser(structure)
        parser.parse()

        Log.d(TAG, "passwordIds=${parser.passwordIds.size} newPasswordIds=${parser.newPasswordIds.size} " +
            "usernameIds=${parser.usernameIds.size} webDomain=${parser.webDomain}")

        val responseBuilder = FillResponse.Builder()
        var hasSuggestion = false

        if (parser.newPasswordIds.isNotEmpty()) {
            addGenerateSuggestion(responseBuilder, parser.newPasswordIds)
            hasSuggestion = true
        }

        if (parser.passwordIds.isNotEmpty()) {
            val domain = parser.webDomain?.takeIf { it.isNotBlank() }
            if (domain == null) {
                Log.d(TAG, "No webDomain - skipping existing-credential fill")
            } else {
                val entries = AutofillCache.getEntries(this)
                Log.d(TAG, "Cache has ${entries.size} entries. Looking for domain=$domain")
                val matches = entries.filter { it.url.isNotBlank() && domainsMatch(it.url, domain) }
                Log.d(TAG, "Matches found: ${matches.size}")
                if (matches.isNotEmpty()) {
                    addFillDatasets(responseBuilder, parser, matches)
                    hasSuggestion = true
                }
            }
        }

        if (!hasSuggestion) return callback.onSuccess(null)
        callback.onSuccess(responseBuilder.build())
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        val structure = request.fillContexts.lastOrNull()?.structure
        if (structure == null) { callback.onSuccess(); return }

        val parser = StructureParser(structure)
        parser.parse()

        val password = parser.newPasswordIds
            .mapNotNull { findValue(structure, it) }
            .firstOrNull { it.isNotBlank() }

        if (password != null) {
            val domain = parser.webDomain?.takeIf { it.isNotBlank() } ?: resolveAppLabel(structure)
            PendingAutofillSave.queue(this, domain ?: "?", password)
            Log.d(TAG, "Queued a generated password for later confirmation (domain=$domain)")
        }

        // Always succeeds here: the real encrypted write happens from the running
        // app (see PendingAutofillSave), never from this background callback.
        callback.onSuccess()
    }

    // -- Existing-credential fill ------------------------------------------------

    private fun addFillDatasets(
        builder: FillResponse.Builder,
        parser:  StructureParser,
        matches: List<AutofillEntry>,
    ) {
        matches.forEach { entry ->
            val label = entry.login.ifBlank { entry.url }
            val presentation = RemoteViews(packageName, android.R.layout.simple_list_item_1).apply {
                setTextViewText(android.R.id.text1, label)
            }

            val datasetBuilder = Dataset.Builder()
            parser.usernameIds.forEach { id ->
                datasetBuilder.setValue(id, AutofillValue.forText(entry.login), presentation)
            }
            parser.passwordIds.forEach { id ->
                datasetBuilder.setValue(id, AutofillValue.forText(entry.password), presentation)
            }
            builder.addDataset(datasetBuilder.build())
        }
    }

    private fun domainsMatch(storedUrl: String, requestDomain: String): Boolean {
        val stored = storedUrl
            .removePrefix("https://").removePrefix("http://").removePrefix("www.")
            .split("/").first().lowercase().trimEnd('.')
        val request = requestDomain.removePrefix("www.").lowercase().trimEnd('.')
        return stored == request ||
               request.endsWith(".$stored") ||
               stored.endsWith(".$request")
    }

    // -- New-password generation --------------------------------------------------

    /**
     * Offers a "Generate a strong password" suggestion gated behind the app's own
     * unlock screen: selecting it launches MainActivity (via setAuthentication),
     * which runs the real LockScreen/BiometricUnlockService flow before generating
     * anything - no native biometric prompt duplicated here. setSaveInfo is what
     * makes Android actually call onSaveRequest once the third-party form is
     * submitted; without it the save callback below is unreachable dead code.
     */
    private fun addGenerateSuggestion(builder: FillResponse.Builder, ids: List<AutofillId>) {
        val idArray = ids.toTypedArray()

        val presentation = RemoteViews(packageName, android.R.layout.simple_list_item_1).apply {
            setTextViewText(android.R.id.text1, "Generate a strong password")
        }

        val authIntent = Intent(this, MainActivity::class.java).apply {
            action = ACTION_AUTOFILL_GENERATE
            putExtra(EXTRA_NEW_PASSWORD_IDS, idArray)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        // FLAG_MUTABLE: the autofill framework adds its own extras (assist structure,
        // client state) to this intent before launching MainActivity with it.
        val intentSender = PendingIntent.getActivity(
            this,
            idArray.contentHashCode(),
            authIntent,
            PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_MUTABLE
        ).intentSender

        builder
            .setAuthentication(idArray, intentSender, presentation)
            .setSaveInfo(SaveInfo.Builder(SaveInfo.SAVE_DATA_TYPE_PASSWORD, idArray).build())
    }

    private fun findValue(structure: AssistStructure, target: AutofillId): String? {
        for (i in 0 until structure.windowNodeCount) {
            val found = findValueInNode(structure.getWindowNodeAt(i).rootViewNode, target)
            if (found != null) return found
        }
        return null
    }

    private fun findValueInNode(node: AssistStructure.ViewNode, target: AutofillId): String? {
        if (node.autofillId == target) {
            return node.autofillValue?.takeIf { it.isText }?.textValue?.toString()
        }
        for (i in 0 until node.childCount) {
            val found = findValueInNode(node.getChildAt(i), target)
            if (found != null) return found
        }
        return null
    }

    private fun resolveAppLabel(structure: AssistStructure): String? {
        val pkg = structure.activityComponent?.packageName ?: return null
        return runCatching {
            packageManager.getApplicationLabel(packageManager.getApplicationInfo(pkg, 0)).toString()
        }.getOrDefault(pkg)
    }
}
