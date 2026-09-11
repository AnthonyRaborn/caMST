context("Testing polytomous support in mixed_adaptive_test")

make_polytomous_design = function(cat_seed, mst_seed, nrCat = 3) {
  cat_bank = catR::genPolyMatrix(items = 6, nrCat = nrCat, model = "GRM",
                                 seed = cat_seed, same.nrCat = TRUE)
  mst_bank = catR::genPolyMatrix(items = 6, nrCat = nrCat, model = "GRM",
                                 seed = mst_seed, same.nrCat = TRUE)
  rownames(cat_bank) = paste0("CAT", 1:6)
  rownames(mst_bank) = paste0("MST", 1:6)

  modules = matrix(0, nrow = 6, ncol = 2)
  modules[1:3, 1] = 1
  modules[4:6, 2] = 1
  transition_matrix = matrix(c(0, 0, 1, 0), nrow = 2)

  list(cat_bank = cat_bank, mst_bank = mst_bank,
       modules = modules, transition_matrix = transition_matrix)
}

test_that("mixed_adaptive_test runs end to end for a polytomous (GRM) design", {
  design = make_polytomous_design(cat_seed = 11, mst_seed = 22)
  set.seed(1)
  response_matrix = matrix(sample(0:2, 3 * 12, replace = TRUE), nrow = 3)
  colnames(response_matrix) = c(rownames(design$cat_bank), rownames(design$mst_bank))

  results = mixed_adaptive_test(
    response_matrix = response_matrix,
    cat_item_bank = design$cat_bank,
    initial_theta = 0,
    method = "BM",
    item_method = "MFI",
    cat_length = 3,
    cbControl = NULL,
    cbGroup = NULL,
    randomesque = 1,
    mst_item_bank = design$mst_bank,
    modules = design$modules,
    transition_matrix = design$transition_matrix,
    n_stages = 2,
    model = "GRM"
  )

  expect_s4_class(results, "MAT")
  expect_equal(results@final.theta.method, "BM")
  expect_length(results@final.theta.estimate, 3)
  expect_false(any(is.na(results@final.theta.estimate)))
  expect_true(all(is.finite(results@final.theta.estimate)))
})

test_that("mixed_adaptive_test errors clearly on mismatched category counts", {
  design = make_polytomous_design(cat_seed = 11, mst_seed = 22, nrCat = 3)
  mismatched_mst_bank = catR::genPolyMatrix(items = 6, nrCat = 4, model = "GRM",
                                           seed = 22, same.nrCat = TRUE)
  rownames(mismatched_mst_bank) = paste0("MST", 1:6)

  set.seed(1)
  response_matrix = matrix(sample(0:3, 3 * 12, replace = TRUE), nrow = 3)
  colnames(response_matrix) = c(rownames(design$cat_bank), rownames(mismatched_mst_bank))

  expect_error(
    mixed_adaptive_test(
      response_matrix = response_matrix,
      cat_item_bank = design$cat_bank,
      initial_theta = 0,
      method = "BM",
      item_method = "MFI",
      cat_length = 3,
      cbControl = NULL,
      cbGroup = NULL,
      randomesque = 1,
      mst_item_bank = mismatched_mst_bank,
      modules = design$modules,
      transition_matrix = design$transition_matrix,
      n_stages = 2,
      model = "GRM"
    )
  )
})
