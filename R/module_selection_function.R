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
#' @param n_stage The total number of stages in the test, including the CAT
#'   routing stage (so \code{n_stage - 1} MST modules are selected).
#' @param module_select The module-selection criterion passed to
#'   \code{nextModule} as \code{criterion} (e.g. \code{"MFI"}); invalid or
#'   \code{NULL} values fall back to \code{"MFI"}.
#' @param final_theta_method A character value indicating the method used
#'   for the single final theta estimate returned. One of "BM", "ML", "WL",
#'   "ROB" (passed to \code{catR::thetaEst}) or "EAP" (uses
#'   \code{catR::eapEst}).
#'
#' @return A list with \code{final.theta.estimate.mstR}, \code{final.theta.SEM},
#'   \code{final.item.bank}, \code{final.items.seen}, \code{modules.seen}, and
#'   \code{final.responses} for the one person tested.
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
                                n_stage,
                                module_select = NULL,
                                final_theta_method = NULL) {
  if (is.null(module_select)|
      !(module_select %in% c("MFI", "MLWMI", "MPWMI", "MKL", "MKLP", "random"))) {
    module_select <- "MFI"
  }
  if (is.null(final_theta_method)) final_theta_method = method

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

  final.result = final_theta_estimate(
    item.params = module_item_bank[seen.items, ],
    responses = final.responses,
    method = final_theta_method
  )

  return(
    list(
      final.theta.estimate.mstR = final.result$theta,
      final.theta.SEM = final.result$sem,
      final.item.bank = module_item_bank,
      final.items.seen = seen.items,
      modules.seen = seen.modules,
      final.responses = as.numeric(final.responses)
    )
  )
}
