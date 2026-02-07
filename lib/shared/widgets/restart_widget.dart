import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Rebuilds the whole app subtree without killing the process.
///
/// This is a "soft restart": it recreates widgets/providers so they reload
/// state from disk (SharedPreferences/Hive/files), while keeping the same OS
/// process alive.
class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  /// Triggers a soft restart.
  ///
  /// It also clears Flutter's global image cache so restored avatar/background
  /// files become visible immediately.
  static void restartApp(BuildContext context) {
    final isMounted = context is Element ? context.mounted : true;
    assert(() {
      if (!isMounted) {
        debugPrint('RestartWidget.restartApp: called with an unmounted context. Ignoring.');
      }
      return true;
    }());
    if (!isMounted) return;

    try {
      final cache = PaintingBinding.instance.imageCache;
      cache.clear();
      cache.clearLiveImages();
    } catch (e, st) {
      // TODO: Add release-safe logging/reporting for image cache clear failures.
      assert(() {
        debugPrint('RestartWidget.restartApp: failed to clear PaintingBinding image cache: $e\n$st');
        return true;
      }());
    }

    final state = context.findAncestorStateOfType<_RestartWidgetState>();
    assert(() {
      if (state == null) {
        debugPrint(
          'RestartWidget.restartApp: no _RestartWidgetState ancestor found. '
          'Ensure RestartWidget is an ancestor of the provided context.',
        );
      }
      return true;
    }());
    // TODO: Consider state.mounted checks and a user-visible fallback when no ancestor exists.
    if (state == null) return;
    state.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _subtreeKey = UniqueKey();

  void restartApp() {
    setState(() {
      _subtreeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _subtreeKey,
      child: widget.child,
    );
  }
}

