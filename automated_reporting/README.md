# Automated Reporting

This folder contains example scripts and templates for generating automated reports using Quarto and R. 
You can batch-render `.qmd` files to PDF/HTML using the `rmarkdown::render()` or `quarto::quarto_render()` commands.

Example:
```r
quarto::quarto_render("monthly_summary.qmd", output_format = "html")
```