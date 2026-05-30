import Polygons.MultipolygonIntersectionAlgorithmWithPreconditionCheckProofs

/-!
# Multipolygon Intersection With Precondition Check — Interface

A self-contained variant of `multipolygonIntersectionAlgorithm` that performs a
computable check of the preconditions of
`multipolygonIntersectionAlgorithm_interior_eq` and returns
`Option Multipolygon`: `some result` when the preconditions hold,
`none` otherwise.
-/

open Set

/-- The precondition-checking wrapper: returns `some result` when all
    preconditions of `multipolygonIntersectionAlgorithm_interior_eq` are
    detected to hold by a computable test, and `none` otherwise. -/
def multipolygonIntersectionAlgorithmWithPreconditionCheck
    (m1 m2 : Multipolygon) : Option Multipolygon :=
  MultipolygonIntersectionAlgorithmWithPreconditionCheckImpl.multipolygonIntersectionAlgorithmWithPreconditionCheck
    m1 m2

/-- Soundness: whenever
    `multipolygonIntersectionAlgorithmWithPreconditionCheck m1 m2 = some result`,
    the conclusion of `multipolygonIntersectionAlgorithm_interior_eq` is
    satisfied for `result`. -/
theorem multipolygonIntersectionAlgorithmWithPreconditionCheck_interior_eq
    (m1 m2 : Multipolygon) (result : Multipolygon)
    (h : multipolygonIntersectionAlgorithmWithPreconditionCheck m1 m2 = some result) :
    m1.interior ∩ m2.interior = result.interior :=
  MultipolygonIntersectionAlgorithmWithPreconditionCheckProofs.multipolygonIntersectionAlgorithmWithPreconditionCheck_correct
    m1 m2 result h

/-- Completeness: whenever the mathematical preconditions of
    `multipolygonIntersectionAlgorithm_interior_eq` hold,
    `multipolygonIntersectionAlgorithmWithPreconditionCheck m1 m2` returns
    `some result` and `result` satisfies the interior equation. -/
theorem multipolygonIntersectionAlgorithmWithPreconditionCheck_complete
    (m1 m2 : Multipolygon)
    (h1_len : ∀ poly ∈ m1.polygons, poly.vertices.length ≥ 2)
    (h2_len : ∀ poly ∈ m2.polygons, poly.vertices.length ≥ 2)
    (h1_nondeg : ∀ seg ∈ m1.segments, seg.p1 ≠ seg.p2)
    (h2_nondeg : ∀ seg ∈ m2.segments, seg.p1 ≠ seg.p2) :
    ∃ result : Multipolygon,
      multipolygonIntersectionAlgorithmWithPreconditionCheck m1 m2 = some result ∧
      m1.interior ∩ m2.interior = result.interior :=
  MultipolygonIntersectionAlgorithmWithPreconditionCheckProofs.multipolygonIntersectionAlgorithmWithPreconditionCheck_complete
    m1 m2 h1_len h2_len h1_nondeg h2_nondeg
