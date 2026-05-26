import Lake
open Lake DSL System

package «Polygons» where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.15.0-patch1"

@[default_target]
lean_lib «Polygons» where
  globs := #[.submodules `Polygons]

/-- A lean_lib containing only the `Web.lean` entry point, which exposes
`@[export run_intersection]`. The WASM build links against this lib. -/
@[default_target]
lean_lib «Web» where
  roots := #[`Web]

/--
Custom target: a single static archive containing exactly the `.o.export`
files of `Web`'s transitive import closure (Mathlib-free by hierarchy
construction). Lake handles dependency tracking — when a new `XImpl`
module is imported transitively from `Web.lean`, it shows up here
automatically without any edits to `lakefile.lean` or `build.sh`.

Build with:
  `LEAN_CC=./emcc-wasm.sh LEAN_SYSROOT=$PWD/.wasm-toolchain lake build wasmClosure`

Output: `.lake/build/lib/libWasmClosure.a`.

The setup of LEAN_CC / LEAN_SYSROOT is what makes the `.o` files
wasm32-compatible — lake itself is unaware that this is a cross-compile.
-/
target wasmClosure pkg : FilePath := do
  let some webMod := pkg.findModule? `Web
    | error "module `Web` not found"
  let transImps ← webMod.transImports.fetch
  let allMods := transImps.push webMod
  let oJobs ← allMods.mapM (·.oExport.fetch)
  buildStaticLib (pkg.buildDir / "lib" / "libWasmClosure.a") oJobs
