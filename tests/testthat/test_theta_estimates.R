context("Testing theta estimators")
item.params = matrix(c(1.0, -1, 0, 1,
                       1.2, 0, 0, 1,
                       0.8, 1, 0, 1),
                     nrow = 3, byrow = T)
initial.theta = 1.0
response.pattern = as.data.frame(matrix(c(1,0,1), nrow = 1))

test_that("Theta estimates are what is expected", {
expect_equal(catR::thetaEst(it = item.params, x = response.pattern), 0.1307695, tolerance = .0000001)

expect_equal(catR::eapEst(it = item.params, x = response.pattern), 0.1446946, tolerance = .0000001)

expect_equal(catR::semTheta(thEst = catR::thetaEst(it = item.params, x = response.pattern), it = item.params, x = response.pattern), 0.7705124, tolerance = .0000001)

expect_equal(as.numeric(iterative.theta.estimate(initial_theta = 1, item.params = item.params, response.pattern = response.pattern)[,1]), 0.3248462, tolerance = .0000001)
})

test_that("iterative.theta.estimate clamps to the positive boundary with a warning", {
  # very easy items, all answered correctly: theta is driven up without bound
  easy.items = matrix(c(1.5, -3, 0, 1,
                        1.5, -3, 0, 1,
                        1.5, -3, 0, 1,
                        1.5, -3, 0, 1,
                        1.5, -3, 0, 1),
                      nrow = 5, byrow = TRUE)
  all.correct = as.data.frame(matrix(rep(1, 5), nrow = 1))

  expect_warning(
    result <- iterative.theta.estimate(initial_theta = 0, item.params = easy.items,
                                       response.pattern = all.correct),
    regexp = "boundary"
  )
  expect_equal(unname(result[1, "final.theta.estimates"]), 4)
  expect_true(is.na(result[1, "final.theta.SEM"]))
})

test_that("iterative.theta.estimate clamps to the negative boundary with a warning", {
  # very hard items, all answered incorrectly: theta is driven down without bound
  hard.items = matrix(c(1.5, 3, 0, 1,
                        1.5, 3, 0, 1,
                        1.5, 3, 0, 1,
                        1.5, 3, 0, 1,
                        1.5, 3, 0, 1),
                      nrow = 5, byrow = TRUE)
  all.incorrect = as.data.frame(matrix(rep(0, 5), nrow = 1))

  expect_warning(
    result <- iterative.theta.estimate(initial_theta = 0, item.params = hard.items,
                                       response.pattern = all.incorrect),
    regexp = "boundary"
  )
  expect_equal(unname(result[1, "final.theta.estimates"]), -4)
  expect_true(is.na(result[1, "final.theta.SEM"]))
})

test_that("iterative.theta.estimate clamps when observed information is zero", {
  # zero discrimination items: the observed information denominator is always 0
  degenerate.items = matrix(c(0, -1, 0.2, 1,
                              0, 0, 0.2, 1,
                              0, 1, 0.2, 1),
                            nrow = 3, byrow = TRUE)
  response.pattern.pos = as.data.frame(matrix(c(1, 1, 0), nrow = 1))
  response.pattern.neg = as.data.frame(matrix(c(1, 1, 0), nrow = 1))

  expect_warning(
    result.pos <- iterative.theta.estimate(initial_theta = 2, item.params = degenerate.items,
                                           response.pattern = response.pattern.pos),
    regexp = "zero or non-finite"
  )
  expect_equal(unname(result.pos[1, "final.theta.estimates"]), 4)
  expect_true(is.na(result.pos[1, "final.theta.SEM"]))

  expect_warning(
    result.neg <- iterative.theta.estimate(initial_theta = -2, item.params = degenerate.items,
                                           response.pattern = response.pattern.neg),
    regexp = "zero or non-finite"
  )
  expect_equal(unname(result.neg[1, "final.theta.estimates"]), -4)
  expect_true(is.na(result.neg[1, "final.theta.SEM"]))
})
