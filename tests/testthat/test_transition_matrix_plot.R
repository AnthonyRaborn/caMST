context("Testing transition_matrix_plot")

data(example_transition_matrix)

test_that("transition_matrix_plot runs on a raw transition matrix", {
  pdf(file = NULL)
  on.exit(dev.off())
  expect_error(
    transition_matrix_plot(example_transition_matrix, n_stages = 3),
    NA
  )
})

test_that("transition_matrix_plot runs on an MST object", {
  mst_object = new(
    'MST',
    function.call = quote(multistage_test(mst_item_bank = x, response_matrix = y)),
    final.theta.estimate = c(0.5, -0.3),
    eap.theta = c(0.4, -0.2),
    final.theta.Baker = c(0.45, -0.25),
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2"), nrow = 1),
    modules.seen = matrix(c(1, 2, 5), nrow = 1),
    final.responses = matrix(c(1, 0), nrow = 1),
    transition.matrix = example_transition_matrix,
    n.stages = 3,
    nc.list = NULL,
    runtime = as.difftime(1, units = "secs")
  )

  pdf(file = NULL)
  on.exit(dev.off())
  expect_error(
    transition_matrix_plot(mst_object),
    NA
  )
})

test_that("transition_matrix_plot runs on a MAT object", {
  mat_object = new(
    'MAT',
    function.call = quote(mixed_adaptive_test(cat_item_bank = x, mst_item_bank = y)),
    final.theta.estimate = c(0.5, -0.3),
    eap.theta = c(0.4, -0.2),
    final.theta.Baker = c(0.45, -0.25),
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2"), nrow = 1),
    modules.seen = matrix(c(1, 2, 5), nrow = 1),
    final.responses = matrix(c(1, 0), nrow = 1),
    transition.matrix = example_transition_matrix,
    n.stages = 3,
    runtime = as.difftime(1, units = "secs")
  )

  pdf(file = NULL)
  on.exit(dev.off())
  expect_error(
    transition_matrix_plot(mat_object),
    NA
  )
})
