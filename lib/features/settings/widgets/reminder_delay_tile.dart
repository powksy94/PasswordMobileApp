import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../utils/reminder_delay_format.dart';
import './reminder_delay_picker_dialog.dart';

/// One "Reminder N" row: shows the current delay, tapping it opens
/// [ReminderDelayPickerDialog]. Reports the chosen delay (in hours) via
/// [onChanged]; does not persist anything itself.
class ReminderDelayTile extends StatelessWidget {
  final int stageNumber;
  final int delayHours;
  final ValueChanged<int> onChanged;

  const ReminderDelayTile({
    super.key,
    required this.stageNumber,
    required this.delayHours,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final chosen = await showDialog<int>(
      context: context,
      builder: (_) => ReminderDelayPickerDialog(initialHours: delayHours),
    );
    if (chosen != null) onChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l.labelReminderStage(stageNumber)),
      subtitle: Text(formatDelayHours(l, delayHours)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _pick(context),
    );
  }
}
