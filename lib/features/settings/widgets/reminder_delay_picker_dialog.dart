import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../utils/reminder_delay_format.dart';

/// Dialog for one reminder's delay: common presets (calendar-event-reminder
/// style) or a custom number + unit entry. Returns the chosen delay in
/// hours, or null if cancelled.
class ReminderDelayPickerDialog extends StatefulWidget {
  final int initialHours;

  const ReminderDelayPickerDialog({super.key, required this.initialHours});

  @override
  State<ReminderDelayPickerDialog> createState() => _ReminderDelayPickerDialogState();
}

class _ReminderDelayPickerDialogState extends State<ReminderDelayPickerDialog> {
  bool _customMode = false;
  int? _selectedPreset;

  final _customValueCtrl = TextEditingController();
  bool _customInDays = false;

  @override
  void initState() {
    super.initState();
    if (presetDelaysHours.contains(widget.initialHours)) {
      _selectedPreset = widget.initialHours;
    } else {
      _customMode = true;
      _customInDays = widget.initialHours % 24 == 0;
      _customValueCtrl.text =
          (_customInDays ? widget.initialHours ~/ 24 : widget.initialHours).toString();
    }
  }

  @override
  void dispose() {
    _customValueCtrl.dispose();
    super.dispose();
  }

  int? get _customHours {
    final value = int.tryParse(_customValueCtrl.text);
    if (value == null || value <= 0) return null;
    return _customInDays ? value * 24 : value;
  }

  int? get _chosenHours => _customMode ? _customHours : _selectedPreset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.titleWeakReminderDelays),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_customMode) ...[
              RadioGroup<int>(
                groupValue: _selectedPreset,
                onChanged: (v) => setState(() => _selectedPreset = v),
                child: Column(
                  children: presetDelaysHours.map((hours) {
                    return RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(formatDelayHours(l, hours)),
                      value: hours,
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.optionCustomDelay),
                onTap: () => setState(() => _customMode = true),
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customValueCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<bool>(
                    value: _customInDays,
                    items: [
                      DropdownMenuItem(value: false, child: Text(l.labelDelayHours)),
                      DropdownMenuItem(value: true, child: Text(l.labelDelayDays)),
                    ],
                    onChanged: (v) => setState(() => _customInDays = v ?? _customInDays),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.btnCancel),
        ),
        TextButton(
          onPressed: _chosenHours != null ? () => Navigator.pop(context, _chosenHours) : null,
          child: Text(l.btnSave),
        ),
      ],
    );
  }
}
