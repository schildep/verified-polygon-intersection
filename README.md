# Formally verified multipolygon intersection

To my knowledge, this is the first formally verified implementation of an intersection algorithm for polygons.

I was able to delegate large parts of the work to AI agents, by providing proof strategies in plain English, and without reviewing almost all of the code in this repository. Trust in the correctness comes entirely from the Lean checker and human review of a small specification, not from the LLM (see [Use of AI agents](#use-of-ai-agents)).

## Try it out

Try out [the formally verified web app](https://schildep.github.io/verified-polygon-intersection/), where you can draw and intersect multipolygons.

## Background

Multipolygon intersection is a standard feature of many vector graphic editors.

A multipolygon is defined by a list of polygon components and polygonal holes, each defined by a list of vertices. It describes a two-dimensional area: the set of interior points. This set can be formally defined by [counting the parity](https://en.wikipedia.org/wiki/Point_in_polygon) of the number of intersections of the polygon with rays cast from each point on the plane. (Note that the formal proof that this is independent of the ray direction alone takes thousands of lines.) Given two multipolygons, we construct a new multipolygon, whose interior set is the intersection of the two interior sets of the input multipolygons.

![Example of multipolygon intersection](readme-assets/IntersectionExample.png)

There are infinitely many configurations of input polygons, so without formal verification no property can be verified for every configuration by classical testing. Furthermore, for each polygon the set of interior points is infinite, so without formal verification interior sets and their intersection are just an interpretation that cannot be represented in the code.

In this development the intersection specification is formally described and fully verified with the Lean 4 proof assistant. So we can guarantee that these infinite sets of interior points actually satisfy the intersection equality, for any configuration of input polygons. This is currently restricted to the preconditions described in [`multipolygonIntersectionAlgorithmWithPreconditionCheck_complete`](Polygons/MultipolygonIntersectionAlgorithmWithPreconditionCheck.lean). In particular any pair of segments from the two multipolygons can overlap/intersect at most in one point. For example the case where the two multipolygons share a segment is rejected in the current implementation.

Implementations of computational geometry algorithms like this are notoriously hard to verify by classical testing, because of rare special configurations of inputs that may make up much of the complexity of the algorithm. Consider for example the following example where we intersect a cross with a square with a hole. To produce a multipolygon that describes the intersection, the algorithm must choose closed boundary components and order the vertices. This choice of which green segments belong together is not unique in this case (for example it could be 4 squares or a cross with a square hole), but it would be unique if the yellow hole were a tiny bit smaller or larger. It is a non-trivial fact that it is possible to partition and order the segments into closed boundary components in all cases.

![Example of multipolygon intersection](readme-assets/IntersectionExampleCross.png)

## Use of AI agents

The setup of this repository aims to minimize human review needed to verify correctness of the implementation of the polygon intersection algorithm. A human reviewer just needs to read the 3 files [`DataStructures.lean`](Polygons/DataStructures.lean), [`Defs.lean`](Polygons/Defs.lean) and [`MultipolygonIntersectionAlgorithmWithPreconditionCheck.lean`](Polygons/MultipolygonIntersectionAlgorithmWithPreconditionCheck.lean) and run the Lean checker. These are 87 lines of simple-to-understand Lean specification, mostly setting up basic geometrical definitions for polygons. The unoptimized code implementing the algorithm is already more than twice that and more complicated to understand. The code will grow a lot once we add optimizations and, for example, allow overlaps between segments. The specification that humans have to read to review correctness, on the other hand, will stay the same size.

It is not necessary to read other files to review correctness. I also read and directed the content of other files that don't end in `...Proofs.lean` and `...Impl.lean` to steer the strategy. The main theorems in these other files served as checkpoints, so I could use the Lean checker to determine when the agent actually succeeded at a task.
The implementation and formal proof of its correctness in the `...Proofs.lean` and `...Impl.lean` files was autonomously written by AI agents and never reviewed by me or any other human, but thanks to the Lean checker, neither I nor any human reviewer needs to trust any LLM in this process.

The way this separation is structured is described in [`CLAUDE.md`](CLAUDE.md) and may not be Lean-idiomatic.

Claude Opus 4.7 in the Claude Code harness is **not** able to produce the algorithm implementation with formal proof autonomously in one go, just given the specification. I needed to describe the algorithm and proof strategy in multiple steps. It will be interesting to see if future models will be able to produce verified implementations of this complexity autonomously. At that point, the approach of combining AI agents and proof assistants might become practically interesting.

Using AI agents, I produced over 30,000 lines of Lean code in this repository over many sessions. Presumably there are many duplicated arguments and detours, since neither I nor any single agent understood the formal proof end to end. I am sure that a hand-written formal proof by a trained formal verification engineer setting up the definitions and proof strategy to minimize the formal proof would be significantly shorter. Thanks to the use of AI agents, I was able to set up the proof strategy in the way I first thought about the problem, and to amend it when the agents ran into issues, without worrying about the impact on the size of the formal proof.

Parts of the proofs were written by Claude Opus 4.5, which required me to write out the informal proof on a more fine grained level. I was then stuck on this project until Claude Opus 4.7 was released, which allowed me to advance in larger steps.

Claude completely freed me from thinking about any Lean-specific technicalities. For many steps, it was able to plan and work independently, freeing me from thinking about individual cases in the proofs. In some larger tasks the model became stuck; I had the feeling that the model was unable to come up with and consistently follow longer term plans, and that it had bad geometrical intuitions that led it down the wrong paths when I did not intervene.

A drawback I observed from forcing AI agents to formally verify their implementation is that this tends to produce code that is slower or disregards other practical considerations that are not captured in the specification. This probably stems from the difficulty of the formal verification pushing for simpler code and from the lack of formally verified practical software in the training data.

# Building and checking

Requires [elan](https://github.com/leanprover/elan). The Lean version is pinned in [`lean-toolchain`](lean-toolchain) (currently `leanprover/lean4:v4.15.0`) to simplify the WebAssembly build.

Check all proofs:

```
lake build
```

Inspect the axioms the theorems of interest depend on (e.g. here correctness theorem of the algorithm). This is important since agents could have introduced unwanted axioms into the proofs. We only depend on trusted axioms `[propext, Classical.choice, Quot.sound]`.

```
printf 'import Polygons.MultipolygonIntersectionAlgorithmWithPreconditionCheck\n#print axioms multipolygonIntersectionAlgorithmWithPreconditionCheck_interior_eq\n#print axioms multipolygonIntersectionAlgorithmWithPreconditionCheck_complete\n' | lake env lean --stdin
```

Build the WebAssembly bundle served by the web app (requires `emscripten`, `zstd`, `wasm-opt`):

```
./build.sh
```

# Next steps

- Measure and improve the performance of the implementation
- Remove the finite intersection of boundaries precondition
- Simplify proofs, that take unnecessary detours, using latest models
- SVG import/export

# Related work

[Di Vito and Hocking (NASA Formal Methods 2021)](https://doi.org/10.1007/978-3-030-76384-8_6) verified a polygon *merge* algorithm in PVS, combining two overlapping simple polygons, computing a single outer boundary without holes.
