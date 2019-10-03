#' Transition Matrix Plot
#'
#' Given a transition matrix and the number of modules at each stage, produces a plot
#' that demonstrates the potential paths through a (mixed) multistage test.
#'
#' @param transition_matrix A matrix describing how individuals can transition from one stage to the next.
#' @param n_each_stage A numeric vector indicating how many modules exist at each stage.
#'
#' @return A plot using the current graphic device.
#' @export
#'
#' @examples
#' # Create a plot for a multistage test with a 1-3-3 design
#' data('example_transition_matrix')
#' transition_matrix_plot(example_transition_matrix, n_each_stage = c(1,3,3))
#'
#' \donttest{
#' # Save the plot as a png file.
#' png("Example 1-3-3 Transition Matrix Plot.png")
#' transition_matrix_plot(example_transition_matrix, n_each_stage = c(1,3,3))
#' title("Transition Matrix for a 1-3-3 Design MST")
#' dev.off()
#' }
#'

transition_matrix_plot = function(transition_matrix = NULL, n_each_stage = NULL) {

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
