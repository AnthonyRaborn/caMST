#' An S4 class for computerized adaptive tests
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate Numeric vector of theta estimates calculated by the provided `method`.
#' @slot eap.theta Numeric vector of theta estimates calculated by `catR::eapEst`.
#' @slot final.theta.Baker Numeric vector of theta estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.theta.SEM Numeric vector of SEM estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @return An S4 object of class `CAT`.
#' @export
#'
setClass('CAT',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate = 'numeric',
             eap.theta = 'numeric',
             final.theta.Baker = 'numeric',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             final.responses = 'matrix',
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
            line3 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line4 = paste0("Average SEM: ", round(Average.SEM, 3))
            line5 = paste0("Average Number of Items Seen: ", round(Average.Items, 3))

            cat(paste0(c(line0, line1, line2, line3, line4, line5), collapse = "\n"))
            })

#' An S4 method for multistage adaptive tests.
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate Numeric vector of theta estimates calculated by the provided `method`.
#' @slot eap.theta Numeric vector of theta estimates calculated by `catR::eapEst`.
#' @slot final.theta.Baker Numeric vector of theta estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.theta.SEM Numeric vector of SEM estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot modules.seen Numeric matrix of the modules seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot transition.matrix Numeric matrix; the transition matrix entered into the function.
#' @slot n.stages Numeric; the number of stages specified.
#' @slot nc.list A list of the number correct scoring logic and method, if applicable. Defaults to `NULL`.
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @return An S4 object of class `MST`.
#' @export
#'
setClass('MST',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate = 'numeric',
             eap.theta = 'numeric',
             final.theta.Baker = 'numeric',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             modules.seen = 'matrix',
             final.responses = 'matrix',
             transition.matrix = 'matrix',
             n.stages = 'numeric',
             nc.list = 'ANY',
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
                test = is.null(object@nc.list$method)|
                  object@nc.list$method!="module_sum",
                yes  = c("Test Format: Multistage Adaptive Test with Cumulative Summation Scoring"),
                no   = c("Test Format: Multistage Adaptive Test with Module Summation Scoring")
                )
              )
            line1 = Original.Call
            line2 = paste0("Total Run Time: ", round(Total.Time[[1]], 3), " ", attr(Total.Time, "units"))
            line3 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line4 = paste0("Average SEM: ", round(Average.SEM, 3))
            line5 = paste0("Most Common Path(s) Taken: ", attr(Most.Path, 'names'), " taken by ", Most.Path, " subjects")

            cat(paste0(c(line0, line1, line2, line3, line4, line5), collapse = "\n"))
          })

#' An S4 method for mixed adaptive tests.
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate Numeric vector of theta estimates calculated by the provided `method`.
#' @slot eap.theta Numeric vector of theta estimates calculated by `catR::eapEst`.
#' @slot final.theta.Baker Numeric vector of theta estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.theta.SEM Numeric vector of SEM estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot modules.seen Numeric matrix of the modules seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot transition.matrix Numeric matrix; the transition matrix entered into the function.
#' @slot n.stages Numeric; the number of stages specified.
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @return An S4 object of class `MAT`.
#' @export
#'
setClass('MAT',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate = 'numeric',
             eap.theta = 'numeric',
             final.theta.Baker = 'numeric',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             modules.seen = 'matrix',
             final.responses = 'matrix',
             transition.matrix = 'matrix',
             n.stages = 'numeric',
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
            line3 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line4 = paste0("Average SEM: ", round(Average.SEM, 3))
            line5 = paste0("Most Common Path(s) Taken: ", attr(Most.Path, 'names'), " taken by ", Most.Path, " subjects")

            cat(paste0(c(line0, line1, line2, line3, line4, line5), collapse = "\n"))
          })

