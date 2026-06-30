import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../shared/utils/legal_urls.dart';
import '../../../l10n/app_localizations.dart';
import '../services/settings_service.dart';

class PrivacySettingsPanel extends StatefulWidget {
  const PrivacySettingsPanel({super.key});

  @override
  State<PrivacySettingsPanel> createState() => _PrivacySettingsPanelState();
}

class _PrivacySettingsPanelState extends State<PrivacySettingsPanel> {
  int _clipboardSeconds = SettingsService.defaultClipboardClearSeconds;
  bool _biometricEnabled = true;
  bool _maskInBackground = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final seconds    = await SettingsService.getClipboardClearSeconds();
    final biometric  = await SettingsService.getBiometricEnabled();
    final masking    = await SettingsService.getMaskInBackground();
    if (mounted) {
      setState(() {
        _clipboardSeconds  = seconds;
        _biometricEnabled  = biometric;
        _maskInBackground  = masking;
        _loading           = false;
      });
    }
  }

  Future<void> _saveClipboardSeconds(int seconds) async {
    await SettingsService.setClipboardClearSeconds(seconds);
    if (mounted) setState(() => _clipboardSeconds = seconds);
  }

  Future<void> _setBiometricEnabled(bool enabled) async {
    await SettingsService.setBiometricEnabled(enabled);
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  Future<void> _setMaskInBackground(bool enabled) async {
    await SettingsService.setMaskInBackground(enabled);
    if (enabled) {
      await ScreenProtector.protectDataLeakageOn();
    } else {
      await ScreenProtector.protectDataLeakageOff();
    }
    if (mounted) setState(() => _maskInBackground = enabled);
  }

  String _clipboardLabel(BuildContext context, int seconds) {
    final l = AppLocalizations.of(context)!;
    switch (seconds) {
      case 10:  return l.clipboardClear10s;
      case 30:  return l.clipboardClear30s;
      case 60:  return l.clipboardClear1min;
      case 120: return l.clipboardClear2min;
      default:  return '$seconds s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.titlePrivacy,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Text(l.titleClipboardClear, style: Theme.of(context).textTheme.titleSmall),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Text(l.subtitleClipboardClear,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            RadioGroup<int>(
              groupValue: _clipboardSeconds,
              onChanged: (v) { if (v != null) _saveClipboardSeconds(v); },
              child: Column(
                children: SettingsService.clipboardClearOptions.map((seconds) {
                  return RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_clipboardLabel(context, seconds)),
                    value: seconds,
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.titleBiometricToggle),
              subtitle: Text(l.subtitleBiometricToggle),
              value: _biometricEnabled,
              onChanged: _setBiometricEnabled,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.titleScreenMasking),
              subtitle: Text(l.subtitleScreenMasking),
              value: _maskInBackground,
              onChanged: _setMaskInBackground,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.policy_outlined),
              title: Text(l.linkPrivacyPolicy),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => launchUrl(
                Uri.parse(privacyPolicyUrl(context)),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
