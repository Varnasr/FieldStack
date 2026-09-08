# FieldStack

**Reusable R notebooks, scripts, and tools for applied data work and evaluation.**

[![Part of OpenStacks](https://img.shields.io/badge/Part%20of-OpenStacks-blue)](https://openstacks.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15250764.svg)](https://doi.org/10.5281/zenodo.15250764)
[![Status: Stable](https://img.shields.io/badge/Status-Stable-0969da?style=flat-square)](https://github.com/Varnasr/OpenStacks-for-Change/blob/main/MAINTENANCE.md)

> For the fortnight the data is being collected, and for the analysis after. Health, gender, climate and education programmes in South Asia.

> **Status: Stable.** This repository works and is correct, but it is not under active
> development. Bug reports are welcome and issues stay open; new features are unlikely,
> and replies are measured in weeks rather than days. Dependencies are pinned deliberately
> so that a clone still runs years from now. See the [maintenance policy](https://github.com/Varnasr/OpenStacks-for-Change/blob/main/MAINTENANCE.md).

---

## What This Is

FieldStack is R for two jobs. The first is **field operations**: the checks a
supervisor runs each evening against the day's export, while the team is still
in the district and a problem can still be fixed. The second is **survey
analysis**: sample size, weights and design-based estimates once the data is in.

Around those sit smaller pieces for regression, cost-effectiveness, qualitative
coding, visualisation and reporting.

This is the **applied research layer** of [OpenStacks for Change](https://openstacks.dev) — an open ecosystem of tools for public interest research and evaluation.

## What's Inside

### Field operations

The evening run. One command against the day's export returns the cases to act
on tomorrow and the per-enumerator summary for the morning meeting.

| File | What It Does |
|---|---|
| `field_ops/daily_report.R` | The thing that gets run. Applies the whole battery and writes two CSVs |
| `field_ops/high_frequency_checks.R` | Duplicate IDs, blanks in never-skipped questions, out-of-range values, interview duration, working hours, straightlining |
| `field_ops/enumerator_monitoring.R` | Workload, missingness and "don't know" rates, leave-one-out outlier detection, daily load |
| `field_ops/back_checks.R` | Supervisor re-interview compared against the original, by question type |
| `field_ops/gps_checks.R` | Haversine distance, interviews recorded far from the assigned cluster, households sharing a coordinate |
| `field_ops/read_odk.R` | Reads an ODK/KoBo/SurveyCTO wide export: strips group prefixes, parses timestamps, converts sentinel codes, expands select_multiple |

Base R throughout, no packages, because this runs on whatever laptop is in the
district office. See `field_ops/README.md` for the five things that decide
whether it works, including why `within` is not really optional and why the
timezone argument matters more than it looks.

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
| `tests/` | 7 testthat files, 119 checks, run in CI on every pull request |

### Survey Tools

| Script | What It Does |
|--------|-------------|
| `survey_tools/sample_size_calculator.R` | Simple, stratified, and cluster sampling calculations with design effect |
| `survey_tools/sampling_weights.R` | Base weight calculation, trimming, weighted summary statistics |
| `survey_tools/survey_summary.R` | Survey design objects, weighted descriptives, proportions using the `survey` package |
| `survey_tools/dhs_stunting.R` | Worked example: DHS stunting by wealth quintile with design-based intervals, checked against the published NFHS-5 table |

### Automated Reporting

| File | What It Does |
|------|-------------|
| `automated_reporting/render_reports.R` | Batch Quarto/RMarkdown rendering with logging |
| `automated_reporting/monthly_summary.qmd` | Quarto template for monthly indicator summary with inline plots |

### Supporting

| Directory | What It Contains |
|-----------|-----------------|
| `python_integration/` | R-Python interop via reticulate |

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
| [PolicyStack](https://github.com/Varnasr/PolicyStack) | 15 flagship schemes, four years of budget data, performance indicators; superseded for new work by [PolicyDhara](https://github.com/Varnasr/PolicyDhara) |

**Use FieldStack when** you need R-based analysis tools. Use **EquityStack** for Python/Jupyter equivalents. Use **InsightStack** for Stata tools and MEL calculators.

## Contributing

Contributions welcome — especially from field researchers and evaluators. See [contributing guidelines](https://github.com/Varnasr/.github/blob/main/CONTRIBUTING.md).

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
