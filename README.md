![FieldStack banner](banner/FieldStack_banner.png)  

<!-- TOC START -->
## 📚 Table of Contents

- [What’s Inside](#-whats-inside)
- [How to Use](#-how-to-use)
- [Citation](#-citation)
- [Repository Status & Metadata](#-repository-status--metadata)
- [Related Repositories](#-related-repositories)
- [License](#-license)

<!-- TOC END -->


# FieldStack 📊

Reusable R Scripts, Notebooks, and Sample Data for Evaluation, MEL, and Social Research

![R tests](https://github.com/Varnasr/FieldStack/actions/workflows/r-tests.yml/badge.svg)
![Quarto Render](https://github.com/Varnasr/FieldStack/actions/workflows/quarto-render.yml/badge.svg)
<!-- [![CI](https://github.com/Varnasr/FieldStack/actions/workflows/ci.yml/badge.svg)](...) -->
CI workflow enabled (badge will display after first successful run)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15250764.svg)](https://doi.org/10.5281/zenodo.15250764)

---

## 👋 Welcome

**FieldStack** is a personal, open-source collection of reusable R code, Quarto notebooks, and sample datasets that I’ve developed over years of working in public health, gender equity, education, climate resilience, and MEL.

It’s meant for:
- Researchers and MEL professionals needing clean, modular R logic
- Students looking for working examples tied to real development problems
- Field practitioners building quick summaries, dashboards, or insights

Every script and notebook runs out of the box using included data.  
Everything is tested, documented, and designed to reflect **real South Asian fieldwork needs**.

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

## 🧪 How to Use

- 🔁 Clone the repo or download ZIP
- 📊 Open any `.qmd` in RStudio to explore summaries
- 🧪 To run all tests:
  ```r
  source("tests/run_all_tests.R")
  ```

To export dashboard-ready CSVs, use the MEL module or edit any notebook’s output block.

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

## 📑 Cite This

> Sri Raman, V. (2025). *FieldStack: Reproducible R Code for MEL, Evaluation, and Social Data*. Zenodo. https://doi.org/10.5281/zenodo.15250764

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

> 💡 You can also cite this repository using the Zenodo DOI badge above, or by downloading the `CITATION.cff` file.

---

## 📊 Repository Status & Metadata

[![License: MIT](https://img.shields.io/badge/License-MIT-blue?label=license)](LICENSE)  
<!-- [![CI](https://github.com/Varnasr/FieldStack/actions/workflows/ci.yml/badge.svg)](...) -->
CI workflow enabled (badge will display after first successful run)  
[![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen?label=2025)]()  
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15250764.svg)](https://doi.org/10.5281/zenodo.15250764)

---

## 🔗 Related

🌐 Also see:  
**EquityStack** → Python + Jupyter + Notebooks for social data  
🔗 [github.com/Varnasr/EquityStack](https://github.com/Varnasr/EquityStack)

---

## 📜 License

MIT License — feel free to fork, reuse, or build on this work.

---

## ✉️ Contact

- 📧 varna[DOT]sr [AT] gmail [DOT] com  
- 🌐 [varnasr.github.io](https://varnasr.github.io)  
- 🧵 [Threads](https://www.threads.net/@varnasriraman)  
- 💼 [LinkedIn](https://www.linkedin.com/in/varna)

---

## 🧠 Why FieldStack?

This repository reflects my approach to building transparent, reusable, and field-adapted tools for the social sector — especially in the Indian and South Asian context.  

I believe good evaluation tools should be:
- Easy to adapt 🧩
- Easy to test 🔍
- Easy to learn from 📚

You're welcome to explore, borrow, cite, fork — or reach out with your own use cases.

Thanks for visiting ✨  
– Varna
