context("Testing theta estimators")
item.params = matrix(c(1.0, -1, 0, 1,
                       1.2, 0, 0, 1,
                       0.8, 1, 0, 1),
                     nrow = 3, byrow = T)
initial.theta = 1.0
response.pattern = as.data.frame(matrix(c(1,0,1), nrow = 1))

test_that("Theta estimates are what is expected", {
expect_equal(catR::thetaEst(it = item.params, x = response.pattern), 0.1307695, tolerance = .0000001)
expect_equal(mstR::thetaEst(it = item.params, x = response.pattern), 0.1307695, tolerance = .0000001)

expect_equal(catR::eapEst(it = item.params, x = response.pattern), 0.1446946, tolerance = .0000001)
expect_equal(mstR::eapEst(it = item.params, x = response.pattern), 0.1446946, tolerance = .0000001)

expect_equal(catR::semTheta(thEst = catR::thetaEst(it = item.params, x = response.pattern), it = item.params, x = response.pattern), 0.7705124, tolerance = .0000001)
expect_equal(mstR::semTheta(thEst = mstR::thetaEst(it = item.params, x = response.pattern), it = item.params, x = response.pattern), 0.7705124, tolerance = .0000001)

expect_equal(as.numeric(iterative.theta.estimate(initial_theta = 1, item.params = item.params, response.pattern = response.pattern)[,1]), 0.3248462, tolerance = .0000001)
})
