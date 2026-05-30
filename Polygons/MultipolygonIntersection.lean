import Polygons.MultipolygonIntersectionProofs

/-!
# Multipolygon Intersection – Interface

For any two multipolygons whose polygons all have at least two vertices and
non-degenerate segments, the intersection of their interiors is itself the
interior of a single multipolygon.

Proofs live in `MultipolygonIntersectionProofs.lean`.
-/

open Classical Set

noncomputable section

/-- Existence of a multipolygon whose interior equals the intersection of the
    interiors of `m1` and `m2`. -/
theorem exists_multipolygon_inter_interior_eq_multipolygon_interior
    (m1 m2 : Multipolygon)
    (h1_len : ∀ poly ∈ m1.polygons, poly.vertices.length ≥ 2)
    (h2_len : ∀ poly ∈ m2.polygons, poly.vertices.length ≥ 2)
    (h1_nondeg : ∀ seg ∈ m1.segments, seg.p1 ≠ seg.p2)
    (h2_nondeg : ∀ seg ∈ m2.segments, seg.p1 ≠ seg.p2) :
    ∃ m : Multipolygon, m1.interior ∩ m2.interior = m.interior :=
  MultipolygonIntersectionProofs.exists_multipolygon_inter_interior_eq_multipolygon_interior_impl
    m1 m2 h1_len h2_len h1_nondeg h2_nondeg

end
