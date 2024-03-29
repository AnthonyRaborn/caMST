# module_selection() is used for the MST format
module_selection = function(i,
                            module_item_bank,
                            modules,
                            transition_matrix,
                            theta_est,
                            method = "BM",
                            response_matrix,
                            seen_cat_items,
                            cat_length,
                            module_select,
                            initial_theta = 0) {
  if (is.null(module_select)|
      !(module_select %in% c("MFI", "MLWMI", "MPWMI", "MKL", "MKLP", "random"))) {
        module_select <- "MFI"
      }

  next.module = mstR::nextModule(
    itemBank = module_item_bank,
    modules = modules,
    transMatrix = transition_matrix,
    current.module = 1,
    out = c(1:cat_length),
    theta = theta_est,
    criterion = module_select
  )

  current.responses = as.numeric(c(response_matrix[i, c(seen_cat_items)], response_matrix[i, c(rownames(next.module$par))]))

  seen.items = c(seen_cat_items, rownames(next.module$par))

  current.theta = mstR::thetaEst(it = module_item_bank[c(1:cat_length, next.module$items), ], x = current.responses, method = method)

  current.module = next.module$module


  final.module = mstR::nextModule(
    itemBank = module_item_bank,
    modules = modules,
    transMatrix = transition_matrix,
    current.module = current.module,
    out = seen.items,
    theta = current.theta
  )

  seen.items = c(seen_cat_items,
                 rownames(next.module$par),
                 rownames(final.module$par))
  final.responses = response_matrix[i, c(seen.items)]

  final.theta = mstR::thetaEst(it = module_item_bank[c(1:cat_length, next.module$items, final.module$items), ], x = final.responses, method = method)

  final.theta.eap = mstR::eapEst(it = module_item_bank[c(1:cat_length, next.module$items, final.module$items), ], x = final.responses)

  final.theta.iterative = iterative.theta.estimate(
    initial_theta = initial_theta,
    item.params = module_item_bank[c(1:cat_length, next.module$items, final.module$items), ],
    response.pattern = matrix(final.responses, nrow = 1, byrow = T)
  )

  return(
    list(
      final.theta.estimate.mstR = final.theta,
      eap.theta = final.theta.eap,
      final.theta.iterative = final.theta.iterative[, 1],
      sem.iterative = final.theta.iterative[, 2],
      final.item.bank = module_item_bank,
      final.items.seen = seen.items,
      modules.seen = c(next.module$module, final.module$module),
      final.responses = as.numeric(final.responses)
    )
  )
}

# moduleSelectionCAMST() is used for caMST
moduleSelectionCAMST = function(i,
                                module_item_bank,
                                modules,
                                transition_matrix,
                                theta_est,
                                method = "BM",
                                response_matrix,
                                seen_cat_items,
                                cat_length,
                                initial_theta = 0,
                                n_stage,
                                module_select = NULL) {
  if (is.null(module_select)|
      !(module_select %in% c("MFI", "MLWMI", "MPWMI", "MKL", "MKLP", "random"))) {
    module_select <- "MFI"
  }
  seen.modules = 1
  seen.items = seen_cat_items
  for (m in 2:n_stage) {
    next.module = mstR::nextModule(
      itemBank = module_item_bank,
      modules = modules,
      transMatrix = transition_matrix,
      current.module = seen.modules[m -
                                      1],
      out = seen.modules,
      theta = theta_est
    )
    seen.items = c(seen.items, rownames(next.module$par))
    current.responses = response_matrix[i, seen.items]
    current.theta = mstR::thetaEst(it = module_item_bank[seen.items,],
                                   x = current.responses,
                                   method = method)
    seen.modules = c(seen.modules, next.module$module)
  }

  final.responses = response_matrix[i, c(seen.items)]

  final.theta = mstR::thetaEst(it = module_item_bank[seen.items,], x = final.responses, method = method)

  final.theta.eap = mstR::eapEst(it = module_item_bank[seen.items,], x = final.responses)

  final.theta.iterative = iterative.theta.estimate(
    initial_theta = initial_theta,
    item.params = module_item_bank[seen.items, ],
    response.pattern = matrix(final.responses, nrow = 1, byrow = T)
  )

  return(
    list(
      final.theta.estimate.mstR = final.theta,
      eap.theta = final.theta.eap,
      final.theta.iterative = final.theta.iterative[, 1],
      sem.iterative = final.theta.iterative[, 2],
      final.item.bank = module_item_bank,
      final.items.seen = seen.items,
      modules.seen = seen.modules,
      final.responses = as.numeric(final.responses)
    )
  )
}
