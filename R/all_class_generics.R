#' An S4 class for computerized adaptive tests
#'
#' @slot function.call The original function call.
#' @slot final.theta.estimate.catR Numeric vector of theta estimates calculated by the provided `method`.
#' @slot eap.theta Numeric vector of theta estimates calculated by `catR::eapEst`.
#' @slot final.theta.Baker Numeric vector of theta estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.theta.SEM Numeric vector of SEM estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @return An S4 object of class `cat`.
#' @export
#'
setClass('cat',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate.catR = 'numeric',
             eap.theta = 'numeric',
             final.theta.Baker = 'numeric',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             final.responses = 'matrix',
             runtime = 'ANY'
           )
         )

setMethod('print',
          signature = 'cat',
          definition = function(x) {
            Original.Call = x@function.call
            # Original.Call = strwrap(paste0("Function call: computerized_adaptive_test",
            #                                gsub("^list", "", Original.Call)),
            #                         exdent = 4)
            Total.Time = x@runtime
            Average.Theta = mean(x@final.theta.estimate.catR)
            Average.SEM = mean(x@final.theta.SEM, na.rm = T)
            Average.Items = mean(apply(x@final.items.seen, 1, FUN = function(x) sum(!is.na(x))))

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
#' @slot final.theta.estimate.catR Numeric vector of theta estimates calculated by the provided `method`.
#' @slot eap.theta Numeric vector of theta estimates calculated by `catR::eapEst`.
#' @slot final.theta.Baker Numeric vector of theta estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.theta.SEM Numeric vector of SEM estimates calculated by the internal `iterative.theta.estimate` function.
#' @slot final.items.seen Character matrix of the final items seen by each individual.
#' @slot modules.seen Numeric matrix of the modules seen by each individual.
#' @slot final.responses Numeric matrix of the response patterns observed.
#' @slot runtime A `difftime` object of the total run time of the function.
#'
#' @return An S4 object of class `mst`.
#' @export
#'
setClass('mst',
         slots =
           list(
             function.call = 'call',
             final.theta.estimate.catR = 'numeric',
             eap.theta = 'numeric',
             final.theta.Baker = 'numeric',
             final.theta.SEM = 'numeric',
             final.items.seen = 'matrix',
             modules.seen = 'matrix',
             final.responses = 'matrix',
             runtime = 'ANY'
           )
)

setMethod('print',
          signature = 'mst',
          definition = function(x) {
            Original.Call = x@function.call
            # Original.Call = strwrap(paste0("Function call: ",
            #                                Original.Call, sep = ""),
            #                         exdent = 4)
            Total.Time = x@runtime
            Average.Theta = mean(x@final.theta.estimate.catR)
            Average.SEM = mean(x@final.theta.SEM, na.rm = T)
            # Average.Items = mean(apply(x@final.items.seen, 1, FUN = function(x) sum(!is.na(x))))
            Path.Taken = apply(x@modules.seen, 1, FUN = function(x) paste0(x, collapse = '-'))
            Most.Path = table(Path.Taken)[which(table(Path.Taken)==max(table(Path.Taken)))]

            line0 = c("Test Format: Multistage Adaptive Test")
            line1 = Original.Call
            line2 = paste0("Total Run Time: ", round(Total.Time[[1]], 3), " ", attr(Total.Time, "units"))
            line3 = paste0("Average Theta Estimate: ", round(Average.Theta, 3))
            line4 = paste0("Average SEM: ", round(Average.SEM, 3))
            line5 = paste0("Most Common Path Taken: ", attr(Most.Path, 'names'), " taken by ", Most.Path, " subjects")

            cat(paste0(c(line0, line1, line2, line3, line4, line5), collapse = "\n"))
          })
