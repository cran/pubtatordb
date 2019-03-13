#' Create sqlite database from the pubtator data.
#'
#' @param pt_path A character string indicating the full path of the
#'   directory containing the pubtator gz files to be extracted.
#' @param skip_behavior TRUE/FALSE indicating whether the file should be
#'   re-extracted if it has already been extracted.
#' @param remove_behavior TRUE/FALSE indicating whether the gz files should be
#'   removed following successful extraction.
#'
#' @export
#'
#' @examples
#' \donttest{
#' download_path <- tempdir()
#' current_dir <- getwd()
#' setwd(download_path)
#' pt_to_sql("PubTator")
#' setwd(current_dir)
#' }
pt_to_sql <- function(
  pt_path,
  skip_behavior = TRUE,
  remove_behavior = FALSE
){
  # Define internal parameter.
  db_from_scratch <- TRUE

  # Check the flag inputs
  assertthat::is.flag(skip_behavior)
  assertthat::is.flag(remove_behavior)

  # Create a database connection.
  # Remove existing database if requested.
  db_path <- make_pubtator_sqlite_path(pt_path)
  db_exists <- file.exists(db_path)
  if(db_from_scratch && db_exists){
    tryCatch(
      {
        unlink(db_path, force = TRUE)
      },
      error = function(e){
        message(paste0("Error:\n", e, "\n"))
        stop("Could not remove database: ", db_path)
      }
    )
  }
  tryCatch(
    {
      db_con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop(paste0("Connection to database failed: ", db_path))
    }
  )

  # Define tables of interest.
  tables <- pubtator_tables()

  for(i in seq_along(tables)){
    # Retrieve information for the current table.
    current_table_name <- names(tables[i])
    current_file_prefix <- as.vector(tables[i])

    # Notify the user what is being worked on.
    message(paste0("\n\nWorking on: ", current_table_name))

    # Create path_strings.
    file_gz <- file.path(pt_path, paste0(current_file_prefix, ".gz"))
    file_path <- file.path(pt_path, current_file_prefix)
    file_tmp <- file.path(pt_path, paste0(current_file_prefix, ".tmp"))

    # Remove the tmp file if it exists.
    tryCatch(
      {
        if(file.exists(file_tmp)){
          unlink(file_tmp, force = TRUE)
        }
      },
      error = function(e){
        message(paste0("Error:\n", e, "\n"))
        stop(paste0("Removal of file failed: ", file_tmp))
      }
    )

    # Check for file existence.
    file_gz_exists <- file.exists(file_gz)
    file_extracted_exists <- file.exists(file_path)
    if(file_extracted_exists && skip_behavior){
      message(paste0("File already extracted: ", file_path))
      if(file_gz_exists && remove_behavior){
        message(paste0("Removing file: ", file_gz))
        tryCatch(
          {
            unlink(file_gz, force = TRUE)
            message(paste0("File removed: ", file_gz))
          },
          error = function(e){
            DBI::dbDisconnect(db_con)
            message(paste0("Error:\n", e, "\n"))
            message(paste0("File removal failed: ", file_gz))
          }
        )
      }
      # Skip to the next file.
      if(!db_from_scratch) next
    }
    skip_extraction <- FALSE
    if(
      (!file_gz_exists && file_extracted_exists && skip_behavior) ||
      (skip_behavior && file_extracted_exists)
    ){ # Skip if gz file not found.
      message(paste0("Skipping extraction of: ", file_gz))
      skip_extraction <- TRUE
    }
    if(!db_from_scratch && !file_extracted_exists) next

    # Extract the file.
    if(!skip_extraction){
      tryCatch(
        {
          message(paste0("Extracting file: ", file_gz))
          R.utils::gunzip(
            filename = file_gz,
            destname = file_path,
            skip = skip_behavior,
            overwrite = TRUE,
            remove = remove_behavior
          )
          message("Extraction successful.")
        },
        error = function(e){
          DBI::dbDisconnect(db_con)
          message(paste0("Error:\n", e, "\n"))
          stop(paste0("Extraction failed for: ", file_gz))
        }
      )
    }

    # Determine the number of columns in the file.
    num_cols <- length(unlist(strsplit(readLines(file_path, n = 1), "\t")))

    # Load a single row then remove it to create a template for the sqlite db.
    df <- readr::read_tsv(
      file_path,
      n_max = 1,
      col_types = paste0(rep("c", num_cols), collapse = "")
    )
    # Change NCBI_Gene to ENTREZID if it is present.
    if("NCBI_Gene" %in% colnames(df)){
      df <- dplyr::rename(df, ENTREZID = "NCBI_Gene")
    }
    # Convert column names to upper case.
    colnames(df) <- toupper(colnames(df))
    # Remove the data to retain only the template header.
    df <- df[-1,]

    # Initialize the table.
    message(paste0("Creating table: ", current_table_name))
    tryCatch(
      {
        DBI::dbWriteTable(db_con, current_table_name, df, overwrite = TRUE)
      },
      error = function(e){
        DBI::dbDisconnect(db_con)
        message(paste0("Error:\n", e, "\n"))
        stop(paste0("Table creation failed: ", current_table_name))
      }
    )

    # Append data from the file to the table.
    message(paste0("Inserting data into table: ", current_table_name))
    message("This may take a while.")
    tryCatch(
      {
        DBI::dbWriteTable(
          conn = db_con,
          name = current_table_name,
          value = file_path,
          field.types = NULL,
          overwrite = FALSE,
          append = TRUE,
          header = FALSE,
          colClasses = NA,
          row.names = FALSE,
          sep = "\t",
          eol = "\n",
          temporary = FALSE,
          skip = 1
        )
      },
      error = function(e){
        DBI::dbDisconnect(db_con)
        message(paste0("Error:\n", e, "\n"))
        stop(paste0("Data insertion failed for table: ", current_table_name))
      }
    )

    # Notify the user that the table was created successfully.
    message(paste0("Table created: ", current_table_name))

    # Attempt to remove the unzipped file if requested.
    if(remove_behavior){
      tryCatch(
        {
          unlink(file_path, force = TRUE)
          message("Removing extracted file.")
        },
        error = function(e){
          DBI::dbDisconnect(db_con)
          message(paste0("Error:\n", e, "\n"))
          stop(paste0("File removal failed: ", file_path))
        }
      )
    }

    # Notify the user of progress.
    message(paste0("Finished processing: ", current_table_name))
  }


  # Disconnect from the database.
  DBI::dbDisconnect(db_con)
  message(paste0("\n\nDabase created successfully: ", db_path))
  message(paste0("Connect to it using pt_connector"))

  pubtator_citations()
}
