#' Computerized Adaptive Test
#'
#' @param cat_item_bank A data frame with the items on the rows and their item parameters on the columns. These should be in the \pkg{catR} package format for item banks.
#' @param response_matrix A matrix of the person responses, with individuals as rows and items as columns.
#' @param initial_theta The initial theta estimate for all individuals. Default is 0.
#' @param model Either NULL (default) for dichotomous models or a character value indicating the polytomous model used. See the \pkg{mstR} package for more details.
#' @param randomesque An integer value that indicates the number of items from which the selection rule should choose from randomly for administration. See the help documentation for \code{catR::nextItem} for more details.
#' @param maxItems An integer value indicating the maximum number of items to administer, regardless of other stopping rules.
#' @param method A character value indicating method for the provisional theta estimate. Defaults to "BM" (Bayes Modal). See the \pkg{catR} package for more details.
#' @param nextItemControl A list of control values passed to \code{catR::nextItem}. See that function for more details.
#' @param ... Further arguments to be passed to internal functions. Currently unimplemented.
#'
#' @return An S4 object of class 'CAT' with the following slots:
#' \item{function.call}{The function and arguments called to create this object.}
#' \item{final.theta.estimate}{A numeric vector of the final theta estimates using the \code{method} provided in \code{function.call}.}
#' \item{eap.theta}{A numeric vector of the final theta estimates using the expected a posteriori (EAP) theta estimate from \code{catR::eapEst}.}
#' \item{final.theta.Baker}{A numeric vector of the final theta estimates using an iterative maximum likelihood estimation procedure as described in chapter 5 of Baker (2001).}
#' \item{final.theta.SEM}{A numeric vector of the final standard error of measurement (SEM) estimates using an iterative maximum likelihood estimation procedure as described in chapter 5 of Baker (2001)[http://echo.edres.org:8080/irt/baker/final.pdf].}
#' \item{final.items.seen}{A matrix of the final items seen by each individual using the supplied item names. \code{NA} values indicate that an individual wasn't given any items to answer after the last specified item in their row.}
#' \item{final.responses}{A matrix of the responses to the items seen in \code{final.items.seen}. \code{NA} values indicate that the individual didn't answer the question in the supplied response file or wasn't given any more items to answer.}
#' \item{runtime}{A \code{difftime} object recording how long the function took to complete.}
#' @export
#' @references Baker, F. B. (2001). The basics of item response theory. For full text: http://echo.edres.org:8080/irt/baker/final.pdf.
#' @seealso [mixed_adative_test] for a multistage test with a routing module using item-level adaptation.
#'
#' @examples
#' data(example_thetas) # 5 simulated abilities
#' data(example_responses) # 5 simulated responses
#' data(cat_items) # using just the CAT routing stage items
#' catResults <- computerized_adaptive_test(cat_item_bank = cat_items,
#' response_matrix = example_responses, randomesque = 1, maxItems = 3,
#' nextItemControl = list(criterion = "MFI",
#' priorDist = "norm", priorPar = c(0, 1), D = 1, range = c(-4, 4),
#' parInt = c(-4, 4, 33), infoType = "Fisher", randomesque = 1, random.seed = NULL,
#' rule = "precision", thr = .3, nAvailable = NULL,
#' cbControl = NULL, cbGroup = NULL))

computerized_adaptive_test <-
  function(cat_item_bank,
           response_matrix,
           initial_theta = 0,
           model = NULL,
           randomesque = 1,
           maxItems = 50,
           method = "BM",
           nextItemControl = list(
             criterion = "MFI",
             method = method,
             priorDist = "norm",
             priorPar = c(0, 1),
             D = 1,
             range = c(-4, 4),
             parInt = c(-4, 4, 33),
             infoType = "Fisher",
             random.seed = NULL,
             rule = "precision",
             thr = .3,
             SETH = NULL,
             AP = 1,
             nAvailable = NULL,
             cbControl = NULL,
             cbGroup = NULL),
           ...) {
    # initialize start time to keep track of replication length
    start.time = Sys.time()

    # create empty vectors and matrices for final output
    final.theta = final.theta.eap = final.theta.Baker =
      final.theta.SEM = final.theta.Baker.SEM = c()
    final.items.seen = matrix(nrow = nrow(response_matrix), ncol = maxItems)
    final.responses = matrix(nrow = nrow(response_matrix), ncol = maxItems)

    # check item names
    if (is.null(rownames(cat_item_bank))) {
      rownames(cat_item_bank) = paste0("Item", 1:nrow(cat_item_bank))
      colnames(response_matrix) = paste0("Item", 1:nrow(cat_item_bank))
      cat(message("The cat_item_bank did not have row names indicating which items were which, so the item names were filled in automatically for both the item bank and the response matrix."))
    }


    # begin default args; these will be open to user-control
    nextItemControl = nextItemControl
    nextItemControl$randomesque = randomesque
    nextItemControl$itemBank = cat_item_bank

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
          N = nrow(cat_item_bank[seen.items,]),
          it = cat_item_bank[seen.items,],
          model = model,
          stop = list(
            rule = nextItemControl$rule,
            thr = nextItemControl$thr,
            alpha = nextItemControl$alpha
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

    # create results object
    results =
      new(
        'CAT',
        function.call = match.call(),
        final.theta.estimate = final.theta,
        eap.theta = final.theta.eap,
        final.theta.Baker = final.theta.Baker,
        final.theta.SEM = final.theta.SEM,
        final.items.seen = final.items.seen,
        final.responses = final.responses,
        runtime = Sys.time() - start.time
      )

    print(results@runtime)

    return(
      results
    )
  }
