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
    next.item = catR::nextItem(cat_item_bank, theta = current.theta, out = which(rownames(cat_item_bank) %in% all.selected.items), x = current.responses, criterion = item_method, method = method, nAvailable = NULL, cbControl = cbControl, cbGroup = cat_item_bank$cbGroup, randomesque = randomesque)
    all.selected.items = c(all.selected.items, rownames(cat_item_bank)[next.item$item])
  }

  current.responses = response_matrix[i, c(all.selected.items)]

  return(list(Theta.Est = current.theta, Seen.Items = all.selected.items, Responses = current.responses))
}
