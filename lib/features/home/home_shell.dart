import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../shared/widgets/quit_confirmation_dialog.dart';
import '../settings/settings_screen.dart';
import 'continue_reading_tab.dart';
import 'library_tab.dart';

/// The app's primary surface after splash. Hosts the main sections — Library,
/// Continue Reading, and Settings — behind a Material 3 [NavigationBar]. Each
/// tab is a self-contained screen kept alive in an [IndexedStack] so its scroll
/// position and state survive switching tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0});

  /// Tab shown first: 0 = Library, 1 = Continue Reading, 2 = Settings.
  final int initialTab;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const int _tabCount = 3;

  late int _index = widget.initialTab.clamp(0, _tabCount - 1);

  void _onSelect(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final shouldQuit = await QuitConfirmationDialog.show(context);
    if (shouldQuit) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    // Built per-frame so each tab learns whether it's the visible one (drives
    // its first-run feature tour, since IndexedStack keeps tabs mounted).
    final tabs = <Widget>[
      LibraryTab(isActive: _index == 0),
      const ContinueReadingTab(),
      SettingsScreen(isActive: _index == 2),
    ];
    return PopScope(
      // This is the app's root screen (no back stack beneath it), so an
      // intercepted pop here means the user is trying to leave the app —
      // confirm before letting SystemNavigator.pop() close it.
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        // Wrap each tab in HeroMode so only the visible tab's heroes can take
        // part in a flight. The IndexedStack keeps every tab mounted, so without
        // this an offstage tab's cover hero could fly when opening a book from a
        // different tab (wrong source rect) and destabilize the transition.
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < tabs.length; i++)
              HeroMode(enabled: _index == i, child: tabs[i]),
          ],
        ),
        // A hairline divider keeps the flat (elevation-0) nav bar visually
        // separated from the body content above it.
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onSelect,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.local_library_outlined),
                selectedIcon: const Icon(Icons.local_library_rounded),
                label: l10n.navLibrary,
              ),
              NavigationDestination(
                icon: const Icon(Icons.auto_stories_outlined),
                selectedIcon: const Icon(Icons.auto_stories_rounded),
                label: l10n.navReading,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: l10n.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
