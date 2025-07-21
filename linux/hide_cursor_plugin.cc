#include "include/hide_cursor/hide_cursor_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <sys/utsname.h>

#include <cstring>

#include "hide_cursor_plugin_private.h"

#define HIDE_CURSOR_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), hide_cursor_plugin_get_type(), \
                              HideCursorPlugin))

struct _HideCursorPlugin {
  GObject parent_instance;
  GtkWidget* flutter_window;
  gboolean is_cursor_hidden;
};

G_DEFINE_TYPE(HideCursorPlugin, hide_cursor_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void hide_cursor_plugin_handle_method_call(
    HideCursorPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = get_platform_version();
  } else if (strcmp(method, "hideCursor") == 0) {
    // Hide cursor
    if (self->flutter_window != nullptr && !self->is_cursor_hidden) {
      GdkWindow* window = gtk_widget_get_window(self->flutter_window);
      if (window != nullptr) {
        GdkCursor* blank_cursor = gdk_cursor_new_for_display(
            gdk_window_get_display(window), GDK_BLANK_CURSOR);
        gdk_window_set_cursor(window, blank_cursor);
        g_object_unref(blank_cursor);
        self->is_cursor_hidden = TRUE;
        g_print("HideCursorPlugin: Cursor hidden\n");
      }
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(TRUE)));
  } else if (strcmp(method, "showCursor") == 0) {
    // Show cursor
    if (self->flutter_window != nullptr && self->is_cursor_hidden) {
      GdkWindow* window = gtk_widget_get_window(self->flutter_window);
      if (window != nullptr) {
        gdk_window_set_cursor(window, nullptr);  // Set to default cursor
        self->is_cursor_hidden = FALSE;
        g_print("HideCursorPlugin: Cursor shown\n");
      }
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(TRUE)));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);
  g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
  g_autoptr(FlValue) result = fl_value_new_string(version);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

// Show cursor when mouse leaves the window
static gboolean on_leave_notify_event(GtkWidget* widget, GdkEventCrossing* event, gpointer user_data) {
  HideCursorPlugin* self = HIDE_CURSOR_PLUGIN(user_data);
  if (self->is_cursor_hidden) {
    GdkWindow* window = gtk_widget_get_window(self->flutter_window);
    if (window != nullptr) {
      gdk_window_set_cursor(window, nullptr);  // Set to default cursor
      self->is_cursor_hidden = FALSE;
      g_print("HideCursorPlugin: Cursor shown because mouse left window\n");
    }
  }
  return FALSE;  // Continue event propagation
}

static void hide_cursor_plugin_dispose(GObject* object) {
  HideCursorPlugin* self = HIDE_CURSOR_PLUGIN(object);
  
  // Ensure cursor is visible when plugin is destroyed
  if (self->is_cursor_hidden && self->flutter_window != nullptr) {
    GdkWindow* window = gtk_widget_get_window(self->flutter_window);
    if (window != nullptr) {
      gdk_window_set_cursor(window, nullptr);  // Set to default cursor
      g_print("HideCursorPlugin: Cursor shown because plugin was disposed\n");
    }
  }
  
  G_OBJECT_CLASS(hide_cursor_plugin_parent_class)->dispose(object);
}

static void hide_cursor_plugin_class_init(HideCursorPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = hide_cursor_plugin_dispose;
}

static void hide_cursor_plugin_init(HideCursorPlugin* self) {
  self->flutter_window = nullptr;
  self->is_cursor_hidden = FALSE;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  HideCursorPlugin* plugin = HIDE_CURSOR_PLUGIN(user_data);
  hide_cursor_plugin_handle_method_call(plugin, method_call);
}

void hide_cursor_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  HideCursorPlugin* plugin = HIDE_CURSOR_PLUGIN(
      g_object_new(hide_cursor_plugin_get_type(), nullptr));

  // Get Flutter window
  FlView* view = fl_plugin_registrar_get_view(registrar);
  if (view != nullptr) {
    plugin->flutter_window = gtk_widget_get_toplevel(GTK_WIDGET(view));
    
    // Add event handler for mouse leaving window
    if (plugin->flutter_window != nullptr) {
      g_signal_connect(plugin->flutter_window, "leave-notify-event",
                      G_CALLBACK(on_leave_notify_event), plugin);
      g_print("HideCursorPlugin: Connected to Flutter window\n");
    } else {
      g_print("HideCursorPlugin: Could not find Flutter window\n");
    }
  }

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "hide_cursor",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}