package com.passwordmobileapp.app

import android.os.CancellationSignal
import android.service.autofill.*
import android.util.Log
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews

class VaultAutofillService : AutofillService() {

    companion object { private const val TAG = "VaultAutofillService" }

    override fun onFillRequest(
        request:            FillRequest,
        cancellationSignal: CancellationSignal,
        callback:           FillCallback
    ) {
        val structure = request.fillContexts.lastOrNull()?.structure
            ?: return callback.onSuccess(null)

        val parser = StructureParser(structure)
        parser.parse()

        Log.d(TAG, "passwordIds=${parser.passwordIds.size} usernameIds=${parser.usernameIds.size} webDomain=${parser.webDomain}")

        if (parser.passwordIds.isEmpty()) {
            Log.d(TAG, "No password fields found — skipping")
            return callback.onSuccess(null)
        }

        val domain = parser.webDomain?.takeIf { it.isNotBlank() }
            ?: run { Log.d(TAG, "No webDomain — skipping"); return callback.onSuccess(null) }

        val entries = AutofillCache.getEntries(this)
        Log.d(TAG, "Cache has ${entries.size} entries. Looking for domain=$domain")
        entries.forEach { Log.d(TAG, "  entry url=${it.url}") }

        val matches = entries.filter { entry ->
            entry.url.isNotBlank() && domainsMatch(entry.url, domain)
        }

        Log.d(TAG, "Matches found: ${matches.size}")
        if (matches.isEmpty()) return callback.onSuccess(null)

        val responseBuilder = FillResponse.Builder()
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
            responseBuilder.addDataset(datasetBuilder.build())
        }

        callback.onSuccess(responseBuilder.build())
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        callback.onSuccess()
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
}
