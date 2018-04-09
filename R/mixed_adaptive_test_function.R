#' Mixed Computerized Adaptive Multistage Test
#'
#' @param response_matrix A matrix of the person responses, with individuals as rows and items as columns.
#' @param cat_item_bank A data frame with the first stage items on the rows and their item parameters on the columns. These should be in the \pkg{mstR} package format for item banks.
#' @param initial_theta The initial theta estimate for all individuals.
#' @param method A character value indicating method for the provisional theta estimate. Defaults to "BM" (Bayes Modal). See the \pkg{catR} and \pkg{mstR} packages for more details.
#' @param item_method A character value indicating the method for the item-level selection in the first stage. Defaults to "MFI" (Maximum Fisher Information). See the \pkg{catR} and \pkg{mstR} packages for more details.
#' @param cat_length A numeric value indicating the number of items in the first stage.
#' @param nAvailable_cat Defaults to `NULL`. See the \pkg{catR} package for more information on how to use this option.
#' @param cbControl A list of the appropriate format used to control for content balancing in the first stage. See the Details in the nextItem function in \pkg{catR}.
#' @param cbGroup A factor vector of the appropriate format used to control for content balancing in the first stage. See the Details in the nextItem function in \pkg{catR}.
#' @param randomesque An integer indicating the number of items from which to select the next item to administer in the first stage. Default value is 1.
#' @param mst_item_bank A data frame with the second stage and beyond items on the rows and their item parameters on the columns. These should be in the \pkg{mstR} package format for item banks.
#' @param modules A matrix describing the relationship between the items and the modules they belong to. See \strong{Details}.
#' @param transition_matrix A matrix describing how individuals can transition from one stage to the next.
#'
#' @details To be filled in later.
#'
#' @return A list with eight elements. The first three elements are the final
#' theta estimates (the chosen estimate put into the function
#' [$final.theta.estimate.mstR], the EAP estimate [$eap.theta], and the
#' iterative estimate from Baker 2004 [$final.theta.iterative]). The fourth
#' element is the standard error of measurement of the iterative theta estimate
#' [$sem.iterative]. The fifth element is a data frame of the final item bank
#' the individual saw [$final.item.bank]. The sixth element is a character
#' vector of the item names the person saw [$final.items.seen]. The seventh
#' element is a vector of the modules the person saw [$modules.seen]. The eighth
#' and final element is a vector of the response pattern
#'
#' @export
#'
#' @examples
#' # using simulated test data
#' data(example_thetas) # 5 simulated abilities
#' data(example_responses) # 5 simulated response vectors
#' # the transition matrix for an 18 item 1-3-3 balanced design
#' data(example_transition_matrix)
#' # the items designated for use in the routing module with item-level
#' # adaptation
#' data(cat_items)
#' # the items designated for use in the second and third modules with
#' # module-level adaptation
#' data(mst_items)
#' # the matrix specifying how the item data frame relates to the modules
#' data(example_module_items)
#'
#' # run the Mca-MST model
#' results <- mixed_adaptive_test(response_matrix = example_responses,
#'                                cat_item_bank = cat_items, initial_theta = 0,
#'                                method = "EAP", item_method = "MFI",
#'                                cat_length = 6, cbControl = NULL, cbGroup = NULL,
#'                                randomesque = 1, mst_item_bank = mst_items,
#'                                modules = example_module_items,
#'                                transition_matrix = example_transition_matrix)
#'
#'

mixed_adaptive_test = function(response_matrix,
                               cat_item_bank,
                               initial_theta = 0,
                               method = "BM",
                               item_method = "MFI",
                               cat_length,
                               nAvailable_cat = NULL,
                               cbControl = NULL,
                               cbGroup = NULL,
                               randomesque = 1,
                               mst_item_bank,
                               modules,
                               transition_matrix) {
  start.time = Sys.time()

  internal_response_matrix = response_matrix
  total.item.bank = rbind(cat_item_bank[, 1:4], mst_item_bank[, 1:4])

  list.of.cat.results <- list()
  for (i in 1:nrow(internal_response_matrix)) {
    list.of.cat.results[[i]] = routing_item_selection(
      i,
      cat_item_bank = cat_item_bank,
      initial_theta = initial_theta,
      response_matrix = internal_response_matrix,
      model = NULL,
      method = method,
      item_method = item_method,
      cat_length = cat_length,
      nAvailable = nAvailable_cat,
      cbControl = cbControl,
      cbGroup = cbGroup,
      randomesque = randomesque
    )

  }

  list.of.mst.results = list()

  for (i in 1:length(list.of.cat.results)) {
    module_item_bank = total.item.bank[c(list.of.cat.results[[i]]$Seen.Items,
                                         rownames(mst_item_bank)), ]

    seen_cat_items = list.of.cat.results[[i]]$Seen.Items

    list.of.mst.results[[i]] = module_selection(
      i,
      module_item_bank = module_item_bank,
      modules = modules,
      transition_matrix = transition_matrix,
      theta_est = list.of.cat.results[[i]]$Theta.Est,
      method = method,
      seen_cat_items = list.of.cat.results[[i]]$Seen.Items,
      cat_length,
      response_matrix = internal_response_matrix
    )

  }

  print(Sys.time() - start.time)

  return(list.of.mst.results)

}
