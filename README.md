# FieldStack

**Reusable R notebooks, scripts, and tools for applied data work and evaluation.**

[![Part of OpenStacks](https://img.shields.io/badge/Part%20of-OpenStacks-blue)](https://openstacks.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15250764.svg)](https://doi.org/10.5281/zenodo.15250764)

> Built for use in the field — across health, gender, climate, and education programs in South Asia.

---

## What This Is

FieldStack is a collection of **R notebooks, scripts, and sample data** for applied research and evaluation work. It covers regression analysis, cost-effectiveness, qualitative coding, data visualisation, and reporting — all grounded in real South Asian fieldwork needs.

This is the **applied research layer** of [OpenStacks for Change](https://openstacks.dev) — an open ecosystem of tools for public interest research and evaluation.

## What's Inside

### Core Scripts

| Directory | What It Does | Status |
|-----------|-------------|--------|
| `scripts/` | Index functions: health access, climate vulnerability, education outcomes, MEL reshaping | Ready |
| `notebooks/` | 4 Quarto notebooks: education summary, public health index, climate risk, MEL dashboard | Ready |
| `regression/` | Logistic models, interaction terms, multicollinearity checks (VIF) | Ready |
| `evaluation/` | SROI calculators, cost-effectiveness, qual-to-quant conversion, evaluation summaries | Ready |
| `custom_viz/` | Waterfall charts, bullet charts, sf map visualisation | Ready |
| `visualisation/` | ggplot2 dashboard bars, faceted plots | Ready |
| `qualitative/` | Qualitative coding with quanteda (corpus, tokens, DFM) | Ready |

### Data and Testing

| Directory | What It Contains |
|-----------|-----------------|
| `sample_data/` | 4 realistic datasets: climate exposure (150 rows), health services (200), education outcomes (200), MEL indicators (100) |
| `codebook_templates/` | Variable metadata for health surveys and programme monitoring |
| `tests/` | 9 testthat unit tests covering all core functions |

### Supporting

| Directory | What It Contains |
|-----------|-----------------|
| `python_integration/` | R-Python interop via reticulate |
| `survey_tools/` | Survey data utilities |
| `automated_reporting/` | Report generation workflows |

## Getting Started

### Prerequisites

- **R 4.0+** with RStudio or VS Code
- **Key packages:** tidyverse, haven, survey, ggplot2, quarto, testthat
- **Optional:** reticulate (for Python integration), sf (for mapping)

### Quick Start

```r
# Clone and explore
git clone https://github.com/Varnasr/FieldStack.git
cd FieldStack

# Open any notebook in RStudio
# Start with notebooks/ for guided analysis examples
# Use sample_data/ to test before using your own data

# Run the test suite
source("tests/run_all_tests.R")
```

### Typical Workflow

1. Pick a notebook from `notebooks/` that matches your analysis need
2. Load sample data from `sample_data/` to test the workflow
3. Replace with your own data and adapt the analysis
4. Use `custom_viz/` for publication-ready charts
5. Generate reports with `automated_reporting/`

## How It Connects

FieldStack is one of several stacks in the [OpenStacks](https://openstacks.dev) ecosystem:

| Stack | Focus |
|-------|-------|
| [InsightStack](https://github.com/Varnasr/InsightStack) | MEL tools, calculators, documentation |
| **FieldStack** (this repo) | R notebooks for fieldwork and evaluation |
| [EquityStack](https://github.com/Varnasr/EquityStack) | Python workflows for development data |
| [SignalStack](https://github.com/Varnasr/SignalStack) | Research Rundown newsletter archive |

**Use FieldStack when** you need R-based analysis tools. Use **EquityStack** for Python/Jupyter equivalents. Use **InsightStack** for Stata tools and MEL calculators.

## Contributing

Contributions welcome — especially from field researchers and evaluators. See [CONTRIBUTING.md](CONTRIBUTING.md).

High-impact areas:
- **Survey design** — sample size calculators, PSU allocation, sampling frameworks
- **Simulation** — Monte Carlo scripts for evaluation design
- **Visualisation** — heatmaps, treemaps, time series templates
- R notebooks from your own evaluation work (anonymised)

## Citation

```bibtex
@software{fieldstack,
  author = {Sri Raman, Varna},
  title = {FieldStack: R Tools for Applied Development Research},
  url = {https://github.com/Varnasr/FieldStack},
  doi = {10.5281/zenodo.15250764}
}
```

## License

MIT — free to use, modify, and share. See [LICENSE](LICENSE).

---

Part of [OpenStacks for Change](https://openstacks.dev). Created by [Varna Sri Raman](https://on-web.link/varna).
