import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../core/l10n/app_locales.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/dimens.dart';
import '../../models/enums.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/permission_service.dart';
import '../../services/tour_service.dart';
import '../../shared/widgets/permission_rationale_dialog.dart';

/// App-wide preferences, wired to [SettingsProvider]. Every control reads and
/// writes the provider (which persists on change). Themed with tokens only.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.isActive = true});

  /// Whether this tab is the visible one in the home shell. Used to start the
  /// feature tour only when the user actually lands on Settings (the tab is
  /// kept mounted offstage inside an IndexedStack).
  final bool isActive;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _perm = PermissionService();

  /// Hardcoded app version (no `package_info_plus` dependency). Mirrors
  /// `pubspec.yaml` `version: 1.0.0+1`.
  static const String _appVersion = '1.0.0';

  // Showcase coach-mark anchors.
  final _themeKey = GlobalKey();
  final _languageKey = GlobalKey();
  final _voicesKey = GlobalKey();
  final _tintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _scheduleTour();
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fired when the user switches to the Settings tab.
    if (widget.isActive && !oldWidget.isActive) _scheduleTour();
  }

  void _scheduleTour() {
    if (TourService.instance.seen(TourService.settings)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
  }

  void _startTour() {
    if (!mounted || TourService.instance.seen(TourService.settings)) return;
    TourService.instance.markSeen(TourService.settings);
    ShowCaseWidget.of(context).startShowCase(
      [_themeKey, _languageKey, _voicesKey, _tintKey],
    );
  }

  void _replayTours() {
    TourService.instance.resetAll();
    // The Settings tour is shown right now; Library/Reader replay on next visit.
    TourService.instance.markSeen(TourService.settings);
    ShowCaseWidget.of(context).startShowCase(
      [_themeKey, _languageKey, _voicesKey, _tintKey],
    );
  }

  /// Bottom sheet to choose the app UI language (native names).
  Future<void> _pickLanguage() async {
    final settings = context.read<SettingsProvider>();
    final current = settings.locale.languageCode;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (code) {
            if (code != null) settings.setLocale(Locale(code));
            Navigator.of(sheetCtx).pop();
          },
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimens.space4,
                  0,
                  Dimens.space4,
                  Dimens.space2,
                ),
                child: Text(
                  sheetCtx.l10n.chooseLanguage,
                  style: Theme.of(sheetCtx).textTheme.titleMedium,
                ),
              ),
              for (final l in kAppLocales)
                RadioListTile<String>(
                  value: l.locale.languageCode,
                  title: Text(l.nativeName),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Dimens.space8),
        children: [
          // ---- Theme ----
          _SectionHeader(l10n.appearance),
          Showcase(
            key: _themeKey,
            title: l10n.tourThemeTitle,
            description: l10n.tourThemeBody,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.space4),
              child: SegmentedButton<AppThemeMode>(
                segments: [
                  ButtonSegment(
                    value: AppThemeMode.system,
                    label: _SegLabel(l10n.themeSystem),
                    icon: const Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.day,
                    label: _SegLabel(l10n.themeDay),
                    icon: const Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.night,
                    label: _SegLabel(l10n.themeNight),
                    icon: const Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: {settings.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    context.read<SettingsProvider>().setThemeMode(s.first),
              ),
            ),
          ),

          // ---- App language ----
          _SectionHeader(l10n.appLanguage),
          Showcase(
            key: _languageKey,
            title: l10n.tourLanguageTitle,
            description: l10n.tourLanguageBody,
            child: ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(l10n.appLanguage),
              subtitle: Text(l10n.appLanguageSub),
              trailing: Text(
                nativeLanguageName(settings.locale.languageCode),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              onTap: _pickLanguage,
            ),
          ),

          // ---- Reading ----
          _SectionHeader(l10n.reading),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_rounded),
            title: Text(l10n.pageTurnSound),
            subtitle: Text(l10n.pageTurnSoundSub),
            value: settings.soundEnabled,
            onChanged: context.read<SettingsProvider>().setSoundEnabled,
          ),
          // Volume — disabled (dimmed, no-op) when sound is off.
          Opacity(
            opacity: settings.soundEnabled ? 1.0 : 0.4,
            child: ListTile(
              leading: Dimens.space6.horizontalSpace,
              title: Text(l10n.volume),
              subtitle: Slider(
                value: settings.soundVolume,
                divisions: 10,
                label: '${(settings.soundVolume * 100).round()}%',
                onChanged: settings.soundEnabled
                    ? context.read<SettingsProvider>().setSoundVolume
                    : null,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_rounded),
            title: Text(l10n.haptics),
            subtitle: Text(l10n.hapticsSub),
            value: settings.hapticsEnabled,
            onChanged: context.read<SettingsProvider>().setHaptics,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lightbulb_outline_rounded),
            title: Text(l10n.keepScreenOn),
            subtitle: Text(l10n.keepScreenOnSub),
            value: settings.keepScreenOn,
            onChanged: context.read<SettingsProvider>().setKeepScreenOn,
          ),
          // Read-aloud (TTS) speech rate — mirrors the Volume slider above.
          ListTile(
            leading: const Icon(Icons.headphones_rounded),
            title: Text(l10n.readAloudSpeed),
            subtitle: Slider(
              value: settings.speechRate,
              divisions: 10,
              label: '${(settings.speechRate * 100).round()}%',
              onChanged: context.read<SettingsProvider>().setSpeechRate,
            ),
          ),
          Showcase(
            key: _voicesKey,
            title: l10n.tourVoicesTitle,
            description: l10n.tourVoicesBody,
            child: ListTile(
              leading: const Icon(Icons.record_voice_over_rounded),
              title: Text(l10n.readAloudVoices),
              subtitle: Text(l10n.readAloudVoicesSub),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/voices'),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.document_scanner_rounded),
            title: Text(l10n.readScannedBooks),
            subtitle: Text(l10n.readScannedBooksSub),
            value: settings.readScannedBooks,
            onChanged: context.read<SettingsProvider>().setReadScannedBooks,
          ),

          // ---- Default page tint ----
          _SectionHeader(l10n.defaultPageTint),
          Showcase(
            key: _tintKey,
            title: l10n.tourTintTitle,
            description: l10n.tourTintBody,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.space4),
              child: SegmentedButton<PageTint>(
                segments: [
                  ButtonSegment(
                    value: PageTint.paper,
                    label: _SegLabel(l10n.tintPaper),
                    icon: const Icon(Icons.article_rounded),
                  ),
                  ButtonSegment(
                    value: PageTint.sepia,
                    label: _SegLabel(l10n.tintSepia),
                    icon: const Icon(Icons.coffee_rounded),
                  ),
                  ButtonSegment(
                    value: PageTint.night,
                    label: _SegLabel(l10n.tintNight),
                    icon: const Icon(Icons.nightlight_round),
                  ),
                ],
                selected: {settings.pageTint},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    context.read<SettingsProvider>().setPageTint(s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimens.space4,
              Dimens.space2,
              Dimens.space4,
              0,
            ),
            child: Text(
              l10n.defaultPageTintNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // ---- Library (device scan; Android only) ----
          if (_perm.supportsDeviceScan) ...[
            _SectionHeader(l10n.librarySection),
            const _RescanTile(perm: _perm),
          ],

          // ---- About ----
          _SectionHeader(l10n.about),
          ListTile(
            leading: const Icon(Icons.replay_rounded),
            title: Text(l10n.takeTourAgain),
            subtitle: Text(l10n.takeTourAgainSub),
            onTap: _replayTours,
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.appTagline),
            trailing: Text(l10n.appVersion(_appVersion)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.openSourceLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: l10n.appVersion(_appVersion),
            ),
          ),
        ],
      ),
    );
  }
}

/// A segmented-button label that shrinks to fit instead of clipping when a
/// translated word is longer than the segment — keeps multilingual labels tidy.
class _SegLabel extends StatelessWidget {
  const _SegLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, softWrap: false),
    );
  }
}

/// A small, muted section header above a group of settings.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.space4,
        Dimens.space6,
        Dimens.space4,
        Dimens.space2,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// "Rescan device for PDFs" — runs the permission rationale → request →
/// [LibraryProvider.scanDevice] flow, reporting results via snackbars.
class _RescanTile extends StatelessWidget {
  const _RescanTile({required this.perm});

  final PermissionService perm;

  Future<void> _rescan(BuildContext context) async {
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    final granted = await StoragePermissionFlow(perm).ensure(context);
    if (!granted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.noStorageAccess)),
      );
      return;
    }

    final count = await library.scanDevice();
    messenger.showSnackBar(
      SnackBar(
        content: Text(count == 0 ? l10n.noNewBooks : l10n.foundBooks(count)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanning = context.watch<LibraryProvider>().isScanning;
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.refresh_rounded),
      title: Text(l10n.rescanTitle),
      subtitle: Text(l10n.rescanSub),
      trailing: scanning
          ? SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: scanning ? null : () => _rescan(context),
    );
  }
}
