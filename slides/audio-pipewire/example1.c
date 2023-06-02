#include <pipewire/pipewire.h>

/* We will run indefinitely, getting events for each
   added and removed global objects.

   An influx of Registry::Global events will come in at
   the start to list all already-existing globals. Use
   the Core::Sync method and Core::Done event to know
   when that initial sync is done. See pw_core_sync(). */

static void registry_event_global(void *data,
    uint32_t id, uint32_t permissions, const char *type,
    uint32_t version, const struct spa_dict *props) {
  printf("object added: id:%u\ttype:%s/%d\n", id, type,
      version);
}

static void registry_event_global_remove(void *data,
    uint32_t id) {
  printf("object removed: id:%u\n", id);
}

static const struct pw_registry_events registry_events = {
  PW_VERSION_REGISTRY_EVENTS,
  .global = registry_event_global,
  .global_remove = registry_event_global_remove,
};

int main(int argc, char *argv[]) {
  struct pw_main_loop *loop;
  struct pw_context *context;
  struct pw_core *core;
  struct pw_registry *registry;
  struct spa_hook registry_listener;

  pw_init(&argc, &argv);

  loop = pw_main_loop_new(NULL);
  context = pw_context_new(pw_main_loop_get_loop(loop),
      NULL, 0);
  core = pw_context_connect(context, NULL, 0);
  registry = pw_core_get_registry(core,
      PW_VERSION_REGISTRY, 0);

  spa_zero(registry_listener);
  pw_registry_add_listener(registry, &registry_listener,
      &registry_events, NULL);

  pw_main_loop_run(loop);

  pw_proxy_destroy((struct pw_proxy*)registry);
  pw_core_disconnect(core);
  pw_context_destroy(context);
  pw_main_loop_destroy(loop);

  return 0;
}
