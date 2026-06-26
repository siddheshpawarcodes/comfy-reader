import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/dimens.dart';
import '../../models/enums.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/permission_service.dart';
import '../../shared/widgets/permission_rationale_dialog.dart';

/// App-wide preferences, wired to [SettingsProvider]. Every control reads and
/// writes the provider (which persists on change). Themed with tokens only.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _perm = PermissionService();

  /// Hardcoded app version (no `package_info_plus` dependency). Mirrors
  /// `pubspec.yaml` `version: 1.0.0+1`.
  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Dimens.space8),
        children: [
          // ---- Theme ----
          const _SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.space4),
            child: SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_rounded),
                ),
                ButtonSegment(
                  value: AppThemeMode.day,
                  label: Text('Day'),
                  icon: Icon(Icons.light_mode_rounded),
                ),
                ButtonSegment(
                  value: AppThemeMode.night,
                  label: Text('Night'),
                  icon: Icon(Icons.dark_mode_rounded),
                ),
              ],
              selected: {settings.themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  context.read<SettingsProvider>().setThemeMode(s.first),
            ),
          ),

          // ---- Reading ----
          const _SectionHeader('Reading'),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_rounded),
            title: const Text('Page-turn sound'),
            subtitle: const Text('Play a soft flip sound on each turn'),
            value: settings.soundEnabled,
            onChanged: context.read<SettingsProvider>().setSoundEnabled,
          ),
          // Volume — disabled (dimmed, no-op) when sound is off.
          Opacity(
            opacity: settings.soundEnabled ? 1.0 : 0.4,
            child: ListTile(
              leading: Dimens.space6.horizontalSpace,
              title: const Text('Volume'),
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
            title: const Text('Haptics'),
            subtitle: const Text('Gentle buzz on a completed page turn'),
            value: settings.hapticsEnabled,
            onChanged: context.read<SettingsProvider>().setHaptics,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lightbulb_outline_rounded),
            title: const Text('Keep screen on'),
            subtitle: const Text('Prevent the screen sleeping while reading'),
            value: settings.keepScreenOn,
            onChanged: context.read<SettingsProvider>().setKeepScreenOn,
          ),
          // Read-aloud (TTS) speech rate — mirrors the Volume slider above.
          ListTile(
            leading: const Icon(Icons.headphones_rounded),
            title: const Text('Read-aloud speed'),
            subtitle: Slider(
              value: settings.speechRate,
              divisions: 10,
              label: '${(settings.speechRate * 100).round()}%',
              onChanged: context.read<SettingsProvider>().setSpeechRate,
            ),
          ),

          // ---- Default page tint ----
          const _SectionHeader('Default page tint'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.space4),
            child: SegmentedButton<PageTint>(
              segments: const [
                ButtonSegment(
                  value: PageTint.paper,
                  label: Text('Paper'),
                  icon: Icon(Icons.article_rounded),
                ),
                ButtonSegment(
                  value: PageTint.sepia,
                  label: Text('Sepia'),
                  icon: Icon(Icons.coffee_rounded),
                ),
                ButtonSegment(
                  value: PageTint.night,
                  label: Text('Night'),
                  icon: Icon(Icons.nightlight_round),
                ),
              ],
              selected: {settings.pageTint},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  context.read<SettingsProvider>().setPageTint(s.first),
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
              'New books open with this tint. You can still change it per book '
              'from the reader.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // ---- Library (device scan; Android only) ----
          if (_perm.supportsDeviceScan) ...[
            const _SectionHeader('Library'),
            const _RescanTile(perm: _perm),
          ],

          // ---- About ----
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.menu_book_rounded),
            title: Text('Comfy Reader'),
            subtitle: Text("Read like it's a real book."),
            trailing: Text('v$_appVersion'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Open-source licenses'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Comfy Reader',
              applicationVersion: 'v$_appVersion',
            ),
          ),
        ],
      ),
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

    final granted = await StoragePermissionFlow(perm).ensure(context);
    if (!granted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No storage access — tap + to add PDFs.')),
      );
      return;
    }

    final count = await library.scanDevice();
    messenger.showSnackBar(
      SnackBar(
        content:
            Text(count == 0 ? 'No new books found' : 'Found $count book(s)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanning = context.watch<LibraryProvider>().isScanning;
    return ListTile(
      leading: const Icon(Icons.refresh_rounded),
      title: const Text('Rescan device for PDFs'),
      subtitle:
          const Text('Search Downloads, Documents, and Books for new files'),
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
