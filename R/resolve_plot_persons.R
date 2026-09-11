#' Resolve person indices and faceting for trajectory plots
#'
#' @param object A result object of class \code{CAT}, \code{MST}, \code{MAT},
#'   or \code{HAT}.
#' @param person Row index or vector of indices into \code{object@final.responses}.
#'   \code{NULL} defaults to 1 with a message.
#' @param facet_person Logical; whether to facet by person.
#'
#' @return A list with \code{person} (resolved integer vector) and
#'   \code{facet_person} (possibly downgraded to \code{FALSE}).
#'
#' @keywords internal

resolve_plot_persons = function(object, person, facet_person) {
  if (is.null(person)) {
    message("No person specified; defaulting to respondent 1.")
    person = 1L
  }

  n_persons = nrow(object@final.responses)
  if (any(person < 1) || any(person > n_persons)) {
    stop("person indices must be between 1 and ", n_persons, ".")
  }

  if (facet_person && length(person) == 1) {
    warning("facet_person = TRUE ignored: only one person was selected.")
    facet_person = FALSE
  }

  list(person = as.integer(person), facet_person = facet_person)
}
