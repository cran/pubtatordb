#' List the column names for a table in the PubTator sqlite database
#'
#' @inheritParams pt_tables
#' @param table_name The name of the table of interest. Valid tables can be
#'   found using pt_tables. Capitalization does not matter.
#'
#' @return A character vector of the column names for a given table.
#' @export
#'
#' @examples
#' \donttest{
#' db_con <- pt_connector(pt_path)
#' pubtator_columns(db_con, "gene")
#' }
pt_columns <- function(db_con, table_name){
  tryCatch(
    {
      table_name <- tolower(table_name)
      if(!(table_name %in% pt_tables(db_con))){
        stop("Table not found.")
      }
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("Verify that this table is in the database by using pt_tables")
    }
  )
  tryCatch(
    {
      out <- DBI::dbListFields(db_con, table_name)
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("Failed to call DBI::dbListFields")
    }
  )
  return(out)
}
