context("Testing hybrid_adaptive_test")

data(example_thetas)
data(example_responses)
data(example_transition_matrix)
data(mst_only_items)
data(cat_items)
data(example_module_items)

cat_bank <- cat_items[!rownames(cat_items) %in% rownames(mst_only_items), ]

# --- S4 class ---

make_hat_object = function() {
  new(
    'HAT',
    function.call = quote(hybrid_adaptive_test(cat_item_bank = x, mst_item_bank = y)),
    final.theta.estimate = c(0.5, -0.3),
    final.theta.method = "BM",
    final.theta.SEM = c(0.3, 0.35),
    final.items.seen = matrix(c("Item1", "Item2", "Item3", "Item4"), nrow = 2),
    modules.seen = matrix(c(1, 1, 3, 4, 8, 8), nrow = 2),
    final.responses = matrix(c(1, 0, 0, 1), nrow = 2),
    transition.matrix = matrix(c(0, 0, 1, 0), nrow = 2),
    n.stages = 3,
    runtime = as.difftime(1.5, units = "secs")
  )
}

test_that("HAT class can be constructed and shown", {
  object = make_hat_object()
  expect_s4_class(object, "HAT")
  output = capture.output(show(object))
  expect_true(any(grepl("Hybrid Adaptive Test", output)))
  expect_true(any(grepl("Most Common Path", output)))
  expect_true(any(grepl("Average Theta Estimate", output)))
})

# --- Snapshot test: reproducibility ---

test_that("hybrid_adaptive_test produces expected results", {
  results <- hybrid_adaptive_test(
    response_matrix = example_responses[1:2, ],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4,
    cat_length = 6,
    initial_theta = 0,
    method = "EAP",
    item_method = "MFI"
  )

  reference = readRDS(file = file.path("hybrid_adaptive_test_expected_results1.rds"))
  expect_equal(results@final.theta.estimate, reference@final.theta.estimate)
  expect_equal(results@final.theta.SEM, reference@final.theta.SEM)
  expect_equal(results@final.items.seen, reference@final.items.seen)
  expect_equal(results@modules.seen, reference@modules.seen)
})

# --- Transition matrix: auto-append vs explicit CAT module ---

test_that("MST-only and full transition matrices produce identical results", {
  full_tm <- cbind(example_transition_matrix, c(0, 0, 0, 0, 1, 1, 1))
  full_tm <- rbind(full_tm, rep(0, 8))

  results_auto <- hybrid_adaptive_test(
    response_matrix = example_responses[1:2, ],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4, cat_length = 6,
    initial_theta = 0, method = "EAP", item_method = "MFI"
  )

  results_full <- hybrid_adaptive_test(
    response_matrix = example_responses[1:2, ],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = full_tm,
    n_stages = 4, cat_length = 6,
    initial_theta = 0, method = "EAP", item_method = "MFI"
  )

  expect_equal(results_auto@final.theta.estimate, results_full@final.theta.estimate)
  expect_equal(results_auto@final.items.seen, results_full@final.items.seen)
  expect_equal(results_auto@modules.seen, results_full@modules.seen)
})

test_that("stored transition matrix always includes the CAT module", {
  results <- hybrid_adaptive_test(
    response_matrix = example_responses[1:2, ],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4, cat_length = 6,
    initial_theta = 0, method = "EAP", item_method = "MFI"
  )

  expect_equal(ncol(results@transition.matrix), ncol(example_module_items) + 1)
  expect_equal(nrow(results@transition.matrix), ncol(example_module_items) + 1)
  cat_col <- results@transition.matrix[, ncol(results@transition.matrix)]
  expect_true(any(cat_col == 1))
  expect_true(all(results@transition.matrix[nrow(results@transition.matrix), ] == 0))
})

test_that("invalid transition matrix dimensions produce an error", {
  bad_tm <- matrix(0, nrow = 3, ncol = 3)
  expect_error(
    hybrid_adaptive_test(
      response_matrix = example_responses[1:2, ],
      cat_item_bank = cat_bank,
      mst_item_bank = mst_only_items,
      modules = example_module_items,
      transition_matrix = bad_tm,
      n_stages = 4, cat_length = 6,
      initial_theta = 0, method = "EAP", item_method = "MFI"
    ),
    "transition_matrix"
  )
})

# --- n_stages = 2: single MST routing module + CAT ---

test_that("n_stages = 2 works (one MST module then CAT)", {
  mst_routing <- mst_only_items[mst_only_items$module == 1, ]
  hat_modules <- matrix(rep(1, nrow(mst_routing)), ncol = 1)
  hat_transition <- matrix(0, 1, 1)

  results <- hybrid_adaptive_test(
    response_matrix = example_responses[1:2, ],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_routing,
    modules = hat_modules,
    transition_matrix = hat_transition,
    n_stages = 2,
    cat_length = 10,
    initial_theta = 0, method = "BM", item_method = "MFI"
  )

  expect_s4_class(results, "HAT")
  expect_length(results@final.theta.estimate, 2)
  expect_false(any(is.na(results@final.theta.estimate)))
  expect_equal(ncol(results@modules.seen), 2)
  expect_true(all(results@modules.seen[, 2] == ncol(results@transition.matrix)))
  n_items_per_person <- apply(results@final.items.seen, 1,
                              function(x) sum(!is.na(x)))
  expect_true(all(n_items_per_person == nrow(mst_routing) + 10))
})

# --- Structural invariants ---

test_that("modules.seen last column is always the CAT module", {
  results <- hybrid_adaptive_test(
    response_matrix = example_responses,
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4, cat_length = 6,
    initial_theta = 0, method = "EAP", item_method = "MFI"
  )

  cat_module <- ncol(results@transition.matrix)
  expect_true(all(results@modules.seen[, ncol(results@modules.seen)] == cat_module))
  expect_equal(ncol(results@modules.seen), 4)
  expect_length(results@final.theta.estimate, nrow(example_responses))
  expect_length(results@final.theta.SEM, nrow(example_responses))
})

test_that("final_theta_method defaults to method and can be overridden", {
  results_default <- hybrid_adaptive_test(
    response_matrix = example_responses[1, , drop = FALSE],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4, cat_length = 4,
    initial_theta = 0, method = "BM", item_method = "MFI"
  )

  results_override <- hybrid_adaptive_test(
    response_matrix = example_responses[1, , drop = FALSE],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4, cat_length = 4,
    initial_theta = 0, method = "BM", item_method = "MFI",
    final_theta_method = "EAP"
  )

  expect_equal(results_default@final.theta.method, "BM")
  expect_equal(results_override@final.theta.method, "EAP")
  expect_false(identical(results_default@final.theta.estimate,
                         results_override@final.theta.estimate))
})

test_that("items and responses matrices have consistent dimensions", {
  results <- hybrid_adaptive_test(
    response_matrix = example_responses[1:2, ],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4, cat_length = 6,
    initial_theta = 0, method = "EAP", item_method = "MFI"
  )

  expect_equal(dim(results@final.items.seen), dim(results@final.responses))
  expect_equal(nrow(results@final.items.seen), 2)
  non_na <- apply(results@final.items.seen, 1, function(x) sum(!is.na(x)))
  expect_true(all(non_na > 0))
})
