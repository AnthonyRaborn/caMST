context("Testing generate_transition_matrix")

data(example_transition_matrix)

test_that("generate_transition_matrix reproduces example_transition_matrix", {
  generated = generate_transition_matrix(
    modules = 7,
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
    modules = 3,
    paths = list("1" = 2, "2" = 3, "3" = 0)
  )

  expected = matrix(c(0, 1, 0,
                      0, 0, 1,
                      0, 0, 0),
                    nrow = 3, byrow = TRUE)

  expect_equal(generated, expected)
})

test_that("generate_transition_matrix errors when modules is not greater than 1", {
  expect_error(
    generate_transition_matrix(modules = 1, paths = list("1" = 0)),
    "Modules needs to be an integer value greater than 1"
  )
  expect_error(
    generate_transition_matrix(modules = 1L, paths = list("1" = 0)),
    "Modules needs to be an integer value greater than 1"
  )
  expect_error(
    generate_transition_matrix(modules = 0, paths = list()),
    "Modules needs to be an integer value greater than 1"
  )
})

test_that("generate_transition_matrix errors when paths length doesn't match modules", {
  expect_error(
    generate_transition_matrix(modules = 3, paths = list("1" = 2, "2" = 3)),
    "Each module needs a valid path to another module"
  )
})

test_that("terminal modules (path = 0) produce all-zero rows", {
  generated = generate_transition_matrix(
    modules = 2,
    paths = list("1" = 2, "2" = 0)
  )

  expect_equal(generated[2, ], c(0, 0))
})
