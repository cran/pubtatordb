#' See the citations for PubTator
#'
#' @aliases pubtator_citation
#'
#' @export
#'
#' @examples
#' pubtator_citations()
pubtator_citations <- function(){
  # Define the citation information.
  citations <- list(
    "1" = paste0(
      "Wei CH et. al., PubTator: a Web-based text mining tool for assisting ",
      "Biocuration, Nucleic acids research, 2013, 41 (W1): W518-W522. doi: ",
      "10.1093/nar/gkt44"
    ),
    "2" = paste0(
      "Wei CH et. al., Accelerating literature curation with text-mining ",
      "tools: a case study of using PubTator to curate genes in PubMed ",
      "abstracts, Database (Oxford), bas041, 2012"
    ),
    "3" = paste0(
      "Wei CH et. al., PubTator: A PubMed-like interactive curation system ",
      "for document triage and literature curation, in Proceedings of ",
      "BioCreative 2012 workshop, Washington DC, USA, 145-150, 2012"
    )
  )

  message("Please cite PubTator in any publications:\n")
  for(i in seq_along(citations)){
    message(paste0(i, ". ", citations[[i]]))
  }
}
