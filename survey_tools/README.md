# Survey Tools

R functions for survey design and analysis using the `survey` and `srvyr` packages.

## Contents

| Script | Purpose |
|--------|---------|
| `sample_size_calculator.R` | Calculate sample sizes for simple, stratified, and cluster designs |
| `sampling_weights.R` | Compute and apply survey weights for complex designs |
| `survey_summary.R` | Weighted descriptive statistics with confidence intervals |
| `dhs_stunting.R` | Worked example: DHS stunting by wealth quintile, design-based, checked against the published NFHS-5 table |

## Usage

```r
source("survey_tools/sample_size_calculator.R")
sample_size_simple(p = 0.5, margin = 0.05, confidence = 0.95)
```

## The DHS worked example

`dhs_stunting.R` is the analysis half of a chain that begins in
[InsightStack](https://github.com/Varnasr/InsightStack)'s
`data_starters/dhs-south-asia/`, which turns a raw DHS recode into a clean CSV.
The two repositories are coupled through a file, not a dependency.

```r
source("survey_tools/dhs_stunting.R")
dhs_stunting_report("children.csv")
```

It reproduces India's published NFHS-5 stunting table by wealth quintile and
tells you when it does not, which is the only cheap check that a survey pipeline
is right end to end.

Two DHS specifics are handled in it, and both bite people who do not know them.
Subgroups go through `svyby` on the whole design, never a data frame filtered
before `svydesign()`, because filtering first discards the clusters holding none
of the subgroup and shrinks the standard error. And design effects use
`deff = "replace"`, because `v005` is a relative weight normalised to average
one, not a population expansion weight: on a 40-cluster extract the default
`deff = TRUE` returned 165, 207 and two NAs where the correct values are 1.11,
0.83 and 1.49. The same mismatch makes `survey` warn "Sample size greater than
population size: are weights correctly scaled?", which on DHS data is expected
and is not a reason to rescale anything.

## Requirements

- R 4.0+
- `tidyverse`
- `survey` (for `survey_summary.R` and `dhs_stunting.R`)

Verified on R 4.3.3 with survey 4.2.1. `dhs_stunting.R` previously declared a
dependency on dplyr and used none of it; that has been removed.
