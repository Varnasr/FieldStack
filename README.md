
![FieldStack Banner](banner/FieldStack-banner.png)

# FieldStack 📊  
![R tests](https://github.com/Varnasr/FieldStack/actions/workflows/r-tests.yml/badge.svg)
![Quarto Render](https://github.com/Varnasr/FieldStack/actions/workflows/quarto-render.yml/badge.svg)

Welcome to **FieldStack** — a modular, multi-format archive of reusable code, notebooks, scripts, and utilities built for applied data work in development research, MEL (Monitoring, Evaluation & Learning), and public systems.

It is designed to be field-ready: reusable, interpretable, and easy to adapt to messy, real-world data across sectors like education, health, gender, climate, and livelihoods.

---

## 📁 Folder Structure

```
FieldStack/
├── notebooks/            # Notebooks in .Rmd and .qmd formats
├── scripts/              # Reusable R scripts
├── sample data/          # Example datasets (.csv, .xlsx, .sav, .dta, .rds, .RData)
├── spatial/              # Shapefiles and spatial data
├── dashboards/           # flexdashboard, Looker, Power BI integration
├── shiny/                # Starter shiny app
├── utils/                # Reusable helper functions
├── sql/                  # R + SQL workflow templates
├── stata/                # Stata-compatible data and guidance
├── qualitative/          # Coding summaries and conversion
├── evaluation/           # Program evaluation utilities
├── survey_tools/         # Instruments, weights, templates
├── codebook_templates/   # Documentation patterns
├── custom_viz/           # ggplot, bullet, waterfall charts
├── simulation/           # Synthetic data generators
├── tableau/              # Tableau export-ready examples
├── tidyverse/            # Core tidy data pipelines
├── .github/workflows/    # GitHub Actions
├── LICENSE
├── README.md
├── ROADMAP.md
├── CONTRIBUTING.md
├── USE_CASES.md
└── _quarto.yml
```

---

## 🧩 What You'll Find

### 🔁 Notebooks (`.qmd` + `.Rmd`)
Reusable examples using Quarto + RMarkdown:
- Weighted survey analysis
- Gender time-use
- Cost-effectiveness and SROI
- Missing data and reshaping
- Spatial analysis (Moran's I, joins, maps)
- Dashboard prep (wide→long, clean outputs)
- File format conversion (SPSS, Stata, Excel, RDS)

### 🧠 Scripts (`.R`)
Standalone modules:
- Survey tabulation
- Time-use summaries
- SROI calculation
- Spatial joins + mapping
- Excel + Looker Studio exports

### 📊 Dashboarding
- `flexdashboard` layout
- Power BI/Excel summaries
- Google Sheets-ready exports
- Looker Studio compatible `.csv`

---

## 🛠 How to Use

- Open `.qmd` in RStudio (Quarto) or `.Rmd` (Knit)
- Use `sample data/` to test notebooks out-of-the-box
- Reuse `.R` scripts in your project pipeline
- Visualize spatial outputs or export to external tools

---

## 📬 Contact

- Email: varna[DOT]sr [AT] gmail [DOT] com  
- Website: [varnasr.github.io](https://varnasr.github.io)  
- LinkedIn: [Varna Sri Raman](https://www.linkedin.com/in/varna)  
- Threads: [@varnasriraman](https://www.threads.net/@varnasriraman)

---

Thanks for visiting. Contributions welcome — this is a living repository that grows from practice.

If you use this repository in your work, please cite it as:
Sri Raman, V. (2025). *[EquityStack/FieldStack]: Reusable Tools for Applied Data Analysis and Evaluation*. GitHub. https://github.com/Varnasr/EquityStack

---

### 🔗 See Also

If you're working in Python, check out the companion repository:  
**EquityStack** → [https://github.com/Varnasr/EquityStack](https://github.com/Varnasr/EquityStack)

---

### 📜 License

FieldStack is released under the MIT License — feel free to reuse, remix, and build on it.

---

### 🟢 Run-Ready Notebooks

Notebooks marked with this symbol are ready to run out-of-the-box using the `/sample data` folder.  
No extra setup required beyond installing the standard R packages.
