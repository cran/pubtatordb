#' Make a path to the PubTator sqlite file.
#'
#' @inheritParams pt_to_sql
#'
#' @return A character string indicating the full path to the sqlite file.
make_pubtator_sqlite_path <- function(pt_path){
  if(!assertthat::is.string(pt_path)){
    stop("The path is invalid.")
  }
  file.path(pt_path, "pubtator.sqlite")
}
