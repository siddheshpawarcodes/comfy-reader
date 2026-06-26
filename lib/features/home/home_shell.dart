import 'package:flutter/material.dart';

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
  static const List<Widget> _tabs = <Widget>[
    LibraryTab(),
    ContinueReadingTab(),
    SettingsScreen(),
  ];

  late int _index = widget.initialTab.clamp(0, _tabs.length - 1);

  void _onSelect(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.local_library_outlined),
              selectedIcon: Icon(Icons.local_library_rounded),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Reading',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
