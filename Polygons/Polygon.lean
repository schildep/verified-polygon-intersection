import Polygons.HelperDefs
import Polygons.PolygonProofs

/-!
# Polygon Interior via Ray Crossing Parity

This file defines the interior of a polygon using the ray-casting rule:
a point is interior if every ray from that point (that avoids polygon vertices)
crosses an odd number of polygon edges.
-/

open Classical Set

noncomputable section

/-- The interior of a polygon: the set of points not on any edge such that
    every ray from the point that avoids the polygon's vertices
    intersects an odd number of polygon segments. -/
def Polygon.interior (poly : Polygon) : Set Vector2D :=
  { p : Vector2D |
    (∀ seg ∈ poly.segments, pointAvoidsSegment p seg) ∧
    ∀ r : Ray, r.origin = p → rayAvoidsVertices r poly →
      intersectionRayPolygonSegmentsNumber r poly % 2 = 1 }

/-- The interior defined via the universal quantifier over rays equals the
    interior defined via the existential quantifier: it suffices that there
    exists one ray from the point (avoiding vertices) with an odd crossing number. -/
theorem Polygon.interior_eq_exists (poly : Polygon)
    (h_len : poly.vertices.length ≥ 2) :
    poly.interior =
    { p : Vector2D |
        (∀ seg ∈ poly.segments, pointAvoidsSegment p seg) ∧
        ∃ r : Ray, r.origin = p ∧ rayAvoidsVertices r poly ∧
          intersectionRayPolygonSegmentsNumber r poly % 2 = 1 } :=
  PolygonProofs.interior_forall_eq_exists poly h_len
