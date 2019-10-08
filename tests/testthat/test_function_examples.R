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

referenceMSTResults = readRDS(file = file.path("multistage_test_expected_results1.rds"))
expect_equal(
  c(referenceMSTResults@function.call,
    referenceMSTResults@final.theta.estimate.catR,
    referenceMSTResults@final.items.seen,
    referenceMSTResults@final.theta.SEM),
  c(results1@function.call,
    results1@final.theta.estimate.catR,
    results1@final.items.seen,
    results1@final.theta.SEM)
)

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

referenceNCResults = readRDS(file = file.path("multistage_test_expected_results2.rds"))
expect_equal(
  c(referenceNCResults@function.call,
    referenceNCResults@final.theta.estimate.catR,
    referenceNCResults@final.items.seen,
    referenceNCResults@final.theta.SEM),
  c(results2@function.call,
    results2@final.theta.estimate.catR,
    results2@final.items.seen,
    results2@final.theta.SEM)
)

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

referenceMixedResults = readRDS(file = file.path("mixed_adaptive_test_expected_results1.rds"))
expect_equal(
  c(referenceMixedResults@function.call,
    referenceMixedResults@final.theta.estimate.catR,
    referenceMixedResults@final.items.seen,
    referenceMixedResults@final.theta.SEM),
  c(results3@function.call,
    results3@final.theta.estimate.catR,
    results3@final.items.seen,
    results3@final.theta.SEM)
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
referenceCatResults = readRDS(file = file.path("computerized_adaptive_test_expected_results1.rds"))
expect_equal(
  c(referenceCatResults@function.call,
    referenceCatResults@final.theta.estimate.catR,
    referenceCatResults@final.items.seen,
    referenceCatResults@final.theta.SEM),
  c(catResults@function.call,
    catResults@final.theta.estimate.catR,
    catResults@final.items.seen,
    catResults@final.theta.SEM)
)
