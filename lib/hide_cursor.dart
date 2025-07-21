import 'dart:async';
import 'package:flutter/widgets.dart';
import 'hide_cursor_platform_interface.dart';

/// Default duration after which cursor will be hidden if no movement is detected
const kAutoHideCursorDuration = Duration(milliseconds: 1200);

/// A class for controlling system cursor visibility
class HideCursor {
  /// Returns the platform version.
  Future<String?> getPlatformVersion() {
    return HideCursorPlatform.instance.getPlatformVersion();
  }

  /// Hides the cursor at system level
  Future<bool> hideCursor() {
    return HideCursorPlatform.instance.hideCursor();
  }

  /// Shows the cursor at system level
  Future<bool> showCursor() {
    return HideCursorPlatform.instance.showCursor();
  }
}

/// Global instance of [HideCursor] for easy access
final hideCursor = HideCursor();

/// A mixin that provides auto-hide cursor functionality for StatefulWidget
mixin AutoHideCursor<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  bool _mouseVisible = true;
  Duration hideDelay = kAutoHideCursorDuration;

  /// Start auto-hiding the cursor after a period of inactivity
  ///
  /// [duration] - Duration after which cursor will be hidden if no movement is detected
  void startAutoHideCursor({Duration? duration}) {
    // Set the hide delay
    if (duration != null) {
      hideDelay = duration;
    }

    // Start the initial timer
    _timer = Timer(hideDelay, _hideMouse);
  }

  /// Stop auto-hiding the cursor and ensure it's visible
  void stopAutoHideCursor() {
    _timer?.cancel();
    _timer = null;
    _showMouse();
  }

  /// Call this method when pointer movement is detected
  void handlePointerMovement({Duration? duration}) {
    // Show mouse if it was hidden
    _showMouse();

    // Reset the timer
    _timer?.cancel();

    // Only restart timer if auto-hide is active
    if (_timer != null) {
      _timer = Timer(duration ?? hideDelay, _hideMouse);
    }
  }

  /// Hide cursor if it's visible
  void _hideMouse() async {
    if (_mouseVisible) {
      _mouseVisible = false;
      await hideCursor.hideCursor();
    }
  }

  /// Show cursor if it's hidden
  void _showMouse() async {
    if (!_mouseVisible) {
      _mouseVisible = true;
      await hideCursor.showCursor();
    }
  }

  /// Wrap a widget with auto-hide cursor functionality
  Widget autoHideCursor({ required Widget child, Duration? duration }) {
    // Update the hide delay
    if (duration != null) {
      hideDelay = duration;
    }

    return Listener(
      onPointerMove: (_) => handlePointerMovement(duration: duration),
      onPointerHover: (_) => handlePointerMovement(duration: duration),
      child: MouseRegion(
        onHover: (_) => handlePointerMovement(duration: duration),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    // Ensure cursor is visible when widget is disposed
    stopAutoHideCursor();
    super.dispose();
  }
}