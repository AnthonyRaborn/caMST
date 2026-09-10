context("Testing polytomous support in mstR_vendored.R")

# catR::Pi/catR::Ii share the exact (th, it, model, D) signature with the
# vendored .mstR_Pi/.mstR_Ii, and produce identical values -- using them as an
# oracle avoids hand-deriving six different polytomous IRT formulas, and
# guards against the vendored copy silently drifting from upstream.
polytomous_models = c("GRM", "MGRM", "PCM", "GPCM", "RSM", "NRM")
thetas = c(-2, -0.5, 0, 0.5, 2)

test_that(".mstR_Pi matches catR::Pi for every polytomous model", {
  for (model in polytomous_models) {
    bank = catR::genPolyMatrix(items = 4, nrCat = 3, model = model, seed = 42,
                               same.nrCat = TRUE)
    for (theta in thetas) {
      expect_equal(
        caMST:::.mstR_Pi(theta, bank, model = model)$Pi,
        catR::Pi(theta, bank, model = model)$Pi,
        info = paste("model =", model, ", theta =", theta)
      )
    }
  }
})

test_that(".mstR_Ii matches catR::Ii for every polytomous model", {
  for (model in polytomous_models) {
    bank = catR::genPolyMatrix(items = 4, nrCat = 3, model = model, seed = 42,
                               same.nrCat = TRUE)
    for (theta in thetas) {
      expect_equal(
        caMST:::.mstR_Ii(theta, bank, model = model)$Ii,
        catR::Ii(theta, bank, model = model)$Ii,
        info = paste("model =", model, ", theta =", theta)
      )
    }
  }
})

test_that("startModule and nextModule run for a polytomous (GRM) design", {
  bank = catR::genPolyMatrix(items = 6, nrCat = 3, model = "GRM", seed = 7,
                             same.nrCat = TRUE)
  modules = matrix(0, nrow = 6, ncol = 2)
  modules[1:3, 1] = 1
  modules[4:6, 2] = 1
  transition_matrix = matrix(c(0, 0, 1, 0), nrow = 2)

  first.module = caMST:::startModule(itemBank = bank, modules = modules,
                                     transMatrix = transition_matrix,
                                     model = "GRM", theta = 0)
  expect_equal(first.module$module, 1)
  expect_equal(first.module$items, 1:3)

  # module 2 is the only eligible transition here (no real choice to make);
  # exercises the #22 fix for every module_select criterion
  for (criterion in c("MFI", "MLWMI", "MPWMI", "MKL", "MKLP", "random")) {
    next.module = caMST:::nextModule(
      itemBank = bank, modules = modules, transMatrix = transition_matrix,
      model = "GRM", current.module = first.module$module,
      out = first.module$items, x = c(1, 0, 2), theta = 0,
      criterion = criterion
    )
    expect_equal(next.module$module, 2, info = paste("criterion =", criterion))
  }
})
