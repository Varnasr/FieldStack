# FieldStack

R for two jobs: the checks a survey team runs each evening while the data is
being collected, and sampling and weighted estimation once it is in. Built for
health, gender, climate and education programmes in South Asia. Part of
[OpenStacks](https://openstacks.dev). Status: Stable, per the family
[maintenance policy](https://github.com/Varnasr/OpenStacks-for-Change/blob/main/MAINTENANCE.md).
DOI: [10.5281/zenodo.15250764](https://doi.org/10.5281/zenodo.15250764).

Site: [varnasr.github.io/FieldStack](https://varnasr.github.io/FieldStack/).

## Field operations

`field_ops/` runs against the day's export and returns the cases to act on
tomorrow and a per-enumerator summary. Base R, no packages.

| File | What it does |
| --- | --- |
| `daily_report.R` | Runs the whole battery and writes two CSVs |
| `high_frequency_checks.R` | Duplicate IDs, blanks in required questions, out-of-range values, interview duration, working hours, straightlining |
| `enumerator_monitoring.R` | Workload, missingness, "don't know" rates, leave-one-out outliers, daily load |
| `back_checks.R` | Supervisor re-interview against the original, by question type |
| `gps_checks.R` | Distance from the assigned cluster, households sharing a coordinate |
| `read_odk.R` | Reads an ODK, KoBo or SurveyCTO export: group prefixes, timestamps, sentinel codes, select_multiple |

See [`field_ops/README.md`](field_ops/README.md) for usage and the settings
that matter.

## Survey tools

| Script | What it does |
| --- | --- |
| `survey_tools/sample_size_calculator.R` | Sample size for simple, stratified and cluster designs |
| `survey_tools/sampling_weights.R` | Base weights, trimming, weighted summaries |
| `survey_tools/survey_summary.R` | Design objects and weighted descriptives with the `survey` package |
| `survey_tools/dhs_stunting.R` | DHS stunting by wealth quintile with design-based intervals, checked against the published NFHS-5 table |

## Other directories

| Directory | What it holds |
| --- | --- |
| `scripts/` | Index functions: health access, climate vulnerability, education outcomes, MEL reshaping |
| `notebooks/` | Four Quarto notebooks: education, public health, climate risk, MEL dashboard |
| `regression/` | Logistic models, interaction terms, VIF |
| `evaluation/` | SROI, cost-effectiveness, qualitative-to-quantitative conversion |
| `custom_viz/`, `visualisation/` | Waterfall and bullet charts, sf maps, ggplot2 dashboards |
| `qualitative/` | Coding with quanteda |
| `automated_reporting/` | Batch Quarto rendering and a monthly summary template |
| `python_integration/` | Calling Python from R with reticulate |
| `sample_data/` | Four small datasets |
| `tests/` | testthat, 119 checks, run in CI |

Several files in `evaluation/` and `custom_viz/` are demonstration scripts
that run top to bottom rather than libraries.

## Getting started

R 4.0 or later. Packages: tidyverse, haven, survey, ggplot2, quarto, testthat.

```r
git clone https://github.com/Varnasr/FieldStack.git
source("tests/run_all_tests.R")
```

## The family

| Repository | What it is for | Language |
| --- | --- | --- |
| [InsightStack](https://github.com/Varnasr/InsightStack) | MEL tools, calculators, research documentation, loaders for survey microdata | Stata, Python, R, SPSS |
| **FieldStack** (this repository) | Field operations while a survey is in the field; sampling and weighted estimation after | R |
| [EquityStack](https://github.com/Varnasr/EquityStack) | Inequality measurement and design-based survey estimation | Python |

[openstacks.dev](https://openstacks.dev) is the index.
[SignalStack](https://github.com/Varnasr/SignalStack) is the companion archive
for the [Research Rundown](https://varna.substack.com) newsletter, beside the
stacks rather than one of them.
[PolicyStack](https://github.com/Varnasr/PolicyStack) is superseded by
[PolicyDhara](https://github.com/Varnasr/PolicyDhara). RootStack, BridgeStack
and ViewStack are archived.

## Citation and license

```bibtex
@software{fieldstack,
  author = {Sri Raman, Varna},
  title = {FieldStack: R for field operations and survey analysis},
  url = {https://github.com/Varnasr/FieldStack},
  doi = {10.5281/zenodo.15250764}
}
```

MIT. See [LICENSE](LICENSE).
