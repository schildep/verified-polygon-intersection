#!/usr/bin/env bash
set -euo pipefail

# Build Polygons → WebAssembly.
#
# Pipeline:
#   1. `lake build wasmClosure` compiles Web's transitive import closure
#      (Mathlib-free by hierarchy construction) into a single static
#      archive.
#      `LEAN_CC=./emcc-wasm.sh` redirects leanc to emcc with the wasm-
#      specific flags lake/leanc don't know to add.
#   2. `emcc` links the archive + `wrapper.c` against the prebuilt
#      wasm32 Lean toolchain.  (We do the link ourselves because leanc's
#      hard-coded link flags include `-lgmp -luv` which the wasm32
#      toolchain doesn't ship.)
#   3. `wasm-opt -Oz` shrinks the output a few % further.
#
# Requires: elan + Lean v4.15.0, emscripten, zstd
# Output → docs/  (committed; served by GitHub Pages).

LEAN_VER="4.15.0"
TOOLCHAIN_URL="https://github.com/leanprover/lean4/releases/download/v${LEAN_VER}/lean-${LEAN_VER}-linux_wasm32.tar.zst"
TOOLCHAIN_DIR=".wasm-toolchain"
OUTPUT_DIR="docs"
ARCHIVE=".lake/build/lib/libWasmClosure.a"

# Hard ceiling on the gzipped `lean_app.wasm` payload — that's what GitHub
# Pages actually serves to the user (it transparently gzips on the wire) and
# what dominates the bundle (~90% of the gzipped total). If the build crosses
# this number, fail loudly: either the runtime closure has grown (check
# `Web.lean`'s transitive imports) or the growth is intended and the limit
# should be raised here in a follow-up commit.
MAX_WASM_GZIP_BYTES=$((320 * 1024))

[ -d ".lake/packages/mathlib" ] || { echo "ERROR: setup packages first"; exit 1; }

# 1. wasm32 toolchain (one-time).
if [ ! -d "${TOOLCHAIN_DIR}/include/lean" ]; then
    echo "==> Downloading wasm32 Lean toolchain"
    mkdir -p "$TOOLCHAIN_DIR"
    curl -L "$TOOLCHAIN_URL" -o "$TOOLCHAIN_DIR/lean.tar.zst"
    zstd -d "$TOOLCHAIN_DIR/lean.tar.zst" --stdout | tar -x -C "$TOOLCHAIN_DIR" --strip-components=1
fi
TOOLCHAIN_ABS="$(cd "$TOOLCHAIN_DIR" && pwd)"
REPO_ABS="$(pwd)"

# 2. Build Web's transitive closure as a wasm32 static archive.
export LEAN_SYSROOT="$TOOLCHAIN_ABS"
export LEAN_CC="$REPO_ABS/emcc-wasm.sh"
# Rewrite absolute build-host paths in __FILE__ and debug info so the wasm
# carries no host-specific paths.
export LEAN_CC_PREFIX_MAP_FLAGS="-ffile-prefix-map=${TOOLCHAIN_ABS}=/toolchain -ffile-prefix-map=${REPO_ABS}=/src"

# Lake's incremental cache doesn't include LEAN_CC in its trace.  Any
# .c.o.export file left behind by a prior host `lake build` will be
# silently reused — wasm-ld then fails deep in the link with
# "Bitcode section not found".  Scan every
# .c.o.export file and purge any whose architecture isn't WebAssembly;
# lake will recompile those on the next step.  (-L: descend into
# .lake/packages, which is a symlink to a sandbox-writable tree.)
# `|| true`: grep -v exits 1 when nothing matches — i.e. the all-clean
# case — and pipefail would otherwise kill the script.
stale=$(find -L .lake -name '*.c.o.export' -exec file {} + 2>/dev/null \
    | { grep -v WebAssembly || true; } | cut -d: -f1)
if [ -n "$stale" ]; then
    echo "==> Stale host-arch .c.o.export files detected — purging:"
    echo "$stale" | sed 's/^/    /'
    echo "$stale" | while IFS= read -r f; do
        rm -f "$f" "$f.hash" "$f.trace"
    done
    rm -f "$ARCHIVE"
fi

# Lake's cache also doesn't key on LEAN_CC_PREFIX_MAP_FLAGS, so objects
# compiled before this flag was introduced still embed host paths. One-time
# evict via a sentinel; fresh clones already have nothing to purge.
PREFIX_MAP_SENTINEL=".lake/build/.prefix-map-applied"
if [ ! -f "$PREFIX_MAP_SENTINEL" ]; then
    echo "==> One-time purge of pre-remap cached objects"
    find -L .lake -name '*.c.o.export' -delete 2>/dev/null || true
    rm -f "$ARCHIVE"
    mkdir -p "$(dirname "$PREFIX_MAP_SENTINEL")"
    touch "$PREFIX_MAP_SENTINEL"
fi

echo "==> lake build wasmClosure"
lake build wasmClosure

# 3. Compile wrapper.c
mkdir -p "$OUTPUT_DIR" .lake/build/ir
WRAPPER_O=".lake/build/ir/wrapper.o"
echo "==> Compiling wrapper.c"
"$LEAN_CC" -c wrapper.c -o "$WRAPPER_O" -I "${TOOLCHAIN_ABS}/include" ${LEAN_CC_PREFIX_MAP_FLAGS}

# 4. Link.
echo "==> Linking wasm"
emcc -o "${OUTPUT_DIR}/lean_app.js" \
    "$WRAPPER_O" \
    -Wl,--whole-archive "$ARCHIVE" -Wl,--no-whole-archive \
    -L "${TOOLCHAIN_ABS}/lib/lean" \
    -Wl,--start-group -lLean -lInit -lStd -lleancpp -lleanrt -Wl,--end-group \
    -Wl,--allow-multiple-definition \
    -Wl,--gc-sections \
    -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=4194304 \
    -sEXPORTED_FUNCTIONS='["_main","_init_lean","_call_run_intersection","_malloc","_free"]' \
    -sEXPORTED_RUNTIME_METHODS='["ccall","cwrap","UTF8ToString"]' \
    -fwasm-exceptions -sMODULARIZE -sEXPORT_NAME=LeanModule \
    -pthread -Wno-pthreads-mem-growth -sFORCE_FILESYSTEM -O2 \
    ${LEAN_CC_PREFIX_MAP_FLAGS}

# 5. wasm-opt -Oz.
WASM_OPT="$({ find /opt/homebrew/Cellar/emscripten /usr/local/Cellar/emscripten -name wasm-opt 2>/dev/null || true; } | head -1)"
if [ -n "$WASM_OPT" ] && [ -x "$WASM_OPT" ]; then
    echo "==> wasm-opt -Oz"
    "$WASM_OPT" --all-features -Oz --strip-debug --strip-producers \
        "${OUTPUT_DIR}/lean_app.wasm" -o "${OUTPUT_DIR}/lean_app.wasm.tmp"
    mv "${OUTPUT_DIR}/lean_app.wasm.tmp" "${OUTPUT_DIR}/lean_app.wasm"
fi

# 6. Size gate before copying static assets.
wasm_gz=$(gzip -9 -c "${OUTPUT_DIR}/lean_app.wasm" | wc -c | tr -d ' ')
if [ "$wasm_gz" -gt "$MAX_WASM_GZIP_BYTES" ]; then
    echo "ERROR: lean_app.wasm gzipped is $wasm_gz bytes, limit is $MAX_WASM_GZIP_BYTES."
    echo "       Either reduce the runtime closure (check Web.lean's import chain)"
    echo "       or raise MAX_WASM_GZIP_BYTES in build.sh if the growth is intended."
    exit 1
fi

cp index.html "${OUTPUT_DIR}/index.html"
cp coi-serviceworker.min.js "${OUTPUT_DIR}/coi-serviceworker.min.js"

echo "==> Done. lean_app.wasm: $wasm_gz bytes gzipped (limit $MAX_WASM_GZIP_BYTES)."
ls -lh "${OUTPUT_DIR}"/lean_app.wasm "${OUTPUT_DIR}"/lean_app.js
