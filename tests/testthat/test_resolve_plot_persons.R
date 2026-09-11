context("Testing resolve_plot_persons")

# resolve_plot_persons only touches nrow(object@final.responses), so the
# lightweight fixtures from test_s4_classes.R (2 persons) are sufficient
# here -- no need for a real administered result.
make_two_person_object = function() {
  new(
    'CAT',
    function.call = quote(computerized_adaptive_test(cat_item_bank = x, response_matrix = y)),
    final.theta.estimate = c(0.5, -0.3),
    final.theta.method = "BM",
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2", "Item3", "Item4"), nrow = 2),
    final.responses = matrix(c(1, 0, 0, 1), nrow = 2),
    item.bank = data.frame(a = c(1, 1.2), b = c(-0.5, 0.5), c = c(0.2, 0.2), d = c(1, 1)),
    method = "BM",
    model = NULL,
    runtime = as.difftime(1, units = "secs")
  )
}

test_that("NULL person defaults to 1 with a message", {
  object = make_two_person_object()
  expect_message(
    resolved <- resolve_plot_persons(object, NULL, FALSE),
    "defaulting to respondent 1"
  )
  expect_equal(resolved$person, 1L)
  expect_false(resolved$facet_person)
})

test_that("out-of-range person indices error clearly", {
  object = make_two_person_object()
  expect_error(resolve_plot_persons(object, 0, FALSE), "between 1 and 2")
  expect_error(resolve_plot_persons(object, 3, FALSE), "between 1 and 2")
  expect_error(resolve_plot_persons(object, c(1, 3), FALSE), "between 1 and 2")
})

test_that("facet_person = TRUE with a single person warns and is ignored", {
  object = make_two_person_object()

  expect_warning(
    resolved <- resolve_plot_persons(object, 1, TRUE),
    "only one person was selected"
  )
  expect_false(resolved$facet_person)
  expect_equal(resolved$person, 1L)

  # same collapse when person defaults to 1 (no explicit person given)
  expect_warning(
    expect_message(
      resolved2 <- resolve_plot_persons(object, NULL, TRUE),
      "defaulting to respondent 1"
    ),
    "only one person was selected"
  )
  expect_false(resolved2$facet_person)
})

test_that("facet_person = TRUE with multiple persons is left alone", {
  object = make_two_person_object()
  resolved = resolve_plot_persons(object, c(1, 2), TRUE)
  expect_true(resolved$facet_person)
  expect_equal(resolved$person, c(1L, 2L))
})

test_that("explicit valid person passes through unchanged, no facet", {
  object = make_two_person_object()
  resolved = resolve_plot_persons(object, 2, FALSE)
  expect_equal(resolved$person, 2L)
  expect_false(resolved$facet_person)
})
