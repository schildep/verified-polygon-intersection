import Polygons.DataStructures
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Set.Basic

/-!
# Definitions

Definitions needed to state the main specification for multipolygon
intersection. Also see `DataStructures.lean` for structures that are used
in the algorithm interface.
-/

open Classical

attribute [ext] Vector2D

noncomputable section

/-- Convert a line segment to the set of points it contains. -/
def LineSegment.toSet (seg : LineSegment) : Set Vector2D :=
  { p : Vector2D |
    ∃ t : ℚ, 0 ≤ t ∧ t ≤ 1 ∧
      p.x = (1 - t) * seg.p1.x + t * seg.p2.x ∧
      p.y = (1 - t) * seg.p1.y + t * seg.p2.y }

/-- Convert a ray to the set of points it contains. -/
def Ray.toSet (r : Ray) : Set Vector2D :=
  { p : Vector2D |
    ∃ t : ℚ, 0 ≤ t ∧
      p.x = r.origin.x + t * r.direction.x ∧
      p.y = r.origin.y + t * r.direction.y }

/-- A point is not on a line segment. -/
def pointAvoidsSegment (p : Vector2D) (seg : LineSegment) : Prop :=
  p ∉ seg.toSet

/-- Whether a ray intersects a line segment (propositional). -/
def rayIntersectsSegment (r : Ray) (seg : LineSegment) : Prop :=
  (r.toSet ∩ seg.toSet).Nonempty

/-- The set of all vertices of all polygons in the multipolygon. -/
def Multipolygon.toVertices (m : Multipolygon) : Set Vector2D :=
  { p : Vector2D | p ∈ m.allVertices }

/-- The boundary of a multipolygon: the union of all segments of all
constituent polygons. -/
def Multipolygon.toBoundarySet (m : Multipolygon) : Set Vector2D :=
  { p : Vector2D | ∃ seg ∈ m.segments, p ∈ seg.toSet }

/-- A ray does not pass through any vertex of the multipolygon. -/
def rayAvoidsMultipolygonVertices (r : Ray) (m : Multipolygon) : Prop :=
  r.toSet ∩ m.toVertices = ∅

/-- The number of segments of a multipolygon that a ray intersects. -/
noncomputable def intersectionRayMultipolygonSegmentsNumber
    (r : Ray) (m : Multipolygon) : ℕ :=
  m.segments.countP fun seg => decide (rayIntersectsSegment r seg)

/-- The interior of a multipolygon: not on any segment, and every
ray-from-the-point that avoids vertices intersects an odd number of
multipolygon segments. -/
def Multipolygon.interior (m : Multipolygon) : Set Vector2D :=
  { p : Vector2D |
    (∀ seg ∈ m.segments, pointAvoidsSegment p seg) ∧
    ∀ r : Ray, r.origin = p → rayAvoidsMultipolygonVertices r m →
      intersectionRayMultipolygonSegmentsNumber r m % 2 = 1 }

end
