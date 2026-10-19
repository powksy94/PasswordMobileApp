import 'package:flutter/material.dart';
import '../../auth/services/auth_exceptions.dart';
import '../../auth/services/auth_service.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/utils/error_message.dart';
import '../../../shared/widgets/common/app_page_scaffold.dart';
import '../widgets/reminder_delay_tile.dart';
import '../../../l10n/app_localizations.dart';

class WeakRemindersSettingsPage extends StatefulWidget {
  const WeakRemindersSettingsPage({super.key});

  @override
  State<WeakRemindersSettingsPage> createState() => _WeakRemindersSettingsPageState();
}

class _WeakRemindersSettingsPageState extends State<WeakRemindersSettingsPage> {
  bool _loading = true;
  bool _enabled = true;
  bool _includeMedium = true;
  List<int> _delaysHours = [4, 24, 48];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw NotAuthenticatedException();
      final settings = await ApiService().getWeakReminderSettings(token);
      if (!mounted) return;
      setState(() {
        _enabled       = settings['enabled'] as bool;
        _includeMedium = settings['includeMedium'] as bool;
        _delaysHours   = (settings['delaysHours'] as List).cast<int>();
        _loading       = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _snack(errorMessage(AppLocalizations.of(context)!, e));
      }
    }
  }

  Future<void> _save({
    required bool enabled,
    required bool includeMedium,
    required List<int> delaysHours,
  }) async {
    final previous = (_enabled, _includeMedium, _delaysHours);
    setState(() {
      _enabled       = enabled;
      _includeMedium = includeMedium;
      _delaysHours   = delaysHours;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw NotAuthenticatedException();
      await ApiService().updateWeakReminderSettings(
        token,
        enabled:       enabled,
        includeMedium: includeMedium,
        delaysHours:   delaysHours,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enabled       = previous.$1;
        _includeMedium = previous.$2;
        _delaysHours   = previous.$3;
      });
      _snack(errorMessage(AppLocalizations.of(context)!, e));
    }
  }

  void _onDelayChanged(int stageIndex, int hours) {
    final l = AppLocalizations.of(context)!;
    final updated = [..._delaysHours];
    updated[stageIndex] = hours;
    for (var i = 1; i < updated.length; i++) {
      if (updated[i] <= updated[i - 1]) {
        _snack(l.errorDelaysNotIncreasing);
        return;
      }
    }
    _save(enabled: _enabled, includeMedium: _includeMedium, delaysHours: updated);
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AppPageScaffold(
      title:    l.titleWeakReminders,
      safeArea: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title:    Text(l.titleWeakRemindersEnabled),
                  subtitle: Text(l.subtitleWeakRemindersEnabled),
                  value:    _enabled,
                  onChanged: (v) => _save(
                    enabled: v, includeMedium: _includeMedium, delaysHours: _delaysHours,
                  ),
                ),
                SwitchListTile(
                  title:    Text(l.titleWeakRemindersIncludeMedium),
                  subtitle: Text(l.subtitleWeakRemindersIncludeMedium),
                  value:    _includeMedium,
                  onChanged: (v) => _save(
                    enabled: _enabled, includeMedium: v, delaysHours: _delaysHours,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l.titleWeakReminderDelays, style: Theme.of(context).textTheme.titleMedium),
                ),
                for (var i = 0; i < _delaysHours.length; i++)
                  ReminderDelayTile(
                    stageNumber: i + 1,
                    delayHours:  _delaysHours[i],
                    onChanged:   (hours) => _onDelayChanged(i, hours),
                  ),
              ],
            ),
    );
  }
}
