This development formalizes polygon intersections.

# Guideline on placement of definitions/theorems

Polygons/Defs.lean and Polygons/Datastructures.lean contain exactly the definitions
necessary to state the main specifications Polygons/MultipolygonIntersectionAlgorithm.lean,
Polygons/MultipolygonIntersectionAlgorithmWithPreconditionCheck.lean.

Beyond that, files in `Polygons/` follow a three-level hierarchy. For each topic `X`:
- `Polygons/X.lean` — top of hierarchy for topic `X`. Restates
  definitions or characterizes definitions and restates theorems that are
  worth exporting for topic `X`. This is setup such that a reviewer only
  needs to review `Polygons/X.lean` to completely understand definitions
  and theorem statement from the associated files and when the implementation
  changes, the file `Polygons/X.lean` does not need to change.
    - Contains user-facing definitions with either their full definition statement
      or their unique characterizations (a `def` that defers to `XImpl` plus a
      theorem that uniquely characterizes it). In either case this involves a
      new definition in the `X` namespace.
    - Contains theorem statements of theorems worth exporting, with proofs
      referring to `XProofs`.
    - Theorem statements in `Polygons/X.lean` never should refer to definitions
      from `XImpl` or `XProofs`, instead they should refer to the counterparts
      defined in `Polygons/X.lean`.
    - Never contains a proof; instead refers to a copy of the theorem stated
      in `XProofs.lean`. Even short proofs go to `XProofs`, so future proof
      rewrites do not touch the top-of-hierarchy file.
    - Never contains an implementation. Instead refer to `XImpl`.
    - Never contains definitions or helper theorems that will only be used
      in `XProofs.lean` or `XImpl.lean`.
- `Polygons/XImpl.lean` — runtime implementation. Contains the
  computable `def`s that are called in the runtime path of the algorithm.
  Mathlib-free so it can be initialized in the WASM binary without dragging
  the tactic chain in. Does not contain `def`s that are not (directly or indirectly)
  called in the runtime path.
- `Polygons/XProofs.lean` restatement and proofs of theorems in `X` and private
  helper definitions and theorems. Free to use Mathlib and tactics. Dead-code
  eliminated out of the WASM binary because no `XImpl` initializer references
  it.

It is important that you follow this guideline when adding definitions or
theorems.

# Network access

Network access is restricted to the domains needed for building the Lean→WASM
pipeline: GitHub (for cloning Mathlib and downloading the wasm32 Lean
toolchain release assets) and localhost (for serving the web UI). Do not
fetch from other domains.

# Bash commands

Do not issue any composite bash commands or bash commands with expansions, env variables etc. as this might trip up the permissions systems. Note that you can always write temporary bash scripts to circumvent these restrictions on composite bash commands, expansions etc.

Do not use use multi line bash commands. If you need this instead write a temporary scripts and execute the script.
In particular do not use bash command to write to files. Use the write tool or you can write temporary bash or python to edit files programmatically scripts and execute them.
