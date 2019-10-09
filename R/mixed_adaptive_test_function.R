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
#' @param n_stages A numerical value indicating the number of stages in the test.
#'
#' @details To be filled in later.
#'
#' @return A list of all individuals with the following elements: the vector of final theta estimates based on "method", the vector of final theta estimates based on EAP, the vector of final theta estimates based on the iterative estimate from Baker 2004, a matrix of the final items taken, a matrix of the modules seen, and a matrix of the final responses.
#' @return An S4 object of class 'MST' with the following slots:
#' \item{function.call}{The function and arguments called to create this object.}
#' \item{final.theta.estimate}{A numeric vector of the final theta estimates using the \code{method} provided in \code{function.call}.}
#' \item{eap.theta}{A numeric vector of the final theta estimates using the expected a posteriori (EAP) theta estimate from \code{catR::eapEst}.}
#' \item{final.theta.Baker}{A numeric vector of the final theta estimates using an iterative maximum likelihood estimation procedure as described in chapter 5 of Baker (2001).}
#' \item{final.theta.SEM}{A numeric vector of the final standard error of measurement (SEM) estimates using an iterative maximum likelihood estimation procedure as described in chapter 5 of Baker (2001).}
#' \item{final.items.seen}{A matrix of the final items seen by each individual using the supplied item names. `NA` values indicate that an individual wasn't given any items to answer after the last specified item in their row.}
#' \item{final.responses}{A matrix of the responses to the items seen in \code{final.items.seen}. \code{NA} values indicate that the individual didn't answer the question in the supplied response file or wasn't given any more items to answer.}
#' \item{transition.matrix}{The \code{transition_matrix} originally supplied to the function.}
#' \item{n.stages}{The \code{n_stages} originally supplied to the function.}
#' \item{runtime}{A \code{difftime} object recording how long the function took to complete.}
#' @export
#'
#' @references Baker (2001). http://echo.edres.org:8080/irt/baker/final.pdf
#' @seealso [multistage_test] for a standard multistage test, [computerized_adaptive_test] for a standard computerized adaptive test.
#'
#' @export
#'
#' @examples
#' \donttest{
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
#' results <- mixed_adaptive_test(response_matrix = example_responses[1:2,],
#'                                cat_item_bank = cat_items, initial_theta = 0,
#'                                method = "EAP", item_method = "MFI",
#'                                cat_length = 6, cbControl = NULL, cbGroup = NULL,
#'                                randomesque = 1, mst_item_bank = mst_items,
#'                                modules = example_module_items,
#'                                transition_matrix = example_transition_matrix,
#'                                n_stages = 3)
#'}
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
                               transition_matrix,
                               n_stages) {
  start.time = Sys.time()

  internal_response_matrix = response_matrix
  total.item.bank = rbind(cat_item_bank[, 1:4], mst_item_bank[, 1:4])

  if (is.null(rownames(total.item.bank))) {
    rownames(total.item.bank) = paste0("Item", 1:nrow(total.item.bank))
    rownames(cat_item_bank) = paste0("Item", 1:nrow(cat_item_bank))
    rownames(mst_item_bank) = paste0("Item", (nrow(cat_item_bank)+1):(nrow(cat_item_bank)+nrow(mst_item_bank)))
    colnames(response_matrix) = paste0("Item", 1:nrow(total.item.bank))
    cat(message("The input item banks did not have row names indicating which items were which, so the item names were filled in automatically for both the item banks and the response matrix.\n\nFor this method, it assumes that by columns the response matrix has the CAT items first, followed by the MST items, and that for each set the order of responses is the same as the order in the item banks!"))
  }


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

    list.of.mst.results[[i]] = moduleSelectionCAMST(
      i,
      module_item_bank = module_item_bank,
      modules = modules,
      transition_matrix = transition_matrix,
      theta_est = list.of.cat.results[[i]]$Theta.Est,
      method = method,
      seen_cat_items = list.of.cat.results[[i]]$Seen.Items,
      cat_length,
      response_matrix = internal_response_matrix,
      n_stage = n_stages
    )

  }

  # create results object
  results =
    new(
      'MAT',
      function.call = match.call(),
      final.theta.estimate = sapply(list.of.mst.results, FUN = function(x) x$final.theta.estimate.mstR),
      eap.theta = sapply(list.of.mst.results, FUN = function(x) x$eap.theta),
      final.theta.Baker = sapply(list.of.mst.results, FUN = function(x) x$final.theta.iterative),
      final.theta.SEM = sapply(list.of.mst.results, FUN = function(x) x$sem.iterative),
      final.items.seen = sapply(list.of.mst.results, FUN = function(x) x$final.items.seen),
      modules.seen = t(sapply(list.of.mst.results, FUN = function(x) x$modules.seen)),
      final.responses = t(sapply(list.of.mst.results, FUN = function(x) x$final.responses)),
      runtime = Sys.time() - start.time
    )

  print(results@runtime)

  return(
    results
  )
}
