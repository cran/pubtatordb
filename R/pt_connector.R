#' Connect to pubtator.sqlite
#'
#' @inheritParams pt_to_sql
#'
#' @return A SQLiteConnection
#' @export
#'
#' @examples
#' \donttest{
#' pt_connector("D:/Reference_data/PubTator")
#' }
pt_connector <- function(pt_path){
  # Create the path to the database file.
  db_path <- make_pubtator_sqlite_path(pt_path)

  # Notify the user if the database does not exist.
  db_exists <- file.exists(db_path)
  if(!db_exists){
    stop(paste0("Database does not exist: ", db_path, ".\nSee pt_to_sql"))
  }

  # Attempt to create a connection to the database.
  tryCatch(
    {
      db_con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop(paste0("Connection to database failed: ", db_path))
    }
  )

  # Return the connection if nothing above failed.
  return(db_con)
}
