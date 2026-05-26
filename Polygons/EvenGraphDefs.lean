import Polygons.HelperDefs
import Polygons.GraphDefs
import Mathlib.Data.Multiset.Basic
import Mathlib.Data.List.Perm.Basic

/-!
# Even Graph Definitions

Core definitions for graphs where every vertex has even degree.
-/

open Classical List

noncomputable section

/-- A graph where every vertex has even degree.
    Consists of a list of non-degenerate line segments where, for every point in
    the plane, the number of segments incident to that point is even. -/
structure EvenGraph extends Graph where
  /-- Every point has even degree (the count is `0` for non-endpoints). -/
  even_degree : toGraph.IsEven

/-- Unordered endpoints of a line segment, as a multiset. Two line segments
    with swapped endpoints have the same `toEndpointsMultiset`. -/
def LineSegment.toEndpointsMultiset (s : LineSegment) : Multiset Vector2D :=
  {s.p1, s.p2}

/-- Equivalence of even graphs: their segment lists are a permutation
    when each segment is identified with its unordered endpoint-multiset
    (so a segment is identified with its reverse). -/
def EvenGraph.Equiv (G1 G2 : EvenGraph) : Prop :=
  G1.segments.map LineSegment.toEndpointsMultiset ~
  G2.segments.map LineSegment.toEndpointsMultiset

/-- Coerce an even graph to its underlying graph. Lets us pass an `EvenGraph`
    to graph-level functions like `intersectionRayGraphSegmentsNumber` and
    `rayAvoidsGraphVertices` without writing `.toGraph` each time. -/
instance : Coe EvenGraph Graph := ⟨EvenGraph.toGraph⟩

/-- The interior of an even graph: the set of points not on any edge such that
    every ray from the point that avoids the graph's vertices
    intersects an odd number of graph segments. -/
def EvenGraph.interior (G : EvenGraph) : Set Vector2D :=
  { p : Vector2D |
    (∀ seg ∈ G.segments, pointAvoidsSegment p seg) ∧
    ∀ r : Ray, r.origin = p → rayAvoidsGraphVertices r G →
      intersectionRayGraphSegmentsNumber r G % 2 = 1 }

end
