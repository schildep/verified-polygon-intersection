#!/bin/sh
# emcc wrapper that prepends the wasm cross-compile flags lake/leanc don't
# know to add. Set as `LEAN_CC=./emcc-wasm.sh` so `lake build wasmClosure`
# produces wasm32 object files instead of host objects.
exec emcc -fwasm-exceptions -pthread -O2 -ffunction-sections -fdata-sections ${LEAN_CC_PREFIX_MAP_FLAGS:-} "$@"
