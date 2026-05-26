import Polygons.MultipolygonProofs

/-!
# Multipolygon Interior via Ray Crossing Parity

A `Multipolygon` is a list of polygons (i.e. a list of lists of vertices). Its
`interior` is defined by the ray-crossing parity rule applied to all polygon
segments – analogous to `Polygon.interior` but counting crossings over every
polygon's edges at once.

This file exposes `Multipolygon.toEvenGraph`, the even graph obtained by
combining the polygon-derived even graphs, together with theorems linking the
multipolygon's segments, boundary, vertex set, and interior to those of the
even graph. As a corollary, the multipolygon interior is the symmetric
difference of the polygon interiors, with the multipolygon boundary removed.

Proofs live in `MultipolygonProofs.lean`.
-/

open Classical Set

noncomputable section

/-- The even graph obtained from a multipolygon (combining the polygon-derived
    even graphs of its polygons). -/
def Multipolygon.toEvenGraph (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    EvenGraph :=
  MultipolygonProofs.toEvenGraph m h_len h_distinct

/-- The segments of the even graph obtained from a multipolygon equal the
    multipolygon segments. -/
theorem Multipolygon.toEvenGraph_segments_eq (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    (m.toEvenGraph h_len h_distinct).segments = m.segments :=
  MultipolygonProofs.toEvenGraph_segments_eq m h_len h_distinct

/-- The boundary of the even graph obtained from a multipolygon equals the
    multipolygon boundary. -/
theorem Multipolygon.toEvenGraph_toBoundarySet_eq (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    (m.toEvenGraph h_len h_distinct).toBoundarySet = m.toBoundarySet :=
  MultipolygonProofs.toEvenGraph_toBoundarySet_eq m h_len h_distinct

/-- The vertex set of the even graph obtained from a multipolygon equals the
    multipolygon's vertex set. -/
theorem Multipolygon.toEvenGraph_toVertexSet_eq (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    (m.toEvenGraph h_len h_distinct).toVertexSet = m.toVertices :=
  MultipolygonProofs.toEvenGraph_toVertexSet_eq m h_len h_distinct

/-- The interior of the even graph obtained from a multipolygon equals the
    multipolygon interior. -/
theorem Multipolygon.toEvenGraph_interior_eq (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    (m.toEvenGraph h_len h_distinct).interior = m.interior :=
  MultipolygonProofs.toEvenGraph_interior_eq m h_len h_distinct

/-- For a multipolygon satisfying length and non-degeneracy hypotheses, every
    vertex in `allVertices` lies on some multipolygon segment. -/
theorem Multipolygon.vertex_on_some_segment (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2)
    (v : Vector2D) (hv : v ∈ m.allVertices) :
    ∃ seg ∈ m.segments, v ∈ seg.toSet :=
  MultipolygonProofs.vertex_on_some_segment m h_len h_distinct v hv

/-- The interior of a multipolygon characterized via *some* ray (rather than
    *every* ray), analogous to `Polygon.interior_eq_exists`. -/
theorem Multipolygon.interior_eq_exists (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    m.interior =
    { p : Vector2D |
        (∀ seg ∈ m.segments, pointAvoidsSegment p seg) ∧
        ∃ r : Ray, r.origin = p ∧ rayAvoidsMultipolygonVertices r m ∧
          intersectionRayMultipolygonSegmentsNumber r m % 2 = 1 } :=
  MultipolygonProofs.interior_eq_exists m h_len h_distinct

/-- The interior of a multipolygon equals the symmetric difference of its
    polygons' interiors, with the multipolygon boundary removed. -/
theorem Multipolygon.interior_eq_symmDiffAll_sdiff_boundary (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    m.interior =
      (m.polygons.map Polygon.interior).symmDiffAll \ m.toBoundarySet :=
  MultipolygonProofs.interior_eq_symmDiffAll_sdiff_boundary m h_len h_distinct

end
