#' Example items for the CAT stage of an example adaptive test.
#'
#' A data frame formatted in the style required by \pkg{mstR} for item data.
#' Represents items to be used in an item-level adaptation portion of a
#' computerized adaptive test.
#'
#' @format A data frame with 564 rows (items) and 6 columns (item parameters):
#' \describe{
#' \item{a}{item discrimination}
#' \item{b}{item difficulty}
#' \item{c}{item guessing}
#' \item{u}{item carelessness}
#' \item{content_ID}{what content area the item comes from}
#' \item{stage}{which stage the item belongs to}
#' }
#'
"cat_items"

#' Example items for the MST stages of an example adaptive test.
#'
#' A data frame formatted in the style required by \pkg{mstR} for item data.
#' Represents items to be used in module-level adaptation portions of a
#' computerized adaptive test.
#'
#' @format A data frame with 564 rows (items) and 6 columns (item parameters):
#' \describe{
#' \item{a}{item discrimination}
#' \item{b}{item difficulty}
#' \item{c}{item guessing}
#' \item{u}{item carelessness}
#' \item{content_ID}{what content area the item comes from}
#' \item{stage}{which stage the item belongs to}
#' }
#'
"mst_items"

#' Example "item-to-module" map matrix, showcasing how the items and modules are related.
#'
#' A matrix with items on the rows and modules on the columns, where 0 indicates
#' the item and module are unrelated and 1 indicates that the item is a part of
#' that module. Used in combination with a transition matrix to describe a
#' multistage adaptive test.
"example_module_items"

#' Example transition matrix showing how individuals traverse the multistage test.
#'
#' A matrix with modules on the rows and columns. A 0 indicates that an individual
#'  cannot move from the row module to the column module, while a 1 indicates that
#'  an individual who has completed the row module can potentially transition
#'  into the column module.
"example_transition_matrix"

#' Theta values used in the examples.
#'
#' A numeric vector with five simulated theta values.
"example_thetas"

#' Responses to all of the example items by the five individuals represented in
#' the "example_thetas" data.
#'
#' A data frame with individuals on the rows and items on the columns. The
#' values of the data frame are the response patterns of the individuals to all
#' of the items in the example item files.
"example_responses"

#' The matrix of items used in the "multistage_test" example.
#'
#' A data frame formatted in the style required by \pkg{mstR} for item data.
#' Represents items to be used in an item-level adaptation portion of a
#' computerized adaptive test.
#'
#' @format A data frame with 564 rows (items) and 6 columns (item parameters):
#' \describe{
#' \item{a}{item discrimination}
#' \item{b}{item difficulty}
#' \item{c}{item guessing}
#' \item{u}{item carelessness}
#' \item{content_ID}{what content area the item comes from}
#' }
"mst_only_items"

#' Example "item-to-module" map matrix for the "multistage_test" example.
#'
#' A matrix with items on the rows and modules on the columns, where 0 indicates
#' the item and module are unrelated and 1 indicates that the item is a part of
#' that module. Used in combination with a transition matrix to describe a
#' multistage adaptive test.
"mst_only_matrix"
