#' Generate a Transition Matrix from Module Paths
#'
#' Builds the \code{modules} x \code{modules} transition matrix expected by
#' \code{\link{multistage_test}}'s \code{transition_matrix} argument (and by
#' \code{\link{transition_matrix_plot}}) from a simple list of which
#' module(s) each module can route to, instead of hand-writing the matrix.
#'
#' @param modules A single numeric value giving the total number of modules
#'   in the design. Must be greater than 1.
#' @param paths A list with one element per module (so \code{length(paths)}
#'   must equal \code{modules}), where element \code{i} is a numeric vector
#'   naming the module(s) that module \code{i} can transition to, or
#'   \code{0} if module \code{i} is terminal (routes to no further module).
#'
#' @details The design does not need to be crossed or balanced: any module
#'   may route to any subset of later modules. Terminal modules (typically
#'   the last stage) should use \code{0} for their path, meaning "no further
#'   transitions."
#'
#' @return A \code{modules} x \code{modules} numeric matrix with a \code{1}
#'   in row \code{i}, column \code{j} wherever module \code{i} can transition
#'   to module \code{j}, and \code{0} elsewhere -- the same format as
#'   \code{example_transition_matrix}.
#'
#' @export
#'
#' @examples
#' # reproduces example_transition_matrix: a 1-3-3 design where module 1
#' # routes to modules 2-4, and modules 2-4 each route to some subset of the
#' # terminal modules 5-7
#' transition_matrix <- generate_transition_matrix(
#'   modules = 7,
#'   paths = list(
#'     "1" = c(2, 3, 4),
#'     "2" = c(5, 6),
#'     "3" = c(5, 6, 7),
#'     "4" = c(6, 7),
#'     "5" = 0,
#'     "6" = 0,
#'     "7" = 0
#'   )
#' )
generate_transition_matrix <-
  function(modules, paths) {
    if (modules <= 1) {
      stop("Modules needs to be an integer value greater than 1!")
    }
    truncated_modules = as.integer(modules)
    if (truncated_modules != modules) {
      message("modules = ", modules, " was truncated to ", truncated_modules, ".")
    }
    modules = truncated_modules

    if (length(paths) != modules) {
      stop("Each module needs a valid path to another module.")
    }

    transition_matrix <-
      matrix(
        data = 0,
        nrow = modules,
        ncol = modules
      )

    for (i in 1:modules) transition_matrix[i,paths[[i]]] <- 1

    transition_matrix
  }
