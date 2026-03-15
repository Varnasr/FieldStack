# Survey Tools

R functions for survey design and analysis using the `survey` and `srvyr` packages.

## Contents

| Script | Purpose |
|--------|---------|
| `sample_size_calculator.R` | Calculate sample sizes for simple, stratified, and cluster designs |
| `sampling_weights.R` | Compute and apply survey weights for complex designs |
| `survey_summary.R` | Weighted descriptive statistics with confidence intervals |

## Usage

```r
source("survey_tools/sample_size_calculator.R")
sample_size_simple(p = 0.5, margin = 0.05, confidence = 0.95)
```

## Requirements

- R 4.0+
- `tidyverse`
- `survey` (for `survey_summary.R`)
