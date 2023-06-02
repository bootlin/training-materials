#include <pipewire/pipewire.h>

static void registry_event_global(void *data, uint32_t id,
    uint32_t permissions, const char *type, uint32_t version,
    const struct spa_dict *props) {
  printf("object added: id:%u\ttype:%s/%d\n", id, type, version);
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

struct data { int sync_pending_seq; struct pw_main_loop *loop; };

void core_done(void *data, uint32_t id, int seq) {
  struct data *d = data;

  if (id == PW_ID_CORE && seq == d->sync_pending_seq) {
    printf("sync done");
    pw_main_loop_quit(d->loop);
  }
}

static const struct pw_core_events core_events = {
  PW_VERSION_CORE_EVENTS,
  .done = core_done,
};

int main(int argc, char *argv[]) {
  struct pw_context *context;
  struct pw_core *core;
  struct pw_registry *registry;
  struct spa_hook registry_listener, core_listener;
  struct data data;

  pw_init(&argc, &argv);

  data.loop = pw_main_loop_new(NULL);
  context = pw_context_new(pw_main_loop_get_loop(data.loop), NULL, 0);
  core = pw_context_connect(context, NULL, 0);
  registry = pw_core_get_registry(core, PW_VERSION_REGISTRY, 0);

  spa_zero(core_listener);
  pw_core_add_listener(core, &core_listener, &core_events, &data);
  data.sync_pending_seq = pw_core_sync(core, PW_ID_CORE, 0);

  spa_zero(registry_listener);
  pw_registry_add_listener(registry, &registry_listener,
      &registry_events, NULL);

  pw_main_loop_run(data.loop);

  pw_proxy_destroy((struct pw_proxy*)registry);
  pw_core_disconnect(core);
  pw_context_destroy(context);
  pw_main_loop_destroy(data.loop);

  return 0;
}
