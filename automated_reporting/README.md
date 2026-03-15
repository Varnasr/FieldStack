# Automated Reporting

R scripts and Quarto templates for generating automated field reports.

## Contents

| File | Purpose |
|------|---------|
| `render_reports.R` | Batch render Quarto notebooks to HTML/PDF |
| `monthly_summary.qmd` | Template for monthly indicator summary report |

## Usage

```r
source("automated_reporting/render_reports.R")
render_all_notebooks("../notebooks/")
```
