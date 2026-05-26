import Polygons.Defs
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Rat.Lemmas
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Finite.Basic
import Mathlib.Data.Set.SymmDiff
import Mathlib.Data.List.Basic
import Mathlib.Logic.Basic

/-!
# Helper definitions

Basic definitions needed in proofs and helper theorems but not in the main
specification itself.
-/

open Classical

noncomputable section

/-- A line defined by a point and a direction vector. -/
structure Line where
  p : Vector2D
  direction : Vector2D
  direction_nonzero : direction ≠ ⟨0, 0⟩

/-- A half-plane: a point on the boundary plus an inward normal. -/
structure HalfPlane where
  p : Vector2D
  normal : Vector2D
  normal_nonzero : normal ≠ ⟨0, 0⟩

/-- The dot product `(q - hp.p) · hp.normal`. -/
def HalfPlane.dot (hp : HalfPlane) (q : Vector2D) : ℚ :=
  (q.x - hp.p.x) * hp.normal.x + (q.y - hp.p.y) * hp.normal.y

/-- The boundary line of a half-plane (direction perpendicular to the normal). -/
def HalfPlane.toBoundaryLine (hp : HalfPlane) : Line where
  p := hp.p
  direction := ⟨-hp.normal.y, hp.normal.x⟩
  direction_nonzero := by
    intro h
    apply hp.normal_nonzero
    have hx : (-hp.normal.y : ℚ) = 0 := congrArg Vector2D.x h
    have hy : hp.normal.x = 0 := congrArg Vector2D.y h
    simp at hx
    exact (Vector2D.mk.injEq _ _ _ _).mpr ⟨hy, hx⟩

/-- An intersection of half-planes. -/
structure HalfPlaneIntersection where
  halfPlanes : List HalfPlane

/-- Convert a line to the set of points it contains. -/
def Line.toSet (l : Line) : Set Vector2D :=
  { q : Vector2D |
    ∃ t : ℚ,
      q.x = l.p.x + t * l.direction.x ∧
      q.y = l.p.y + t * l.direction.y }

/-- The open interior of a half-plane. -/
def HalfPlane.toInteriorSet (hp : HalfPlane) : Set Vector2D :=
  { q : Vector2D | hp.dot q > 0 }

/-- The open exterior of a half-plane. -/
def HalfPlane.toExteriorSet (hp : HalfPlane) : Set Vector2D :=
  { q : Vector2D | hp.dot q < 0 }

/-- The boundary of a half-plane: points where (q - p) · normal = 0. -/
def HalfPlane.toBoundarySet (hp : HalfPlane) : Set Vector2D :=
  { q : Vector2D | hp.dot q = 0 }

/-- The open interior: intersection of all half-plane interiors. -/
def HalfPlaneIntersection.toInteriorSet (hpi : HalfPlaneIntersection) : Set Vector2D :=
  { q : Vector2D | ∀ hp ∈ hpi.halfPlanes, q ∈ hp.toInteriorSet }

/-- The exterior: union of all half-plane exteriors. -/
def HalfPlaneIntersection.toExteriorSet (hpi : HalfPlaneIntersection) : Set Vector2D :=
  { q : Vector2D | ∃ hp ∈ hpi.halfPlanes, q ∈ hp.toExteriorSet }

/-- The boundary: points on the boundary of some half-plane and not exterior to any. -/
def HalfPlaneIntersection.toBoundarySet (hpi : HalfPlaneIntersection) : Set Vector2D :=
  { q : Vector2D |
    (∃ hp ∈ hpi.halfPlanes, q ∈ hp.toBoundarySet) ∧
    ∀ hp ∈ hpi.halfPlanes, q ∉ hp.toExteriorSet }

/-- The vertices of a half-plane intersection. -/
def HalfPlaneIntersection.toVertexSet (hpi : HalfPlaneIntersection) : Set Vector2D :=
  { q : Vector2D |
    ∃ hp1 ∈ hpi.halfPlanes, ∃ hp2 ∈ hpi.halfPlanes,
      hp1 ≠ hp2 ∧ q ∈ hp1.toBoundarySet ∧ q ∈ hp2.toBoundarySet }

/-- A line segment intersects the boundary of a half-plane. -/
def LineSegment.intersectsBoundary (seg : LineSegment) (hp : HalfPlane) : Prop :=
  ∃ q ∈ seg.toSet, q ∈ hp.toBoundarySet

/-- Boundary-crossing points of a segment over a half-plane intersection. -/
def LineSegment.boundaryCrossings (seg : LineSegment) (hpi : HalfPlaneIntersection) : Set Vector2D :=
  seg.toSet ∩ hpi.toBoundarySet

/-- Crossing count for a single segment (0 if not finite). -/
noncomputable def segCrossingCount (seg : LineSegment) (hpi : HalfPlaneIntersection) : ℕ :=
  if h : (seg.boundaryCrossings hpi).Finite then h.toFinset.card else 0

/-- The set of vertices of a polygon. -/
def Polygon.toVertices (poly : Polygon) : Set Vector2D :=
  { p : Vector2D | p ∈ poly.vertices }

/-- The boundary of a polygon: the union of all segment sets. -/
def Polygon.toBoundarySet (poly : Polygon) : Set Vector2D :=
  { p : Vector2D | ∃ seg ∈ poly.segments, p ∈ seg.toSet }

/-- The number of segments of a polygon that a ray intersects. -/
noncomputable def intersectionRayPolygonSegmentsNumber (r : Ray) (poly : Polygon) : ℕ :=
  poly.segments.countP fun seg => decide (rayIntersectsSegment r seg)

/-- Predicate: a ray does not pass through any vertex of a polygon. -/
def rayAvoidsVertices (r : Ray) (poly : Polygon) : Prop :=
  r.toSet ∩ poly.toVertices = ∅

/-- Two rays have the same origin. -/
def sameOrigin (r1 r2 : Ray) : Prop :=
  r1.origin = r2.origin

/-- Two line segments do not share any point. -/
def segmentDoesNotIntersectSegment (seg1 seg2 : LineSegment) : Prop :=
  seg1.toSet ∩ seg2.toSet = ∅

/-- Symmetric difference of a list of sets. -/
def List.symmDiffAll {α : Type*} (l : List (Set α)) : Set α :=
  l.foldr symmDiff ∅

end
