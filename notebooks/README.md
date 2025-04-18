
# R Code Repository 📊

This repository contains reusable, annotated R notebooks and scripts for common workflows in development research, MEL, and policy-linked data analysis. Each notebook is runnable out of the box with included sample data.

---

## 📁 Contents

| Notebook | Purpose |
|----------|---------|
| `Survey_Education_Summary.Rmd` | Apply survey weights, compute education outcomes |
| `Care_TimeUse_Analysis.Rmd` | Analyse gendered time use for paid/unpaid/rest |
| `SROI_Walkthrough.Rmd` | Estimate and visualise Social Return on Investment |
| `Cluster_HealthFacilities.Rmd` | Segment health facilities using k-means clustering |
| `Spatial_Autocorrelation.Rmd` | Compute Moran’s I for spatial vulnerability data |
| `Auto_Report_Template.Rmd` | Generate automated program summary reports |
| `Explore_Missing_Data.Rmd` | Visualise and handle missing data using `naniar` |
| `Reshape_Wide_Long.Rmd` | Convert indicator data from wide to long format |

Each notebook uses tidyverse conventions and is structured with section headers, inline tests, and visual outputs.

---

## ▶️ How to Run

1. Open any `.Rmd` file in RStudio.
2. Click **"Knit"** to render an HTML report.
3. Or run from the console:  
   ```r
   rmarkdown::render("filename.Rmd")
   ```

Ensure the matching `.csv` file is in your working directory.

---

## 🔍 Requirements

- R ≥ 4.0
- R packages: `tidyverse`, `survey`, `srvyr`, `ggplot2`, `sf`, `spdep`, `naniar`, `rmarkdown`, `factoextra`, `cluster`, `knitr`

---

## 📬 Contact

- **Email**: varna[DOT]sr [AT] gmail [DOT] com  
- **Website**: [varnasr.github.io](https://varnasr.github.io)

You're welcome to fork, remix, adapt — and let me know how you're using it!

