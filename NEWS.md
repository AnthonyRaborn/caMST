# Package v0.2.0

This release removes the dependency on the archived `mstR` package (the
reason caMST was archived from CRAN), relicenses the package to resolve
the resulting license incompatibility, fixes a substantial number of
correctness bugs, and adds hybrid adaptive testing and theta trajectory
plotting.

## New Features
  - Added `hybrid_adaptive_test()` and the `HAT` result class: one or
    more MST stages followed by a final CAT stage (the reverse order
    from `mixed_adaptive_test()`).
  - Added polytomous item support (`model` argument) to
    `mixed_adaptive_test()`, matching the existing support in
    `computerized_adaptive_test()` and `multistage_test()`.
  - Added `generate_transition_matrix()` and `generate_modules()` to
    build transition and item-to-module matrices from a design
    specification instead of hand-writing them.
  - Added `theta_trajectory_plot()` and `theta_trajectory_animate()`:
    static and animated plots of the provisional theta trajectory
    across test administration (item-by-item for CAT, module-by-module
    for MST), with faceting across respondents.
  - Added vignettes covering the package overview, CAT, MST, mixed
    adaptive testing, and theta trajectory plots.

## Breaking Changes
  - `computerized_adaptive_test()`, `multistage_test()`,
    `mixed_adaptive_test()`, and `hybrid_adaptive_test()` now take a
    `final_theta_method` argument controlling which single method
    computes the reported final theta estimate, instead of always
    computing and returning three (the provisional method, EAP, and an
    iterative "Baker" estimate). The `eap.theta` and `final.theta.Baker`
    S4 slots are removed accordingly, replaced by `final.theta.method`.
  - Removed `iterative.theta.estimate()` (the "Baker" estimator); it was
    dichotomous-only and no longer used by any public function.
  - Item banks now carry a `module` column identifying which module an
    item belongs to, in place of the coarser `stage` column.

## Bug Fixes
  - Fixed a row-index bug in `multistage_test()`'s theta-based branch
    that produced incorrect theta estimates for every respondent after
    the first.
  - Fixed a variable name collision that silently overwrote an 18-item
    transition matrix definition with a 30-item one.
  - Fixed `cbGroup`, `nAvailable`, and `module_select` arguments being
    silently dropped instead of forwarded to the underlying `catR`/
    vendored `mstR` calls.
  - Fixed `module_sum` NC scoring, which was only correct by coincidence
    for 3-stage designs and incorrect for 4+ stages.
  - Fixed theta-based module selection in `multistage_test()` never
    updating past the first module.
  - Fixed `nextModule()` crashing when only one module was eligible at a
    transition (affects any non-crossed or otherwise constrained
    design), including a related bug in its `"random"` criterion.
  - Fixed `nextModule()` not forwarding `model` to the `MLWMI`/`MPWMI`/
    `MKL`/`MKLP` item-information criteria, which broke those criteria
    for polytomous designs.
  - Fixed `mixed_adaptive_test()` not storing its `transition.matrix`/
    `n.stages` slots.
  - Fixed double console output and a garbled package startup message.
  - Fixed a `logical(0)` bug in `MST`'s `show()` method when
    `nc.list$method` was `NULL`.
  - Fixed silent item-bank column truncation in `mixed_adaptive_test()`;
    item bank columns are now selected by name rather than position.

## Removed
  - Removed the dependency on the archived `mstR` package; the small set
    of functions caMST needs are now vendored directly.
  - Removed dead code: an unused `module_selection()` function and
    ~400 lines of unused hard-coded transition matrices.
  - Removed the Travis CI configuration in favor of GitHub Actions.

## Licensing
  - Relicensed from LGPL/MPL to GPL (>= 3), resolving a license
    incompatibility introduced by vendoring GPL-licensed `mstR` code.

## Testing
  - Substantially increased test coverage (from roughly 50% to roughly
    88%).

# Package v0.1.6
## Bug Fixes
  - Fixed multiple bugs related to theta estimation issues

# Package v0.1.4
## Bug Fixes
  - Fixed the creation of one of the transition matrices to prevent a WARNING
## Documentation updates
  - Now using Roxygen v7.1.1

# Package v0.1.3
## Bug Fixes
  - Fix the use of equality testing (e.g., `class(object)=="CLASS") in the transition_matrix_plot function.
