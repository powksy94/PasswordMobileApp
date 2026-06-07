import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../services/settings_service.dart';

class LockTimeoutPanel extends StatefulWidget {
  final VoidCallback? onChanged;

  const LockTimeoutPanel({super.key, this.onChanged});

  @override
  State<LockTimeoutPanel> createState() => _LockTimeoutPanelState();
}

class _LockTimeoutPanelState extends State<LockTimeoutPanel> {
  int _selectedMinutes = SettingsService.defaultTimeout;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await SettingsService.getLockTimeout();
    if (mounted) setState(() { _selectedMinutes = v; _loading = false; });
  }

  Future<void> _save(int minutes) async {
    await SettingsService.setLockTimeout(minutes);
    if (mounted) {
      setState(() => _selectedMinutes = minutes);
      widget.onChanged?.call();
    }
  }

  String _label(BuildContext context, int minutes) {
    final l = AppLocalizations.of(context)!;
    switch (minutes) {
      case -1: return l.lockTimeoutNever;
      case 1:  return l.lockTimeout1min;
      case 5:  return l.lockTimeout5min;
      case 15: return l.lockTimeout15min;
      case 30: return l.lockTimeout30min;
      case 60: return l.lockTimeout1h;
      default: return '$minutes min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(l.titleLockTimeout, style: theme.textTheme.titleMedium),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          RadioGroup<int>(
            groupValue: _selectedMinutes,
            onChanged: (v) { if (v != null) _save(v); },
            child: Column(
              children: SettingsService.timeoutOptions.map((minutes) {
                return RadioListTile<int>(
                  title: Text(_label(context, minutes)),
                  value: minutes,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
