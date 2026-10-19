import '../../../l10n/app_localizations.dart';

/// Common reminder delays (in hours), calendar-event-reminder style:
/// 1h, 2h, 4h, 12h, 1 day, 2 days, 3 days, 1 week.
const presetDelaysHours = [1, 2, 4, 12, 24, 48, 72, 168];

/// Human-readable form of a delay in hours, in days once it is an exact
/// multiple of 24 (matches how the presets above are expressed).
String formatDelayHours(AppLocalizations l, int hours) {
  if (hours % 24 == 0) return l.delayInDays(hours ~/ 24);
  return l.delayInHours(hours);
}
