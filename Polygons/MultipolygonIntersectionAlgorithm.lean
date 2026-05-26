import Polygons.MultipolygonIntersectionAlgorithmProofs

/-!
# Multipolygon Intersection Algorithm – Interface

A *computable* algorithm `multipolygonIntersectionAlgorithm : Multipolygon →
Multipolygon → Multipolygon` together with the correctness theorem
`multipolygonIntersectionAlgorithm_interior_eq` whose conclusion is the
multipolygon-level analog of `exists_multipolygon_inter_interior_eq_multipolygon_interior`.

The algorithm refines each polygon segment of `m1` at all rational
intersections with the segments of `m2` together with all of `m1`'s own
polygon vertices that fall in the segment interior (and symmetrically for
`m2`), selects refined segments whose midpoint lies inside the *other
multipolygon* (decided by direct ray casting against the full multipolygon —
not per-polygon-pair, avoiding spurious duplicate segments from multiple
polygon-pair combinations), then greedily decomposes the combined even graph
into polygons using a fuel-based Eulerian-circuit walk, wrapping the result
as a `Multipolygon`.

Implementation and proofs live in `MultipolygonIntersectionAlgorithmImpl.lean`.
-/

open Set

/-- The computable multipolygon intersection algorithm. -/
def multipolygonIntersectionAlgorithm (m1 m2 : Multipolygon) : Multipolygon :=
  MultipolygonIntersectionAlgorithmImpl.multipolygonIntersectionAlgorithm m1 m2

/-- Correctness theorem: the interior intersection equals the interior of the
    multipolygon produced by the algorithm. -/
theorem multipolygonIntersectionAlgorithm_interior_eq
    (m1 m2 : Multipolygon)
    (h1_len : ∀ poly ∈ m1.polygons, poly.vertices.length ≥ 2)
    (h2_len : ∀ poly ∈ m2.polygons, poly.vertices.length ≥ 2)
    (h1_nondeg : ∀ seg ∈ m1.segments, seg.p1 ≠ seg.p2)
    (h2_nondeg : ∀ seg ∈ m2.segments, seg.p1 ≠ seg.p2)
    (h_fin : Set.Finite (m1.toBoundarySet ∩ m2.toBoundarySet)) :
    m1.interior ∩ m2.interior =
      (multipolygonIntersectionAlgorithm m1 m2).interior :=
  MultipolygonIntersectionAlgorithmProofs.multipolygonIntersectionAlgorithm_correct
    m1 m2 h1_len h2_len h1_nondeg h2_nondeg h_fin

/-! ## Example: two unit squares, shifted by `(1/2, 1/2)`.
The intersection is a single `1/2 × 1/2` square (as a singleton multipolygon). -/

deriving instance Repr for Polygon
deriving instance Repr for Multipolygon

namespace MultipolygonIntersectionAlgorithmExample

/-- Multipolygon 1: a single unit square at the origin. -/
def square1 : Multipolygon :=
  ⟨[⟨[⟨0, 0⟩, ⟨1, 0⟩, ⟨1, 1⟩, ⟨0, 1⟩]⟩]⟩

/-- Multipolygon 2: a single unit square translated by `(1/2, 1/2)`. -/
def square2 : Multipolygon :=
  ⟨[⟨[⟨1/2, 1/2⟩, ⟨3/2, 1/2⟩, ⟨3/2, 3/2⟩, ⟨1/2, 3/2⟩]⟩]⟩

/-- The intersection: a singleton multipolygon containing a square
    whose vertex sequence encodes the boundary of
    `square1.interior ∩ square2.interior`. -/
example : (multipolygonIntersectionAlgorithm square1 square2).polygons.map (·.vertices) =
    [[⟨1, 1/2⟩, ⟨1, 1⟩, ⟨1/2, 1⟩, ⟨1/2, 1/2⟩]] := by
  native_decide

end MultipolygonIntersectionAlgorithmExample
