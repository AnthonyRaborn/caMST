#' Hybrid Computerized Adaptive Multistage Test
#'
#' @param response_matrix A matrix of the person responses, with individuals as rows and items as columns.
#' @param cat_item_bank A data frame with the final (CAT) stage items on the rows and their item parameters on the columns. These should be in the \pkg{catR} package format for item banks.
#' @param initial_theta The initial theta estimate for all individuals.
#' @param method A character value indicating method for the provisional theta estimate. Defaults to "BM" (Bayes Modal). See the \pkg{catR} package for more details.
#' @param item_method A character value indicating the method for the item-level selection in the CAT stage. Defaults to "MFI" (Maximum Fisher Information). See the \pkg{catR} package for more details.
#' @param cat_length A numeric value indicating the number of items in the CAT stage.
#' @param nAvailable_cat Defaults to `NULL`. See the \pkg{catR} package for more information on how to use this option.
#' @param cbControl A list of the appropriate format used to control for content balancing in the CAT stage. See the Details in the nextItem function in \pkg{catR}.
#' @param cbGroup A factor vector of the appropriate format used to control for content balancing in the CAT stage. See the Details in the nextItem function in \pkg{catR}.
#' @param randomesque An integer indicating the number of items from which to select the next item to administer in the CAT stage. Default value is 1.
#' @param mst_item_bank A data frame with the MST stage items on the rows and their item parameters on the columns. These should be in the \pkg{catR} package format for item banks.
#' @param modules A matrix describing the relationship between the items and the modules they belong to. See \strong{Details}.
#' @param transition_matrix A matrix describing how individuals can transition from one module to the next. This may include only the MST modules (\code{ncol(modules)} columns); if so, a final CAT column is appended automatically with terminal MST modules routing to it. Alternatively, the matrix may include the CAT stage as the last row/column (\code{ncol(modules) + 1} columns), which is recommended so that \code{\link{transition_matrix_plot}} can display the full design.
#' @param n_stages A numerical value indicating the total number of stages in the test, including both the MST stages and the final CAT stage. The MST portion uses \code{n_stages - 1} stages.
#' @param module_select A character value indicating the information method used to select modules at transition stages. One of "MFI" (default), "MLWMI", "MPWMI", "MKL", "MKLP", "random".
#' @param final_theta_method A character value indicating the method used for the single final theta estimate reported in the result. One of "BM", "ML", "WL", "ROB" (passed to \code{catR::thetaEst}) or "EAP" (uses \code{catR::eapEst}). Defaults to \code{NULL}, which reuses whatever \code{method} was.
#' @param model Either \code{NULL} (default) for dichotomous models or a character value indicating the polytomous model used, applied to both the CAT and MST stages. See the \pkg{catR} package for more details.
#'
#' @details A hybrid adaptive test runs two stages of adaptation back to back
#' in the opposite order from \code{\link{mixed_adaptive_test}}. First,
#' every person takes one or more MST stages: modules are selected from
#' \code{mst_item_bank} using module-level adaptation (\code{module_select}),
#' exactly as in \code{\link{multistage_test}}, to produce a provisional
#' theta estimate. That estimate is then used as the starting theta for a
#' final CAT stage: \code{cat_length} items are chosen one at a time from
#' \code{cat_item_bank} using item-level adaptation (\code{item_method}),
#' with theta re-estimated after each item using \emph{all} items seen so
#' far (MST and CAT combined). The first \code{n_stages - 1} stages are
#' the MST portion; the last stage is the CAT. So a design with one MST
#' routing module followed by a CAT stage uses \code{n_stages = 2}, and a
#' design with a 1-3 MST followed by CAT uses \code{n_stages = 3}.
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
#' Either way, the two banks are combined internally (MST items first, then
#' CAT items) to build the item bank used for scoring; \code{modules} and
#' \code{transition_matrix} describe only the MST portion, in the same
#' format used by \code{\link{multistage_test}}, and should reference item
#' positions within \code{mst_item_bank}.
#'
#' @return An S4 object of class 'HAT' with the following slots:
#' \item{function.call}{The function and arguments called to create this object.}
#' \item{final.theta.estimate}{A numeric vector of the final theta estimates, computed using \code{final_theta_method}.}
#' \item{final.theta.method}{The \code{final_theta_method} used to compute \code{final.theta.estimate} and \code{final.theta.SEM}.}
#' \item{final.theta.SEM}{A numeric vector of the final standard error of measurement (SEM) estimates, from \code{catR::semTheta}.}
#' \item{final.items.seen}{A matrix of the final items seen by each individual using the supplied item names. \code{NA} values indicate that an individual wasn't given any items to answer after the last specified item in their row.}
#' \item{modules.seen}{A matrix of the modules seen by each individual, including the CAT stage as the final module.}
#' \item{final.responses}{A matrix of the responses to the items seen in \code{final.items.seen}. \code{NA} values indicate that the individual didn't answer the question in the supplied response file or wasn't given any more items to answer.}
#' \item{transition.matrix}{The \code{transition_matrix} originally supplied to the function.}
#' \item{n.stages}{The \code{n_stages} originally supplied to the function.}
#' \item{runtime}{A \code{difftime} object recording how long the function took to complete.}
#' @export
#'
#' @references Wang, S., Lin, H., Chang, H.-H., & Douglas, J. (2016).
#'   Hybrid computerized adaptive testing: From group sequential design to
#'   fully sequential design. \emph{Journal of Educational Measurement,
#'   53}(1), 45--62. \doi{10.1111/jedm.12100}
#' @seealso [mixed_adaptive_test] for the reversed design (CAT routing then MST),
#'   [multistage_test] for a standard multistage test,
#'   [computerized_adaptive_test] for a standard computerized adaptive test.
#'
#' @examples
#' \donttest{
#' # using simulated test data
#' data(example_thetas) # 5 simulated abilities
#' data(example_responses) # 5 simulated response vectors
#' # the full MST item bank (42 items, 7 modules in a 1-3-3 design)
#' data(mst_only_items)
#' # the module-to-item map and transition matrix for the 1-3-3 design
#' data(example_module_items)
#' data(example_transition_matrix)
#' # the items designated for use in the final CAT stage
#' data(cat_items)
#'
#' # run a hybrid test: 3 MST stages (1-3-3) followed by a 6-item CAT
#' # remove any MST items from the CAT bank to avoid overlap
#' cat_bank <- cat_items[!rownames(cat_items) %in% rownames(mst_only_items), ]
#' results <- hybrid_adaptive_test(
#'   response_matrix = example_responses[1:2, ],
#'   cat_item_bank = cat_bank,
#'   mst_item_bank = mst_only_items,
#'   modules = example_module_items,
#'   transition_matrix = example_transition_matrix,
#'   n_stages = 4,
#'   cat_length = 6,
#'   initial_theta = 0,
#'   method = "EAP",
#'   item_method = "MFI"
#' )
#' }
#'

hybrid_adaptive_test = function(response_matrix,
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
    total.item.bank = rbind(mst_item_bank[, param_cols], cat_item_bank[, param_cols])
  } else {
    total.item.bank = rbind(mst_item_bank, cat_item_bank)
  }

  if (is.null(rownames(total.item.bank))) {
    rownames(total.item.bank) = paste0("Item", 1:nrow(total.item.bank))
    rownames(mst_item_bank) = paste0("Item", 1:nrow(mst_item_bank))
    rownames(cat_item_bank) = paste0("Item", (nrow(mst_item_bank)+1):(nrow(mst_item_bank)+nrow(cat_item_bank)))
    colnames(internal_response_matrix) = paste0("Item", 1:nrow(total.item.bank))
    message("The input item banks did not have row names indicating which items were which, so the item names were filled in automatically for both the item banks and the response matrix.\n\nFor this method, it assumes that by columns the response matrix has the MST items first, followed by the CAT items, and that for each set the order of responses is the same as the order in the item banks!")
  }

  n_mst_stages = n_stages - 1
  n_mst_modules = ncol(modules)

  if (ncol(transition_matrix) == n_mst_modules) {
    terminal_modules = which(rowSums(transition_matrix) == 0)
    cat_col = integer(n_mst_modules)
    cat_col[terminal_modules] = 1L
    transition_matrix = cbind(transition_matrix, cat_col)
    transition_matrix = rbind(transition_matrix, integer(n_mst_modules + 1))
  } else if (ncol(transition_matrix) != n_mst_modules + 1) {
    stop("transition_matrix must have either ncol(modules) columns (MST-only; the CAT stage is appended automatically) or ncol(modules) + 1 columns (including the final CAT stage).")
  }
  cat_module = ncol(transition_matrix)

  n_persons = nrow(internal_response_matrix)

  final.theta = final.theta.SEM = numeric(n_persons)
  all.items.seen.list = vector("list", n_persons)
  all.responses.list = vector("list", n_persons)
  all.modules.seen.list = vector("list", n_persons)

  for (i in 1:n_persons) {

    # --- MST stages ---
    mst.responses = internal_response_matrix[i, rownames(mst_item_bank)]

    first.module = startModule(
      itemBank = mst_item_bank,
      modules = modules,
      transMatrix = transition_matrix,
      model = model,
      theta = initial_theta
    )

    seen.mst.indices = first.module$items
    seen.modules = first.module$module
    current.responses = mst.responses[, first.module$items]

    current.theta = catR::thetaEst(
      it = mst_item_bank[seen.mst.indices, ],
      x = current.responses,
      model = model,
      method = method
    )

    if (n_mst_stages > 1) {
      for (m in 2:n_mst_stages) {
        next.module = nextModule(
          itemBank = mst_item_bank,
          modules = modules,
          transMatrix = transition_matrix,
          current.module = seen.modules[m - 1],
          out = seen.modules,
          theta = current.theta,
          criterion = module_select,
          model = model
        )
        seen.mst.indices = c(seen.mst.indices, next.module$items)
        current.responses = mst.responses[, seen.mst.indices]
        current.theta = catR::thetaEst(
          it = mst_item_bank[seen.mst.indices, ],
          x = current.responses,
          model = model,
          method = method
        )
        seen.modules = c(seen.modules, next.module$module)
      }
    }

    mst.theta = current.theta
    mst.seen.items = rownames(mst_item_bank)[seen.mst.indices]

    # --- CAT stage ---
    initial.item = catR::startItems(
      cat_item_bank,
      model = model,
      theta = mst.theta,
      nAvailable = nAvailable_cat,
      cbControl = cbControl,
      cbGroup = cbGroup,
      randomesque = randomesque
    )

    cat.seen.items = rownames(cat_item_bank)[initial.item$items]

    for (j in 2:cat_length) {
      all.seen.so.far = c(mst.seen.items, cat.seen.items)
      all.current.responses = internal_response_matrix[i, all.seen.so.far]

      current.theta = catR::thetaEst(
        it = total.item.bank[all.seen.so.far, ],
        x = all.current.responses,
        model = model,
        method = method
      )

      next.item = catR::nextItem(
        cat_item_bank,
        theta = current.theta,
        out = which(rownames(cat_item_bank) %in% cat.seen.items),
        x = internal_response_matrix[i, cat.seen.items],
        model = model,
        criterion = item_method,
        method = method,
        nAvailable = nAvailable_cat,
        cbControl = cbControl,
        cbGroup = cbGroup,
        randomesque = randomesque
      )
      cat.seen.items = c(cat.seen.items, rownames(cat_item_bank)[next.item$item])
    }

    # --- Final scoring ---
    all.seen = c(mst.seen.items, cat.seen.items)
    final.responses.i = internal_response_matrix[i, all.seen]

    final.result = final_theta_estimate(
      item.params = total.item.bank[all.seen, ],
      responses = final.responses.i,
      model = model,
      method = final_theta_method
    )

    final.theta[i] = final.result$theta
    final.theta.SEM[i] = final.result$sem
    all.items.seen.list[[i]] = all.seen
    all.responses.list[[i]] = as.numeric(final.responses.i)
    all.modules.seen.list[[i]] = c(seen.modules, cat_module)
  }

  max.items = max(sapply(all.items.seen.list, length))
  final.items.matrix = matrix(NA_character_, nrow = n_persons, ncol = max.items)
  final.responses.matrix = matrix(NA_real_, nrow = n_persons, ncol = max.items)
  final.modules.matrix = matrix(NA_real_, nrow = n_persons, ncol = n_stages)

  for (i in 1:n_persons) {
    n.items = length(all.items.seen.list[[i]])
    final.items.matrix[i, 1:n.items] = all.items.seen.list[[i]]
    final.responses.matrix[i, 1:n.items] = all.responses.list[[i]]
    final.modules.matrix[i, ] = all.modules.seen.list[[i]]
  }

  results =
    new(
      'HAT',
      function.call = match.call(),
      final.theta.estimate = final.theta,
      final.theta.method = final_theta_method,
      final.theta.SEM = final.theta.SEM,
      final.items.seen = final.items.matrix,
      modules.seen = final.modules.matrix,
      final.responses = final.responses.matrix,
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
