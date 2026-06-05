package com.passwordmobileapp.app

import android.app.assist.AssistStructure
import android.text.InputType
import android.view.View
import android.view.autofill.AutofillId

class StructureParser(private val structure: AssistStructure) {

    val usernameIds = mutableListOf<AutofillId>()
    val passwordIds = mutableListOf<AutofillId>()
    var webDomain:   String? = null

    fun parse() {
        for (i in 0 until structure.windowNodeCount) {
            parseNode(structure.getWindowNodeAt(i).rootViewNode)
        }
    }

    private fun parseNode(node: AssistStructure.ViewNode) {
        if (webDomain == null) webDomain = node.webDomain?.takeIf { it.isNotBlank() }

        val id = node.autofillId
        if (id != null) {
            val hints = node.autofillHints ?: emptyArray()
            when {
                hints.any { it == View.AUTOFILL_HINT_USERNAME || it == View.AUTOFILL_HINT_EMAIL_ADDRESS } ->
                    usernameIds += id
                hints.any { it == View.AUTOFILL_HINT_PASSWORD } ->
                    passwordIds += id
                isPasswordType(node) -> passwordIds += id
                isUsernameType(node) -> usernameIds += id
            }
        }

        for (i in 0 until node.childCount) parseNode(node.getChildAt(i))
    }

    private fun isPasswordType(node: AssistStructure.ViewNode): Boolean {
        val v = node.inputType and InputType.TYPE_MASK_VARIATION
        return v == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
               v == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD ||
               v == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD
    }

    private fun isUsernameType(node: AssistStructure.ViewNode): Boolean {
        val hint = node.hint?.lowercase() ?: ""
        if (hint.contains("email") || hint.contains("login") ||
            hint.contains("username") || hint.contains("identifiant") ||
            hint.contains("utilisateur")) return true
        val v = node.inputType and InputType.TYPE_MASK_VARIATION
        return v == InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS ||
               v == InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS
    }
}
