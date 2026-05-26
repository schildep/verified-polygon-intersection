import Polygons.PolygonIntersectionHelpersProofs

/-!
# Polygon Refinement – Interface

`polygonRefinement` inserts a point on an edge of a polygon as a new vertex,
producing a refined polygon with the same boundary and the same interior.

Implementation and proofs live in `PolygonIntersectionHelpersProofs.lean`.
-/

open Set

noncomputable section

/-- Given a polygon, a segment (edge) of that polygon, and a point on the segment,
    return the polygon with the point inserted as a new vertex in that segment. -/
def polygonRefinement (poly : Polygon) (seg : LineSegment) (pt : Vector2D) : Polygon :=
  PolygonIntersectionHelpersProofs.polygonRefinement poly seg pt

/-- The boundary of the refined polygon equals the boundary of the original polygon. -/
theorem polygonRefinement_boundary_eq
    (poly : Polygon) (seg : LineSegment) (pt : Vector2D)
    (h_seg : seg ∈ poly.segments) (h_pt : pt ∈ seg.toSet) :
    (polygonRefinement poly seg pt).toBoundarySet = poly.toBoundarySet :=
  PolygonIntersectionHelpersProofs.refinement_boundary_eq poly seg pt h_seg h_pt

/-- The vertex count of the refined polygon is one more than the original. -/
theorem polygonRefinement_vertices_length
    (poly : Polygon) (seg : LineSegment) (pt : Vector2D)
    (h_seg : seg ∈ poly.segments) :
    (polygonRefinement poly seg pt).vertices.length = poly.vertices.length + 1 :=
  PolygonIntersectionHelpersProofs.polygonRefinement_vertices_length poly seg pt h_seg

/-- Every vertex of the refined polygon is either a vertex of the original polygon or
    equals the inserted point. -/
theorem polygonRefinement_vertex_mem_or_eq
    (poly : Polygon) (seg : LineSegment) (pt : Vector2D)
    (v : Vector2D) (hv : v ∈ (polygonRefinement poly seg pt).vertices) :
    v ∈ poly.vertices ∨ v = pt :=
  PolygonIntersectionHelpersProofs.polygonRefinement_vertex_mem_or_eq poly seg pt v hv

/-- The segments of the refined polygon, augmented with the replaced edge `seg`, form a
    permutation of the original polygon's segments augmented with the two new sub-edges
    `⟨seg.p1, pt⟩` and `⟨pt, seg.p2⟩`. -/
theorem polygonRefinement_segments_perm
    (poly : Polygon) (seg : LineSegment) (pt : Vector2D)
    (h_seg : seg ∈ poly.segments) (h_pt : pt ∈ seg.toSet) :
    ((polygonRefinement poly seg pt).segments ++ [seg]).Perm
    (poly.segments ++ [⟨seg.p1, pt⟩, ⟨pt, seg.p2⟩]) :=
  PolygonIntersectionHelpersProofs.polygonRefinement_segments_perm poly seg pt h_seg h_pt

/-- The interior of the refined polygon equals the interior of the original polygon. -/
theorem polygonRefinement_interior_eq
    (poly : Polygon) (seg : LineSegment) (pt : Vector2D)
    (h_seg : seg ∈ poly.segments) (h_pt : pt ∈ seg.toSet) :
    (polygonRefinement poly seg pt).interior = poly.interior :=
  PolygonIntersectionHelpersProofs.refinement_interior_eq poly seg pt h_seg h_pt

/-- Given two polygons whose boundaries intersect in finitely many points,
    refine the first polygon by inserting all boundary intersection points
    as new vertices. The resulting polygon has the same boundary and interior. -/
def polygonRefinementWrt
    (poly1 poly2 : Polygon)
    (h_fin : Set.Finite (poly1.toBoundarySet ∩ poly2.toBoundarySet)) : Polygon :=
  PolygonIntersectionHelpersProofs.polygonRefinementWrt poly1 poly2 h_fin

/-- The boundary of the polygon refined with respect to another polygon
    equals the boundary of the original polygon. -/
theorem polygonRefinementWrt_boundary_eq
    (poly1 poly2 : Polygon)
    (h_fin : Set.Finite (poly1.toBoundarySet ∩ poly2.toBoundarySet)) :
    (polygonRefinementWrt poly1 poly2 h_fin).toBoundarySet = poly1.toBoundarySet :=
  PolygonIntersectionHelpersProofs.refinementWrt_boundary_eq poly1 poly2 h_fin

/-- The interior of the polygon refined with respect to another polygon
    equals the interior of the original polygon. -/
theorem polygonRefinementWrt_interior_eq
    (poly1 poly2 : Polygon)
    (h_fin : Set.Finite (poly1.toBoundarySet ∩ poly2.toBoundarySet)) :
    (polygonRefinementWrt poly1 poly2 h_fin).interior = poly1.interior :=
  PolygonIntersectionHelpersProofs.refinementWrt_interior_eq poly1 poly2 h_fin

/-- Each segment of the refined polygon can only intersect the other polygon's boundary
    at the segment's endpoints. -/
theorem polygonRefinementWrt_seg_inter_boundary_subset
    (poly1 poly2 : Polygon)
    (h_fin : Set.Finite (poly1.toBoundarySet ∩ poly2.toBoundarySet))
    (seg : LineSegment)
    (h_seg : seg ∈ (polygonRefinementWrt poly1 poly2 h_fin).segments) :
    seg.toSet ∩ poly2.toBoundarySet ⊆ ({seg.p1, seg.p2} : Set Vector2D) :=
  PolygonIntersectionHelpersProofs.refinementWrt_seg_inter_boundary_subset poly1 poly2 h_fin seg h_seg
