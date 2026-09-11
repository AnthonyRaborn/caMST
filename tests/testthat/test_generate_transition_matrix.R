context("Testing generate_transition_matrix")

data(example_transition_matrix)

test_that("generate_transition_matrix reproduces example_transition_matrix", {
  generated = generate_transition_matrix(
    n_modules = 7,
    paths = list(
      "1" = c(2, 3, 4),
      "2" = c(5, 6),
      "3" = c(5, 6, 7),
      "4" = c(6, 7),
      "5" = 0,
      "6" = 0,
      "7" = 0
    )
  )

  expect_equal(unname(generated), unname(as.matrix(example_transition_matrix)))
})

test_that("generate_transition_matrix handles a simple linear chain", {
  # module 1 -> module 2 -> module 3 (terminal)
  generated = generate_transition_matrix(
    n_modules = 3,
    paths = list("1" = 2, "2" = 3, "3" = 0)
  )

  expected = matrix(c(0, 1, 0,
                      0, 0, 1,
                      0, 0, 0),
                    nrow = 3, byrow = TRUE)

  expect_equal(generated, expected)
})

test_that("generate_transition_matrix errors when n_modules is not greater than 1", {
  expect_error(
    generate_transition_matrix(n_modules = 1, paths = list("1" = 0)),
    "n_modules needs to be an integer value greater than 1"
  )
  expect_error(
    generate_transition_matrix(n_modules = 1L, paths = list("1" = 0)),
    "n_modules needs to be an integer value greater than 1"
  )
  expect_error(
    generate_transition_matrix(n_modules = 0, paths = list()),
    "n_modules needs to be an integer value greater than 1"
  )
})

test_that("generate_transition_matrix messages only when n_modules is truncated", {
  expect_message(
    generated <- generate_transition_matrix(n_modules = 3.7, paths = list("1" = 2, "2" = 3, "3" = 0)),
    "truncated"
  )
  expect_equal(dim(generated), c(3, 3))

  expect_no_message(
    generate_transition_matrix(n_modules = 7.0, paths = list(
      "1" = c(2, 3, 4), "2" = c(5, 6), "3" = c(5, 6, 7),
      "4" = c(6, 7), "5" = 0, "6" = 0, "7" = 0
    ))
  )
})

test_that("generate_transition_matrix errors when paths length doesn't match n_modules", {
  expect_error(
    generate_transition_matrix(n_modules = 3, paths = list("1" = 2, "2" = 3)),
    "Each module needs a valid path to another module"
  )
})

test_that("terminal modules (path = 0) produce all-zero rows", {
  generated = generate_transition_matrix(
    n_modules = 2,
    paths = list("1" = 2, "2" = 0)
  )

  expect_equal(generated[2, ], c(0, 0))
})

test_that("generate_modules reproduces example_module_items from mst_only_items", {
  data(mst_only_items)
  data(example_module_items)

  generated = generate_modules(mst_only_items, n_modules = 7)

  expect_equal(unname(generated), unname(as.matrix(example_module_items)))
  expect_true(all(rowSums(generated) == 1))
})

test_that("generate_modules errors without a module column", {
  item_bank = data.frame(a = 1:3, b = 1:3)
  expect_error(
    generate_modules(item_bank, n_modules = 2),
    "Your item bank needs to have module information"
  )
})

test_that("generate_modules errors on non-numeric or non-positive module values", {
  item_bank_non_numeric = data.frame(a = 1:3, module = c("1", "2", "3"))
  expect_error(
    generate_modules(item_bank_non_numeric, n_modules = 3),
    "single numeric value"
  )

  item_bank_zero = data.frame(a = 1:3, module = c(0, 1, 2))
  expect_error(
    generate_modules(item_bank_zero, n_modules = 3),
    "single numeric value"
  )
})
