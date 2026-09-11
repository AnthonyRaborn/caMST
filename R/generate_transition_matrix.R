#' Generate a Transition Matrix from Module Paths
#'
#' Builds the \code{modules} x \code{modules} transition matrix expected by
#' \code{\link{multistage_test}}'s \code{transition_matrix} argument (and by
#' \code{\link{transition_matrix_plot}}) from a simple list of which
#' module(s) each module can route to, instead of hand-writing the matrix.
#'
#' @param n_modules A single numeric value giving the total number of modules
#'   in the design. Must be greater than 1. Coerced to an integer.
#' @param paths A list with one element per module (so \code{length(paths)}
#'   must equal \code{n_modules}), where element \code{i} is a numeric vector
#'   naming the module(s) that module \code{i} can transition to, or
#'   \code{0} if module \code{i} is terminal (routes to no further module).
#'   While the list can be named (e.g., list("Stage 1" = c(2, 3))), the 
#'   vector needs to be numeric or the matrix will not be created appropriately.
#'
#' @details The design does not need to be crossed or balanced: any module
#'   may route to any subset of later modules. Terminal modules (typically
#'   the last stage) should use \code{0} for their path, meaning "no further
#'   transitions."
#'
#' @return A \code{n_modules} x \code{n_modules} numeric matrix with a \code{1}
#'   in row \code{i}, column \code{j} wherever module \code{i} can transition
#'   to module \code{j}, and \code{0} elsewhere; the same format as
#'   \code{example_transition_matrix}.
#'
#' @export
#'
#' @examples
#' # reproduces example_transition_matrix: a 1-3-3 design where module 1
#' # routes to modules 2-4, and modules 2-4 each route to some subset of the
#' # terminal modules 5-7
#' transition_matrix <- generate_transition_matrix(
#'   n_modules = 7,
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
  function(n_modules, paths) {
    if (n_modules <= 1) {
      stop("n_modules needs to be an integer value greater than 1!")
    }
    truncated_modules = as.integer(n_modules)
    if (truncated_modules != n_modules) {
      message("n_modules = ", n_modules, " was truncated to ", truncated_modules, ".")
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

#' Generate an Item-to-Module Matrix from an Item Bank
#'
#' Builds the items-by-modules matrix expected by \code{\link{multistage_test}}'s
#' \code{modules} argument (and by \code{\link{generate_transition_matrix}}'s
#' companion functions) from an item bank that carries its module assignment
#' as a \code{module} column, instead of hand-writing the matrix.
#'
#' @param item_bank A data frame of item parameters, in \pkg{catR} item-bank
#'   format, with a \code{module} column giving each item's module number
#'   (a single positive integer per item; see \strong{Details}).
#' @param n_modules A single numeric value giving the total number of
#'   modules in the design.
#'
#' @details \code{item_bank$module} must be present, numeric, and at least
#'   \code{1} for every item; each item is assigned to exactly the one
#'   module named in that column. This is normally paired with
#'   \code{\link{generate_transition_matrix}}, which describes how those
#'   same modules connect to each other.
#'
#' @return An \code{nrow(item_bank)} x \code{n_modules} numeric matrix with a
#'   \code{1} in row \code{i}, column \code{j} whenever item \code{i} belongs
#'   to module \code{j}, and \code{0} elsewhere -- the same format as
#'   \code{example_module_items}.
#'
#' @export
#'
#' @examples
#' # reproduces example_module_items from mst_only_items, which carries its
#' # module assignment (1-7) in a `module` column
#' data(mst_only_items)
#' module_items <- generate_modules(mst_only_items, n_modules = 7)
#'
#' data(example_module_items)
#' identical(unname(module_items), unname(as.matrix(example_module_items)))
generate_modules <-
  function(item_bank, n_modules) {
    if (!any(colnames(item_bank) == 'module')) {
      stop("Your item bank needs to have module information.")
    }
    if (any(!is.numeric(item_bank$module)) || any(item_bank$module < 1)) {
      stop("The module assignment in your item bank needs to be a single numeric value for each item.")
    }
    
    module_items <-
      matrix(
      data = 0,
      nrow = nrow(item_bank),
      ncol = n_modules
    )    

    for (i in 1:nrow(module_items)) {
      module_items[i,item_bank$module[i]] <- 1
    }

    module_items
  }
