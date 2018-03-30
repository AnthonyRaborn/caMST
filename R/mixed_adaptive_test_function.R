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
#' @details
#'
#' @return
#' @export
#'
#' @examples
#'

mixed_adaptive_test = function(response_matrix, cat_item_bank,
                               initial_theta = 0, method = "BM",
                               item_method = "MFI", cat_length,
                               nAvailable_cat = NULL, cbControl = NULL,
                               cbGroup = NULL, randomesque = 1,
                               mst_item_bank, modules, transition_matrix){

  start.time = Sys.time()

  internal_response_matrix = response_matrix
  total.item.bank = rbind(cat_item_bank[,1:4], mst_item_bank[,1:4])

  list.of.cat.results <- list()
  for(i in 1:nrow(internal_response_matrix)){

    list.of.cat.results[[i]] = routing_item_selection(i, cat_item_bank = cat_item_bank, initial_theta = initial_theta, response_matrix = internal_response_matrix, model = NULL, method = method, item_method = item_method, cat_length = cat_length, nAvailable = nAvailable_cat, cbControl = cbControl, cbGroup = cbGroup, randomesque= randomesque)

  }

  list.of.mst.results = list()

  for(i in 1:length(list.of.cat.results)){

    module_item_bank = total.item.bank[c(list.of.cat.results[[i]]$Seen.Items, rownames(mst_item_bank)),]

    seen_cat_items = list.of.cat.results[[i]]$Seen.Items

    list.of.mst.results[[i]] = module_selection(i, module_item_bank = module_item_bank, modules = modules, transition_matrix = transition_matrix, theta_est = list.of.cat.results[[i]]$Theta.Est, method = method, seen_cat_items = list.of.cat.results[[i]]$Seen.Items, cat_length, response_matrix = internal_response_matrix)

  }

  print(Sys.time() - start.time)

  return(list.of.mst.results)

}
