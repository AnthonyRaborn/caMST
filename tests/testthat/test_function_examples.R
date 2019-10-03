context("Testing function examples")

## example data files ####
data(example_thetas) # 5 simulated abilities
data(example_responses) # 5 simulated response vectors
# the transition matrix for an 18 item 1-3-3 balanced design
data(example_transition_matrix)
# the MST item bank
data(mst_only_items)
# the items designated for use in the routing module with item-level adaptation
data(cat_items)
# the items designated for use in the second and third modules with module-level adaptation
data(mst_items)
# the matrix specifying how the item data frame relates to the modules
data(example_module_items)
# the NC control list
nc_list = list(
  module1 = c(4, 5, 7),
  module2 = c(8, 14, Inf),
  module3 = c(8, 14, 18),
  module4 = c(-Inf, 14, 18),
  method = 3
) # the method here will default to "cumulative_sum" as described in 'details'


## multistage_test ####
# run the MST model
results1 <- multistage_test(
  mst_item_bank = mst_only_items,
  modules = example_module_items,
  transition_matrix = example_transition_matrix,
  method = "BM",
  response_matrix = example_responses,
  initial_theta = 0,
  model = NULL,
  n_stages = 3,
  test_length = 18
)

expect_equal(readRDS(file = file.path("multistage_test_expected_results1.rds")),
          results1)

# run the NC example
results2 <- multistage_test(
  mst_item_bank = mst_only_items,
  modules = example_module_items,
  transition_matrix = example_transition_matrix,
  method = "BM",
  response_matrix = example_responses,
  initial_theta = 0,
  model = NULL,
  n_stages = 3,
  test_length = 18,
  nc_list = nc_list
)

expect_equal(readRDS(file = file.path("multistage_test_expected_results2.rds")),
          results2)


## mixed_adaptive_test ####
# run the Mca-MST model
results3 <-
  mixed_adaptive_test(
    response_matrix = example_responses[1:2, ],
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
    n_stages = 3
  )
expect_equal(
  readRDS(file = file.path("mixed_adaptive_test_expected_results1.rds")),
  results3
)

## computerized_adaptive_test ####
catResults <- computerized_adaptive_test(
  cat_item_bank = cat_items,
  response_matrix = example_responses,
  randomesque = 1,
  maxItems = 3,
  nextItemControl = list(
    criterion = "MFI",
    priorDist = "norm",
    priorPar = c(0, 1),
    D = 1,
    range = c(-4, 4),
    parInt = c(-4, 4, 33),
    infoType = "Fisher",
    randomesque = 1,
    random.seed = NULL,
    rule = "precision",
    thr = .3,
    nAvailable = NULL,
    cbControl = NULL,
    cbGroup = NULL
  )
)
expect_equal(
  readRDS(file = file.path("computerized_adaptive_test_expected_results1.rds")),
  catResults
)
