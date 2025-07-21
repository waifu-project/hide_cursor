//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <hide_cursor/hide_cursor_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) hide_cursor_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HideCursorPlugin");
  hide_cursor_plugin_register_with_registrar(hide_cursor_registrar);
}
