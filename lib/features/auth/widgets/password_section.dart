import 'package:flutter/material.dart';
import '../../../shared/widgets/common/password_strength_bar.dart';
import '../../../l10n/app_localizations.dart';

class PasswordSection extends StatefulWidget {
  final String                      label;
  final TextEditingController       controller;
  final TextEditingController       confirmController;
  final int                         minLength;
  final bool                        showToggle;
  final String?                     warningText;
  final bool                        withInfoIcon;
  final FormFieldValidator<String>? confirmValidator;

  const PasswordSection({
    super.key,
    required this.label,
    required this.controller,
    required this.confirmController,
    required this.minLength,
    this.showToggle    = false,
    this.warningText,
    this.withInfoIcon  = false,
    this.confirmValidator,
  });

  @override
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill   = isDark ? Colors.white10 : Colors.black12;
    final sub    = isDark ? Colors.white54 : Colors.black45;

    final fieldLabel   = widget.withInfoIcon ? l.labelMasterPassword : l.labelPassword;
    final confirmLabel = widget.withInfoIcon
        ? l.labelConfirmMasterPassword
        : l.labelConfirmPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.withInfoIcon)
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: sub),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color:      sub,
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            widget.label,
            style: TextStyle(
              color:      sub,
              fontSize:   12,
              fontWeight: FontWeight.w600,
            ),
          ),

        if (widget.warningText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.warningText!,
            style: TextStyle(
              color:    Colors.orangeAccent.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),

        TextFormField(
          controller:  widget.controller,
          obscureText: !_showPassword,
          onChanged:   (_) => setState(() {}),
          validator: (v) => v != null && v.length >= widget.minLength
              ? null
              : '${widget.minLength} ${l.validatorMinCharsUnit}',
          decoration: InputDecoration(
            labelText:  fieldLabel,
            prefixIcon: Icon(
              widget.withInfoIcon ? Icons.vpn_key_outlined : Icons.lock_outline,
            ),
            filled:    true,
            fillColor: fill,
            suffixIcon: widget.showToggle
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        PasswordStrengthBar(password: widget.controller.text),
        const SizedBox(height: 8),

        TextFormField(
          controller:  widget.confirmController,
          obscureText: true,
          validator:   widget.confirmValidator,
          decoration: InputDecoration(
            labelText:  confirmLabel,
            prefixIcon: Icon(
              widget.withInfoIcon ? Icons.vpn_key_outlined : Icons.lock_outline,
            ),
            filled:    true,
            fillColor: fill,
          ),
        ),
      ],
    );
  }
}
