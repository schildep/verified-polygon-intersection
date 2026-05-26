import Polygons.MultipolygonIntersectionAlgorithmWithPreconditionCheckImpl
open MultipolygonIntersectionAlgorithmWithPreconditionCheckImpl
  (multipolygonIntersectionAlgorithmWithPreconditionCheck)

/-!
# Web entry point

`runIntersection` is a pure `String → String` wrapper around
`multipolygonIntersectionAlgorithmWithPreconditionCheck`. The web UI
serializes its two multipolygons into the input format below, calls
into WASM, and parses the result.

## Input format
```
k1                  -- number of polygons in multipolygon 1
n1                  -- number of vertices in polygon 1 of multipolygon 1
num/den num/den     -- vertex 1 (x and y as rationals num/den)
...                 -- n1 vertex lines
n2                  -- number of vertices in polygon 2 of multipolygon 1
...                 -- k1 polygon blocks total
k2                  -- number of polygons in multipolygon 2
...                 -- k2 polygon blocks
```

## Output format
First line: `ok` or `fail`. On `ok`:
```
ok
k                   -- number of polygons in the result multipolygon
m1
num/den num/den
...
```

Soundness of the returned multipolygon is guaranteed by
`multipolygonIntersectionAlgorithmWithPreconditionCheck_interior_eq`.
-/

namespace Web

private def parseRat (s : String) : Option Rat :=
  match s.splitOn "/" with
  | [n] => n.toInt?.map (fun n => (n : Rat))
  | [n, d] => do
      let n ← n.toInt?
      let d ← d.toInt?
      if d == 0 then none else some ((n : Rat) / (d : Rat))
  | _ => none

private def parseVertex (line : String) : Option Vector2D := do
  let parts := line.trim.splitOn " " |>.filter (·.length > 0)
  match parts with
  | [xs, ys] =>
      let x ← parseRat xs
      let y ← parseRat ys
      some ⟨x, y⟩
  | _ => none

/-- Take `n` vertices from `lines`, returning them and the remaining lines. -/
private def takeVertices : (n : Nat) → (lines : List String) →
    Option (List Vector2D × List String)
  | 0, rest => some ([], rest)
  | _ + 1, [] => none
  | n + 1, line :: rest => do
      let v ← parseVertex line
      let (vs, rest') ← takeVertices n rest
      some (v :: vs, rest')

private def takePolygon (lines : List String) : Option (Polygon × List String) := do
  match lines with
  | [] => none
  | nLine :: rest =>
      let n ← nLine.trim.toNat?
      let (vs, rest') ← takeVertices n rest
      some (⟨vs⟩, rest')

private def takePolygons : (k : Nat) → (lines : List String) →
    Option (List Polygon × List String)
  | 0, rest => some ([], rest)
  | k + 1, lines => do
      let (p, rest) ← takePolygon lines
      let (ps, rest') ← takePolygons k rest
      some (p :: ps, rest')

private def takeMultipolygon (lines : List String) :
    Option (Multipolygon × List String) := do
  match lines with
  | [] => none
  | kLine :: rest =>
      let k ← kLine.trim.toNat?
      let (ps, rest') ← takePolygons k rest
      some (⟨ps⟩, rest')

private def parseInput (input : String) : Option (Multipolygon × Multipolygon) := do
  let lines := input.splitOn "\n" |>.map String.trim |>.filter (·.length > 0)
  let (m1, rest) ← takeMultipolygon lines
  let (m2, _) ← takeMultipolygon rest
  some (m1, m2)

private def ratToString (q : Rat) : String :=
  if q.den == 1 then toString q.num else s!"{q.num}/{q.den}"

private def vertexToString (v : Vector2D) : String :=
  s!"{ratToString v.x} {ratToString v.y}"

private def polygonToString (p : Polygon) : String :=
  let header := toString p.vertices.length
  let lines := p.vertices.map vertexToString
  String.intercalate "\n" (header :: lines)

private def multipolygonToString (m : Multipolygon) : String :=
  let header := toString m.polygons.length
  let blocks := m.polygons.map polygonToString
  String.intercalate "\n" (header :: blocks)

/-- The verified pure entry point. -/
def runIntersection (input : String) : String :=
  match parseInput input with
  | none => "fail"
  | some (m1, m2) =>
    match multipolygonIntersectionAlgorithmWithPreconditionCheck m1 m2 with
    | none => "fail"
    | some result => "ok\n" ++ multipolygonToString result

end Web

/-- Export the verified entry point as `run_intersection` for the C wrapper. -/
@[export run_intersection]
def runIntersectionExport (input : String) : String := Web.runIntersection input
