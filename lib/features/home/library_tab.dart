import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/dimens.dart';
import '../../models/enums.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/tour_service.dart';
import '../../shared/widgets/permission_rationale_dialog.dart';
import 'widgets/add_pdf_fab.dart';
import 'widgets/empty_state.dart';
import 'widgets/library_grid.dart';
import 'widgets/library_list.dart';

/// The "Library" tab: the full collection of imported/scanned books with
/// search, layout toggle, and sort. Lives inside [HomeShell]'s bottom nav.
class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key, this.isActive = true});

  /// Whether this is the visible tab — gates the first-run feature tour.
  final bool isActive;

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  // Showcase coach-mark anchors.
  final _searchKey = GlobalKey();
  final _layoutKey = GlobalKey();
  final _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _scheduleTour();
  }

  @override
  void didUpdateWidget(LibraryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _scheduleTour();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleTour() {
    if (TourService.instance.seen(TourService.home)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
  }

  void _startTour() {
    if (!mounted || TourService.instance.seen(TourService.home)) return;
    TourService.instance.markSeen(TourService.home);
    ShowCaseWidget.of(context).startShowCase([_searchKey, _layoutKey, _fabKey]);
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
    final l10n = context.l10n;
    final granted = await const StoragePermissionFlow().ensure(context);
    if (!granted) {
      // Android-only: the rationale/settings dialogs already explained; nudge
      // toward manual import. (iOS returns granted=true, so it never lands here.)
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.noStorageAccess)),
      );
      return;
    }
    final count = await library.scanDevice();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(count == 0 ? l10n.noNewBooks : l10n.foundBooks(count)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final books = library.filteredSortedBooks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: _searching ? _searchField() : Text(l10n.libraryTitle),
        actions: [
          Showcase(
            key: _searchKey,
            title: l10n.tourSearchTitle,
            description: l10n.tourSearchBody,
            child: IconButton(
              tooltip: _searching ? l10n.closeSearchTooltip : l10n.searchTooltip,
              icon:
                  Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
              onPressed: _toggleSearch,
            ),
          ),
          Showcase(
            key: _layoutKey,
            title: l10n.tourLayoutTitle,
            description: l10n.tourLayoutBody,
            child: IconButton(
              tooltip: l10n.toggleLayoutTooltip,
              icon: Icon(library.view == LibraryView.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded),
              onPressed: library.toggleView,
            ),
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
                    Text(isDark ? l10n.dayTheme : l10n.nightTheme),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              _sortItem('sort_recent', l10n.sortRecent, SortMode.recent),
              _sortItem('sort_name', l10n.sortName, SortMode.name),
              _sortItem('sort_date', l10n.sortDateAdded, SortMode.dateAdded),
            ],
          ),
        ],
      ),
      floatingActionButton: Showcase(
        key: _fabKey,
        title: l10n.tourAddTitle,
        description: l10n.tourAddBody,
        child: const AddPdfFab(),
      ),
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
      decoration: InputDecoration(
        hintText: context.l10n.searchHint,
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
