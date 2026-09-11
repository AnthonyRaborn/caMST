#' Theta Trajectory Plot
#'
#' Plots the provisional theta estimate trajectory for one or more respondents
#' from a \code{CAT}, \code{MST}, \code{MAT}, or \code{HAT} result object.
#' Theta is reconstructed from the stored item bank and responses using the
#' same provisional estimation method that was used during administration.
#'
#' @param object An S4 result object of class \code{"CAT"}, \code{"MST"},
#'   \code{"MAT"}, or \code{"HAT"}.
#' @param person Row index or vector of indices into
#'   \code{object@@final.responses}. Default \code{NULL} uses respondent 1
#'   with a message.
#' @param facet_person Logical; if \code{TRUE} and multiple persons are
#'   selected, each person gets a separate facet panel via
#'   \code{ggplot2::facet_wrap}. Default \code{FALSE}. A warning is issued
#'   (and the flag ignored) when only one person is selected.
#' @param ci_multiplier Numeric multiplier for the SEM error bars. Default
#'   \code{1} gives +/-1 SEM; use \code{1.96} for an approximate 95\%
#'   interval.
#'
#' @return A \code{ggplot} object.
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
#' # Plot trajectory for one respondent
#' theta_trajectory_plot(catResult, person = 1)
#'
#' # Multiple respondents overlaid
#' theta_trajectory_plot(catResult, person = c(1, 2, 3))
#'
#' # Multiple respondents in separate facet panels
#' theta_trajectory_plot(catResult, person = c(1, 2, 3), facet_person = TRUE)
#'
#' # 95% confidence intervals
#' theta_trajectory_plot(catResult, person = 1, ci_multiplier = 1.96)
#'
#' # MST example
#' data(mst_only_items)
#' data(example_module_items)
#' data(example_transition_matrix)
#'
#' mstResult <- multistage_test(
#'   mst_item_bank = mst_only_items,
#'   modules = example_module_items,
#'   transition_matrix = example_transition_matrix,
#'   method = "BM", response_matrix = example_responses,
#'   initial_theta = 0, model = NULL, n_stages = 3, test_length = 18
#' )
#' theta_trajectory_plot(mstResult, person = 1)
#' }

theta_trajectory_plot = function(object, person = NULL, facet_person = FALSE,
                                 ci_multiplier = 1) {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for theta_trajectory_plot(). ",
         "Install it with install.packages(\"ggplot2\").")
  }

  resolved = resolve_plot_persons(object, person, facet_person)
  person       = resolved$person
  facet_person = resolved$facet_person

  all_traj = do.call(rbind, lapply(person, function(p) {
    traj = reconstruct_theta_trajectory(object, p)
    traj$person = p
    traj
  }))

  build_trajectory_ggplot(all_traj, person, facet_person, ci_multiplier)
}


# Suppress R CMD check notes for ggplot2 NSE column references
utils::globalVariables(c("item_index", "theta", "sem", "person_label",
                         "module", "point_type", "frame_state",
                         "segment_type"))


#' @keywords internal
build_trajectory_ggplot = function(all_traj, person, facet_person,
                                   ci_multiplier) {

  has_final = any(all_traj$point_type == "final")
  multi     = length(person) > 1

  all_traj$person_label = paste0("Respondent ", all_traj$person)

  update_rows = all_traj[all_traj$is_update, ]

  p = ggplot2::ggplot(update_rows,
                      ggplot2::aes(x = item_index, y = theta))

  prov_update = update_rows[update_rows$point_type == "provisional", ]

  has_cat = any(prov_update$segment_type == "cat")
  has_mst = any(prov_update$segment_type == "mst")

  cat_data = if (has_cat) prov_update[prov_update$segment_type == "cat", ]
  mst_data = if (has_mst) prov_update[prov_update$segment_type == "mst", ]

  if (has_cat && has_mst) {
    bridge_rows = do.call(rbind, lapply(unique(prov_update$person), function(pid) {
      p_cat = prov_update[prov_update$person == pid &
                            prov_update$segment_type == "cat", ]
      p_mst = prov_update[prov_update$person == pid &
                            prov_update$segment_type == "mst", ]
      if (nrow(p_cat) == 0 || nrow(p_mst) == 0) return(NULL)

      cat_last_idx = max(p_cat$item_index)
      mst_first_idx = min(p_mst$item_index)

      if (cat_last_idx < mst_first_idx) {
        row = p_cat[p_cat$item_index == cat_last_idx, ]
        row$segment_type = "mst"
        return(row)
      } else {
        row = p_mst[p_mst$item_index == max(p_mst$item_index[
          p_mst$item_index < min(p_cat$item_index)]), ]
        if (nrow(row) == 0) {
          row = p_mst[p_mst$item_index == max(p_mst$item_index), ]
        }
        row$segment_type = "cat"
        return(row)
      }
    }))

    if (!is.null(bridge_rows)) {
      cat_bridges = bridge_rows[bridge_rows$segment_type == "cat", ]
      mst_bridges = bridge_rows[bridge_rows$segment_type == "mst", ]
      if (nrow(cat_bridges) > 0) cat_data = rbind(cat_data, cat_bridges)
      if (nrow(mst_bridges) > 0) mst_data = rbind(mst_data, mst_bridges)
    }
  }

  if (has_cat) {
    if (multi && !facet_person) {
      p = p + ggplot2::geom_line(
        data = cat_data,
        ggplot2::aes(group = person, color = person_label),
        na.rm = TRUE
      )
    } else {
      p = p + ggplot2::geom_line(data = cat_data, na.rm = TRUE)
    }
  }

  if (has_mst) {
    if (multi && !facet_person) {
      p = p + ggplot2::geom_step(
        data = mst_data,
        ggplot2::aes(group = person, color = person_label),
        direction = "hv", na.rm = TRUE
      )
    } else {
      p = p + ggplot2::geom_step(
        data = mst_data,
        direction = "hv", na.rm = TRUE
      )
    }
  }

  p = p + ggplot2::geom_errorbar(
    ggplot2::aes(ymin = theta - sem * ci_multiplier,
                 ymax = theta + sem * ci_multiplier),
    width = 0.2, alpha = 0.5, na.rm = TRUE
  )

  if (has_final) {
    prov_pts = update_rows[update_rows$point_type == "provisional", ]
    final_pts = update_rows[update_rows$point_type == "final", ]

    if (multi && !facet_person) {
      p = p +
        ggplot2::geom_point(
          data = prov_pts,
          ggplot2::aes(color = person_label),
          shape = 16, size = 2, na.rm = TRUE
        ) +
        ggplot2::geom_point(
          data = final_pts,
          ggplot2::aes(color = person_label),
          shape = 17, size = 3, na.rm = TRUE
        )
    } else {
      p = p +
        ggplot2::geom_point(data = prov_pts, shape = 16, size = 2,
                            na.rm = TRUE) +
        ggplot2::geom_point(data = final_pts, shape = 17, size = 3,
                            color = "red", na.rm = TRUE)
    }
  } else {
    if (multi && !facet_person) {
      p = p + ggplot2::geom_point(
        ggplot2::aes(color = person_label),
        shape = 16, size = 2, na.rm = TRUE
      )
    } else {
      p = p + ggplot2::geom_point(shape = 16, size = 2, na.rm = TRUE)
    }
  }

  if (has_mst) {
    first_person_traj = all_traj[all_traj$person == person[1], ]

    cat_rows = first_person_traj[first_person_traj$segment_type == "cat", ]
    if (nrow(cat_rows) > 0) {
      mid_x = mean(c(min(cat_rows$item_index), max(cat_rows$item_index)))
      p = p + ggplot2::annotate(
        "text", x = mid_x, y = -Inf, label = "CAT",
        vjust = -0.5, size = 3, fontface = "italic"
      )
    }

    mst_rows = first_person_traj[first_person_traj$segment_type == "mst", ]
    modules_in_traj = unique(mst_rows$module)
    cat_before_mst = nrow(cat_rows) > 0 &&
      min(cat_rows$item_index) < min(mst_rows$item_index)

    for (i in seq_along(modules_in_traj)) {
      mod = modules_in_traj[i]
      mod_rows = mst_rows[mst_rows$module == mod, ]
      if (nrow(mod_rows) == 0) next
      mid_x = mean(c(min(mod_rows$item_index), max(mod_rows$item_index)))

      stage_num = i
      if (cat_before_mst) stage_num = stage_num + 1

      label_text = paste0("Stage ", stage_num, ": Module ", mod)
      p = p + ggplot2::annotate(
        "text", x = mid_x, y = -Inf, label = label_text,
        vjust = -0.5, size = 3, fontface = "italic"
      )
    }

    all_idx = first_person_traj$item_index
    p = p + ggplot2::scale_x_continuous(
      limits = c(min(all_idx) - 0.5, max(all_idx) + 0.5)
    )
  }

  title_label = if (length(person) == 1) {
    paste0("Respondent ", person)
  } else {
    paste0("Respondents ", paste(person, collapse = ", "))
  }

  p = p +
    ggplot2::labs(
      title = paste0("Theta Trajectory: ", title_label),
      x = "Item Position",
      y = expression(theta),
      color = NULL
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_minimal()

  if (facet_person) {
    p = p + ggplot2::facet_wrap(~ person_label)
  }

  p
}
