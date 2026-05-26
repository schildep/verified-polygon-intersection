import Polygons.EvenGraphIntersectionProofs

/-!
# Even Graph Intersection – Interface

Given two even graphs whose boundaries intersect finitely,
construct the **intersection graph** whose ray-parity interior
equals the set-theoretic intersection of the input interiors.

The intersection graph is formed by:
1. Refining each graph with respect to the other (so every segment
   is either completely inside or completely outside the other interior).
2. Selecting the segments from each refined graph that lie inside the
   other graph's interior.
3. Taking the union of the two selected segment families as a single graph.

The key parity result (`evenGraphIntersection_parity`) is proved by an
elementary pair-counting argument: along a ray, for each pair of G₁'/G₂'
crossings exactly one has the smaller parameter (no ties by refinement),
so the sum of "inside-G₂ for each G₁'-crossing" and "inside-G₁ for each
G₂'-crossing" has the parity of `n₁·n₂`.

Proofs live in `EvenGraphIntersectionProofs.lean`.
-/

open Classical Set

noncomputable section

/-- Flip the order of the intersection in a finiteness hypothesis on a pair of
    even-graph boundaries. Lets public APIs take only the `G1 ∩ G2` hypothesis. -/
lemma flipFin {G1 G2 : EvenGraph}
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    Set.Finite (G2.toBoundarySet ∩ G1.toBoundarySet) :=
  EvenGraphIntersectionProofs.flipFin h_fin12

/-- The intersection of two even graphs `G1` and `G2`, as a `Graph`.
    Built from the segments of the refinement of `G1` (with respect to `G2`)
    that lie inside `G2.interior`, together with the segments of the
    refinement of `G2` (with respect to `G1`) that lie inside `G1.interior`. -/
def evenGraphIntersection (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) : Graph :=
  ((graphRefinementSelfAndWrt G1 G2 h_fin12).toGraph.selectSegmentsInside G2.interior).append
    ((graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)).toGraph.selectSegmentsInside G1.interior)

/-- The boundary of the intersection graph: the union of all its segments. -/
def evenGraphIntersectionBoundary (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    Set Vector2D :=
  (evenGraphIntersection G1 G2 h_fin12).toBoundarySet

/-- The number of intersection-graph segments that a ray crosses. -/
noncomputable def evenGraphIntersectionRayCount (r : Ray) (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) : ℕ :=
  intersectionRayGraphSegmentsNumber r (evenGraphIntersection G1 G2 h_fin12)

/-- The interior of the intersection graph, defined via ray-crossing parity
    on the intersection segments. A point is interior iff it avoids both
    refined graph boundaries and every ray from it (avoiding both refined
    vertex sets) crosses an odd number of intersection segments. -/
def evenGraphIntersectionInterior (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    Set Vector2D :=
  { p : Vector2D |
    (∀ seg ∈ (graphRefinementSelfAndWrt G1 G2 h_fin12).segments, pointAvoidsSegment p seg) ∧
    (∀ seg ∈ (graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)).segments,
      pointAvoidsSegment p seg) ∧
    ∀ r : Ray, r.origin = p →
      rayAvoidsGraphVertices r (graphRefinementSelfAndWrt G1 G2 h_fin12) →
      rayAvoidsGraphVertices r (graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)) →
      evenGraphIntersectionRayCount r G1 G2 h_fin12 % 2 = 1 }

/-- The parity of `evenGraphIntersectionRayCount` is odd if and only if the
    ray crosses both input graphs an odd number of times. Proved by an elementary
    pair count (see `EvenGraphIntersectionProofs.intersectionRayCount_parity`). -/
theorem evenGraphIntersection_parity
    (r : Ray) (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet))
    (h_avoids1 : rayAvoidsGraphVertices r (graphRefinementSelfAndWrt G1 G2 h_fin12))
    (h_avoids2 : rayAvoidsGraphVertices r
      (graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)))
    (h_origin_avoids1 : ∀ seg ∈ (graphRefinementSelfAndWrt G1 G2 h_fin12).segments,
      pointAvoidsSegment r.origin seg)
    (h_origin_avoids2 : ∀ seg ∈ (graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)).segments,
      pointAvoidsSegment r.origin seg) :
    evenGraphIntersectionRayCount r G1 G2 h_fin12 % 2 = 1 ↔
    (intersectionRayGraphSegmentsNumber r (graphRefinementSelfAndWrt G1 G2 h_fin12) % 2 = 1 ∧
     intersectionRayGraphSegmentsNumber r
       (graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)) % 2 = 1) :=
  EvenGraphIntersectionProofs.intersectionRayCount_parity
    r G1 G2 h_fin12 h_avoids1 h_avoids2 h_origin_avoids1 h_origin_avoids2

/-- The interior of the intersection graph equals the intersection of
    the interiors of the two input graphs. -/
theorem evenGraphIntersection_interior_eq_helper
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    evenGraphIntersectionInterior G1 G2 h_fin12 =
    G1.interior ∩ G2.interior :=
  EvenGraphIntersectionProofs.intersectionInterior_eq_helper G1 G2 h_fin12

/-- The ∃-ray version of the intersection-graph interior: the set of points `p`
    that avoid both refined graphs' boundaries and admit *some* ray from `p`
    avoiding both refined graphs' vertices and crossing the intersection graph
    an odd number of times. Equals the intersection of the two input interiors. -/
def evenGraphIntersectionInteriorExists (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    Set Vector2D :=
  { p : Vector2D |
    (∀ seg ∈ (graphRefinementSelfAndWrt G1 G2 h_fin12).segments, pointAvoidsSegment p seg) ∧
    (∀ seg ∈ (graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)).segments,
      pointAvoidsSegment p seg) ∧
    ∃ r : Ray, r.origin = p ∧
      rayAvoidsGraphVertices r (graphRefinementSelfAndWrt G1 G2 h_fin12) ∧
      rayAvoidsGraphVertices r (graphRefinementSelfAndWrt G2 G1 (flipFin h_fin12)) ∧
      evenGraphIntersectionRayCount r G1 G2 h_fin12 % 2 = 1 }

/-- The ∃-ray version of the intersection interior helper: just one witness ray
    suffices to certify that a point lies in `G1.interior ∩ G2.interior`. -/
theorem evenGraphIntersection_interior_eq_exists_helper
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    evenGraphIntersectionInteriorExists G1 G2 h_fin12 =
    G1.interior ∩ G2.interior :=
  EvenGraphIntersectionProofs.intersectionInteriorExists_eq_helper G1 G2 h_fin12

/-- The intersection graph of two even graphs (with finite boundary
    intersections) is itself an even graph, and the `EvenGraph.interior` of
    its even-graph wrapping equals the set-theoretic intersection of the
    interiors of the two input graphs. -/
theorem evenGraphIntersection_isEven_and_interior_eq
    (G1 G2 : EvenGraph)
    (h_fin12 : Set.Finite (G1.toBoundarySet ∩ G2.toBoundarySet)) :
    ∃ h_even : (evenGraphIntersection G1 G2 h_fin12).IsEven,
      (⟨evenGraphIntersection G1 G2 h_fin12, h_even⟩ : EvenGraph).interior =
        G1.interior ∩ G2.interior :=
  EvenGraphIntersectionProofs.intersection_isEven_and_interior_eq
    G1 G2 h_fin12

end
