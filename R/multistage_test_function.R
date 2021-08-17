#' Computer Adaptive Multistage Test
#'
#' @param mst_item_bank A data frame with the items on the rows and their item parameters on the columns. These should be in the \pkg{mstR} package format for item banks.
#' @param modules A matrix describing the relationship between the items and the modules they belong to. See \strong{Details}.
#' @param transition_matrix A matrix describing how individuals can transition from one stage to the next.
#' @param method A character value indicating method for the provisional theta estimate. Defaults to "BM" (Bayes Modal). See the \pkg{mstR} package for more details.
#' @param response_matrix A matrix of the person responses, with individuals as rows and items as columns.
#' @param initial_theta The initial theta estimate for all individuals. Default is 0.
#' @param model Either NULL (default) for dichotomous models or a character value indicating the polytomous model used. See the\pkg{mstR} package for more details.
#' @param n_stages A numeric value indicating the number of stages in the test.
#' @param test_length A numeric value indicating the total number of items each individual answers.
#' @param module_select A character value indicating the information method used to select modules at transition stages. One of "MFI" (default), "MLWMI", "MPWMI", "MKL", "MKLP", "random". See the \pkg{mstR} for more details.
#' @param nc_list This parameter controls whether or not to use number correct ("NC") scoring to select modules. Defaults to `NULL`, using module information. Otherwise, this should be a list where the elements of the list correspond to each module which routes to other modules by number correct. If no `method` argument is provided in this list, or if an invalid entry is given, the method will default to `'cumulative_sum'`, meaning the values provided are a running tally of the number of items correctly answered on the test. If `method` is set to `module_sum`, then the sum of the number correct within the current module will be used to select the next module. See 'details' for more information.
#'
#' @details When using (cumulative) number correct module selection, the input list should contain one element for each module that needs to route to other modules. For example, in a 1-3-3 design the first module can route to any module in the second stage, so the first element of `nc_list` would be a numeric vector with three values indicating the *maximum* number of correct items needed in order to be routed to the second, third, or fourth module respectively. When the design is not crossed (e.g., a person routed to the easy module in the second stage **cannot** be routed to the hard module in the third stage), `-Inf` and `Inf` need to be used within `nc_list` to indicate this. Continuing the example, let's assume the 1-3-3 design is not crossed and will be balanced so that each stage has the same number of items (10 each) for a total of 30 items administered. The `nc_list` object could be specified like so:
#' nc_list = list(module1 = c(4, 5, 7),
#' module2 = c(8, 14, Inf),
#' module3 = c(8, 14, 20),
#' module4 = c(-Inf, 14, 20),
#' method = "cumulative_sum").
#'
#' As it is the most common method of number correct scoring, "cumulative_sum" is the default. Any value included in the `method` argument of `nc_list` that does _not_ equal "module_sum" will cause the default "cumulative_sum" to be used. _This is intentional and will not be changed unless I am given a good argument to change it_.
#'
#' @return A list of all individuals with the following elements: the vector of final theta estimates based on "method", the vector of final theta estimates based on EAP, the vector of final theta estimates based on the iterative estimate from Baker 2004, a matrix of the final items taken, a matrix of the modules seen, and a matrix of the final responses.
#' @return An S4 object of class 'MST' with the following slots:
#' \item{function.call}{The function and arguments called to create this object.}
#' \item{final.theta.estimate}{A numeric vector of the final theta estimates using the \code{method} provided in \code{function.call}.}
#' \item{eap.theta}{A numeric vector of the final theta estimates using the expected a posteriori (EAP) theta estimate from \code{catR::eapEst}.}
#' \item{final.theta.Baker}{A numeric vector of the final theta estimates using an iterative maximum likelihood estimation procedure as described in chapter 5 of Baker (2001).}
#' \item{final.theta.SEM}{A numeric vector of the final standard error of measurement (SEM) estimates using an iterative maximum likelihood estimation procedure as described in chapter 5 of Baker (2001).}
#' \item{final.items.seen}{A matrix of the final items seen by each individual using the supplied item names. `NA` values indicate that an individual wasn't given any items to answer after the last specified item in their row.}
#' \item{final.responses}{A matrix of the responses to the items seen in \code{final.items.seen}. \code{NA} values indicate that the individual didn't answer the question in the supplied response file or wasn't given any more items to answer.}
#' \item{transition.matrix}{The \code{transition_matrix} originally supplied to the function.}
#' \item{n.stages}{The \code{n_stages} originally supplied to the function.}
#' \item{nc.list}{The \code{nc_list} originally supplied to the function.}
#' \item{runtime}{A \code{difftime} object recording how long the function took to complete.}
#' @export
#'
#' @references Baker (2001). http://echo.edres.org:8080/irt/baker/final.pdf
#' @seealso [mixed_adaptive_test] for a multistage test with a routing module using item-level adaptation.
#'
#' @examples
#' \donttest{
#' # using simulated test data
#' data(example_thetas) # 5 simulated abilities
#' data(example_responses) # 5 simulated response vectors
#' # the transition matrix for an 18 item 1-3-3 design
#' data(example_transition_matrix)
#' # the MST item bank
#' data(mst_only_items)
#' # the MST module matrix
#' data(example_module_items)
#' # run the MST model
#' results <- multistage_test(mst_item_bank = mst_only_items,
#' modules = example_module_items, transition_matrix = example_transition_matrix,
#' method = "BM", response_matrix = example_responses, initial_theta = 0,
#' model = NULL, n_stages = 3, test_length = 18)
#'}
#'# using number correct scoring for the same data
#'# create nc_list as explained in 'details'
#' nc_list = list(module1 = c(4, 5, 7),
#' module2 = c(8, 14, Inf),
#' module3 = c(8, 14, 18),
#' module4 = c(-Inf, 14, 18),
#' method = 3) # the method here will default to "cumulative_sum" as described in 'details'
#' # this is the ONLY difference currently! Everything else remains the same
#' # run the example
#'nc.results <- multistage_test(mst_item_bank = mst_only_items,
#'modules = example_module_items, transition_matrix = example_transition_matrix,
#'method = "BM", response_matrix = example_responses, initial_theta = 0,
#'model = NULL, n_stages = 3, test_length = 18, nc_list = nc_list)



multistage_test <-
  function(mst_item_bank,
           modules,
           transition_matrix,
           method = "BM",
           response_matrix,
           initial_theta = 0,
           model = NULL,
           n_stages = 3,
           test_length = 18,
           module_select = "MFI",
           nc_list = NULL) {

    # initialize start time to keep track of replication length
    start.time = Sys.time()

    # create empty vectors and matrices for final output
    final.theta = final.theta.eap = final.theta.Baker = final.theta.SEM = c()
    final.items.seen = matrix(nrow = nrow(response_matrix), ncol = test_length)
    final.modules.seen = matrix(nrow = nrow(response_matrix), ncol = n_stages)
    final.responses = matrix(nrow = nrow(response_matrix), ncol = test_length)

    if (is.null(rownames(mst_item_bank))) {
      rownames(mst_item_bank) = paste0("Item", 1:nrow(mst_item_bank))
      colnames(response_matrix) = paste0("Item", 1:nrow(mst_item_bank))
      cat(message("The mst_item_bank did not have row names indicating which items were which, so the item names were filled in automatically for both the item bank and the response matrix."))
    }

    # one person at a time,
    for (i in 1:nrow(response_matrix)) {
      if (is.list(nc_list)) {
        if (is.null(nc_list$method)) {
          nc_list$method = "cumulative_sum"
        }
        if (nc_list$method!="module_sum"|nc_list$method=="cumulative_sum") {
          # pull the responses specific to the items chosen for the test and administer first module
          mst.responses = response_matrix[i, rownames(mst_item_bank)]
          first.module = mstR::startModule(
            itemBank = mst_item_bank,
            modules = modules,
            transMatrix = transition_matrix,
            model = model,
            theta = initial_theta
          )
          current.responses = mst.responses[, first.module$items]
          seen.modules = first.module$module
          seen.items = first.module$items
          num.correct = sum(current.responses)

          # using current module(s) and number correct, select the next module until test ends
          # save the module, items, and responses chosen by updating the appropriate objects
          for (m in 2:n_stages) {
            current.module = seen.modules[m - 1]
            next.module.selected = (findInterval(
              x = num.correct,
              vec = nc_list[[m - 1]],
              rightmost.closed = TRUE
            ) + 1)
            selected.module = which(transition_matrix[current.module,]==1)[next.module.selected]
            next.module = modules[,selected.module]
            seen.items = c(seen.items, which(next.module==1))
            current.responses = mst.responses[, seen.items]
            num.correct = sum(current.responses)
            current.theta = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                           x = as.numeric(current.responses),
                                           method = method)
            seen.modules = c(seen.modules, selected.module)
          }

          final.responses[i, ] = as.numeric(mst.responses[, seen.items])
          final.items.seen[i, ] = seen.items
          final.modules.seen[i,] = seen.modules
          final.theta[i] = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                          x = final.responses[i, ],
                                          method = method)

          final.theta.eap[i] = mstR::eapEst(it = mst_item_bank[seen.items, ], x = final.responses[i, ])

          temp.iter = iterative.theta.estimate(
            initial_theta = initial_theta,
            item.params = mst_item_bank[seen.items, ],
            response.pattern = as.data.frame(matrix(
              final.responses[i, ], nrow = 1, byrow = T
            )))
          final.theta.Baker[i] = temp.iter[1]
          final.theta.SEM[i] = temp.iter[2]

          # end loop for this person; repeat loop for next

        } else if (nc_list$method=="module_sum") {
          # pull the responses specific to the items chosen for the test and administer first module
          mst.responses = response_matrix[i, rownames(mst_item_bank)]
          first.module = mstR::startModule(
            itemBank = mst_item_bank,
            modules = modules,
            transMatrix = transition_matrix,
            model = model,
            theta = initial_theta
          )
          current.responses = mst.responses[, first.module$items]
          seen.modules = first.module$module
          seen.items = first.module$items
          num.correct = sum(current.responses)

          # using current module(s) and number correct, select the next module until test ends
          # save the module, items, and responses chosen by updating the appropriate objects
          for (m in 2:n_stages) {
            current.module = seen.modules[m - 1]
            next.module.selected = (findInterval(
              x = num.correct,
              vec = nc_list[[m - 1]],
              rightmost.closed = TRUE
            ) + 1)
            selected.module = which(transition_matrix[current.module,]==1)[next.module.selected]
            next.module = modules[,selected.module]
            seen.items = c(seen.items, which(next.module==1))
            current.responses = mst.responses[, seen.items]
            num.correct = sum(current.responses[length(current.responses):(sum(next.module)+1)])
            current.theta = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                           x = as.numeric(current.responses),
                                           method = method)
            seen.modules = c(seen.modules, selected.module)
          }

          final.responses[i, ] = as.numeric(mst.responses[, seen.items])
          final.items.seen[i, ] = seen.items
          final.modules.seen[i,] = seen.modules
          final.theta[i] = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                          x = final.responses[i, ],
                                          method = method)

          final.theta.eap[i] = mstR::eapEst(it = mst_item_bank[seen.items, ], x = final.responses[i, ])

          temp.iter = iterative.theta.estimate(
            initial_theta = initial_theta,
            item.params = mst_item_bank[seen.items, ],
            response.pattern = as.data.frame(matrix(
              final.responses[i, ], nrow = 1, byrow = T
            )))
          final.theta.Baker[i] = temp.iter[1]
          final.theta.SEM[i] = temp.iter[2]

          # end loop for this person; repeat loop for next
        }
      } else {
        for (i in 1:nrow(response_matrix)) {
          # pull the responses specific to the items chosen for the test and administer first module
          mst.responses = response_matrix[i, rownames(mst_item_bank)]
          first.module = mstR::startModule(
            itemBank = mst_item_bank,
            modules = modules,
            transMatrix = transition_matrix,
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
              theta = first.theta.est,
              criterion = module_select
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
          final.modules.seen[i, ] = seen.modules
          final.theta[i] = mstR::thetaEst(it = mst_item_bank[seen.items, ],
                                          x = final.responses[i, ],
                                          method = method)

          final.theta.eap[i] = mstR::eapEst(it = mst_item_bank[seen.items, ], x = final.responses[i, ])

          temp.iter = iterative.theta.estimate(
            initial_theta = initial_theta,
            item.params = mst_item_bank[seen.items, ],
            response.pattern = as.data.frame(matrix(
              final.responses[i, ], nrow = 1, byrow = T
            )))
          final.theta.Baker[i] = temp.iter[1]
          final.theta.SEM[i] = temp.iter[2]

          # end loop for this person; repeat loop for next
        }
      }
    }

    # create results object
    results =
      new(
        'MST',
        function.call = match.call(),
        final.theta.estimate = final.theta,
        eap.theta = final.theta.eap,
        final.theta.Baker = final.theta.Baker,
        final.theta.SEM = final.theta.SEM,
        final.items.seen = final.items.seen,
        modules.seen = final.modules.seen,
        final.responses = final.responses,
        transition.matrix = transition_matrix,
        n.stages = n_stages,
        nc.list = nc_list,
        runtime = Sys.time() - start.time
      )

    print(results@runtime)

    return(
      results
    )
  }
