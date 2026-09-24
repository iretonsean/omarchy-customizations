/*
 * gtk4-pointer: the pointer (hand) cursor on clickable widgets in GTK 4 apps.
 *
 * GTK 4 has no CSS property for the cursor, and only app code can set one.
 * This small library is loaded into an app with LD_PRELOAD (see
 * ~/.local/bin/gtk4-pointer-run). When a widget is shown, it checks the
 * widget against the rules in ~/.config/gtk-4.0/pointer.conf and, on a
 * match, sets the "pointer" cursor on it.
 *
 * It links no GTK code. It looks up GTK's functions in the running app, so in
 * a program without GTK 4 it does nothing. It also removes itself from
 * LD_PRELOAD at load, so programs that the app starts do not inherit it.
 *
 * Build: gcc -shared -fPIC -O2 -o libgtk4-pointer.so gtk4-pointer.c \
 *          $(pkg-config --cflags gtk4)
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_RULES 64
#define MAX_CLASSES 4

typedef struct {
  char node[32];
  char classes[MAX_CLASSES][32];
  int n_classes;
} Rule;

static Rule rules[MAX_RULES];
static int n_rules;

/* GTK and GLib functions, looked up at run time. */
static guint (*p_idle_add)(GSourceFunc, gpointer);
static guint (*p_signal_lookup)(const char *, GType);
static gulong (*p_add_emission_hook)(guint, GQuark, GSignalEmissionHook, gpointer, GDestroyNotify);
static GType (*p_widget_get_type)(void);
static const char *(*p_get_css_name)(GtkWidget *);
static gboolean (*p_has_css_class)(GtkWidget *, const char *);
static void (*p_set_cursor_from_name)(GtkWidget *, const char *);
static GdkCursor *(*p_get_cursor)(GtkWidget *);
static GListModel *(*p_window_get_toplevels)(void);
static guint (*p_model_n_items)(GListModel *);
static gpointer (*p_model_get_item)(GListModel *, guint);
static GtkWidget *(*p_first_child)(GtkWidget *);
static GtkWidget *(*p_next_sibling)(GtkWidget *);
static void (*p_object_unref)(gpointer);
static gpointer (*p_value_peek_pointer)(const GValue *);
static gboolean (*p_check_instance_is_a)(GTypeInstance *, GType);

static int lookup(void) {
#define FIND(ptr, name) if (!(*(void **)&ptr = dlsym(RTLD_DEFAULT, name))) return 0
  FIND(p_idle_add, "g_idle_add");
  FIND(p_signal_lookup, "g_signal_lookup");
  FIND(p_add_emission_hook, "g_signal_add_emission_hook");
  FIND(p_widget_get_type, "gtk_widget_get_type");
  FIND(p_get_css_name, "gtk_widget_get_css_name");
  FIND(p_has_css_class, "gtk_widget_has_css_class");
  FIND(p_set_cursor_from_name, "gtk_widget_set_cursor_from_name");
  FIND(p_get_cursor, "gtk_widget_get_cursor");
  FIND(p_window_get_toplevels, "gtk_window_get_toplevels");
  FIND(p_model_n_items, "g_list_model_get_n_items");
  FIND(p_model_get_item, "g_list_model_get_item");
  FIND(p_first_child, "gtk_widget_get_first_child");
  FIND(p_next_sibling, "gtk_widget_get_next_sibling");
  FIND(p_object_unref, "g_object_unref");
  FIND(p_check_instance_is_a, "g_type_check_instance_is_a");
  FIND(p_value_peek_pointer, "g_value_peek_pointer");
#undef FIND
  return 1;
}

/* One rule per line: a CSS node name, then optional .classes.
 * Example: "row.activatable". Lines starting with # are comments. */
static void load_rules(void) {
  const char *home = getenv("HOME");
  char path[512];
  snprintf(path, sizeof path, "%s/.config/gtk-4.0/pointer.conf", home ? home : "");
  FILE *file = fopen(path, "r");
  if (!file) return;

  char line[256];
  while (n_rules < MAX_RULES && fgets(line, sizeof line, file)) {
    char *s = line;
    while (*s == ' ' || *s == '\t') s++;
    if (*s == '#' || *s == '\n' || *s == '\0') continue;
    s[strcspn(s, " \t\r\n#")] = '\0';

    Rule *rule = &rules[n_rules];
    memset(rule, 0, sizeof *rule);
    char *part = strtok(s, ".");
    if (!part) continue;
    snprintf(rule->node, sizeof rule->node, "%s", part);
    while ((part = strtok(NULL, ".")) && rule->n_classes < MAX_CLASSES)
      snprintf(rule->classes[rule->n_classes++], sizeof rule->classes[0], "%s", part);
    n_rules++;
  }
  fclose(file);
}

static int matches(GtkWidget *widget) {
  const char *node = p_get_css_name(widget);
  if (!node) return 0;
  for (int i = 0; i < n_rules; i++) {
    if (strcmp(rules[i].node, node) != 0 && strcmp(rules[i].node, "*") != 0) continue;
    int ok = 1;
    for (int c = 0; c < rules[i].n_classes && ok; c++)
      ok = p_has_css_class(widget, rules[i].classes[c]);
    if (ok) return 1;
  }
  return 0;
}

static void apply(GtkWidget *widget) {
  /* Leave widgets alone that the app gave a cursor of its own. */
  if (matches(widget) && !p_get_cursor(widget))
    p_set_cursor_from_name(widget, "pointer");
}

static void apply_tree(GtkWidget *widget) {
  apply(widget);
  for (GtkWidget *child = p_first_child(widget); child; child = p_next_sibling(child))
    apply_tree(child);
}

static gboolean on_map(GSignalInvocationHint *hint, guint n_values, const GValue *values, gpointer data) {
  (void)hint; (void)data;
  if (n_values < 1) return TRUE;
  gpointer instance = p_value_peek_pointer(&values[0]);
  if (instance && p_check_instance_is_a(instance, p_widget_get_type()))
    apply((GtkWidget *)instance);
  return TRUE; /* keep the hook */
}

static gboolean start(gpointer data) {
  (void)data;
  guint map = p_signal_lookup("map", p_widget_get_type());
  if (map) p_add_emission_hook(map, 0, on_map, NULL, NULL);

  /* Windows that were shown before this ran. */
  GListModel *toplevels = p_window_get_toplevels();
  guint n = p_model_n_items(toplevels);
  for (guint i = 0; i < n; i++) {
    GtkWidget *window = p_model_get_item(toplevels, i);
    if (window) { apply_tree(window); p_object_unref(window); }
  }
  return G_SOURCE_REMOVE;
}

/* Take this library out of LD_PRELOAD, so child processes do not load it. */
static void remove_from_preload(void) {
  const char *preload = getenv("LD_PRELOAD");
  if (!preload) return;
  char *copy = strdup(preload), *out = calloc(1, strlen(preload) + 1);
  if (!copy || !out) { free(copy); free(out); return; }
  for (char *item = strtok(copy, ": "); item; item = strtok(NULL, ": ")) {
    if (strstr(item, "libgtk4-pointer.so")) continue;
    if (*out) strcat(out, ":");
    strcat(out, item);
  }
  if (*out) setenv("LD_PRELOAD", out, 1);
  else unsetenv("LD_PRELOAD");
  free(copy);
  free(out);
}

__attribute__((constructor)) static void init(void) {
  remove_from_preload();
  if (!lookup()) return;
  load_rules();
  if (n_rules == 0) return;
  p_idle_add(start, NULL);
}
