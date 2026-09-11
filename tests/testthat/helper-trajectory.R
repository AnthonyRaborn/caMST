# Shared small result-object builders for the theta-trajectory test files.
# Kept deliberately small (few items/persons) since several of these get
# fed into ggplot2/gganimate, which are slower to build/render than the
# underlying test administration itself.

make_small_cat_result = function(n_persons = 2, final_theta_method = NULL) {
  data(example_responses, package = "caMST", envir = environment())
  data(cat_items, package = "caMST", envir = environment())

  computerized_adaptive_test(
    cat_item_bank = cat_items,
    response_matrix = example_responses[1:n_persons, , drop = FALSE],
    randomesque = 1,
    maxItems = 4,
    final_theta_method = final_theta_method,
    nextItemControl = list(
      criterion = "MFI", priorDist = "norm", priorPar = c(0, 1), D = 1,
      range = c(-4, 4), parInt = c(-4, 4, 33), infoType = "Fisher",
      random.seed = NULL, rule = "precision", thr = .3,
      nAvailable = NULL, cbControl = NULL, cbGroup = NULL
    )
  )
}

make_small_mst_result = function(n_persons = 2, final_theta_method = NULL) {
  data(example_responses, package = "caMST", envir = environment())
  data(mst_only_items, package = "caMST", envir = environment())
  data(example_module_items, package = "caMST", envir = environment())
  data(example_transition_matrix, package = "caMST", envir = environment())

  multistage_test(
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    method = "BM",
    response_matrix = example_responses[1:n_persons, , drop = FALSE],
    initial_theta = 0,
    model = NULL,
    n_stages = 3,
    test_length = 18,
    final_theta_method = final_theta_method
  )
}

make_small_mat_result = function(n_persons = 2, final_theta_method = NULL) {
  data(example_responses, package = "caMST", envir = environment())
  data(cat_items, package = "caMST", envir = environment())
  data(mst_items, package = "caMST", envir = environment())
  data(example_module_items, package = "caMST", envir = environment())
  data(example_transition_matrix, package = "caMST", envir = environment())

  mixed_adaptive_test(
    response_matrix = example_responses[1:n_persons, , drop = FALSE],
    cat_item_bank = cat_items,
    initial_theta = 0,
    method = "EAP",
    item_method = "MFI",
    cat_length = 6,
    cbControl = NULL,
    cbGroup = NULL,
    randomesque = 1,
    mst_item_bank = mst_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 3,
    final_theta_method = final_theta_method
  )
}

make_small_hat_result = function(n_persons = 2, final_theta_method = NULL) {
  data(example_responses, package = "caMST", envir = environment())
  data(mst_only_items, package = "caMST", envir = environment())
  data(example_module_items, package = "caMST", envir = environment())
  data(example_transition_matrix, package = "caMST", envir = environment())
  data(cat_items, package = "caMST", envir = environment())

  cat_bank = cat_items[!rownames(cat_items) %in% rownames(mst_only_items), ]

  hybrid_adaptive_test(
    response_matrix = example_responses[1:n_persons, , drop = FALSE],
    cat_item_bank = cat_bank,
    mst_item_bank = mst_only_items,
    modules = example_module_items,
    transition_matrix = example_transition_matrix,
    n_stages = 4,
    cat_length = 4,
    initial_theta = 0,
    method = "EAP",
    item_method = "MFI",
    final_theta_method = final_theta_method
  )
}
