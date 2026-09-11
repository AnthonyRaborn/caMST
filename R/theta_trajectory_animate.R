#' Animated Theta Trajectory Plot
#'
#' Produces an animated version of \code{\link{theta_trajectory_plot}} using
#' \code{gganimate::transition_states}.
#'
#' @inheritParams theta_trajectory_plot
#' @param file Character path to save the animation (e.g. \code{"trajectory.gif"}).
#'   Default \code{NULL} returns the \code{gganim} object without saving.
#' @param transition_length Numeric; relative time spent interpolating between
#'   consecutive item states. Default \code{2}.
#' @param state_length Numeric; relative time spent pausing on each item state.
#'   Default \code{1}.
#' @param fps Frames per second. Default \code{10}.
#' @param ... Further arguments passed to \code{gganimate::animate()}.
#'
#' @return A \code{gganim} object (invisibly if \code{file} is provided).
#' @export
#'
#' @examples
#' \dontrun{
#' library(caMST)
#' data(example_thetas)
#' data(example_responses)
#' data(cat_items)
#'
#' # Run a short CAT
#' catResult <- computerized_adaptive_test(
#'   cat_item_bank = cat_items,
#'   response_matrix = example_responses,
#'   randomesque = 1, maxItems = 6,
#'   nextItemControl = list(criterion = "MFI", priorDist = "norm",
#'     priorPar = c(0, 1), D = 1, range = c(-4, 4),
#'     parInt = c(-4, 4, 33), infoType = "Fisher",
#'     random.seed = NULL, rule = "precision", thr = .3,
#'     nAvailable = NULL, cbControl = NULL, cbGroup = NULL)
#' )
#'
#' # Preview in the viewer
#' theta_trajectory_animate(catResult, person = 1)
#'
#' # Save to file
#' theta_trajectory_animate(catResult, person = 1, file = "trajectory.gif")
#'
#' # Adjust animation speed
#' theta_trajectory_animate(catResult, person = 1,
#'   transition_length = 1, state_length = 2, fps = 5)
#' }

theta_trajectory_animate = function(object, person = NULL, facet_person = FALSE,
                                    ci_multiplier = 1, file = NULL,
                                    transition_length = 2, state_length = 1,
                                    fps = 10, ...) {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for theta_trajectory_animate(). ",
         "Install it with install.packages(\"ggplot2\").")
  }
  if (!requireNamespace("gganimate", quietly = TRUE)) {
    stop("Package 'gganimate' is required for theta_trajectory_animate(). ",
         "Install it with install.packages(\"gganimate\").")
  }

  resolved = resolve_plot_persons(object, person, facet_person)
  person       = resolved$person
  facet_person = resolved$facet_person

  all_traj = do.call(rbind, lapply(person, function(p) {
    traj = reconstruct_theta_trajectory(object, p)
    traj$person = p
    traj
  }))

  all_traj$cumulative_index = all_traj$item_index

  anim_data = do.call(rbind, lapply(unique(all_traj$person), function(pid) {
    ptraj = all_traj[all_traj$person == pid, ]
    update_indices = ptraj$item_index[ptraj$is_update]

    do.call(rbind, lapply(update_indices, function(idx) {
      visible = ptraj[ptraj$item_index <= idx & ptraj$is_update, ]
      visible$frame_state = idx
      visible
    }))
  }))

  p = build_trajectory_ggplot(anim_data, person, facet_person, ci_multiplier)

  p = p + gganimate::transition_states(
    states = frame_state,
    transition_length = transition_length,
    state_length = state_length
  ) +
    gganimate::shadow_mark(past = TRUE)

  if (!is.null(file)) {
    if (!requireNamespace("gifski", quietly = TRUE)) {
      stop("Package 'gifski' is required to save GIF animations. ",
           "Install it with install.packages(\"gifski\").")
    }
    anim = gganimate::animate(p, fps = fps, ...)
    gganimate::anim_save(filename = file, animation = anim)
    return(invisible(anim))
  }

  gganimate::animate(p, fps = fps, ...)
}
