# FieldStack

**Reusable R notebooks, scripts, and tools for applied data work and evaluation.**

[![Part of OpenStacks](https://img.shields.io/badge/Part%20of-OpenStacks-blue)](https://openstacks.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Built for use in the field — across health, gender, climate, and education programs in South Asia.

---

## What This Is

FieldStack is a collection of **R notebooks, scripts, and sample data** for applied research and evaluation work. It covers survey design, regression analysis, qualitative coding, cost-effectiveness analysis, data visualisation, and reporting — all grounded in real South Asian fieldwork needs.

This is the **applied research layer** of [OpenStacks for Change](https://openstacks.dev) — an open ecosystem of tools for public interest research and evaluation.

## What's Inside

| Directory | What It Contains |
|-----------|-----------------|
| `notebooks/` | Quarto/R Markdown notebooks for common analysis tasks |
| `regression/` | Regression templates with interaction terms, multicollinearity checks |
| `evaluation/` | Cost-effectiveness analysis, SROI calculators, evaluation frameworks |
| `survey-design/` | Survey sampling, questionnaire design, power calculations |
| `survey_tools/` | Data reshaping, cleaning, and transformation utilities |
| `qualitative/` | Qualitative coding examples and mixed-methods templates |
| `custom_viz/` | Bullet charts, waterfall charts, maps, and custom ggplot themes |
| `visualisation/` | Standard visualisation templates and chart recipes |
| `tidyverse/` | Tidyverse-based data wrangling recipes |
| `simulation/` | Monte Carlo and simulation scripts for evaluation design |
| `codebook_templates/` | Codebook generation from survey instruments |
| `automated_reporting/` | Automated report generation workflows |
| `python_integration/` | R-Python interop via reticulate |
| `stata/` | Stata companion scripts for cross-platform workflows |
| `sql/` | SQL queries for database-backed analysis |
| `tableau/` | Tableau-ready data exports and connection templates |
| `sample_data/` | Practice datasets for testing (anonymised, realistic) |
| `scripts/` | Standalone utility scripts |
| `utils/` | Helper functions and shared utilities |
| `tests/` | Test scripts for validation |
| `workflows/` | End-to-end workflow guides |

## Getting Started

### Prerequisites

- **R 4.0+** with RStudio or VS Code
- **Key packages:** tidyverse, haven, survey, ggplot2, quarto
- **Optional:** reticulate (for Python integration), DBI (for SQL)

### Quick Start

```r
# Clone and explore
git clone https://github.com/Varnasr/FieldStack.git
cd FieldStack

# Open any notebook in RStudio
# Start with notebooks/ for guided analysis examples
# Use sample_data/ to test before using your own data
```

### Typical Workflow

1. Pick a notebook from `notebooks/` that matches your analysis need
2. Load sample data from `sample_data/` to test the workflow
3. Replace with your own data and adapt the analysis
4. Use `custom_viz/` for publication-ready charts
5. Generate reports with `automated_reporting/`

## How It Connects

FieldStack is one of several stacks in the [OpenStacks](https://openstacks.dev) ecosystem:

| Stack | Focus | Link |
|-------|-------|------|
| [InsightStack](https://github.com/Varnasr/InsightStack) | MEL tools, calculators, documentation | Knowledge systems |
| **FieldStack** (this repo) | R notebooks for fieldwork & evaluation | You are here |
| [EquityStack](https://github.com/Varnasr/EquityStack) | Python workflows for development data | Data pipelines |
| [SignalStack](https://github.com/Varnasr/SignalStack) | Research Rundown newsletter archive | Knowledge curation |

**Use FieldStack when** you need R-based analysis tools. Use **EquityStack** for Python/Jupyter equivalents. Use **InsightStack** for Stata tools and MEL calculators.

## Contributing

Contributions welcome — especially from field researchers and evaluators. See [CONTRIBUTING.md](CONTRIBUTING.md).

Useful contributions include:
- R notebooks from your own evaluation work (anonymised)
- New visualisation recipes for development data
- Survey design templates and sampling frameworks
- Bug fixes and documentation improvements

## Citation

```bibtex
@software{fieldstack,
  author = {Sri Raman, Varna},
  title = {FieldStack: R Tools for Applied Development Research},
  url = {https://github.com/Varnasr/FieldStack}
}
```

## License

MIT — free to use, modify, and share. See [LICENSE](LICENSE).

---

**Created by [Varna Sri Raman](https://github.com/Varnasr)** — Development Economist & Social Researcher
