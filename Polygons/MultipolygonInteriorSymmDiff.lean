import Polygons.Multipolygon

/-!
# Multipolygon Interior as a Symmetric Difference

The interior of a multipolygon (defined by ray-crossing parity over all polygon
segments) equals the symmetric difference of the polygon interiors with the
union of the polygon boundaries removed.
-/

open Classical Set

noncomputable section

/-- For a multipolygon whose polygons all have at least two vertices and
    non-degenerate segments, the multipolygon interior equals the symmetric
    difference of the polygon interiors, minus the union of the polygon
    boundaries. -/
theorem Multipolygon.interior_eq_symmDiffAll_polygon_interiors_sdiff_boundaries
    (m : Multipolygon)
    (h_len : ∀ poly ∈ m.polygons, poly.vertices.length ≥ 2)
    (h_distinct : ∀ seg ∈ m.segments, seg.p1 ≠ seg.p2) :
    m.interior =
      (m.polygons.map Polygon.interior).symmDiffAll \
        { p : Vector2D | ∃ poly ∈ m.polygons, p ∈ poly.toBoundarySet } := by
  rw [m.interior_eq_symmDiffAll_sdiff_boundary h_len h_distinct]
  -- Both boundary forms are equal as sets.
  congr 1
  ext p
  simp only [Multipolygon.toBoundarySet, Multipolygon.segments,
             Polygon.toBoundarySet, Set.mem_setOf_eq, List.mem_flatMap]
  tauto

end
