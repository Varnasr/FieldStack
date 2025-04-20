![FieldStack banner](https://raw.githubusercontent.com/Varnasr/FieldStack/main/banner/FieldStack_banner.png)

<!-- TOC START -->
## 📚 Table of Contents

- [👋 Welcome](#👋-welcome)
- [🧠 Why FieldStack](#🧠-why-fieldstack)
- [🧪 How to Use](#🧪-how-to-use)
- [🧰 Featured Modules](#🧰-featured-modules)
- [📁 Folder Map](#📁-folder-map)
- [📦 Included Modules (2025)](#📦-included-modules-(2025))
- [🔗 Related](#🔗-related)
- [📊 Repository Status & Metadata](#📊-repository-status-&-metadata)
- [📜 License](#📜-license)
- [📑 Cite This](#📑-cite-this)
- [✉️ Contact](#✉️-contact)

<!-- TOC END -->

## 👋 Welcome

**FieldStack** is a personal, open-source collection of reusable R code, Quarto notebooks, and sample datasets that I’ve developed over years of working in public health, gender equity, education, climate resilience, and MEL.

It’s meant for:
- Researchers and MEL professionals needing clean, modular R logic
- Students looking for working examples tied to real development problems
- Field practitioners building quick summaries, dashboards, or insights

Every script and notebook runs out of the box using included data.  
Everything is tested, documented, and designed to reflect **real South Asian fieldwork needs**.

---


## 🧪 How to Use

- 🔁 Clone the repo or download ZIP
- 📊 Open any `.qmd` in RStudio to explore summaries
- 🧪 To run all tests:
  ```r
  source("tests/run_all_tests.R")
  ```

To export dashboard-ready CSVs, use the MEL module or edit any notebook’s output block.

---


## 🧰 Featured Modules

Explore working, documented code across:

- 📊 **Evaluation**: [`cost_effectiveness.R`](evaluation/cost_effectiveness.R) · [`sroi_calc.R`](evaluation/sroi_calc.R)
- 🧮 **Regression**: [`interaction_model.R`](regression/interaction_model.R) · [`multicollinearity_check.R`](regression/multicollinearity_check.R)
- 🧠 **Qualitative**: [`qual_coding_example.R`](qualitative/qual_coding_example.R)
- 🐍 **Python Integration**: [`reticulate_example.R`](python_integration/reticulate_example.R)
- 📍 **Visualization**: [`bullet_chart.R`](custom_viz/bullet_chart.R) · [`waterfall_chart.R`](custom_viz/waterfall_chart.R) · [`map_visualisation_sf.R`](custom_viz/map_visualisation_sf.R)

All scripts run out of the box and include real data or logic.
- [Repository Status & Metadata](#-repository-status--metadata)
- [Related Repositories](#-related-repositories)
- [License](#-license)

<!-- TOC END -->


# FieldStack 📊

Reusable R Scripts, Notebooks, and Sample Data for Evaluation, MEL, and Social Research

<!-- ![R tests](https://github.com/Varnasr/FieldStack/actions/workflows/r-tests.yml/badge.svg) -->
<!-- ![Quarto Render](https://github.com/Varnasr/FieldStack/actions/workflows/quarto-render.yml/badge.svg) -->
<!-- ![CI](https://github.com/Varnasr/FieldStack/actions/workflows/ci.yml/badge.svg) -->
CI workflows enabled — badge will display after first successful run

---


## 📁 Folder Map

```
FieldStack/
├── scripts/         # Core reusable R functions
├── notebooks/       # Quarto notebooks (runnable)
├── tests/           # Unit tests
├── sample_data/     # Example CSVs for each use case
├── banner/          # Banner image
```

---


## 📦 Included Modules (2025)

Each module includes:
- `scripts/`: R logic with examples
- `notebooks/`: Visual walkthroughs in `.qmd`
- `sample_data/`: District-level datasets
- `tests/`: Validation with `testthat`

| Sector       | Notebook                            | Description                                                                 |
|--------------|--------------------------------------|-----------------------------------------------------------------------------|
| Gender       | `gender_labour_summary.qmd`         | Weighted female employment summary from survey-style data                  |
| Public Health| `public_health_index.qmd`           | Health access index using PHC, CHC, and subcentre availability             |
| Education    | `education_summary.qmd`             | District- and gender-wise school pass rates                                |
| Climate      | `climate_risk_summary.qmd`          | Vulnerability index using flood, drought, and temperature variability      |
| MEL          | `mel_dashboard_summary.qmd`         | Wide-to-long reshaping for Power BI/Looker dashboards                      |

---


## 🔗 Related

🌐 Also see:  
**EquityStack** → Python + Jupyter + Notebooks for social data  
🔗 [github.com/Varnasr/EquityStack](https://github.com/Varnasr/EquityStack)

---


## 📊 Repository Status & Metadata

[![License: MIT](https://img.shields.io/badge/License-MIT-blue?label=license)](LICENSE)  
[![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen?label=2025)]()

---


## 📜 License

MIT License — feel free to fork, reuse, or build on this work.

---


## 📑 Cite This

> Sri Raman, V. (2025). *FieldStack: Reproducible R Code for MEL, Evaluation, and Social Data*. Zenodo. https://doi.org/10.5281/zenodo.15250764

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15250764.svg)](https://doi.org/10.5281/zenodo.15250764)

```bibtex
@software{sriraman_fieldstack_2025,
  author       = {Varna Sri Raman},
  title        = {FieldStack: Reproducible R Code for MEL, Evaluation, and Social Data},
  year         = 2025,
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.15250764},
  url          = {https://doi.org/10.5281/zenodo.15250764}
}
```

---


## ✉️ Contact

- 📧 varna[DOT]sr [AT] gmail [DOT] com  
- 🌐 [varnasr.github.io](https://varnasr.github.io)  
- 🧵 [Threads](https://www.threads.net/@varnasriraman)  
- 💼 [LinkedIn](https://www.linkedin.com/in/varna)

---


