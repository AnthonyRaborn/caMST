#' Computerized Adaptive Test
#'
#' @param cat_item_bank A data frame with the items on the rows and their item parameters on the columns. These should be in the \pkg{catR} package format for item banks.
#' @param response_matrix A matrix of the person responses, with individuals as rows and items as columns.
#' @param initial_theta The initial theta estimate for all individuals. Default is 0.
#' @param model Either NULL (default) for dichotomous models or a character value indicating the polytomous model used. See the\pkg{mstR} package for more details.
#' @param randomesque An integer value that indicates the number of items from which the selection rule should choose from randomly for administration. See the help documentation for \code{catR::nextItem} for more details.
#' @param maxItems An integer value indicating the maximum number of items to adminster, regardless of other stopping rules.
#' @param method A character value indicating method for the provisional theta estimate. Defaults to "BM" (Bayes Modal). See the \pkg{catR} package for more details.
#' @param ... Further arguments to be passed to \code{catR::nextItem}. Currently unimplemented.
#'
#' @return List of results.
#' @export
#'
#' @examples #fill in later
computerized_adaptive_test <-
  function(cat_item_bank,
           response_matrix,
           initial_theta = 0,
           model = NULL,
           randomesque = 1,
           maxItems = 50,
           method = "BM",
           ...) {
    # initialize start time to keep track of replication length
    start.time = Sys.time()

    # create empty vectors and matrices for final output
    final.theta = final.theta.eap = final.theta.Baker =
      final.theta.SEM = final.theta.Baker.SEM = c()
    final.items.seen = matrix(nrow = nrow(response_matrix), ncol = maxItems)
    final.responses = matrix(nrow = nrow(response_matrix), ncol = maxItems)

    # begin default args; these will be open to user-control
    nextItemControl = list(
      model = model,
      criterion = "MFI",
      method = method,
      priorDist = "norm",
      priorPar = c(0, 1),
      D = 1,
      range = c(-4, 4),
      parInt = c(-4, 4, 33),
      infoType = "Fisher",
      randomesque = 1,
      random.seed = NULL,
      rule = "precision",
      thr = .3,
      SETH = NULL,
      AP = 1,
      nAvailable = NULL,
      maxItems = maxItems,
      cbControl = NULL,
      cbGroup = NULL
    )
    nextItemControl$itemBank = cat_item_bank
    rule = "precision"
    thr = .5
    alpha = .05

    # one person at a time,
    for (i in 1:nrow(response_matrix)) {
      nextItemControl$out <- NULL
      # administer first item
      seen.items = do.call(catR::nextItem, args = nextItemControl)$name
      current.responses = response_matrix[i, seen.items]
      theta.est = catR::thetaEst(
        it = cat_item_bank[seen.items,],
        x = current.responses,
        model = model,
        method = method
      )
      theta.sem = catR::semTheta(
        thEst = theta.est,
        it = cat_item_bank[seen.items,],
        model = model,
        method = method
      )
      # remaining items
      while (sum(
        catR::checkStopRule(
          th = theta.est,
          se = theta.sem,
          it = cat_item_bank[seen.items],
          model = model,
          stop = list(
            rule = rule,
            thr = thr,
            alpha = alpha
          )
        )$decision,
        length(current.responses) == maxItems
      ) < 1) {
        nextItemControl$out = which(rownames(cat_item_bank) %in% seen.items)
        seen.items = c(seen.items,
                       do.call(catR::nextItem,
                               args = nextItemControl)$name)
        current.responses = response_matrix[i, seen.items]
        theta.est = catR::thetaEst(
          it = cat_item_bank[seen.items,],
          x = current.responses,
          model = model,
          method = method
        )
        theta.sem = catR::semTheta(
          thEst = theta.est,
          it = cat_item_bank[seen.items,],
          model = model,
          method = method
        )
      }


      # compile final information for this individual
      if (length(current.responses) < maxItems) {
        final.individual.responses <- c(as.numeric(current.responses),
                                        rep(NA,
                                            times = maxItems - length(current.responses)))
        final.individual.items <- c(seen.items,
                                    rep(NA,
                                        times = maxItems - length(current.responses)))
      } else {
        final.individual.responses <- as.numeric(current.responses)
        final.individual.items <- seen.items
      }
      final.responses[i, ] = final.individual.responses
      final.items.seen[i, ] = final.individual.items
      final.theta[i] = catR::thetaEst(it = cat_item_bank[seen.items, ],
                                      x = current.responses,
                                      method = method)
      final.theta.SEM[i] = theta.sem

      final.theta.eap[i] = catR::eapEst(it = cat_item_bank[seen.items, ], x = current.responses)

      temp.iter = iterative.theta.estimate(
        initial_theta = initial_theta,
        item.params = cat_item_bank[seen.items, ],
        response.pattern = as.data.frame(matrix(
          current.responses, nrow = 1, byrow = T
        ))
      )
      final.theta.Baker[i] = temp.iter[1]
      final.theta.Baker.SEM[i] = temp.iter[2]

      # end loop for this person; repeat loop for next
    }

    # print total time this replication took to perform
    print(Sys.time() - start.time)

    return(
      list(
        final.theta.estimate.catR = final.theta,
        eap.theta = final.theta.eap,
        final.theta.Baker = final.theta.Baker,
        final.theta.SEM = final.theta.SEM,
        final.items.seen = final.items.seen,
        final.responses = final.responses
      )
    )
  }
