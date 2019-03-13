#' Download PubTator data via ftp.
#'
#' @param pubtator_parent_path The path to the directory where the PubTator data
#'   folder will be created.
#' @param ... Additional arguments to dir.create and download.file.
#'
#' @return The path to the newly created directory. This can be passed to other
#'   functions as the pt_path argument.
#' @export
#'
#' @importFrom utils download.file
#'
#' @examples
#' \donttest{
#' # Use the full path. The files are large. Writing somewhere other than the
#' # temp directory is recommended.
#' download_path <- tempdir()
#' download_pt(dowload_path)
#' }
download_pt <- function(pubtator_parent_path, ...){
  # Define the new directory path.
  if(!assertthat::is.string(pubtator_parent_path)){
    stop("pubtator_parent_path is invalid.")
  }
  pubtator_path <- file.path(pubtator_parent_path, "PubTator")

  # Remove the directory if it exists.
  if(dir.exists(pubtator_path)){
    tryCatch(
      {
        unlink(pubtator_path, recursive = TRUE, force = TRUE)
      },
      error = function(e){
        message(paste0("Error:\n", e, "\n"))
        stop(paste0("Existing directory cannot be removed: ", pubtator_path))
      }
    )
  }

  # Create a new directory.
  tryCatch(
    {
      dir.create(pubtator_path, ...)
    },
    error = function(e){
      message(paste0("Error:\n", e, "\n"))
      stop(paste0("Directory cannot be created: ", pubtator_path))
    }
  )

  # Define the files to download.
  urls <- paste0(paste0(pubtator_ftp_url(), pubtator_tables()), ".gz")
  output_paths <- file.path(pubtator_path, paste0(pubtator_tables(), ".gz"))

  # Download the files.
  message("Downloading files. This may take a while.")
  for(i in seq_along(urls)){
    # Define url and download path.
    ftp_url <- urls[i]
    output_path <- output_paths[i]

    # Attempt to download.
    tryCatch(
      {
        download.file(ftp_url, output_path, ...)
      },
      error = function(e){
        message(paste0("Error:\n", e, "\n"))
        stop(paste0("Download failed: ", ftp_url))
      }
    )
  }

  return(pubtator_path)
}
