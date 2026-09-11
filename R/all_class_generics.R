#' An S4 class for computerized adaptive tests
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate Numeric vector of final theta estimates, computed using `final.theta.method`.
#' @slot final.theta.method Character; the estimation method used to compute `final.theta.estimate` and `final.theta.SEM` (see the `final_theta_method` argument).
#' @slot final.theta.SEM Numeric vector of SEM estimates for `final.theta.estimate`, computed via `catR::semTheta`.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot item.bank The item bank supplied to the test function, stored for post-hoc trajectory reconstruction.
#' @slot method Character; the provisional estimation method used during administration (distinct from `final.theta.method`).
#' @slot model The IRT model specification used during administration (`NULL` for dichotomous).
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @importFrom methods new
#'
#' @return An S4 object of class `CAT`.
#' @export
#'
setClass('CAT',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate = 'numeric',
             final.theta.method = 'character',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             final.responses = 'matrix',
             item.bank = 'ANY',
             method = 'character',
             model = 'ANY',
             runtime = 'ANY'
           )
         )

setMethod('show',
          signature = 'CAT',
          definition = function(object) {
            Original.Call = object@function.call
            Total.Time = object@runtime
            Average.Theta = mean(object@final.theta.estimate)
            Average.SEM = mean(object@final.theta.SEM, na.rm = T)
            Average.Items = mean(apply(object@final.items.seen, 1, FUN = function(x) sum(!is.na(x))))

            line0 = c("Test Format: Computerized Adaptive Test")
            line1 = Original.Call
            line2 = paste0("Total Run Time: ", round(Total.Time[[1]], 3), " ", attr(Total.Time, "units"))
            line3 = paste0("Final Theta Method: ", object@final.theta.method)
            line4 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line5 = paste0("Average SEM: ", round(Average.SEM, 3))
            line6 = paste0("Average Number of Items Seen: ", round(Average.Items, 3))

            cat(paste0(c(line0, line1, line2, line3, line4, line5, line6), collapse = "\n"))
            })

#' An S4 method for multistage adaptive tests.
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate Numeric vector of final theta estimates, computed using `final.theta.method`.
#' @slot final.theta.method Character; the estimation method used to compute `final.theta.estimate` and `final.theta.SEM` (see the `final_theta_method` argument).
#' @slot final.theta.SEM Numeric vector of SEM estimates for `final.theta.estimate`, computed via `catR::semTheta`.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot modules.seen Numeric matrix of the modules seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot transition.matrix Numeric matrix; the transition matrix entered into the function.
#' @slot n.stages Numeric; the number of stages specified.
#' @slot nc.list A list of the number correct scoring logic and method, if applicable. Defaults to `NULL`.
#' @slot item.bank The item bank supplied to the test function, stored for post-hoc trajectory reconstruction.
#' @slot modules The item-to-module mapping matrix supplied to the test function, stored for post-hoc trajectory reconstruction.
#' @slot method Character; the provisional estimation method used during administration (distinct from `final.theta.method`).
#' @slot model The IRT model specification used during administration (`NULL` for dichotomous).
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @importFrom methods new
#'
#' @return An S4 object of class `MST`.
#' @export
#'
setClass('MST',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate = 'numeric',
             final.theta.method = 'character',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             modules.seen = 'matrix',
             final.responses = 'matrix',
             transition.matrix = 'matrix',
             n.stages = 'numeric',
             nc.list = 'ANY',
             item.bank = 'ANY',
             modules = 'ANY',
             method = 'character',
             model = 'ANY',
             runtime = 'ANY'
           )
)

setMethod('show',
          signature = 'MST',
          definition = function(object) {
            Original.Call = object@function.call
            Total.Time = object@runtime
            Average.Theta = mean(object@final.theta.estimate)
            Average.SEM = mean(object@final.theta.SEM, na.rm = T)
            Path.Taken = apply(object@modules.seen, 1, FUN = function(object) paste0(object, collapse = '-'))
            Most.Path = table(Path.Taken)[which(table(Path.Taken)==max(table(Path.Taken)))]

            line0 = ifelse(
              test = is.null(object@nc.list),
              yes  = c("Test Format: Multistage Adaptive Test"),
              no   = ifelse(
                test = is.null(object@nc.list$method)||
                  object@nc.list$method!="module_sum",
                yes  = c("Test Format: Multistage Adaptive Test with Cumulative Summation Scoring"),
                no   = c("Test Format: Multistage Adaptive Test with Module Summation Scoring")
                )
              )
            line1 = Original.Call
            line2 = paste0("Total Run Time: ", round(Total.Time[[1]], 3), " ", attr(Total.Time, "units"))
            line3 = paste0("Final Theta Method: ", object@final.theta.method)
            line4 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line5 = paste0("Average SEM: ", round(Average.SEM, 3))
            line6 = paste0("Most Common Path(s) Taken: ", attr(Most.Path, 'names'), " taken by ", Most.Path, " subjects")

            cat(paste0(c(line0, line1, line2, line3, line4, line5, line6), collapse = "\n"))
          })

#' An S4 method for mixed adaptive tests.
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate Numeric vector of final theta estimates, computed using `final.theta.method`.
#' @slot final.theta.method Character; the estimation method used to compute `final.theta.estimate` and `final.theta.SEM` (see the `final_theta_method` argument).
#' @slot final.theta.SEM Numeric vector of SEM estimates for `final.theta.estimate`, computed via `catR::semTheta`.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot modules.seen Numeric matrix of the modules seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot transition.matrix Numeric matrix; the transition matrix entered into the function.
#' @slot n.stages Numeric; the number of stages specified.
#' @slot cat.item.bank The CAT-stage item bank as supplied, stored for post-hoc trajectory reconstruction.
#' @slot mst.item.bank The MST-stage item bank as supplied, stored for post-hoc trajectory reconstruction.
#' @slot mst.modules The item-to-module mapping matrix for the MST portion, stored for post-hoc trajectory reconstruction.
#' @slot method Character; the provisional estimation method used during administration (distinct from `final.theta.method`).
#' @slot model The IRT model specification used during administration (`NULL` for dichotomous).
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @importFrom methods new
#'
#' @return An S4 object of class `MAT`.
#' @export
#'
setClass('MAT',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate = 'numeric',
             final.theta.method = 'character',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             modules.seen = 'matrix',
             final.responses = 'matrix',
             transition.matrix = 'matrix',
             n.stages = 'numeric',
             cat.item.bank = 'ANY',
             mst.item.bank = 'ANY',
             mst.modules = 'ANY',
             method = 'character',
             model = 'ANY',
             runtime = 'ANY'
           )
)

setMethod('show',
          signature = 'MAT',
          definition = function(object) {
            Original.Call = object@function.call
            Total.Time = object@runtime
            Average.Theta = mean(object@final.theta.estimate)
            Average.SEM = mean(object@final.theta.SEM, na.rm = T)
            Path.Taken = apply(object@modules.seen, 1, FUN = function(object) paste0(object, collapse = '-'))
            Most.Path = table(Path.Taken)[which(table(Path.Taken)==max(table(Path.Taken)))]

            line0 = c("Test Format: Mixed Adaptive Test")
            line1 = Original.Call
            line2 = paste0("Total Run Time: ", round(Total.Time[[1]], 3), " ", attr(Total.Time, "units"))
            line3 = paste0("Final Theta Method: ", object@final.theta.method)
            line4 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line5 = paste0("Average SEM: ", round(Average.SEM, 3))
            line6 = paste0("Most Common Path(s) Taken: ", attr(Most.Path, 'names'), " taken by ", Most.Path, " subjects")

            cat(paste0(c(line0, line1, line2, line3, line4, line5, line6), collapse = "\n"))
          })

#' An S4 class for hybrid adaptive tests.
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate Numeric vector of final theta estimates, computed using `final.theta.method`.
#' @slot final.theta.method Character; the estimation method used to compute `final.theta.estimate` and `final.theta.SEM` (see the `final_theta_method` argument).
#' @slot final.theta.SEM Numeric vector of SEM estimates for `final.theta.estimate`, computed via `catR::semTheta`.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot modules.seen Numeric matrix of the MST modules seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot transition.matrix Numeric matrix; the transition matrix entered into the function.
#' @slot n.stages Numeric; the number of stages specified.
#' @slot cat.item.bank The CAT-stage item bank as supplied, stored for post-hoc trajectory reconstruction.
#' @slot mst.item.bank The MST-stage item bank as supplied, stored for post-hoc trajectory reconstruction.
#' @slot mst.modules The item-to-module mapping matrix for the MST portion, stored for post-hoc trajectory reconstruction.
#' @slot method Character; the provisional estimation method used during administration (distinct from `final.theta.method`).
#' @slot model The IRT model specification used during administration (`NULL` for dichotomous).
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @importFrom methods new
#'
#' @return An S4 object of class `HAT`.
#' @export
#'
setClass('HAT',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate = 'numeric',
             final.theta.method = 'character',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             modules.seen = 'matrix',
             final.responses = 'matrix',
             transition.matrix = 'matrix',
             n.stages = 'numeric',
             cat.item.bank = 'ANY',
             mst.item.bank = 'ANY',
             mst.modules = 'ANY',
             method = 'character',
             model = 'ANY',
             runtime = 'ANY'
           )
)

setMethod('show',
          signature = 'HAT',
          definition = function(object) {
            Original.Call = object@function.call
            Total.Time = object@runtime
            Average.Theta = mean(object@final.theta.estimate)
            Average.SEM = mean(object@final.theta.SEM, na.rm = T)
            Path.Taken = apply(object@modules.seen, 1, FUN = function(object) paste0(object, collapse = '-'))
            Most.Path = table(Path.Taken)[which(table(Path.Taken)==max(table(Path.Taken)))]

            line0 = c("Test Format: Hybrid Adaptive Test")
            line1 = Original.Call
            line2 = paste0("Total Run Time: ", round(Total.Time[[1]], 3), " ", attr(Total.Time, "units"))
            line3 = paste0("Final Theta Method: ", object@final.theta.method)
            line4 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line5 = paste0("Average SEM: ", round(Average.SEM, 3))
            line6 = paste0("Most Common Path(s) Taken: ", attr(Most.Path, 'names'), " taken by ", Most.Path, " subjects")

            cat(paste0(c(line0, line1, line2, line3, line4, line5, line6), collapse = "\n"))
          })
