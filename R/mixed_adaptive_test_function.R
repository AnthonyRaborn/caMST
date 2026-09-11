#' Mixed Computerized Adaptive Multistage Test
#'
#' @param response_matrix A matrix of the person responses, with individuals as rows and items as columns.
#' @param cat_item_bank A data frame with the first stage items on the rows and their item parameters on the columns. These should be in the \pkg{catR} package format for item banks.
#' @param initial_theta The initial theta estimate for all individuals.
#' @param method A character value indicating method for the provisional theta estimate. Defaults to "BM" (Bayes Modal). See the \pkg{catR} package for more details.
#' @param item_method A character value indicating the method for the item-level selection in the first stage. Defaults to "MFI" (Maximum Fisher Information). See the \pkg{catR} package for more details.
#' @param cat_length A numeric value indicating the number of items in the first stage.
#' @param nAvailable_cat Defaults to `NULL`. See the \pkg{catR} package for more information on how to use this option.
#' @param cbControl A list of the appropriate format used to control for content balancing in the first stage. See the Details in the nextItem function in \pkg{catR}.
#' @param cbGroup A factor vector of the appropriate format used to control for content balancing in the first stage. See the Details in the nextItem function in \pkg{catR}.
#' @param randomesque An integer indicating the number of items from which to select the next item to administer in the first stage. Default value is 1.
#' @param mst_item_bank A data frame with the second stage and beyond items on the rows and their item parameters on the columns. These should be in the \pkg{catR} package format for item banks.
#' @param modules A matrix describing the relationship between the items and the modules they belong to. See \strong{Details}.
#' @param transition_matrix A matrix describing how individuals can transition from one stage to the next.
#' @param n_stages A numerical value indicating the number of stages in the test.
#' @param module_select A character value indicating the information method used to select modules at transition stages. One of "MFI" (default), "MLWMI", "MPWMI", "MKL", "MKLP", "random".
#' @param final_theta_method A character value indicating the method used for the single final theta estimate reported in the result. One of "BM", "ML", "WL", "ROB" (passed to \code{catR::thetaEst}) or "EAP" (uses \code{catR::eapEst}). Defaults to \code{NULL}, which reuses whatever \code{method} was.
#' @param model Either \code{NULL} (default) for dichotomous models or a character value indicating the polytomous model used, applied to both the CAT and MST stages. See the \pkg{catR} package for more details.
#'
#' @details A mixed adaptive test runs two stages of adaptation back to back. First,
#' every person takes a CAT routing stage: \code{cat_length} items are chosen
#' one at a time from \code{cat_item_bank} using item-level adaptation
#' (\code{item_method}, e.g. maximum Fisher information), exactly as in
#' \code{\link{computerized_adaptive_test}}. The theta estimate produced by
#' that routing stage is then used as the starting theta for a standard
#' multistage test: \code{n_stages - 1} additional modules are administered
#' from \code{mst_item_bank}, chosen at the module level using
#' \code{module_select} and the person's location in \code{transition_matrix},
#' exactly as in \code{\link{multistage_test}}. The first "stage" of
#' \code{n_stages} is the CAT routing stage itself, so a design with a CAT
#' routing stage followed by two MST modules uses \code{n_stages = 3}.
#'
#' For dichotomous tests (\code{model = NULL}), \code{cat_item_bank} and
#' \code{mst_item_bank} must both be in \pkg{catR} item-bank format and
#' contain the same IRT parameter columns, named either \code{a, b, c, u} or
#' \code{a, b, c, d} (discrimination, difficulty, guessing, and upper
#' asymptote). For polytomous tests, both banks must use the \emph{same}
#' \code{model} and the same number of response categories, since \pkg{catR}
#' gives item banks generated under those conditions identical column
#' layouts (see \code{catR::genPolyMatrix}); a mismatch in category count
#' between the two banks will fail with a clear error when they're combined.
#' Either way, the two banks are combined internally (CAT items first, then
#' MST items) to build the item bank used for scoring; \code{modules} and
#' \code{transition_matrix} describe only the MST portion, in the same
#' format used by \code{\link{multistage_test}}, and should reference item
#' positions within \code{mst_item_bank}.
#'
#' @return An S4 object of class 'MAT' with the following slots:
#' \item{function.call}{The function and arguments called to create this object.}
#' \item{final.theta.estimate}{A numeric vector of the final theta estimates, computed using \code{final_theta_method}.}
#' \item{final.theta.method}{The \code{final_theta_method} used to compute \code{final.theta.estimate} and \code{final.theta.SEM}.}
#' \item{final.theta.SEM}{A numeric vector of the final standard error of measurement (SEM) estimates, from \code{catR::semTheta}.}
#' \item{final.items.seen}{A matrix of the final items seen by each individual using the supplied item names. `NA` values indicate that an individual wasn't given any items to answer after the last specified item in their row.}
#' \item{final.responses}{A matrix of the responses to the items seen in \code{final.items.seen}. \code{NA} values indicate that the individual didn't answer the question in the supplied response file or wasn't given any more items to answer.}
#' \item{transition.matrix}{The \code{transition_matrix} originally supplied to the function.}
#' \item{n.stages}{The \code{n_stages} originally supplied to the function.}
#' \item{runtime}{A \code{difftime} object recording how long the function took to complete.}
#' @export
#'
#' @references Baker, F. B. (2001). The Basics of Item Response Theory (2nd ed.). ERIC Clearinghouse on Assessment and Evaluation. Full text: https://eric.ed.gov/?id=ED458219
#' @seealso [multistage_test] for a standard multistage test, [computerized_adaptive_test] for a standard computerized adaptive test.
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
                               n_stages,
                               module_select = "MFI",
                               final_theta_method = NULL,
                               model = NULL) {
  start.time = Sys.time()

  if (is.null(final_theta_method)) final_theta_method = method

  internal_response_matrix = response_matrix

  if (is.null(model)) {
    param_cols = c("a", "b", "c", "u")
    if (!all(param_cols %in% colnames(cat_item_bank)) ||
        !all(param_cols %in% colnames(mst_item_bank))) {
      param_cols = c("a", "b", "c", "d")
    }
    missing_cols = union(setdiff(param_cols, colnames(cat_item_bank)),
                         setdiff(param_cols, colnames(mst_item_bank)))
    if (length(missing_cols) > 0) {
      stop("cat_item_bank and mst_item_bank must both contain the IRT parameter columns 'a', 'b', 'c', and either 'u' or 'd'.")
    }
    total.item.bank = rbind(cat_item_bank[, param_cols], mst_item_bank[, param_cols])
  } else {
    # polytomous item banks generated under the same model and category
    # count already share column layouts; rbind() fails clearly on mismatch
    total.item.bank = rbind(cat_item_bank, mst_item_bank)
  }

  if (is.null(rownames(total.item.bank))) {
    rownames(total.item.bank) = paste0("Item", 1:nrow(total.item.bank))
    rownames(cat_item_bank) = paste0("Item", 1:nrow(cat_item_bank))
    rownames(mst_item_bank) = paste0("Item", (nrow(cat_item_bank)+1):(nrow(cat_item_bank)+nrow(mst_item_bank)))
    colnames(response_matrix) = paste0("Item", 1:nrow(total.item.bank))
    message("The input item banks did not have row names indicating which items were which, so the item names were filled in automatically for both the item banks and the response matrix.\n\nFor this method, it assumes that by columns the response matrix has the CAT items first, followed by the MST items, and that for each set the order of responses is the same as the order in the item banks!")
  }


  list.of.cat.results <- list()
  for (i in 1:nrow(internal_response_matrix)) {
    list.of.cat.results[[i]] = routing_item_selection(
      i,
      cat_item_bank = cat_item_bank,
      initial_theta = initial_theta,
      response_matrix = internal_response_matrix,
      model = model,
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
      n_stage = n_stages,
      module_select = module_select,
      final_theta_method = final_theta_method,
      model = model
    )

  }

  # create results object
  results =
    new(
      'MAT',
      function.call = match.call(),
      final.theta.estimate = sapply(list.of.mst.results, FUN = function(x) x$final.theta.estimate.mstR),
      final.theta.method = final_theta_method,
      final.theta.SEM = sapply(list.of.mst.results, FUN = function(x) x$final.theta.SEM),
      final.items.seen = sapply(list.of.mst.results, FUN = function(x) x$final.items.seen),
      modules.seen = t(sapply(list.of.mst.results, FUN = function(x) x$modules.seen)),
      final.responses = t(sapply(list.of.mst.results, FUN = function(x) x$final.responses)),
      transition.matrix = transition_matrix,
      n.stages = n_stages,
      cat.item.bank = cat_item_bank,
      mst.item.bank = mst_item_bank,
      mst.modules = modules,
      method = method,
      model = model,
      runtime = Sys.time() - start.time
    )

  print(results@runtime)

  return(
    results
  )
}
