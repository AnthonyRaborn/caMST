#' Select Two MST Modules After a Fixed Routing Stage
#'
#' Selects the next two modules after a CAT routing stage of exactly
#' \code{cat_length} items, hard-coded to a 3-stage (routing + 2 MST modules)
#' design. Unlike \code{\link{moduleSelectionCAMST}}, this does not loop over
#' an arbitrary number of stages and cannot be reused for other designs.
#'
#' \strong{Note:} this function does not currently appear to be called
#' anywhere in the package; \code{\link{mixed_adaptive_test}} uses
#' \code{\link{moduleSelectionCAMST}} instead.
#'
#' @param i The row index of \code{response_matrix} for the person being
#'   tested.
#' @param module_item_bank A data frame of MST item parameters, in \pkg{catR}
#'   item-bank format, for the items referenced by \code{modules}.
#' @param modules A matrix describing the relationship between items and
#'   modules; see \code{\link{multistage_test}}.
#' @param transition_matrix A matrix describing allowed transitions between
#'   modules; see \code{\link{multistage_test}}.
#' @param theta_est The theta estimate (from the CAT routing stage) used to
#'   select the first MST module.
#' @param method The provisional theta estimation method passed to
#'   \code{catR::thetaEst}.
#' @param response_matrix A matrix or data frame of person responses.
#' @param seen_cat_items Names of the items already administered during the
#'   CAT routing stage.
#' @param cat_length The number of items administered in the CAT routing
#'   stage.
#' @param module_select The module-selection criterion passed to
#'   \code{nextModule} as \code{criterion} (e.g. \code{"MFI"}); invalid or
#'   \code{NULL} values fall back to \code{"MFI"}.
#' @param initial_theta The initial theta value passed to
#'   \code{\link{iterative.theta.estimate}}.
#'
#' @return A list with \code{final.theta.estimate.mstR}, \code{eap.theta},
#'   \code{final.theta.iterative}, \code{sem.iterative}, \code{final.item.bank},
#'   \code{final.items.seen}, \code{modules.seen}, and \code{final.responses}
#'   for the one person tested.
#'
#' @keywords internal
module_selection = function(i,
                            module_item_bank,
                            modules,
                            transition_matrix,
                            theta_est,
                            method = "BM",
                            response_matrix,
                            seen_cat_items,
                            cat_length,
                            module_select,
                            initial_theta = 0) {
  if (is.null(module_select)|
      !(module_select %in% c("MFI", "MLWMI", "MPWMI", "MKL", "MKLP", "random"))) {
        module_select <- "MFI"
      }

  next.module = nextModule(
    itemBank = module_item_bank,
    modules = modules,
    transMatrix = transition_matrix,
    current.module = 1,
    out = c(1:cat_length),
    theta = theta_est,
    criterion = module_select
  )

  current.responses = as.numeric(c(response_matrix[i, c(seen_cat_items)], response_matrix[i, c(rownames(next.module$par))]))

  seen.items = c(seen_cat_items, rownames(next.module$par))

  current.theta = catR::thetaEst(it = module_item_bank[c(1:cat_length, next.module$items), ], x = current.responses, method = method)

  current.module = next.module$module


  final.module = nextModule(
    itemBank = module_item_bank,
    modules = modules,
    transMatrix = transition_matrix,
    current.module = current.module,
    out = seen.items,
    theta = current.theta
  )

  seen.items = c(seen_cat_items,
                 rownames(next.module$par),
                 rownames(final.module$par))
  final.responses = response_matrix[i, c(seen.items)]

  final.theta = catR::thetaEst(it = module_item_bank[c(1:cat_length, next.module$items, final.module$items), ], x = final.responses, method = method)

  final.theta.eap = catR::eapEst(it = module_item_bank[c(1:cat_length, next.module$items, final.module$items), ], x = final.responses)

  final.theta.iterative = iterative.theta.estimate(
    initial_theta = initial_theta,
    item.params = module_item_bank[c(1:cat_length, next.module$items, final.module$items), ],
    response.pattern = matrix(final.responses, nrow = 1, byrow = T)
  )

  return(
    list(
      final.theta.estimate.mstR = final.theta,
      eap.theta = final.theta.eap,
      final.theta.iterative = final.theta.iterative[, 1],
      sem.iterative = final.theta.iterative[, 2],
      final.item.bank = module_item_bank,
      final.items.seen = seen.items,
      modules.seen = c(next.module$module, final.module$module),
      final.responses = as.numeric(final.responses)
    )
  )
}

#' Select MST Modules for an Arbitrary Number of Stages
#'
#' Selects the sequence of MST modules following a CAT routing stage, looping
#' over \code{n_stage - 1} module-selection steps. This is the function
#' \code{\link{mixed_adaptive_test}} actually uses to drive its MST portion.
#'
#' @param i The row index of \code{response_matrix} for the person being
#'   tested.
#' @param module_item_bank A data frame of MST item parameters, in \pkg{catR}
#'   item-bank format, for the items referenced by \code{modules}.
#' @param modules A matrix describing the relationship between items and
#'   modules; see \code{\link{multistage_test}}.
#' @param transition_matrix A matrix describing allowed transitions between
#'   modules; see \code{\link{multistage_test}}.
#' @param theta_est The theta estimate (from the CAT routing stage) used to
#'   select the first MST module.
#' @param method The provisional theta estimation method passed to
#'   \code{catR::thetaEst}.
#' @param response_matrix A matrix or data frame of person responses.
#' @param seen_cat_items Names of the items already administered during the
#'   CAT routing stage.
#' @param cat_length The number of items administered in the CAT routing
#'   stage.
#' @param initial_theta The initial theta value passed to
#'   \code{\link{iterative.theta.estimate}}.
#' @param n_stage The total number of stages in the test, including the CAT
#'   routing stage (so \code{n_stage - 1} MST modules are selected).
#' @param module_select The module-selection criterion passed to
#'   \code{nextModule} as \code{criterion} (e.g. \code{"MFI"}); invalid or
#'   \code{NULL} values fall back to \code{"MFI"}.
#'
#' @return A list with \code{final.theta.estimate.mstR}, \code{eap.theta},
#'   \code{final.theta.iterative}, \code{sem.iterative}, \code{final.item.bank},
#'   \code{final.items.seen}, \code{modules.seen}, and \code{final.responses}
#'   for the one person tested.
#'
#' @keywords internal
moduleSelectionCAMST = function(i,
                                module_item_bank,
                                modules,
                                transition_matrix,
                                theta_est,
                                method = "BM",
                                response_matrix,
                                seen_cat_items,
                                cat_length,
                                initial_theta = 0,
                                n_stage,
                                module_select = NULL) {
  if (is.null(module_select)|
      !(module_select %in% c("MFI", "MLWMI", "MPWMI", "MKL", "MKLP", "random"))) {
    module_select <- "MFI"
  }
  seen.modules = 1
  seen.items = seen_cat_items
  for (m in 2:n_stage) {
    next.module = nextModule(
      itemBank = module_item_bank,
      modules = modules,
      transMatrix = transition_matrix,
      current.module = seen.modules[m -
                                      1],
      out = seen.modules,
      theta = theta_est,
      criterion = module_select
    )
    seen.items = c(seen.items, rownames(next.module$par))
    current.responses = response_matrix[i, seen.items]
    current.theta = catR::thetaEst(it = module_item_bank[seen.items,],
                                   x = current.responses,
                                   method = method)
    seen.modules = c(seen.modules, next.module$module)
  }

  final.responses = response_matrix[i, c(seen.items)]

  final.theta = catR::thetaEst(it = module_item_bank[seen.items,], x = final.responses, method = method)

  final.theta.eap = catR::eapEst(it = module_item_bank[seen.items,], x = final.responses)

  final.theta.iterative = iterative.theta.estimate(
    initial_theta = initial_theta,
    item.params = module_item_bank[seen.items, ],
    response.pattern = matrix(final.responses, nrow = 1, byrow = T)
  )

  return(
    list(
      final.theta.estimate.mstR = final.theta,
      eap.theta = final.theta.eap,
      final.theta.iterative = final.theta.iterative[, 1],
      sem.iterative = final.theta.iterative[, 2],
      final.item.bank = module_item_bank,
      final.items.seen = seen.items,
      modules.seen = seen.modules,
      final.responses = as.numeric(final.responses)
    )
  )
}
