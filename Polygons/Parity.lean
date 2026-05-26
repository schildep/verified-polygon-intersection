import Polygons.HelperDefs
import Polygons.ParityProofs

/-- The parity of the number of polygon segments intersected by a ray is invariant
    for rays with the same origin, provided the rays avoid the polygon's vertices
    and the origin avoids all polygon segments. -/
theorem intersectionParity_eq_of_sameOrigin_avoidsVertices
    (r1 r2 : Ray) (poly : Polygon)
    (h_origin : sameOrigin r1 r2)
    (h_r1_avoids : rayAvoidsVertices r1 poly)
    (h_r2_avoids : rayAvoidsVertices r2 poly)
    (h_origin_avoids_segments : ∀ seg ∈ poly.segments, pointAvoidsSegment r1.origin seg) :
    (intersectionRayPolygonSegmentsNumber r1 poly) % 2 =
    (intersectionRayPolygonSegmentsNumber r2 poly) % 2 :=
  ParityProofs.intersectionParity_eq_of_sameOrigin_avoidsVertices r1 r2 poly h_origin h_r1_avoids h_r2_avoids h_origin_avoids_segments

/-- The parity of the number of polygon segments intersected by a ray is invariant
    for rays whose origins are connected by a segment that avoids all polygon segments. -/
theorem intersectionParity_eq_of_originSegmentAvoidsSegments
    (r1 r2 : Ray) (poly : Polygon)
    (h_r1_avoids : rayAvoidsVertices r1 poly)
    (h_r2_avoids : rayAvoidsVertices r2 poly)
    (h_origin_segment_avoids : ∀ seg ∈ poly.segments,
      segmentDoesNotIntersectSegment ⟨r1.origin, r2.origin⟩ seg) :
    (intersectionRayPolygonSegmentsNumber r1 poly) % 2 =
    (intersectionRayPolygonSegmentsNumber r2 poly) % 2 :=
  ParityProofs.intersectionParity_eq_of_originSegmentAvoidsSegments r1 r2 poly h_r1_avoids h_r2_avoids h_origin_segment_avoids
