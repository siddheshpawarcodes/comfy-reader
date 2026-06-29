import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Opens the reader for [bookId] — but only if a reader isn't already open or
/// mid-push. Without this guard, a double-tap (or a tap during the open
/// transition) pushes a second `/reader/:id` route, which overlaps the cover
/// Hero flight and trips Flutter's hero "divert" assertion
/// (`manifest.tag == newManifest.tag`).
void openReader(BuildContext context, String bookId) {
  if (isReaderRoute(GoRouter.of(context))) return;
  context.push('/reader/$bookId');
}

/// Whether the top of the navigation stack is a reader route. Reads the
/// current (top-most) configuration, not the calling widget's own route.
bool isReaderRoute(GoRouter router) =>
    router.state.uri.toString().startsWith('/reader/');
