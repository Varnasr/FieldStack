
# FieldStack 📊

Reusable R Scripts, Notebooks, and Sample Data for Applied MEL & Evaluation  
![R tests](https://github.com/Varnasr/FieldStack/actions/workflows/r-tests.yml/badge.svg)
![Quarto Render](https://github.com/Varnasr/FieldStack/actions/workflows/quarto-render.yml/badge.svg)

---

## 🔍 About This Repository

**FieldStack** is a structured collection of reproducible code and analysis tools for monitoring, evaluation, and social research projects — especially in public health, climate resilience, gender equity, and education.

This repo is designed for:
- MEL professionals needing clean, tested R code
- Students and researchers working on field-based data
- Analysts building visual summaries or dashboard exports

---

## 📦 Included Modules (2024 Update)

This version of FieldStack includes 5 complete, runnable modules — each with real `.R` scripts, runnable `.qmd` notebooks, tests, and sample data drawn from Indian district indicators.

| Sector       | Notebook                            | Description                                                                 |
|--------------|--------------------------------------|-----------------------------------------------------------------------------|
| Gender       | `gender_labour_summary.qmd`         | Weighted summary of female employment using survey-style data              |
| Public Health| `public_health_index.qmd`           | District-wise health access index combining PHC, subcentre, and CHC access |
| Education    | `education_summary.qmd`             | Pass rate visualisations by district and gender                            |
| Climate      | `climate_risk_summary.qmd`          | Vulnerability index using flood, drought, population density               |
| MEL / Dashboards | `mel_dashboard_summary.qmd`     | Wide-to-long reshaping for dashboard-ready outputs                         |

---

## 📁 Folder Structure

```
FieldStack/
├── scripts/         # R scripts with main logic
├── notebooks/       # Quarto notebooks (runnable)
├── tests/           # Unit tests using testthat
├── sample_data/     # CSVs used in examples
├── banner/          # Project banner image
```

---

## 🚀 How to Use

- ✅ All notebooks are ready-to-run with bundled data  
- 🧪 To test all scripts:
  ```r
  source("tests/run_all_tests.R")
  ```
- 📤 To export dashboards: use the MEL module or edit output steps in notebooks

---

## 🧾 Citation & Credit

If you use this repository in your work, please cite:

```bibtex
@misc{sriraman2024fieldstack,
  author       = {Varna Sri Raman},
  title        = {FieldStack: Reusable R Code for MEL, Evaluation, and Social Data},
  year         = {2024},
  howpublished = {\url{https://github.com/Varnasr/FieldStack}},
  note         = {GitHub repository}
}
```

---

## 🔗 See Also

If you're working in Python, check out the companion repository:  
**EquityStack** → [https://github.com/Varnasr/EquityStack](https://github.com/Varnasr/EquityStack)

---

## 📜 License

FieldStack is released under the MIT License — feel free to reuse, remix, and build on it.

---

## ✉️ Contact

- 📧 varna[DOT]sr [AT] gmail [DOT] com  
- 🌐 [varnasr.github.io](https://varnasr.github.io)  
- 🧵 [Threads](https://www.threads.net/@varnasriraman)  
- 💼 [LinkedIn](https://www.linkedin.com/in/varna)
