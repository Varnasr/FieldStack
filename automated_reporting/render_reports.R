# Automated Report Rendering
# Batch render Quarto/R Markdown notebooks to HTML or PDF

library(tidyverse)

#' Render a single Quarto document
#' @param input Path to .qmd file
#' @param output_format "html" or "pdf"
#' @param output_dir Output directory (default: same as input)
render_notebook <- function(input, output_format = "html", output_dir = NULL) {
  if (!file.exists(input)) {
    warning(paste("File not found:", input))
    return(invisible(NULL))
  }

  if (requireNamespace("quarto", quietly = TRUE)) {
    quarto::quarto_render(input, output_format = output_format, output_file = output_dir)
  } else if (requireNamespace("rmarkdown", quietly = TRUE)) {
    rmarkdown::render(input, output_format = paste0(output_format, "_document"),
                       output_dir = output_dir)
  } else {
    stop("Install quarto or rmarkdown package")
  }
  cat(sprintf("Rendered: %s -> %s\n", input, output_format))
}

#' Batch render all .qmd files in a directory
#' @param dir Directory to search for .qmd files
#' @param output_format "html" or "pdf"
#' @param output_dir Output directory for rendered files
#' @param recursive Search subdirectories
render_all_notebooks <- function(dir = ".", output_format = "html",
                                   output_dir = NULL, recursive = FALSE) {
  files <- list.files(dir, pattern = "\\.qmd$", full.names = TRUE, recursive = recursive)

  if (length(files) == 0) {
    cat("No .qmd files found in", dir, "\n")
    return(invisible(NULL))
  }

  cat(sprintf("Found %d notebook(s) to render:\n", length(files)))
  results <- lapply(files, function(f) {
    tryCatch({
      render_notebook(f, output_format, output_dir)
      data.frame(file = f, status = "success", stringsAsFactors = FALSE)
    }, error = function(e) {
      cat(sprintf("  FAILED: %s (%s)\n", f, e$message))
      data.frame(file = f, status = paste("failed:", e$message), stringsAsFactors = FALSE)
    })
  })

  bind_rows(results)
}

#' Generate a summary table from rendered reports
#' @param results Output from render_all_notebooks
#' @return Summary data frame
report_summary <- function(results) {
  results %>%
    mutate(
      basename = basename(file),
      rendered = status == "success"
    ) %>%
    summarise(
      total = n(),
      rendered = sum(rendered),
      failed = sum(!rendered)
    )
}

# Example usage
if (sys.nframe() == 0) {
  cat("=== Automated Report Renderer ===\n")
  cat("Usage:\n")
  cat("  source('automated_reporting/render_reports.R')\n")
  cat("  render_all_notebooks('../notebooks/', output_format = 'html')\n")
  cat("  render_notebook('path/to/notebook.qmd', 'pdf')\n")
}
