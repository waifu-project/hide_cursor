import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:hide_cursor/hide_cursor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AutoHideCursor {
  String _platformVersion = 'Unknown';
  String _cursorStatus = 'Visible';
  bool _isAutoHideEnabled = false; // Auto-hide disabled by default

  @override
  void initState() {
    super.initState();
    initPlatformState();
    
    // Don't start auto-hide in initState, let user control it manually
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await hideCursor.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // Hide cursor manually
  Future<void> _hideCursor() async {
    try {
      await hideCursor.hideCursor();
      setState(() {
        _cursorStatus = 'Hidden';
      });
    } on PlatformException catch (e) {
      setState(() {
        _cursorStatus = 'Error: ${e.message}';
      });
    }
  }

  // Show cursor manually
  Future<void> _showCursor() async {
    try {
      await hideCursor.showCursor();
      setState(() {
        _cursorStatus = 'Visible';
      });
    } on PlatformException catch (e) {
      setState(() {
        _cursorStatus = 'Error: ${e.message}';
      });
    }
  }

  // Toggle auto-hide feature
  void _toggleAutoHide(bool enabled) {
    if (enabled) {
      // Start auto-hide with default duration
      startAutoHideCursor();

      developer.log("Auto-hide enabled");

      setState(() {
        _isAutoHideEnabled = true;
        _cursorStatus = 'Auto-hide enabled (1.2s)';
      });
    } else {
      // Stop auto-hide
      stopAutoHideCursor();

      developer.log("Auto-hide disabled");

      setState(() {
        _isAutoHideEnabled = false;
        _cursorStatus = 'Auto-hide disabled';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hide Cursor Example')),
        body: autoHideCursor(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Running on: $_platformVersion'),
                    const SizedBox(height: 20),
                    Text('Cursor status: $_cursorStatus'),
                    const SizedBox(height: 40),

                    // Video player simulation
                    Container(
                      width: 640,
                      height: 360,
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          'Video Player Simulation\nMove mouse over this area to test cursor behavior\nToggle auto-hide below to enable cursor hiding',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Manual controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _hideCursor,
                          child: const Text('Hide Cursor'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _showCursor,
                          child: const Text('Show Cursor'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Auto-hide toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Auto-hide cursor:'),
                        const SizedBox(width: 10),
                        Switch(
                          value: _isAutoHideEnabled,
                          onChanged: _toggleAutoHide,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Instructions
                    const Text(
                      'Instructions:\n'
                      '1. Toggle "Auto-hide cursor" to enable automatic hiding\n'
                      '2. Move mouse over the black area and wait 1.2 seconds\n'
                      '3. Move mouse again to show cursor\n'
                      '4. Use manual buttons to test hide/show functionality',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}