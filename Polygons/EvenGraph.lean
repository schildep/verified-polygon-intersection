import Polygons.EvenGraphProofs

/-!
# Even Graphs: Interior via Ray Crossing Parity

This file defines the interior of an even graph (a graph where every
vertex has even degree) using the ray-crossing parity rule, generalizing the
polygon interior definition from `Polygon.lean`.

A point is in the interior if every ray from it (avoiding graph vertices)
crosses an odd number of graph edges.
-/

open Classical Set List

noncomputable section

/-- Combine a list of even graphs into one by concatenating their segment
    lists. Non-degeneracy holds segment-wise; even-degree follows because
    a sum of even numbers is even. -/
def EvenGraph.combine (Gs : List EvenGraph) : EvenGraph :=
  EvenGraphProofs.combine Gs

/-- The segments of a combined even graph are the concatenation of the
    components' segments. -/
@[simp] theorem EvenGraph.combine_segments (Gs : List EvenGraph) :
    (EvenGraph.combine Gs).segments = Gs.flatMap (·.segments) :=
  rfl

/-- Equivalent even graphs have the same boundary set. -/
theorem EvenGraph.Equiv.toBoundarySet_eq {G1 G2 : EvenGraph}
    (h : G1.Equiv G2) : G1.toBoundarySet = G2.toBoundarySet :=
  EvenGraphProofs.Equiv_toBoundarySet_eq h

/-- Equivalent even graphs have the same vertex set. -/
theorem EvenGraph.Equiv.toVertexSet_eq {G1 G2 : EvenGraph}
    (h : G1.Equiv G2) : G1.toVertexSet = G2.toVertexSet :=
  EvenGraphProofs.Equiv_toVertexSet_eq h

/-- Equivalent even graphs have the same interior. -/
theorem EvenGraph.Equiv.interior_eq {G1 G2 : EvenGraph}
    (h : G1.Equiv G2) : G1.interior = G2.interior :=
  EvenGraphProofs.Equiv_interior_eq h

/-- The boundary of a combined even graph is the union of the
    component boundaries. -/
theorem EvenGraph.combine_toBoundarySet (Gs : List EvenGraph) :
    (EvenGraph.combine Gs).toBoundarySet = ⋃ G ∈ Gs, G.toBoundarySet :=
  EvenGraphProofs.combine_toBoundarySet Gs

/-- The vertex set of a combined even graph is the union of the
    component vertex sets. -/
theorem EvenGraph.combine_toVertexSet (Gs : List EvenGraph) :
    (EvenGraph.combine Gs).toVertexSet = ⋃ G ∈ Gs, G.toVertexSet :=
  EvenGraphProofs.combine_toVertexSet_eq_iUnion Gs

/-- A point `p` lies in the interior of a combined even graph iff it avoids
    the combined boundary and an odd number of component interiors contain
    `p`: the interior is the XOR (symmetric difference) of the component
    interiors. -/
theorem EvenGraph.combine_interior_iff_xor (Gs : List EvenGraph) (p : Vector2D) :
    p ∈ (EvenGraph.combine Gs).interior ↔
    p ∉ (EvenGraph.combine Gs).toBoundarySet ∧
      Odd (Gs.countP (fun G => decide (p ∈ G.interior))) :=
  EvenGraphProofs.combine_interior_iff_xor Gs p

/-- The interior of a combined even graph is the symmetric difference of the
    component interiors with the combined boundary removed. -/
theorem EvenGraph.combine_interior_eq_symmDiff_sdiff_boundary
    (Gs : List EvenGraph) :
    (EvenGraph.combine Gs).interior =
    (Gs.map EvenGraph.interior).symmDiffAll \
      (EvenGraph.combine Gs).toBoundarySet :=
  EvenGraphProofs.combine_interior_eq_symmDiff_sdiff_boundary Gs

/-- The interior defined via the universal quantifier over rays equals the
    interior defined via the existential quantifier: it suffices that there
    exists one ray from the point (avoiding vertices) with an odd crossing number. -/
theorem EvenGraph.interior_eq_exists (G : EvenGraph) :
    G.interior =
    { p : Vector2D |
        (∀ seg ∈ G.segments, pointAvoidsSegment p seg) ∧
        ∃ r : Ray, r.origin = p ∧ rayAvoidsGraphVertices r G ∧
          intersectionRayGraphSegmentsNumber r G % 2 = 1 } :=
  EvenGraphProofs.interior_forall_eq_exists G

/-- The parity of the number of graph segments intersected by a ray is invariant
    for rays with the same origin, provided both rays avoid the graph's vertices. -/
theorem intersectionParity_eq_of_sameOrigin_avoidsGraphVertices
    (r1 r2 : Ray) (G : EvenGraph)
    (h_origin : sameOrigin r1 r2)
    (h_r1_avoids : rayAvoidsGraphVertices r1 G)
    (h_r2_avoids : rayAvoidsGraphVertices r2 G)
    (h_origin_avoids_segments : ∀ seg ∈ G.segments, pointAvoidsSegment r1.origin seg) :
    (intersectionRayGraphSegmentsNumber r1 G) % 2 =
    (intersectionRayGraphSegmentsNumber r2 G) % 2 :=
  EvenGraphProofs.intersectionParity_eq_of_sameOrigin_avoidsGraphVertices
    r1 r2 G h_origin h_r1_avoids h_r2_avoids h_origin_avoids_segments

/-- The parity of the number of graph segments intersected by a ray is invariant
    for rays whose origins are connected by a segment that avoids all graph segments. -/
theorem intersectionParity_eq_of_originSegmentAvoidsGraphSegments
    (r1 r2 : Ray) (G : EvenGraph)
    (h_r1_avoids : rayAvoidsGraphVertices r1 G)
    (h_r2_avoids : rayAvoidsGraphVertices r2 G)
    (h_origin_segment_avoids : ∀ seg ∈ G.segments,
      segmentDoesNotIntersectSegment ⟨r1.origin, r2.origin⟩ seg)
    (h_verts_avoid_origin_seg : ∀ v ∈ G.toVertices,
      v ∉ (LineSegment.mk r1.origin r2.origin).toSet) :
    (intersectionRayGraphSegmentsNumber r1 G) % 2 =
    (intersectionRayGraphSegmentsNumber r2 G) % 2 :=
  EvenGraphProofs.intersectionParity_eq_of_originSegmentAvoidsGraphSegments
    r1 r2 G h_r1_avoids h_r2_avoids h_origin_segment_avoids h_verts_avoid_origin_seg

/-- Convert a polygon (with ≥ 2 vertices and distinct consecutive vertices)
    to an even graph. -/
def Polygon.toEvenGraph (poly : Polygon) (h_len : poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ poly.segments, seg.p1 ≠ seg.p2) : EvenGraph :=
  EvenGraphProofs.polygonToEvenGraph poly h_len h_distinct

/-- The boundary of the even graph obtained from a polygon
    equals the boundary of the polygon. -/
theorem Polygon.toEvenGraph_boundary_eq (poly : Polygon) (h_len : poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ poly.segments, seg.p1 ≠ seg.p2) :
    (poly.toEvenGraph h_len h_distinct).toBoundarySet = poly.toBoundarySet :=
  EvenGraphProofs.polygonToEvenGraph_boundary_eq poly h_len h_distinct

/-- The vertex set of the even graph obtained from a polygon
    equals the vertex set of the polygon. -/
theorem Polygon.toEvenGraph_toVertexSet_eq (poly : Polygon)
    (h_len : poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ poly.segments, seg.p1 ≠ seg.p2) :
    (poly.toEvenGraph h_len h_distinct).toVertexSet = poly.toVertices :=
  EvenGraphProofs.polygonToEvenGraph_toVertexSet_eq poly h_len h_distinct

/-- The segments of the even graph obtained from a polygon equal the polygon's
    segments. -/
@[simp] theorem Polygon.toEvenGraph_segments_eq (poly : Polygon)
    (h_len : poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ poly.segments, seg.p1 ≠ seg.p2) :
    (poly.toEvenGraph h_len h_distinct).segments = poly.segments :=
  EvenGraphProofs.polygonToEvenGraph_segments_eq poly h_len h_distinct

/-- The interior of the even graph obtained from a polygon
    equals the interior of the polygon. -/
theorem Polygon.toEvenGraph_interior_eq (poly : Polygon) (h_len : poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ poly.segments, seg.p1 ≠ seg.p2) :
    (poly.toEvenGraph h_len h_distinct).interior = poly.interior :=
  EvenGraphProofs.polygonToEvenGraph_interior_eq poly h_len h_distinct

/-- For a half-plane intersection and an even graph, if no graph vertex lies on
    the HPI boundary, and every graph segment avoids the HPI vertices, then:
    1. Every segment's boundary crossings are finite.
    2. The total number of boundary crossings is even. -/
theorem HalfPlaneIntersection.graph_crossings_even
    (hpi : HalfPlaneIntersection) (G : EvenGraph)
    (h_vertices_not_boundary : ∀ v ∈ G.toVertices, v ∉ hpi.toBoundarySet)
    (h_avoids_vertices : ∀ seg ∈ G.segments, ∀ q ∈ seg.toSet, q ∉ hpi.toVertexSet) :
    (∀ seg ∈ G.segments, (seg.boundaryCrossings hpi).Finite) ∧
    Even ((G.segments.map fun seg => segCrossingCount seg hpi).sum) :=
  EvenGraphProofs.graph_crossings_even hpi G h_vertices_not_boundary h_avoids_vertices

end
