import Batteries.Data.Rat.Basic

/-!
# Data structures

Data structures that are used in the multipolygon intersection algorithm
interface.
-/

/-- A 2D vector with rational coordinates. -/
structure Vector2D where
  x : Rat
  y : Rat
  deriving DecidableEq, Repr, Inhabited

/-- A line segment defined by two endpoints. -/
structure LineSegment where
  p1 : Vector2D
  p2 : Vector2D
  deriving Repr, DecidableEq

/-- A ray defined by an origin point and a direction vector. -/
structure Ray where
  origin : Vector2D
  direction : Vector2D
  direction_nonzero : direction ≠ ⟨0, 0⟩

/-- A polygon defined by a list of vertices. -/
structure Polygon where
  vertices : List Vector2D

/-- The list of line segments forming the boundary of a polygon:
connect each vertex to the next, wrapping the last back to the first. -/
def Polygon.segments (poly : Polygon) : List LineSegment :=
  match poly.vertices with
  | [] => []
  | [_] => []
  | v :: vs =>
    let pairs := List.zip (v :: vs) (vs ++ [v])
    pairs.map fun (a, b) => ⟨a, b⟩

/-- A multipolygon: a list of polygons. -/
structure Multipolygon where
  polygons : List Polygon

/-- The list of all segments of all polygons in the multipolygon. -/
def Multipolygon.segments (m : Multipolygon) : List LineSegment :=
  m.polygons.flatMap Polygon.segments

/-- The list of all polygon vertices in the multipolygon (concatenation,
with duplicates). -/
def Multipolygon.allVertices (m : Multipolygon) : List Vector2D :=
  m.polygons.flatMap Polygon.vertices
