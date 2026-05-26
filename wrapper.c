#include <lean/lean.h>
#include <emscripten.h>
#include <string.h>
#include <stdlib.h>

/* Lean runtime (not declared in lean.h but present in libleanrt). */
extern void lean_initialize_runtime_module(void);

/* ── libuv stubs ──────────────────────────────────────────────
   The wasm32 Lean toolchain (v4.15.0) links against libuv symbols that
   libuv itself does not provide on the WebAssembly target. We stub the
   four symbols that Lean's runtime actually references at startup. */

typedef struct { int result; char path[256]; } uv_fs_t;

const char* uv_strerror(int err) {
    (void)err;
    return "uv error (stub)";
}

int uv_os_tmpdir(char* buf, size_t* size) {
    const char* tmp = "/tmp";
    size_t len = strlen(tmp);
    if (*size <= len) { *size = len + 1; return -1; }
    memcpy(buf, tmp, len + 1);
    *size = len;
    return 0;
}

int uv_fs_mkstemp(void* loop, uv_fs_t* req, const char* tpl, void* cb) {
    (void)loop; (void)req; (void)tpl; (void)cb;
    return -1; /* not supported in WASM */
}

int uv_fs_mkdtemp(void* loop, uv_fs_t* req, const char* tpl, void* cb) {
    (void)loop; (void)req; (void)tpl; (void)cb;
    return -1; /* not supported in WASM */
}

/* Lean-generated symbols. */
extern lean_object* initialize_Web(uint8_t builtin, lean_object* w);
extern lean_object* run_intersection(lean_object* s);

static int g_initialized = 0;

EMSCRIPTEN_KEEPALIVE
void init_lean(void) {
    if (g_initialized) return;
    g_initialized = 1;

    lean_initialize_runtime_module();
    lean_init_task_manager();

    lean_object* res = initialize_Web(1 /* builtin */, lean_io_mk_world());
    if (lean_io_result_is_error(res)) {
        lean_dec_ref(res);
        return;
    }
    lean_dec_ref(res);
}

EMSCRIPTEN_KEEPALIVE
const char* call_run_intersection(const char* input) {
    /* C string → Lean string. */
    lean_object* lean_str = lean_mk_string(input);
    /* Invoke the exported verified entry point. */
    lean_object* result = run_intersection(lean_str);
    /* Lean string → C string. Copy out so JS can read after we release. */
    const char* c_result = lean_string_cstr(result);
    size_t len = strlen(c_result);
    char* buf = (char*)malloc(len + 1);
    memcpy(buf, c_result, len + 1);
    lean_dec_ref(result);
    return buf;
}

int main(void) { return 0; }
