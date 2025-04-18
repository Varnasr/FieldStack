
# 🗺️ FieldStack Roadmap

This document outlines the current structure, upcoming enhancements, and contribution areas for the FieldStack repository — a reusable, field-oriented R toolkit for data analysis in MEL, evaluation, and development research.

---

## 🔧 Current Capabilities (v1.0)

- ✅ 10 Quarto + RMarkdown notebooks
- ✅ All notebooks runnable with included data
- ✅ `.R` scripts for common reusable tasks
- ✅ Support for file import/export: `.csv`, `.xlsx`, `.sav`, `.dta`, `.rds`, `.RData`
- ✅ Spatial workflows using `sf`, `spdep`, and mock `.geojson` files
- ✅ Dashboard prep: Power BI, Excel, Looker Studio compatible
- ✅ Starter `shiny` app
- ✅ GitHub Actions for rendering

---

## 🚧 Planned Additions

- [ ] Modular `testthat` test suite for functions
- [ ] Examples of automated reporting to PowerPoint
- [ ] Expand `shiny/` with linked input/output logic
- [ ] Add real (anonymized) district-level public health dataset
- [ ] Add notebook comparison: `survey::svydesign()` vs `srvyr::as_survey_design()`
- [ ] Basic machine learning classification (e.g. logistic w/ LASSO)

---

## 🧠 Contributor Opportunities

- Translating notebooks to French, Hindi, Spanish
- Adding `.do` file equivalents for Stata users
- Converting scripts to Python (for a future FieldStack-Py)
- Writing tests for utility functions
- Sharing anonymized sample data

---

## 📦 Releases

- **v1.0** — Core structure, 10 notebooks, dashboards, spatial, format compatibility
- **v1.1** — Expanded shiny apps, machine learning add-on, new datasets
- **v1.2+** — Internationalisation, real field contributions

---

We welcome forks, improvements, and field-use feedback!
