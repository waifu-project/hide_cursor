# Hide Cursor

A Flutter plugin for hiding and showing the system cursor on macOS and Windows platforms. This is particularly useful for video players, games, or any full-screen applications where the cursor should be hidden after a period of inactivity.

## Features

- Hide the system cursor programmatically
- Show the system cursor programmatically
- Auto-hide cursor after a specified duration of inactivity using a convenient mixin
- Works on macOS and Windows platforms

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hide_cursor: ^0.0.3
```

## Usage

### Basic Usage

```dart
import 'package:hide_cursor/hide_cursor.dart';

// Use the global hideCursor instance
await hideCursor.hideCursor();
await hideCursor.showCursor();

// Access the default auto-hide duration
print('Default auto-hide duration: ${kAutoHideCursorDuration.inMilliseconds}ms');
```

### Auto-hide Cursor with Mixin

The plugin provides an `AutoHideCursor` mixin that makes it easy to add auto-hide functionality to any StatefulWidget:

```dart
import 'package:flutter/material.dart';
import 'package:hide_cursor/hide_cursor.dart';

class MyVideoPlayer extends StatefulWidget {
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> with AutoHideCursor {
  @override
  void initState() {
    super.initState();
    // Start auto-hiding the cursor with default duration (kAutoHideCursorDuration = 1.2 seconds)
    startAutoHideCursor();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap your widget with autoHideCursor helper method
    return autoHideCursor(
      YourVideoPlayerWidget(),
    );
  }
}
```

### Manual Control with Mixin

You can also manually control the auto-hide behavior:

```dart
// In your State<T> class that uses AutoHideCursor mixin

// Start auto-hiding with default duration (kAutoHideCursorDuration = 1.2 seconds)
startAutoHideCursor();

// Start auto-hiding with custom duration
startAutoHideCursor(duration: Duration(milliseconds: 800));

// Stop auto-hiding (and show cursor)
stopAutoHideCursor();

// Handle pointer movement manually if needed
handlePointerMovement();
```

## Important Notes

1. The mixin automatically handles cursor visibility in the `dispose()` method, ensuring the cursor is visible when your widget is removed.
2. The `autoHideCursor()` wrapper method automatically sets up both `Listener` and `MouseRegion` to detect all types of mouse movements.
3. The default hide delay is 1.2 seconds (`kAutoHideCursorDuration`), optimized for video player experiences.
4. This plugin only works on desktop platforms (macOS and Windows).
5. Make sure to wrap your entire UI or at least the relevant parts with the `autoHideCursor()` method.

## Example

Check out the example app in the `example` directory for a complete demonstration of how to use this plugin.

## License

This project is licensed under the MIT License - see the LICENSE file for details.