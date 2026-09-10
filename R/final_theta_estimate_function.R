#' Compute the Final Theta Estimate and SEM for One Person
#'
#' Computes a single final theta estimate and its standard error of
#' measurement using \code{method}, which may be any estimator supported by
#' \code{catR::thetaEst}/\code{catR::semTheta} ("BM", "ML", "WL", "ROB") or
#' "EAP" for the expected a posteriori estimate. Used internally by
#' \code{\link{computerized_adaptive_test}}, \code{\link{multistage_test}},
#' and \code{\link{mixed_adaptive_test}} (via
#' \code{\link{moduleSelectionCAMST}}) to compute their
#' \code{final.theta.estimate} and \code{final.theta.SEM} slots.
#'
#' @param item.params A data frame or matrix of item parameters, in
#'   \pkg{catR} item-bank format, for the items in \code{responses}.
#' @param responses A vector of that person's responses to \code{item.params}.
#' @param model Either \code{NULL} (default) for dichotomous models or a
#'   character value naming the polytomous model used. See \pkg{catR} for
#'   details.
#' @param method A character value naming the estimator: one of "BM", "ML",
#'   "WL", "ROB" (passed to \code{catR::thetaEst}) or "EAP" (uses
#'   \code{catR::eapEst}). In both cases, SEM is computed via
#'   \code{catR::semTheta} with the same \code{method}.
#'
#' @return A list with \code{theta} (the point estimate) and \code{sem} (its
#'   standard error of measurement).
#'
#' @keywords internal
final_theta_estimate = function(item.params, responses, model = NULL, method) {
  theta = if (method == "EAP") {
    catR::eapEst(it = item.params, x = responses, model = model)
  } else {
    catR::thetaEst(it = item.params, x = responses, model = model, method = method)
  }
  sem = catR::semTheta(thEst = theta, it = item.params, x = responses,
                       model = model, method = method)
  list(theta = theta, sem = sem)
}
