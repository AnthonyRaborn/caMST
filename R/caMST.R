#' \code{caMST} package
#'
#' Computer Adaptive Mutistage Test Analysis
#'
#' See the README on \href{https://github.com/AnthonyRaborn/caMST#readme}{GitHub} for more information.
#'
#' @docType package
#' @name ShortForm
NULL


#' Create Package Startup Message
#'
#' Makes package startup message.
#'
#' Idea taken from https://github.com/ntguardian/MCHT/blob/master/R/StartupMessage.R
#'
#' @examples
#' caMST:::caMSTStartup()

caMSTStartup <- function() {
  caMST <- c("
             ___  ___ _____  _____
             |  \\/  |/  ___||_   _|
  ___   __ _ | .  . |\\ `--.   | |
 / __| / _` || |\\/| | `--. \\  | |
| (__ | (_| || |  | |/\\__/ /  | |
 \\___| \\__,_|\\_|  |_/\\____/   \\_/
     ")
  version <- paste("\tVersion", as.character(utils::packageVersion("caMST")))
  penguin <- c("\t (^<", "\t //\\    _", "\t V_/_ ><_>")
  message <- c(caMST, version, penguin)

  cat(message, sep = "\n")
}

#' Package Attach Hook Function
#'
#' Hook triggered when package attached.
#'
#' Idea taken from https://github.com/ntguardian/MCHT/blob/master/R/StartupMessage.R
#'
#' @param lib a character string giving the library directory where the package
#'            defining the namespace was found
#' @param pkg a character string giving the name of the package
#' @examples
#' caMST:::.onAttach(.libPaths()[1], "caMST")

.onAttach <- function(lib, pkg) {
  msg <- caMSTStartup()
  if (!interactive())
    msg[1] <- paste("Package 'caMST' version", packageVersion("caMST"))
  packageStartupMessage(msg)
  invisible()
}
