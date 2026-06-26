import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/dimens.dart';
import '../../models/enums.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../shared/widgets/permission_rationale_dialog.dart';
import 'widgets/add_pdf_fab.dart';
import 'widgets/empty_state.dart';
import 'widgets/library_grid.dart';
import 'widgets/library_list.dart';

/// The "Library" tab: the full collection of imported/scanned books with
/// search, layout toggle, and sort. Lives inside [HomeShell]'s bottom nav.
class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchController.clear();
        context.read<LibraryProvider>().setSearchQuery('');
      }
    });
  }

  void _toggleTheme() {
    final s = context.read<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    s.setThemeMode(isDark ? AppThemeMode.day : AppThemeMode.night);
  }

  Future<void> _onRefresh() async {
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final granted = await const StoragePermissionFlow().ensure(context);
    if (!granted) {
      // Android-only: the rationale/settings dialogs already explained; nudge
      // toward manual import. (iOS returns granted=true, so it never lands here.)
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No storage access — tap + to add PDFs.'),
        ),
      );
      return;
    }
    final count = await library.scanDevice();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(count == 0 ? 'No new books found' : 'Found $count book(s)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final books = library.filteredSortedBooks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _searching ? _searchField() : const Text('Library'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search',
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
          IconButton(
            tooltip: 'Toggle layout',
            icon: Icon(library.view == LibraryView.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
            onPressed: library.toggleView,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _onMenu,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded),
                    Dimens.space3.horizontalSpace,
                    Text(isDark ? 'Day theme' : 'Night theme'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              _sortItem('sort_recent', 'Sort: Recent', SortMode.recent),
              _sortItem('sort_name', 'Sort: Name', SortMode.name),
              _sortItem('sort_date', 'Sort: Date added', SortMode.dateAdded),
            ],
          ),
        ],
      ),
      floatingActionButton: const AddPdfFab(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (library.isScanning)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
            if (books.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: EmptyState(
                    isSearch: library.searchQuery.isNotEmpty,
                  ),
                ),
              )
            else if (library.view == LibraryView.grid)
              LibraryGrid(books: books)
            else
              LibraryList(books: books),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search titles…',
        border: InputBorder.none,
      ),
      style: Theme.of(context).textTheme.titleMedium,
      onChanged: (q) => context.read<LibraryProvider>().setSearchQuery(q),
    );
  }

  PopupMenuItem<String> _sortItem(String value, String label, SortMode mode) {
    final current = context.read<LibraryProvider>().sort == mode;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            Icons.check_rounded,
            size: 18,
            color: current ? null : Colors.transparent,
          ),
          Dimens.space2.horizontalSpace,
          Text(label),
        ],
      ),
    );
  }

  void _onMenu(String value) {
    final library = context.read<LibraryProvider>();
    switch (value) {
      case 'theme':
        _toggleTheme();
      case 'sort_recent':
        library.setSort(SortMode.recent);
      case 'sort_name':
        library.setSort(SortMode.name);
      case 'sort_date':
        library.setSort(SortMode.dateAdded);
    }
  }
}
