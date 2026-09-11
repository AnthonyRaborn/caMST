#' Reconstruct the provisional theta trajectory for one person
#'
#' @param object A result object of class \code{CAT}, \code{MST}, \code{MAT},
#'   or \code{HAT}.
#' @param person A single row index into \code{object@final.responses}.
#'
#' @return A data frame with columns \code{item_index}, \code{item_name},
#'   \code{module}, \code{theta}, \code{sem}, \code{is_update}, and
#'   \code{point_type}.
#'
#' @keywords internal

reconstruct_theta_trajectory = function(object, person) {

  extracted = extract_person_data(object, person)
  items_seen = extracted$items_seen
  responses  = extracted$responses

  est_method = object@method
  est_model  = object@model

  if (is(object, "CAT")) {
    traj = reconstruct_cat_trajectory(
      items_seen, responses, object@item.bank, est_method, est_model
    )
  } else if (is(object, "MST")) {
    modules_seen = object@modules.seen[person, ]
    modules_seen = modules_seen[!is.na(modules_seen)]
    traj = reconstruct_mst_trajectory(
      items_seen, responses, modules_seen, object@item.bank,
      object@modules, est_method, est_model
    )
  } else if (is(object, "MAT")) {
    modules_seen = object@modules.seen[person, ]
    modules_seen = modules_seen[!is.na(modules_seen)]
    traj = reconstruct_mat_trajectory(
      items_seen, responses, modules_seen, object@cat.item.bank,
      object@mst.item.bank, object@mst.modules, est_method, est_model
    )
  } else if (is(object, "HAT")) {
    modules_seen = object@modules.seen[person, ]
    modules_seen = modules_seen[!is.na(modules_seen)]
    traj = reconstruct_hat_trajectory(
      items_seen, responses, modules_seen, object@cat.item.bank,
      object@mst.item.bank, object@mst.modules, est_method, est_model,
      object@n.stages
    )
  } else {
    stop("object must be of class CAT, MST, MAT, or HAT.")
  }

  traj$point_type = "provisional"

  if (object@final.theta.method != est_method) {
    final_row = traj[nrow(traj), , drop = FALSE]
    final_row$theta      = object@final.theta.estimate[person]
    final_row$sem        = object@final.theta.SEM[person]
    final_row$is_update  = TRUE
    final_row$point_type = "final"
    traj = rbind(traj, final_row)
  }

  traj
}


# --- Extract items and responses for one person, handling storage quirks ---
extract_person_data = function(object, person) {
  n_persons = nrow(object@final.responses)

  if (is(object, "MAT") &&
      nrow(object@final.items.seen) != n_persons &&
      ncol(object@final.items.seen) == n_persons) {
    items_seen = object@final.items.seen[, person]
  } else {
    items_seen = object@final.items.seen[person, ]
  }

  responses = object@final.responses[person, ]
  n_items = sum(!is.na(items_seen))
  items_seen = items_seen[1:n_items]
  responses  = responses[1:n_items]

  list(items_seen = items_seen, responses = responses)
}


# --- Resolve item identifiers to row indices in an item bank ---
resolve_item_indices = function(items, item_bank) {
  item_names = rownames(item_bank)
  name_match = match(items, item_names)

  if (!any(is.na(name_match))) return(name_match)

  numeric_items = suppressWarnings(as.integer(items))
  if (!any(is.na(numeric_items)) &&
      all(numeric_items >= 1) &&
      all(numeric_items <= nrow(item_bank))) {
    return(numeric_items)
  }

  name_match
}


# --- CAT: recompute theta after each item ---
reconstruct_cat_trajectory = function(items_seen, responses, item_bank,
                                      method, model) {
  item_bank_mat = as.matrix(item_bank)
  n = length(items_seen)
  theta = sem = numeric(n)

  for (k in seq_len(n)) {
    idx = resolve_item_indices(items_seen[1:k], item_bank)
    it = item_bank_mat[idx, , drop = FALSE]
    x  = responses[1:k]
    theta[k] = catR::thetaEst(it = it, x = x, model = model, method = method)
    sem[k]   = catR::semTheta(thEst = theta[k], it = it, x = x,
                              model = model, method = method)
  }

  data.frame(
    item_index = seq_len(n),
    item_name  = items_seen,
    module     = NA_real_,
    theta      = theta,
    sem        = sem,
    is_update  = TRUE,
    segment_type = "cat",
    stringsAsFactors = FALSE
  )
}


# --- MST: recompute theta once per module ---
reconstruct_mst_trajectory = function(items_seen, responses, modules_seen,
                                      item_bank, modules_mat, method, model) {
  item_bank_mat = as.matrix(item_bank)
  n = length(items_seen)

  all_item_idx = resolve_item_indices(items_seen, item_bank)
  module_assignment = numeric(n)
  for (i in seq_len(n)) {
    module_assignment[i] = which(modules_mat[all_item_idx[i], ] == 1)
  }

  theta = sem = numeric(n)
  is_update = logical(n)

  cumulative_idx = integer(0)
  cumulative_responses = numeric(0)

  for (m in seq_along(modules_seen)) {
    mod_mask = module_assignment == modules_seen[m]
    mod_indices = which(mod_mask)
    if (length(mod_indices) == 0) next

    cumulative_idx = c(cumulative_idx, all_item_idx[mod_mask])
    cumulative_responses = c(cumulative_responses, responses[mod_mask])

    it = item_bank_mat[cumulative_idx, , drop = FALSE]
    x  = cumulative_responses

    current_theta = catR::thetaEst(it = it, x = x, model = model, method = method)
    current_sem   = catR::semTheta(thEst = current_theta, it = it, x = x,
                                   model = model, method = method)

    theta[mod_indices] = current_theta
    sem[mod_indices]   = current_sem
    is_update[mod_indices] = FALSE
    is_update[max(mod_indices)] = TRUE
  }

  data.frame(
    item_index = seq_len(n),
    item_name  = items_seen,
    module     = module_assignment,
    theta      = theta,
    sem        = sem,
    is_update  = is_update,
    segment_type = "mst",
    stringsAsFactors = FALSE
  )
}


# --- MAT: CAT routing stage (module 1) then MST modules ---
reconstruct_mat_trajectory = function(items_seen, responses, modules_seen,
                                      cat_item_bank, mst_item_bank,
                                      mst_modules_mat, method, model) {
  cat_names = rownames(cat_item_bank)
  if (is.null(cat_names)) cat_names = as.character(seq_len(nrow(cat_item_bank)))
  mst_names = rownames(mst_item_bank)
  if (is.null(mst_names)) mst_names = as.character(seq_len(nrow(mst_item_bank)))
  cat_bank_mat = as.matrix(cat_item_bank)
  mst_bank_mat = as.matrix(mst_item_bank)

  n = length(items_seen)
  cat_module = modules_seen[1]
  is_cat = items_seen %in% cat_names
  n_cat = sum(is_cat)

  theta = sem = numeric(n)
  is_update = logical(n)
  module_assignment = numeric(n)

  for (k in seq_len(n_cat)) {
    idx = resolve_item_indices(items_seen[1:k], cat_item_bank)
    it = cat_bank_mat[idx, , drop = FALSE]
    x  = responses[1:k]
    theta[k] = catR::thetaEst(it = it, x = x, model = model, method = method)
    sem[k]   = catR::semTheta(thEst = theta[k], it = it, x = x,
                              model = model, method = method)
    is_update[k] = TRUE
    module_assignment[k] = cat_module
  }

  if (n_cat < n) {
    mst_items = items_seen[(n_cat + 1):n]
    mst_responses = responses[(n_cat + 1):n]
    mst_modules = modules_seen[-1]

    mst_item_idx = resolve_item_indices(mst_items, mst_item_bank)
    mst_module_assignment = numeric(length(mst_items))
    for (i in seq_along(mst_items)) {
      mst_module_assignment[i] = which(mst_modules_mat[mst_item_idx[i], ] == 1)
    }
    module_assignment[(n_cat + 1):n] = mst_module_assignment

    combined_bank = rbind(cat_bank_mat, mst_bank_mat)
    n_cat_bank = nrow(cat_bank_mat)

    cat_cumulative_idx = resolve_item_indices(items_seen[1:n_cat], cat_item_bank)
    cumulative_combined_idx = cat_cumulative_idx
    cumulative_responses = responses[1:n_cat]

    unique_mst_mods = unique(mst_module_assignment)
    for (m in seq_along(unique_mst_mods)) {
      mod_mask = mst_module_assignment == unique_mst_mods[m]
      mod_indices = which(mod_mask) + n_cat
      if (length(mod_indices) == 0) next

      new_mst_idx = mst_item_idx[mod_mask]
      new_combined_idx = new_mst_idx + n_cat_bank
      cumulative_combined_idx = c(cumulative_combined_idx, new_combined_idx)
      cumulative_responses = c(cumulative_responses, mst_responses[mod_mask])

      it = combined_bank[cumulative_combined_idx, , drop = FALSE]
      x  = cumulative_responses

      current_theta = catR::thetaEst(it = it, x = x, model = model, method = method)
      current_sem   = catR::semTheta(thEst = current_theta, it = it, x = x,
                                     model = model, method = method)

      theta[mod_indices] = current_theta
      sem[mod_indices]   = current_sem
      is_update[mod_indices] = FALSE
      is_update[max(mod_indices)] = TRUE
    }
  }

  seg = rep("mst", n)
  seg[seq_len(n_cat)] = "cat"

  data.frame(
    item_index = seq_len(n),
    item_name  = items_seen,
    module     = module_assignment,
    theta      = theta,
    sem        = sem,
    is_update  = is_update,
    segment_type = seg,
    stringsAsFactors = FALSE
  )
}


# --- HAT: MST stages first, then CAT stage last ---
reconstruct_hat_trajectory = function(items_seen, responses, modules_seen,
                                      cat_item_bank, mst_item_bank,
                                      mst_modules_mat, method, model,
                                      n_stages) {
  mst_names = rownames(mst_item_bank)
  if (is.null(mst_names)) mst_names = as.character(seq_len(nrow(mst_item_bank)))
  cat_names = rownames(cat_item_bank)
  if (is.null(cat_names)) cat_names = as.character(seq_len(nrow(cat_item_bank)))
  mst_bank_mat = as.matrix(mst_item_bank)
  cat_bank_mat = as.matrix(cat_item_bank)

  n = length(items_seen)
  n_mst_stages = n_stages - 1
  mst_modules = modules_seen[seq_len(n_mst_stages)]
  cat_module = modules_seen[n_stages]

  is_mst = items_seen %in% mst_names
  n_mst = sum(is_mst)

  theta = sem = numeric(n)
  is_update = logical(n)
  module_assignment = numeric(n)

  mst_items = items_seen[1:n_mst]
  mst_responses = responses[1:n_mst]

  mst_item_idx = resolve_item_indices(mst_items, mst_item_bank)
  mst_module_assignment = numeric(n_mst)
  for (i in seq_len(n_mst)) {
    mst_module_assignment[i] = which(mst_modules_mat[mst_item_idx[i], ] == 1)
  }
  module_assignment[1:n_mst] = mst_module_assignment

  cumulative_mst_idx = integer(0)
  cumulative_mst_responses = numeric(0)

  for (m in seq_along(mst_modules)) {
    mod_mask = mst_module_assignment == mst_modules[m]
    mod_indices = which(mod_mask)
    if (length(mod_indices) == 0) next

    cumulative_mst_idx = c(cumulative_mst_idx, mst_item_idx[mod_mask])
    cumulative_mst_responses = c(cumulative_mst_responses, mst_responses[mod_mask])

    it = mst_bank_mat[cumulative_mst_idx, , drop = FALSE]
    x  = cumulative_mst_responses

    current_theta = catR::thetaEst(it = it, x = x, model = model, method = method)
    current_sem   = catR::semTheta(thEst = current_theta, it = it, x = x,
                                   model = model, method = method)

    theta[mod_indices] = current_theta
    sem[mod_indices]   = current_sem
    is_update[mod_indices] = FALSE
    is_update[max(mod_indices)] = TRUE
  }

  if (n_mst < n) {
    combined_bank = rbind(mst_bank_mat, cat_bank_mat)
    n_mst_bank = nrow(mst_bank_mat)

    mst_combined_idx = cumulative_mst_idx

    cat_items_all = items_seen[(n_mst + 1):n]
    cat_responses_all = responses[(n_mst + 1):n]
    n_cat = length(cat_items_all)
    cat_item_idx = resolve_item_indices(cat_items_all, cat_item_bank)

    for (k in seq_len(n_cat)) {
      pos = n_mst + k
      cat_combined_idx = cat_item_idx[1:k] + n_mst_bank
      all_idx = c(mst_combined_idx, cat_combined_idx)
      it = combined_bank[all_idx, , drop = FALSE]
      x  = c(cumulative_mst_responses, cat_responses_all[1:k])

      theta[pos] = catR::thetaEst(it = it, x = x, model = model, method = method)
      sem[pos]   = catR::semTheta(thEst = theta[pos], it = it, x = x,
                                  model = model, method = method)
      is_update[pos] = TRUE
      module_assignment[pos] = cat_module
    }
  }

  seg = rep("mst", n)
  if (n_mst < n) seg[(n_mst + 1):n] = "cat"

  data.frame(
    item_index = seq_len(n),
    item_name  = items_seen,
    module     = module_assignment,
    theta      = theta,
    sem        = sem,
    is_update  = is_update,
    segment_type = seg,
    stringsAsFactors = FALSE
  )
}
