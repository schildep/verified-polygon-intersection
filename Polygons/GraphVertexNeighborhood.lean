import Polygons.HelperDefs
import Polygons.GraphDefs
import Polygons.GraphVertexNeighborhoodProofs

/-!
# Graph Vertex Neighborhood

Helper theorems about neighborhoods of graph vertices: given rays
emanating from a common origin with pairwise distinct directions,
construct a polygon around the origin that separates the rays.

Implementation and proofs live in `GraphVertexNeighborhoodProofs.lean`.
-/

open Classical Set

noncomputable section

/-- Given a list of rays with pairwise distinct directions and a common origin,
    there exists a polygon whose vertices avoid all the rays, such that each
    polygon segment intersects at most one ray, every ray is intersected by
    some polygon segment, and each ray intersects at most one polygon segment. -/
theorem exists_polygon_separating_rays
    (rs : List Ray)
    (h_origin : ∀ r1 ∈ rs, ∀ r2 ∈ rs, sameOrigin r1 r2)
    (h_distinct : rs.Pairwise (fun r1 r2 => r1.toSet ≠ r2.toSet)) :
    ∃ poly : Polygon,
      (∀ v ∈ poly.toVertices, ∀ r ∈ rs, v ∉ r.toSet) ∧
      (∀ seg ∈ poly.segments, ∀ r1 ∈ rs, ∀ r2 ∈ rs,
         rayIntersectsSegment r1 seg → rayIntersectsSegment r2 seg → r1 = r2) ∧
      (∀ r ∈ rs, ∃ seg ∈ poly.segments, rayIntersectsSegment r seg) ∧
      (∀ r ∈ rs, ∀ seg1 ∈ poly.segments, ∀ seg2 ∈ poly.segments,
         rayIntersectsSegment r seg1 → rayIntersectsSegment r seg2 → seg1 = seg2) ∧
      (∀ seg ∈ poly.segments, ∀ r ∈ rs, ∀ t : ℚ,
         ¬ (r.origin.x = (1-t)*seg.p1.x + t*seg.p2.x ∧
            r.origin.y = (1-t)*seg.p1.y + t*seg.p2.y)) ∧
      poly.segments.Nodup :=
  GraphVertexNeighborhoodProofs.exists_polygon_separating_rays rs h_origin h_distinct

/-- Given a vertex of a graph, there is a positive radius `r` such that the open
    ball of radius `r` around the vertex avoids all other vertices of the graph
    and all segments of the graph that are not incident to the vertex. -/
theorem exists_vertex_neighborhood_avoiding_non_incident
    (G : Graph) (v : Vector2D)
    (hv : ∃ seg ∈ G.segments, seg.p1 = v ∨ seg.p2 = v)
    (h_no_segment_interior_vertices : ∀ seg ∈ G.segments,
      seg.p1 ≠ v → seg.p2 ≠ v → v ∉ seg.toSet) :
    ∃ r : ℚ, 0 < r ∧
      (∀ seg ∈ G.segments, seg.p1 ≠ v → seg.p2 ≠ v →
         ∀ p ∈ seg.toSet, r^2 ≤ (p.x - v.x)^2 + (p.y - v.y)^2) ∧
      (∀ seg ∈ G.segments, ∀ w : Vector2D,
         (w = seg.p1 ∨ w = seg.p2) → w ≠ v →
         r^2 ≤ (w.x - v.x)^2 + (w.y - v.y)^2) :=
  GraphVertexNeighborhoodProofs.exists_vertex_neighborhood_avoiding_non_incident
    G v hv h_no_segment_interior_vertices

end
