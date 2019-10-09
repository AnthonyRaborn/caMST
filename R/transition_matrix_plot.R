#' Transition Matrix Plot
#'
#' Given a transition matrix and the number of modules at each stage, produces a plot
#' that demonstrates the potential paths through a (mixed) multistage test.
#'
#' @param object Either an S4 object of class `"MST"` or class `"MAT"`, or a matrix describing how individuals can transition from one stage to the next. If an S4 object is provided, the `transition.matrix` slot is used to create the plot.
#' @param n_stages A numeric value indicating how many stages are used in the (mixed) multistage test. If an S4 object is provided, this value is taken from the object and the input value is ignored.
#'
#' @return A plot using the current graphic device.
#' @export
#'
#' @examples
#' # Create a plot for a multistage test with a 1-3-3 design
#' data('example_transition_matrix')
#' transition_matrix_plot(example_transition_matrix, n_stages =  3)
#'
#' \donttest{
#' # Save the plot as a png file.
#' png("Example 1-3-3 Transition Matrix Plot.png")
#' transition_matrix_plot(example_transition_matrix, n_stages = 3)
#' title("Transition Matrix for a 1-3-3 Design MST")
#' dev.off()
#'
#' # Use the `results` object from the `mixed_adaptive_test()` example to create
#' # a transition matrix plot and save as a .pdf file.
#' pdf("MAT Transition Matrix.pdf")
#' transition_matrix_plot(results)
#' title("Transition Matrix from the mixed_adaptive_test Example")
#' dev.off()
#' }
#'

transition_matrix_plot = function(object = NULL, n_stages = NULL) {

  if (!is.null(object) & (class(object)=="MST"|class(object)=="MAT")) {
    transition_matrix = object@transition.matrix
    n_stages = object@n.stages
  } else {
    transition_matrix = object
  }

  modules_each_stage = vector('list', length = n_stages)
  modules_each_stage[[1]] = which(colSums(transition_matrix)==0) # which modules are routing
  for (i in 2:n_stages){
    if (is.matrix(transition_matrix[modules_each_stage[[i-1]],])) {
      modules_each_stage[[i]] = which(colSums(transition_matrix[modules_each_stage[[i-1]],])>0)
    }
    else {
      modules_each_stage[[i]] = which(transition_matrix[modules_each_stage[[i-1]],]>0)
    }
  }
  n_each_stage = sapply(modules_each_stage, length)
  source = rep(1:nrow(transition_matrix), times = rowSums(transition_matrix))
  target = vector(length = 0)
  for (i in 1:nrow(transition_matrix)) {
    target =
      c(target, which(transition_matrix[i,]==1))
    }

  paths = data.frame(cbind(source, target))
  diagram::openplotmat()
  pos = diagram::coordinates(n_each_stage)
  for (i in 1:nrow(paths)) {
    diagram::splitarrow(from = pos[paths[i,1],],
                        to = pos[paths[i,2],],
                        endhead = T,
                        dd = .55,
                        arr.type = 'triangle')
  }
  for (i in 1:nrow(pos)) {
    diagram::textrect(mid = pos[i,],
                      radx = .10,
                      rady = .05,
                      cex = 1,
                      lab = paste0("Module ", i),
                      box.col = "#EEEEEE")
  }

    }
