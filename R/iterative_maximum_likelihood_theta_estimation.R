#' Iterative Maximum Likelihood Theta Estimation
#'
#' Estimates person ability (theta) from a response pattern and a set of item
#' parameters using Newton-Raphson iteration, following the maximum
#' likelihood procedure described in chapter 5 of Baker (2001). Used
#' internally by \code{\link{computerized_adaptive_test}},
#' \code{\link{multistage_test}}, and \code{\link{mixed_adaptive_test}} to
#' compute the \code{final.theta.Baker} and \code{final.theta.SEM} slots of
#' their results.
#'
#' @param initial_theta A single numeric value used as the starting theta
#'   estimate for every response pattern. Default is 0.
#' @param item.params A data frame or matrix of 3-parameter logistic item
#'   parameters for the items in \code{response.pattern}, with discrimination,
#'   difficulty, and guessing in the first three columns respectively (in
#'   that order).
#' @param response.pattern A data frame or matrix with one row per person and
#'   one column per item in \code{item.params}, giving 0/1 (incorrect/correct)
#'   responses.
#'
#' @return A two-column numeric matrix with one row per row of
#'   \code{response.pattern}: \code{final.theta.estimates}, the converged (or
#'   boundary-clamped) theta estimate, and \code{final.theta.SEM}, its
#'   standard error of measurement. If iteration hits the \code{[-4, 4]}
#'   boundary or encounters a zero/non-finite observed information, theta is
#'   clamped to the nearest boundary, a warning is issued, and SEM is
#'   reported as \code{NA} for that row.
#'
#' @references Baker, F. B. (2001). The Basics of Item Response Theory (2nd
#'   ed.), Chapter 5. Full text: https://eric.ed.gov/?id=ED458219
#'
#' @keywords internal
iterative.theta.estimate = function (initial_theta = 0, item.params, response.pattern){
  # This function is used to estimate person thetas based on their response patterns, meaning that
  # novel response patterns can produce a (hopefully unbiased) theta estimate.

  # split item param data frame into vectors
  item.discriminations = item.params[,1]
  item.difficulty = item.params[,2]
  item.guessing = item.params[,3]

  ########### To estimate the person parameter based on pre-specified item discriminations, dificulties, a
  ###### given response pattern, and some initial theta value, the following code sets up a WHILE statement
  ###### to continuously update the theta up to the stopping point, defined as changes in theta estimate
  ###### being less than 0.001. Based on Baker, F. B. (2001), The Basics of Item Response Theory
  ###### (2nd ed.), Chapter 5. Full text: https://eric.ed.gov/?id=ED458219
  final.theta.estimates = c() # this is where the point estimates are saved
  final.theta.SEM = c() # this is where the standard error of measurement values are saved
  for (i in 1:nrow(response.pattern)){ # for each individual,
    person.response.pattern = as.numeric(unlist(response.pattern[i,])) # take their response pattern
    current.theta = initial_theta
    new.theta = 0
    hit.boundary = FALSE
    probability.correct = item.guessing + (1 - item.guessing)/(1+exp(-1*item.discriminations*(current.theta-item.difficulty)))
    numerator = sum(item.discriminations * (person.response.pattern - probability.correct))
    denominator = sum(item.discriminations^2 * probability.correct * (1-probability.correct))

    if (!is.finite(denominator) || denominator == 0) {
      hit.boundary = TRUE
      warning("Observed information was zero or non-finite while estimating theta for response pattern ",
              i, "; clamping theta to the nearest [-4, 4] boundary.", call. = FALSE)
      new.theta = if (current.theta >= 0) 4 else -4
    }

    j = 0
    while (!hit.boundary && abs(numerator/denominator) > 0.001 && abs(new.theta) < 4 && j < 100) {
      j = j+1
      numerator = sum(item.discriminations * (person.response.pattern - probability.correct))
      denominator = sum(item.discriminations^2 * probability.correct * (1-probability.correct))

      if (!is.finite(denominator) || denominator == 0) {
        hit.boundary = TRUE
        warning("Observed information was zero or non-finite while estimating theta for response pattern ",
                i, "; clamping theta to the nearest [-4, 4] boundary.", call. = FALSE)
        new.theta = if (current.theta >= 0) 4 else -4
        break
      }

      new.theta = current.theta + (numerator/denominator)
      current.theta = new.theta
      probability.correct = item.guessing + (1 - item.guessing)/(1+exp(-1*item.discriminations*(current.theta-item.difficulty)))
    }

    if (!hit.boundary && abs(new.theta) >= 4) {
      hit.boundary = TRUE
      warning("Iterative theta estimation reached the [-4, 4] boundary for response pattern ",
              i, " before converging; clamping theta.", call. = FALSE)
      new.theta = if (new.theta >= 0) 4 else -4
    }

    final.theta.estimates[i] = new.theta
    final.theta.SEM[i] = if (hit.boundary) NA_real_ else 1/sqrt(denominator)
  }
  return(cbind(final.theta.estimates, final.theta.SEM))
}
