#' List the tables in the PubTator sqlite database
#'
#' @param db_con A connection to the PubTator sqlite database, as created via
#'   pubator_connector.
#'
#' @return A character vector of the names of the tables found in the database.
#' @export
#'
#' @examples
#' \donttest{
#' db_con <- pt_connector(pt_path)
#' pt_tables(db_con)
#' }
pt_tables <- function(db_con){
  tryCatch(
    {
      out <- DBI::dbListTables(db_con)
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("Failed to connect to database and call DBI::dbListTables")
    }
  )
  return(out)
}
