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
    final.theta.method = "BM",
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2"), nrow = 1),
    modules.seen = matrix(c(1, 2, 5), nrow = 1),
    final.responses = matrix(c(1, 0), nrow = 1),
    transition.matrix = example_transition_matrix,
    n.stages = 3,
    nc.list = NULL,
    item.bank = data.frame(a = c(1, 1.2), b = c(-0.5, 0.5), c = c(0.2, 0.2), d = c(1, 1)),
    modules = matrix(c(1, 0, 0, 1), nrow = 2),
    method = "BM",
    model = NULL,
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
    final.theta.method = "BM",
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2"), nrow = 1),
    modules.seen = matrix(c(1, 2, 5), nrow = 1),
    final.responses = matrix(c(1, 0), nrow = 1),
    transition.matrix = example_transition_matrix,
    n.stages = 3,
    cat.item.bank = data.frame(a = c(1), b = c(0), c = c(0.2), d = c(1)),
    mst.item.bank = data.frame(a = c(1.2), b = c(0.5), c = c(0.2), d = c(1)),
    mst.modules = matrix(c(1, 0, 0, 1), nrow = 2),
    method = "BM",
    model = NULL,
    runtime = as.difftime(1, units = "secs")
  )

  pdf(file = NULL)
  on.exit(dev.off())
  expect_error(
    transition_matrix_plot(mat_object),
    NA
  )
})

test_that("transition_matrix_plot runs on a HAT object", {
  hat_object = new(
    'HAT',
    function.call = quote(hybrid_adaptive_test(cat_item_bank = x, mst_item_bank = y)),
    final.theta.estimate = c(0.5, -0.3),
    final.theta.method = "BM",
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2"), nrow = 1),
    modules.seen = matrix(c(1, 2, 5), nrow = 1),
    final.responses = matrix(c(1, 0), nrow = 1),
    transition.matrix = example_transition_matrix,
    n.stages = 3,
    cat.item.bank = data.frame(a = c(1), b = c(0), c = c(0.2), d = c(1)),
    mst.item.bank = data.frame(a = c(1.2), b = c(0.5), c = c(0.2), d = c(1)),
    mst.modules = matrix(c(1, 0, 0, 1), nrow = 2),
    method = "BM",
    model = NULL,
    runtime = as.difftime(1, units = "secs")
  )

  pdf(file = NULL)
  on.exit(dev.off())
  expect_error(
    transition_matrix_plot(hat_object),
    NA
  )
})
