#' Run the CAT Routing Stage for One Person
#'
#' Administers the item-level adaptive routing stage of
#' \code{\link{mixed_adaptive_test}} to a single person: selects
#' \code{cat_length} items one at a time from \code{cat_item_bank} using
#' \pkg{catR}'s \code{startItems}/\code{nextItem} item-selection routines,
#' re-estimating theta after each item.
#'
#' @param i The row index of \code{response_matrix} for the person being
#'   tested.
#' @param cat_item_bank A data frame of items in \pkg{catR} item-bank format.
#' @param initial_theta The starting theta estimate for item selection.
#' @param response_matrix A matrix or data frame of person responses, with
#'   individuals as rows and items (matching \code{cat_item_bank}) as columns.
#' @param model Either \code{NULL} for dichotomous models or a character
#'   value naming the polytomous model used. See \pkg{catR} for details.
#' @param method The provisional theta estimation method passed to
#'   \code{catR::thetaEst}.
#' @param item_method The item-selection criterion passed to
#'   \code{catR::nextItem} as \code{criterion} (e.g. \code{"MFI"}).
#' @param cat_length The number of items to administer in this stage.
#' @param nAvailable,cbControl,cbGroup,randomesque Forwarded to
#'   \code{catR::startItems}/\code{catR::nextItem}; see the Details section of
#'   \code{catR::nextItem} for their format.
#'
#' @return A list with \code{Theta.Est} (the final theta estimate),
#'   \code{Seen.Items} (the names of the items administered, in order), and
#'   \code{Responses} (that person's responses to those items).
#'
#' @keywords internal
routing_item_selection <- function(i, cat_item_bank, initial_theta,
                                   response_matrix, model, method, item_method,
                                   cat_length, nAvailable = NULL,
                                   cbControl = NULL, cbGroup = NULL,
                                   randomesque = 1){

  initial.item = catR::startItems(cat_item_bank, model = model, theta = initial_theta, nAvailable = nAvailable, cbControl = cbControl, cbGroup = cbGroup, randomesque = randomesque)

  all.selected.items = rownames(cat_item_bank)[initial.item$items]

  for(j in 2:cat_length){

    current.responses = response_matrix[i, c(all.selected.items)]
    current.item.params = cat_item_bank[c(all.selected.items),]

    current.theta = catR::thetaEst(current.item.params, current.responses, model = model, method = method)
    next.item = catR::nextItem(cat_item_bank, theta = current.theta, out = which(rownames(cat_item_bank) %in% all.selected.items), x = current.responses, model = model, criterion = item_method, method = method, nAvailable = nAvailable, cbControl = cbControl, cbGroup = cbGroup, randomesque = randomesque)
    all.selected.items = c(all.selected.items, rownames(cat_item_bank)[next.item$item])
  }

  current.responses = response_matrix[i, c(all.selected.items)]

  return(list(Theta.Est = current.theta, Seen.Items = all.selected.items, Responses = current.responses))
}
