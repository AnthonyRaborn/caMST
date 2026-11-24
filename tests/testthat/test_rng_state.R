context("Seeded module selection leaves the user's RNG state alone")

data("example_transition_matrix")
data("example_module_items")
data("mst_only_items")

test_that("startModule() restores the global RNG state after seeding", {
  set.seed(123)
  expected = runif(3)

  set.seed(123)
  res = caMST:::startModule(mst_only_items, example_module_items,
                            example_transition_matrix, seed = 5)
  expect_equal(runif(3), expected)

  # The seed itself still makes the selection reproducible.
  res2 = caMST:::startModule(mst_only_items, example_module_items,
                             example_transition_matrix, seed = 5)
  expect_identical(res$module, res2$module)
})

test_that("startModule() does not create .Random.seed when none existed", {
  if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
    saved = get(".Random.seed", envir = globalenv())
    on.exit(assign(".Random.seed", saved, envir = globalenv()))
    rm(".Random.seed", envir = globalenv())
  }
  caMST:::startModule(mst_only_items, example_module_items,
                      example_transition_matrix, seed = 5)
  expect_false(exists(".Random.seed", envir = globalenv(), inherits = FALSE))
})

test_that("nextModule() restores the global RNG state after seeding", {
  set.seed(321)
  expected = runif(3)

  set.seed(321)
  caMST:::nextModule(mst_only_items, example_module_items,
                     example_transition_matrix, current.module = 1,
                     out = which(example_module_items[, 1] == 1),
                     theta = 0, randomesque = 0.7, random.seed = 9)
  expect_equal(runif(3), expected)
})
