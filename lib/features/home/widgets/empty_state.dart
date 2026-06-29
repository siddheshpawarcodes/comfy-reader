import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/dimens.dart';

/// Friendly empty states: an empty library vs. no search matches.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.isSearch = false});

  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final title = isSearch ? l10n.emptyNoMatches : l10n.emptyNoBooks;
    final subtitle =
        isSearch ? l10n.emptyTryDifferent : l10n.emptyNoBooksBody;
    return Padding(
      padding: const EdgeInsets.all(Dimens.space8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Dimens.space6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.08),
            ),
            child: Icon(
              isSearch ? Icons.search_off_rounded : Icons.menu_book_rounded,
              size: 56,
              color: scheme.primary.withValues(alpha: 0.8),
            ),
          ),
          Dimens.space5.verticalSpace,
          Text(title, style: theme.textTheme.headlineSmall),
          Dimens.space2.verticalSpace,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
