context("Testing S4 classes and show methods")

make_cat_object = function() {
  new(
    'CAT',
    function.call = quote(computerized_adaptive_test(cat_item_bank = x, response_matrix = y)),
    final.theta.estimate = c(0.5, -0.3),
    eap.theta = c(0.4, -0.2),
    final.theta.Baker = c(0.45, -0.25),
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2", "Item3", "Item4"), nrow = 2),
    final.responses = matrix(c(1, 0, 0, 1), nrow = 2),
    runtime = as.difftime(1.234, units = "secs")
  )
}

make_mst_object = function(nc.list = NULL) {
  new(
    'MST',
    function.call = quote(multistage_test(mst_item_bank = x, response_matrix = y)),
    final.theta.estimate = c(0.5, -0.3),
    eap.theta = c(0.4, -0.2),
    final.theta.Baker = c(0.45, -0.25),
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2", "Item3", "Item4"), nrow = 2),
    modules.seen = matrix(c(1, 1, 2, 3), nrow = 2),
    final.responses = matrix(c(1, 0, 0, 1), nrow = 2),
    transition.matrix = matrix(c(0, 1, 0, 0), nrow = 2),
    n.stages = 2,
    nc.list = nc.list,
    runtime = as.difftime(2.345, units = "secs")
  )
}

make_mat_object = function() {
  new(
    'MAT',
    function.call = quote(mixed_adaptive_test(cat_item_bank = x, mst_item_bank = y)),
    final.theta.estimate = c(0.5, -0.3),
    eap.theta = c(0.4, -0.2),
    final.theta.Baker = c(0.45, -0.25),
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2", "Item3", "Item4"), nrow = 2),
    modules.seen = matrix(c(1, 1, 2, 3), nrow = 2),
    final.responses = matrix(c(1, 0, 0, 1), nrow = 2),
    transition.matrix = matrix(c(0, 1, 0, 0), nrow = 2),
    n.stages = 2,
    runtime = as.difftime(3.456, units = "secs")
  )
}

test_that("CAT class can be constructed and shown", {
  object = make_cat_object()
  expect_s4_class(object, "CAT")
  output = capture.output(show(object))
  expect_true(any(grepl("Computerized Adaptive Test", output)))
  expect_true(any(grepl("Average Theta Estimate", output)))
})

test_that("MST class can be constructed and shown, with and without nc.list", {
  object = make_mst_object()
  expect_s4_class(object, "MST")
  output = capture.output(show(object))
  expect_true(any(grepl("Multistage Adaptive Test", output)))
  expect_true(any(grepl("Most Common Path", output)))

  object.cumulative = make_mst_object(nc.list = list(method = "cumulative_sum"))
  output.cumulative = capture.output(show(object.cumulative))
  expect_true(any(grepl("Cumulative Summation Scoring", output.cumulative)))

  object.module_sum = make_mst_object(nc.list = list(method = "module_sum"))
  output.module_sum = capture.output(show(object.module_sum))
  expect_true(any(grepl("Module Summation Scoring", output.module_sum)))
})

test_that("MAT class can be constructed and shown", {
  object = make_mat_object()
  expect_s4_class(object, "MAT")
  output = capture.output(show(object))
  expect_true(any(grepl("Mixed Adaptive Test", output)))
  expect_true(any(grepl("Most Common Path", output)))
})
