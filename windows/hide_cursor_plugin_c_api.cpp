#include "include/hide_cursor/hide_cursor_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "hide_cursor_plugin.h"

void HideCursorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  hide_cursor::HideCursorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
