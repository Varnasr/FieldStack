# Survey tools

R for survey design and weighted analysis with the `survey` package.

| Script | What it does |
| --- | --- |
| `sample_size_calculator.R` | Sample size for simple, stratified and cluster designs |
| `sampling_weights.R` | Base weights, trimming, weighted summaries |
| `survey_summary.R` | Design objects and weighted descriptives with confidence intervals |
| `dhs_stunting.R` | DHS stunting by wealth quintile, design-based, checked against the published NFHS-5 table |

```r
source("survey_tools/sample_size_calculator.R")
sample_size_simple(p = 0.5, margin = 0.05, confidence = 0.95)
```

## The DHS example

`dhs_stunting.R` reads the CSV written by InsightStack's
`data_starters/dhs-south-asia/` loader and reproduces India's published
NFHS-5 stunting table by wealth quintile.

```r
source("survey_tools/dhs_stunting.R")
dhs_stunting_report("children.csv")
```

Two DHS details are handled in it. Subgroups go through `svyby` on the whole
design, not a data frame filtered before `svydesign()`, since filtering drops
the clusters that hold none of the subgroup and shrinks the standard error.
Design effects use `deff = "replace"`, because `v005` is a relative weight
normalised to average one; the default `deff = TRUE` returns values like 165
where the answer is 1.11. On DHS data the warning "Sample size greater than
population size" is expected.

## Requirements

R 4.0 or later, `tidyverse`, `survey`. Verified on R 4.3.3 with survey 4.2.1.
