#include "hide_cursor_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace hide_cursor {

// static
void HideCursorPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "hide_cursor",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<HideCursorPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

HideCursorPlugin::HideCursorPlugin() : is_cursor_hidden_(false) {}

HideCursorPlugin::~HideCursorPlugin() {
  // Ensure cursor is visible when plugin is destroyed
  if (is_cursor_hidden_) {
    // In Windows, ShowCursor is a counter system
    // Calling ShowCursor(TRUE) increments the counter, ShowCursor(FALSE) decrements it
    // When the counter is less than 0, the cursor is hidden
    // To ensure the cursor is visible, we may need to call ShowCursor(TRUE) multiple times
    while (ShowCursor(TRUE) < 0) {
      // Continue calling until the counter is greater than or equal to 0
    }
    is_cursor_hidden_ = false;
  }
}

void HideCursorPlugin::HideCursor() {
  if (!is_cursor_hidden_) {
    ShowCursor(FALSE);
    is_cursor_hidden_ = true;
  }
}

void HideCursorPlugin::ShowCursor() {
  if (is_cursor_hidden_) {
    // Ensure cursor is visible
    while (ShowCursor(TRUE) < 0) {
      // Continue calling until the counter is greater than or equal to 0
    }
    is_cursor_hidden_ = false;
  }
}

void HideCursorPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else if (method_call.method_name().compare("hideCursor") == 0) {
    HideCursor();
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare("showCursor") == 0) {
    ShowCursor();
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

}  // namespace hide_cursor
