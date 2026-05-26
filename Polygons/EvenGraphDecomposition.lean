import Polygons.EvenGraphDecompositionProofs

/-!
# Even Graph Decomposition into Polygons – Interface

Every even graph is `EvenGraph.Equiv`-equivalent (up to direction) to
a `EvenGraph.combine` of even graphs, each obtained from a polygon
via `Polygon.toEvenGraph`.

Because `LineSegment` is directional but `EvenGraph`'s even-degree
condition is direction-agnostic, the comparison has to be at the level of
unordered endpoint multisets, which is exactly `EvenGraph.Equiv`.
-/

open Classical List

noncomputable section

/-- Every even graph is equivalent to the combination of even graphs
    obtained from a list of polygons via `Polygon.toEvenGraph`. -/
theorem EvenGraph.exists_polygon_decomposition (G : EvenGraph) :
    ∃ polyGraphs : List EvenGraph,
      (∀ pG ∈ polyGraphs,
        ∃ poly : Polygon,
        ∃ h_len : poly.vertices.length ≥ 2,
        ∃ h_distinct : ∀ seg ∈ poly.segments, seg.p1 ≠ seg.p2,
          pG = poly.toEvenGraph h_len h_distinct) ∧
      G.Equiv (EvenGraph.combine polyGraphs) :=
  EvenGraphDecompositionProofs.exists_polygon_decomposition G

end
