import Polygons.ConvexProofs
import Mathlib.Data.Set.Finite.Basic

/-!
# Convex Region Theorems

Theorems about half-plane intersections.
-/

open Classical

open ConvexProofs

noncomputable section

/-- The interior, exterior, and boundary of a half-plane intersection are pairwise disjoint
    and their union is the whole plane. -/
theorem HalfPlaneIntersection.partition (hpi : HalfPlaneIntersection) :
    Disjoint hpi.toInteriorSet hpi.toExteriorSet ∧
    Disjoint hpi.toInteriorSet hpi.toBoundarySet ∧
    Disjoint hpi.toExteriorSet hpi.toBoundarySet ∧
    hpi.toInteriorSet ∪ hpi.toExteriorSet ∪ hpi.toBoundarySet = Set.univ :=
  HalfPlaneIntersection.partition_proof hpi

/-- Segment separation by a single half-plane boundary.

    If both endpoints of a segment are not on the boundary of a half-plane,
    then both endpoints are on the same side (both interior or both exterior)
    iff the segment does not cross the boundary. -/
theorem HalfPlane.segment_separation (hp : HalfPlane)
    (seg : LineSegment)
    (hp1_not_boundary : seg.p1 ∉ hp.toBoundarySet)
    (hp2_not_boundary : seg.p2 ∉ hp.toBoundarySet) :
    ((seg.p1 ∈ hp.toInteriorSet ∧ seg.p2 ∈ hp.toInteriorSet) ∨
     (seg.p1 ∈ hp.toExteriorSet ∧ seg.p2 ∈ hp.toExteriorSet)) ↔
    ¬seg.intersectsBoundary hp :=
  hp.segment_separation_proof seg hp1_not_boundary hp2_not_boundary

/-- Segment separation by half-plane intersection boundary.

    Given a half-plane intersection, if a segment's endpoints are not on the boundary
    and the segment avoids the vertices, then:
    1. The boundary crossings form a finite set.
    2. Both endpoints interior implies no boundary crossings.
    3. One interior and one exterior implies at least one boundary crossing.
    4. (Symmetric version of 3 with endpoints swapped.) -/
theorem HalfPlaneIntersection.segment_separation (hpi : HalfPlaneIntersection)
    (seg : LineSegment)
    (hp1_not_boundary : seg.p1 ∉ hpi.toBoundarySet)
    (hp2_not_boundary : seg.p2 ∉ hpi.toBoundarySet)
    (avoids_vertices : ∀ q ∈ seg.toSet, q ∉ hpi.toVertexSet) :
    (seg.boundaryCrossings hpi).Finite ∧
    (seg.p1 ∈ hpi.toInteriorSet → seg.p2 ∈ hpi.toInteriorSet →
      seg.boundaryCrossings hpi = ∅) ∧
    (seg.p1 ∈ hpi.toInteriorSet → seg.p2 ∈ hpi.toExteriorSet →
      (seg.boundaryCrossings hpi).Nonempty) ∧
    (seg.p1 ∈ hpi.toExteriorSet → seg.p2 ∈ hpi.toInteriorSet →
      (seg.boundaryCrossings hpi).Nonempty) :=
  hpi.segment_separation_proof seg hp1_not_boundary hp2_not_boundary avoids_vertices

/-- Both endpoints exterior implies an even number of boundary crossings.

    When both endpoints lie in the exterior of a half-plane intersection,
    the segment may cross the boundary zero or more times, but always an even
    number of times (it must "enter and exit" the interior region in pairs).
    Finiteness of crossings follows from `segment_separation`. -/
theorem HalfPlaneIntersection.exterior_exterior_even_crossings
    (hpi : HalfPlaneIntersection) (seg : LineSegment)
    (hp1_not_boundary : seg.p1 ∉ hpi.toBoundarySet)
    (hp2_not_boundary : seg.p2 ∉ hpi.toBoundarySet)
    (avoids_vertices : ∀ q ∈ seg.toSet, q ∉ hpi.toVertexSet)
    (h1_ext : seg.p1 ∈ hpi.toExteriorSet)
    (h2_ext : seg.p2 ∈ hpi.toExteriorSet) :
    ∃ (hfin : (seg.boundaryCrossings hpi).Finite), Even hfin.toFinset.card :=
  hpi.exterior_exterior_even seg hp1_not_boundary hp2_not_boundary
    avoids_vertices h1_ext h2_ext

/-- Polygon-HPI crossing parity.

    For a half-plane intersection and a polygon, if no polygon vertex lies on
    the HPI boundary, and every polygon segment avoids the HPI vertices, then:
    1. Every segment's boundary crossings are finite.
    2. The total number of boundary crossings (summed over all polygon segments)
       is even. -/
theorem HalfPlaneIntersection.polygon_crossings_even
    (hpi : HalfPlaneIntersection) (poly : Polygon)
    (h_vertices_not_boundary : ∀ v ∈ poly.vertices, v ∉ hpi.toBoundarySet)
    (h_avoids_vertices : ∀ seg ∈ poly.segments, ∀ q ∈ seg.toSet, q ∉ hpi.toVertexSet) :
    (∀ seg ∈ poly.segments, (seg.boundaryCrossings hpi).Finite) ∧
    Even ((poly.segments.map fun seg => segCrossingCount seg hpi).sum) :=
  hpi.polygon_crossings_even_proof poly h_vertices_not_boundary h_avoids_vertices

end
