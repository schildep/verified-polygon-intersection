import Polygons.EvenGraphRefinementProofs

/-!
# Even Graph Refinement – Interface

`graphRefinement` inserts a point on an edge of an even graph as a new vertex,
producing a refined graph with the same boundary and the same interior.

`graphRefinementWrt` inserts all boundary intersection points with another graph
as new vertices, ensuring that each resulting segment can only intersect the
other graph's boundary at the segment's endpoints.
-/

open Set

noncomputable section

/-- Given an even graph, a segment (edge) of that graph, and a point on the
    segment, return the graph with the point inserted as a new vertex,
    splitting the segment into two. -/
def graphRefinement (G : EvenGraph) (seg : LineSegment) (pt : Vector2D)
    (h_seg : seg ∈ G.segments) (h_pt : pt ∈ seg.toSet) : EvenGraph :=
  EvenGraphRefinementProofs.graphRefinement G seg pt h_seg h_pt

/-- The boundary of the refined graph equals the boundary of the original graph. -/
theorem graphRefinement_boundary_eq
    (G : EvenGraph) (seg : LineSegment) (pt : Vector2D)
    (h_seg : seg ∈ G.segments) (h_pt : pt ∈ seg.toSet) :
    (graphRefinement G seg pt h_seg h_pt).toBoundarySet = G.toBoundarySet :=
  EvenGraphRefinementProofs.refinement_boundary_eq G seg pt h_seg h_pt

/-- The interior of the refined graph equals the interior of the original graph. -/
theorem graphRefinement_interior_eq
    (G : EvenGraph) (seg : LineSegment) (pt : Vector2D)
    (h_seg : seg ∈ G.segments) (h_pt : pt ∈ seg.toSet) :
    (graphRefinement G seg pt h_seg h_pt).interior = G.interior :=
  EvenGraphRefinementProofs.refinement_interior_eq G seg pt h_seg h_pt

/-- Given two even graphs whose boundaries intersect in finitely many points,
    refine the first graph by inserting all boundary intersection points
    as new vertices. The resulting graph has the same boundary and interior. -/
def graphRefinementWrt
    (G1 G2 : EvenGraph)
    (h_fin : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) : EvenGraph :=
  EvenGraphRefinementProofs.graphRefinementWrt G1 G2 h_fin

/-- The boundary of the graph refined with respect to another graph
    equals the boundary of the original graph. -/
theorem graphRefinementWrt_boundary_eq
    (G1 G2 : EvenGraph)
    (h_fin : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    (graphRefinementWrt G1 G2 h_fin).toBoundarySet = G1.toBoundarySet :=
  EvenGraphRefinementProofs.refinementWrt_boundary_eq G1 G2 h_fin

/-- The interior of the graph refined with respect to another graph
    equals the interior of the original graph. -/
theorem graphRefinementWrt_interior_eq
    (G1 G2 : EvenGraph)
    (h_fin : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    (graphRefinementWrt G1 G2 h_fin).interior = G1.interior :=
  EvenGraphRefinementProofs.refinementWrt_interior_eq G1 G2 h_fin

/-- Each segment of the refined graph can only intersect the other graph's boundary
    at the segment's endpoints. -/
theorem graphRefinementWrt_seg_inter_boundary_subset
    (G1 G2 : EvenGraph)
    (h_fin : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet))
    (seg : LineSegment)
    (h_seg : seg ∈ (graphRefinementWrt G1 G2 h_fin).segments) :
    seg.toSet ∩ G2.toBoundarySet ⊆ ({seg.p1, seg.p2} : Set Vector2D) :=
  EvenGraphRefinementProofs.refinementWrt_seg_inter_boundary_subset G1 G2 h_fin seg h_seg

/-- Self-refinement: refine `G` at all vertices of `G` that lie strictly in
    the interior of some segment of `G`. The resulting graph has the same
    boundary, the same interior, and no vertex lies in any segment interior. -/
def graphRefinementSelf (G : EvenGraph) : EvenGraph :=
  EvenGraphRefinementProofs.graphRefinementSelf G

/-- The boundary of the self-refined graph equals the boundary of the original. -/
theorem graphRefinementSelf_boundary_eq (G : EvenGraph) :
    (graphRefinementSelf G).toBoundarySet = G.toBoundarySet :=
  EvenGraphRefinementProofs.refinementSelf_boundary_eq G

/-- The interior of the self-refined graph equals the interior of the original. -/
theorem graphRefinementSelf_interior_eq (G : EvenGraph) :
    (graphRefinementSelf G).interior = G.interior :=
  EvenGraphRefinementProofs.refinementSelf_interior_eq G

/-- After self-refinement, no vertex lies in the interior of another segment:
    every vertex `v` lying on a segment must be one of its endpoints. -/
theorem graphRefinementSelf_no_segment_interior_vertices (G : EvenGraph) :
    ∀ v ∈ (graphRefinementSelf G).toVertices,
      ∀ seg ∈ (graphRefinementSelf G).segments,
        seg.p1 ≠ v → seg.p2 ≠ v → v ∉ seg.toSet :=
  EvenGraphRefinementProofs.refinementSelf_no_segment_interior_vertices G

/-- Combined refinement: first apply self-refinement to `G1` (eliminating
    vertices lying in segment interiors), then refine with respect to the
    boundary intersections with `G2`. The resulting graph has the same
    boundary, the same interior as `G1`, each segment intersects `G2`'s
    boundary only at its endpoints, and no vertex lies in any segment interior. -/
def graphRefinementSelfAndWrt
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) : EvenGraph :=
  EvenGraphRefinementProofs.graphRefinementSelfAndWrt G1 G2 h_fin12

/-- The boundary of the combined-refined graph equals the boundary of `G1`. -/
theorem graphRefinementSelfAndWrt_boundary_eq
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    (graphRefinementSelfAndWrt G1 G2 h_fin12).toBoundarySet = G1.toBoundarySet :=
  EvenGraphRefinementProofs.refinementSelfAndWrt_boundary_eq G1 G2 h_fin12

/-- The interior of the combined-refined graph equals the interior of `G1`. -/
theorem graphRefinementSelfAndWrt_interior_eq
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    (graphRefinementSelfAndWrt G1 G2 h_fin12).interior = G1.interior :=
  EvenGraphRefinementProofs.refinementSelfAndWrt_interior_eq G1 G2 h_fin12

/-- Each segment of the combined-refined graph can only intersect `G2`'s
    boundary at the segment's endpoints. -/
theorem graphRefinementSelfAndWrt_seg_inter_boundary_subset
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet))
    (seg : LineSegment)
    (h_seg : seg ∈ (graphRefinementSelfAndWrt G1 G2 h_fin12).segments) :
    seg.toSet ∩ G2.toBoundarySet ⊆ ({seg.p1, seg.p2} : Set Vector2D) :=
  EvenGraphRefinementProofs.refinementSelfAndWrt_seg_inter_boundary_subset
    G1 G2 h_fin12 seg h_seg

/-- After combined refinement, no vertex lies in the interior of another
    segment: every vertex `v` lying on a segment must be one of its endpoints. -/
theorem graphRefinementSelfAndWrt_no_segment_interior_vertices
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    ∀ v ∈ (graphRefinementSelfAndWrt G1 G2 h_fin12).toVertices,
      ∀ seg ∈ (graphRefinementSelfAndWrt G1 G2 h_fin12).segments,
        seg.p1 ≠ v → seg.p2 ≠ v → v ∉ seg.toSet :=
  EvenGraphRefinementProofs.refinementSelfAndWrt_no_segment_interior_vertices G1 G2 h_fin12

end
