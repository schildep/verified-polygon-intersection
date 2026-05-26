import Polygons.HelperDefs

/-!
# Graph Definitions

Core definitions for graphs consisting of non-degenerate line segments.
-/

open Classical

noncomputable section

/-- A graph consisting of a list of non-degenerate line segments. -/
structure Graph where
  segments : List LineSegment
  /-- Every segment has distinct endpoints. -/
  segments_nondegenerate : ∀ seg ∈ segments, seg.p1 ≠ seg.p2

/-- The list of vertices of a graph: all endpoints of its segments,
    deduplicated. -/
def Graph.toVertices (G : Graph) : List Vector2D :=
  (G.segments.flatMap fun seg => [seg.p1, seg.p2]).dedup

/-- The set of vertices of a graph. -/
def Graph.toVertexSet (G : Graph) : Set Vector2D :=
  { p : Vector2D | p ∈ G.toVertices }

/-- The boundary of a graph: the union of all segment sets. -/
def Graph.toBoundarySet (G : Graph) : Set Vector2D :=
  { p : Vector2D | ∃ seg ∈ G.segments, p ∈ seg.toSet }

/-- The number of segments of a graph that a ray intersects. -/
noncomputable def intersectionRayGraphSegmentsNumber (r : Ray) (G : Graph) : ℕ :=
  G.segments.countP fun seg => decide (rayIntersectsSegment r seg)

/-- Predicate stating that a ray does not pass through any vertex of a graph. -/
def rayAvoidsGraphVertices (r : Ray) (G : Graph) : Prop :=
  r.toSet ∩ G.toVertexSet = ∅

/-- A point avoids all segments of a graph (not on any segment). -/
def pointAvoidsGraphSegments (p : Vector2D) (G : Graph) : Prop :=
  ∀ seg ∈ G.segments, pointAvoidsSegment p seg

/-- A graph is *even* if every vertex has even degree: for every point `v`,
    the number of segments incident to `v` is even (vacuously zero for
    non-endpoints). -/
def Graph.IsEven (G : Graph) : Prop :=
  ∀ v : Vector2D, Even (G.segments.countP fun seg => seg.p1 = v ∨ seg.p2 = v)

/-- A segment's open interior (every point of the segment except its
    endpoints) is contained in `S`. -/
def segmentOpenInteriorSubset (seg : LineSegment) (S : Set Vector2D) : Prop :=
  ∀ p ∈ seg.toSet, p ≠ seg.p1 → p ≠ seg.p2 → p ∈ S

/-- Filter a list of segments to those whose open interior is inside `S`. -/
def selectSegmentsInside (segs : List LineSegment) (S : Set Vector2D) : List LineSegment :=
  segs.filter fun seg => decide (segmentOpenInteriorSubset seg S)

/-- The graph obtained by keeping only those segments of `G` whose open
    interior lies in `S`. Non-degeneracy is inherited from `G`. -/
def Graph.selectSegmentsInside (G : Graph) (S : Set Vector2D) : Graph where
  segments := _root_.selectSegmentsInside G.segments S
  segments_nondegenerate seg h_mem := by
    have h_filt : seg ∈ G.segments :=
      List.mem_of_mem_filter (l := G.segments) h_mem
    exact G.segments_nondegenerate seg h_filt

@[simp] theorem Graph.selectSegmentsInside_segments (G : Graph) (S : Set Vector2D) :
    (G.selectSegmentsInside S).segments = _root_.selectSegmentsInside G.segments S := rfl

/-- Concatenate two graphs by appending their segment lists. Non-degeneracy
    holds segment-wise on both inputs, so it holds on the concatenation. -/
def Graph.append (G1 G2 : Graph) : Graph where
  segments := G1.segments ++ G2.segments
  segments_nondegenerate seg h_mem := by
    rcases List.mem_append.mp h_mem with h | h
    · exact G1.segments_nondegenerate seg h
    · exact G2.segments_nondegenerate seg h

@[simp] theorem Graph.append_segments (G1 G2 : Graph) :
    (G1.append G2).segments = G1.segments ++ G2.segments := rfl

end
