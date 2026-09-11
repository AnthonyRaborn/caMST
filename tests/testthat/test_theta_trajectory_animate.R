context("Testing theta_trajectory_animate")

test_that("returns a renderable animation object when file is not provided", {
  result = make_small_cat_result()
  anim = suppressWarnings(
    theta_trajectory_animate(result, person = 1, fps = 5)
  )
  expect_true(inherits(anim, "magick-image") || inherits(anim, "gif_image"))
})

test_that("file = saves a real GIF and returns invisibly", {
  result = make_small_cat_result()
  f = tempfile(fileext = ".gif")

  suppressWarnings(
    theta_trajectory_animate(result, person = 1, file = f, fps = 5)
  )

  expect_true(file.exists(f))
  expect_gt(file.info(f)$size, 0)
  unlink(f)
})

test_that("custom transition_length/state_length/fps don't error", {
  result = make_small_cat_result()
  expect_no_error(
    suppressWarnings(
      theta_trajectory_animate(result, person = 1,
                               transition_length = 1, state_length = 2, fps = 5)
    )
  )
})

test_that("defaults to respondent 1 with a message when person is omitted", {
  result = make_small_cat_result()
  expect_message(
    suppressWarnings(theta_trajectory_animate(result, fps = 5)),
    "defaulting to respondent 1"
  )
})

test_that("facet_person = TRUE with one person warns and is ignored", {
  result = make_small_cat_result()
  expect_warning(
    theta_trajectory_animate(result, person = 1, facet_person = TRUE, fps = 5),
    "only one person was selected"
  )
})

test_that("MST result animates without error", {
  result = make_small_mst_result()
  expect_no_error(
    suppressWarnings(theta_trajectory_animate(result, person = 1, fps = 5))
  )
})
