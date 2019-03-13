#' Retrieve data from the PubTator database.
#'
#' @inheritParams pt_columns
#' @param columns A character vector of the names of the columns of interest.
#'   Capitalization does not matter.
#' @param keys A vector specifying which values must be in the keytype column to
#'   enable retrieval. No filtering is performed if keys = NULL.
#' @param keytype The column in which the keys should be searched for.
#' @param limit The maximum number of rows the query should return. All rows
#'   passing filtering (if any) are returned if limit = Inf.
#'
#' @return A data.frame.
#' @export
#'
#' @examples
#' \donttest{
#' db_con <- pt_connector(pt_path)
#' pt_select(
#'   db_con,
#'   "gene",
#'   columns = c("ENTREZID","Resource","MENTIONS","PMID"),
#'   keys = c("7356", "4199", "7018"),
#'   keytype = "ENTREZID",
#'   limit = 10
#' )
#' }
pt_select <- function(
  db_con,
  table_name,
  columns = NULL,
  keys = NULL,
  keytype = NULL,
  limit = Inf
){
  # Check the table_name.
  tryCatch(
    {
      table_name <- tolower(table_name)
      if(
        !is.character(table_name) &&
        !(length(table_name) == 1) &&
        !(table_name %in% tolower(pt_tables(db_con)))
      ){
        stop("")
      }
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("Possibly invalid table_name. Call pt_tables on the connection.")
    }
  )

  # Handle the keys and keytype.
  if(!is.null(keys) && !is.character(keys)){
    stop("The argument 'keys' must be a character vector.")
  }
  tryCatch(
    {
      if(is.null(keys)){
        keys_addendum <- ""
      }else{
        keytype <- toupper(keytype)
        if(!(keytype %in% toupper(pt_columns(db_con, table_name)))){
          stop("")
        }
        fixed_keys <- paste0(# Handle the presence of single quotes.
          paste0("'", gsub("'", "''", keys), "'"),
          collapse = ", "
        )
        keys_addendum <- paste0(
          ' WHERE ', keytype,
          ' IN ', paste0("(", paste0(fixed_keys, collapse = ", "), ")")
        )
      }
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("Possibly invalid keys/keytype. Call pt_columns on the connection.")
    }
  )

  # Handle the columns.
  tryCatch(
    {
      if(!is.null(columns)){
        columns <- toupper(columns)
        if(!all(columns %in% toupper(pt_columns(db_con, table_name)))){
          stop("")
        }
      }
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("Possibly invalid columns. Call pt_columns on the connection.")
    }
  )
  if(is.null(columns)) columns <- "*"

  # Check the limit.
  limit_addendum <- ""
  tryCatch(
    {
      if(
        !assertthat::is.number(limit) ||
        !((limit > 0) &&
          (is.infinite(limit) ||
           (as.integer(limit) == limit))
        )
      ){
        stop("")
      }
      if(is.finite(limit)){
        limit_addendum <- paste0(" LIMIT ", limit)
      }
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("limit must be Inf or a positive integer.")
    }
  )

  # Query the database.
  tryCatch(
    {
      out <- DBI::dbGetQuery(
        db_con,
        paste0(
          'SELECT ', paste0(columns, collapse = ", "),
          ' FROM ', table_name,
          keys_addendum,
          limit_addendum
        )
      )
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop("Failed in call to DBI::dbGetQuery")
    }
  )
  return(out)
}
