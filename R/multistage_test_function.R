#' Computer Adaptive Multistage Test
#'
#' @param mst_item_bank A data frame with the items on the rows and their item parameters on the columns. These should be in the \pkg{mstR} package format for item banks.
#' @param modules A matrix describing the relationship between the items and the modules they belong to. See \strong{Details}.
#' @param transition_matrix A matrix describing how individuals can transition from one stage to the next.
#' @param method A character value indicating the method for the item-level selection in the first stage. Defaults to "MFI" (Maximum Fisher Information). See the \pkg{catR} and \pkg{mstR} packages for more details.
#' @param response_matrix A matrix of the person responses, with individuals as rows and items as columns.
#' @param initial_theta The initial theta estimate for all individuals. Default is 0.
#' @param model A character value indicating method for the provisional theta estimate. Defaults to "BM" (Bayes Modal). See the \pkg{mstR} package for more details.
#' @param n_stages A numeric value indicating the number of stages in the test.
#' @param test_length A numeric value indicating the total number of items each individual answers.
#'
#' @return A list for each invidual with the following elements: the final theta estimate based on "method", the final theta estimate based on EAP, the final theta estimate based on the iterative estimate from Baker 2004, a vector of the final items taken, a vector of the modules see, and a vector of the final responses.
#' @export
#' # using simulated test data
#' data(example_thetas) # 5 simulated abilities
#' data(example_responses) # 5 simulated response vectors
#' # the transition matrix for an 18 item 1-3-3 design
#' data(example_transition_matrix)
#' # the MST item bank
#' data(mst_only_items)
#' # run the MST model
#' results <- multistage_test(mst_item_bank = mst_only_items, modules, transition_matrix, method = "BM",
#' response_matrix, initial_theta = 0, model = NULL, n_stages = 3, test_length = 18)
#'


multistage_test <-
  function(mst_item_bank,
           modules,
           transition_matrix,
           method = "BM",
           response_matrix,
           initial_theta = 0,
           model = NULL,
           n_stages = 3,
           test_length = 18) {

    # initialize start time to keep track of replication length
    start.time = Sys.time()

    # create empty vectors and matrices for final output
    final.theta = final.theta.eap = final.theta.personal = c()
    final.items.seen = matrix(nrow = nrow(response_matrix), ncol = test_length)
    modules.seen = matrix(nrow = nrow(response_matrix), ncol = n_stages)
    final.responses = matrix(nrow = nrow(response_matrix), ncol = test_length)

    # one person at a time,
    for (i in 1:nrow(response_matrix)) {
      # pull the responses specific to the items chosen for the test and administer first module
      mst.responses = response_matrix[i, rownames(mst_item_bank)]
      first.module = mstR::startModule(
        itemBank = mst_item_bank,
        modules = modules,
        transition_matrix = transition_matrix,
        model = model,
        theta = initial_theta
      )
      current.responses = mst.responses[, first.module$items]
      seen.modules = first.module$module
      seen.items = first.module$items
      first.theta.est = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                       x = current.responses,
                                       method = method)

      # using current module(s) and theta estimate, select the next module until test ends
      # save the module, items, and responses chosen by updating the appropriate objects
      for (m in 2:n_stages) {
        next.module = mstR::nextModule(
          itemBank = mst_item_bank,
          modules = modules,
          transMatrix = transition_matrix,
          current.module = seen.modules[m -
                                          1],
          out = seen.modules,
          theta = first.theta.est
        )
        seen.items = c(seen.items, next.module$items)
        current.responses = response_matrix[, seen.items]
        current.theta = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                       x = current.responses,
                                       method = method)
        seen.modules = c(seen.modules, next.module$module)
      }

      # compile final information for this individual
      final.responses[i, ] = as.numeric(mst.responses[, seen.items])
      final.items.seen[i, ] = seen.items
      final.modules.seen = seen.modules
      final.theta[i] = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                      x = final.responses[i, ],
                                      method = method)

      final.theta.eap[i] = mstR::eapEst(it = mst_item_bank[seen.items, ], x = final.responses[i, ])

      final.theta.personal[i] = iterative.theta.estimate(
        initial_theta = initial_theta,
        item.params = mst_item_bank[seen.items, ],
        response.pattern = as.data.frame(matrix(
          final.responses[i, ], nrow = 1, byrow = T
        ))
      )

      # end loop for this person; repeat loop for next
    }

    # print total time this replication took to perform
    print(Sys.time() - start.time)

    # compile everyones' results into a list and return
    return(
      list(
        final.theta.estimate.mstR = final.theta,
        eap.theta = final.theta.eap,
        final.theta.personal = final.theta.personal,
        final.items.seen = final.items.seen,
        modules.seen = final.modules.seen,
        final.responses = final.responses
      )
    )

  }
