import 'dart:async';

/// A minimal counting semaphore for bounding concurrency (e.g. how many PDF
/// covers render at once so a burst of newly-visible cards can't flood the
/// native renderer and stutter scrolling). FIFO: waiters resume in order.
class Semaphore {
  Semaphore(this.maxConcurrent) : assert(maxConcurrent > 0);

  final int maxConcurrent;
  int _active = 0;
  final List<Completer<void>> _waiters = <Completer<void>>[];

  /// Number of permits currently held (visible for tests/diagnostics).
  int get active => _active;

  /// Acquires a permit, waiting if [maxConcurrent] are already held.
  Future<void> acquire() {
    if (_active < maxConcurrent) {
      _active++;
      return Future<void>.value();
    }
    final waiter = Completer<void>();
    _waiters.add(waiter);
    return waiter.future;
  }

  /// Releases a permit, handing it to the next waiter if any.
  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    } else if (_active > 0) {
      _active--;
    }
  }

  /// Runs [action] while holding a permit, releasing it even on error.
  Future<T> withPermit<T>(Future<T> Function() action) async {
    await acquire();
    try {
      return await action();
    } finally {
      release();
    }
  }
}
