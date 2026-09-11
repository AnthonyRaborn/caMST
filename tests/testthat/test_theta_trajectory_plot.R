context("Testing theta_trajectory_plot")

test_that("returns a ggplot object for a CAT result", {
  result = make_small_cat_result()
  p = theta_trajectory_plot(result, person = 1)

  expect_s3_class(p, "ggplot")
  geoms = sapply(p$layers, function(l) class(l$geom)[1])
  expect_true("GeomLine" %in% geoms)
  expect_true("GeomErrorbar" %in% geoms)
  expect_true("GeomPoint" %in% geoms)
})

test_that("defaults to respondent 1 with a message when person is omitted", {
  result = make_small_cat_result()
  expect_message(
    p <- theta_trajectory_plot(result),
    "defaulting to respondent 1"
  )
  expect_s3_class(p, "ggplot")
  expect_true(grepl("Respondent 1", p$labels$title))
})

test_that("multiple persons overlay by default, facet_person = TRUE facets", {
  result = make_small_cat_result(n_persons = 2)

  p_overlay = theta_trajectory_plot(result, person = c(1, 2))
  expect_s3_class(p_overlay$facet, "FacetNull")

  p_facet = theta_trajectory_plot(result, person = c(1, 2), facet_person = TRUE)
  expect_s3_class(p_facet$facet, "FacetWrap")
})

test_that("facet_person = TRUE with one person warns and falls back to a single panel", {
  result = make_small_cat_result()
  expect_warning(
    p <- theta_trajectory_plot(result, person = 1, facet_person = TRUE),
    "only one person was selected"
  )
  expect_s3_class(p$facet, "FacetNull")
})

test_that("ci_multiplier changes the error bar width", {
  result = make_small_cat_result()
  p1 = theta_trajectory_plot(result, person = 1, ci_multiplier = 1)
  p196 = theta_trajectory_plot(result, person = 1, ci_multiplier = 1.96)

  eb1 = ggplot2::layer_data(p1, which(sapply(p1$layers, function(l) class(l$geom)[1]) == "GeomErrorbar"))
  eb196 = ggplot2::layer_data(p196, which(sapply(p196$layers, function(l) class(l$geom)[1]) == "GeomErrorbar"))

  expect_true(all((eb196$ymax - eb196$ymin) > (eb1$ymax - eb1$ymin)))
})

test_that("MST result plots with a step geom for the module segment", {
  result = make_small_mst_result()
  p = theta_trajectory_plot(result, person = 1)
  geoms = sapply(p$layers, function(l) class(l$geom)[1])
  expect_true("GeomStep" %in% geoms)
})

test_that("MAT and HAT results (mixed CAT+MST segments) plot without error", {
  mat_result = make_small_mat_result()
  expect_no_error(p_mat <- theta_trajectory_plot(mat_result, person = 1))
  expect_s3_class(p_mat, "ggplot")

  hat_result = make_small_hat_result()
  expect_no_error(p_hat <- theta_trajectory_plot(hat_result, person = 1))
  expect_s3_class(p_hat, "ggplot")
})

test_that("a differing final_theta_method produces a visually distinct final point", {
  result = make_small_cat_result(final_theta_method = "EAP")
  p = theta_trajectory_plot(result, person = 1)
  geoms = sapply(p$layers, function(l) class(l$geom)[1])
  # two separate GeomPoint layers: provisional (circle) and final (triangle)
  expect_equal(sum(geoms == "GeomPoint"), 2)
})
