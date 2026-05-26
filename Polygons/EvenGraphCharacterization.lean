import Polygons.EvenGraphCharacterizationProofs

/-!
# Characterization of Even Graphs by Ray-Parity Interior

If a graph `G` has the property that no vertex lies in the interior of a
non-incident segment, and admits a set `I` of points in the plane that is
disjoint from `G`'s boundary and such that for every ray whose origin is
off the graph and that avoids the vertices of the graph, the number of
intersections with the graph is odd iff the origin of the ray lies in `I`,
then `G` is even (every vertex has even degree).

This file states a strengthened version that allows additional finite
"avoidance" parameters: `V_extra` is a finite set of vertices the ray's
support must avoid, and `S_extra` is a finite set of extra non-degenerate
segments whose support the ray's origin must avoid. The parity ↔ membership
in `I` only needs to hold for rays satisfying these additional constraints.

The proof lives in `EvenGraphCharacterizationProofs.lean`.
-/

open Classical Set

noncomputable section

/-- A graph whose ray-parity interior is realised by some subset of the plane
    is necessarily even.

    Concretely, suppose:
    * `S_extra` is a finite list of non-degenerate "extra" segments (each
      `seg ∈ S_extra` satisfies `seg.p1 ≠ seg.p2`).
    * `V_extra` is a finite set of "extra" vertices.
    * `h_no_segment_interior_vertices`: no graph vertex lies in the interior of a non-incident
      segment of `G`, nor in the interior of a non-incident segment of
      `S_extra` (every vertex `v ∈ G.toVertices` is only touched by its
      incident segments in `G ∪ S_extra`).
    * `h_exists`: there exists a set `I ⊆ Vector2D` disjoint from the
      graph's boundary such that, for every ray `r` whose origin avoids the
      graph's boundary and the supports of all `S_extra` segments, whose
      support avoids the graph's vertices, and whose support avoids all
      points in `V_extra`, the parity of the number of graph-segment
      intersections of `r` is odd iff `r.origin ∈ I`.

    Then `G.IsEven`: every vertex of `G` has even degree. -/
theorem Graph.isEven_of_exists_interior_set
    (G : Graph)
    (V_extra : Finset Vector2D)
    (S_extra : Finset LineSegment)
    (h_S_extra_nondeg : ∀ seg ∈ S_extra, seg.p1 ≠ seg.p2)
    (h_no_segment_interior_vertices : ∀ v ∈ G.toVertices,
      (∀ seg ∈ G.segments, seg.p1 ≠ v → seg.p2 ≠ v → v ∉ seg.toSet) ∧
      (∀ seg ∈ S_extra, seg.p1 ≠ v → seg.p2 ≠ v → v ∉ seg.toSet))
    (h_exists : ∃ I : Set Vector2D,
      I ∩ G.toBoundarySet = ∅ ∧
      ∀ r : Ray,
        r.origin ∉ G.toBoundarySet →
        (∀ s ∈ S_extra, r.origin ∉ s.toSet) →
        rayAvoidsGraphVertices r G →
        (∀ v ∈ V_extra, v ∉ r.toSet) →
        (intersectionRayGraphSegmentsNumber r G % 2 = 1 ↔ r.origin ∈ I)) :
    G.IsEven :=
  EvenGraphCharacterizationProofs.isEven_of_exists_interior_set G V_extra S_extra
    h_S_extra_nondeg h_no_segment_interior_vertices h_exists

end
