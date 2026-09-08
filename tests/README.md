# Tests

Six testthat files, 37 checks, run by `.github/workflows/tests.yml` on every
pull request and every push to main.

```r
source("tests/run_all_tests.R")
```

The runner exits non-zero on any failure, so CI genuinely fails rather than
printing red text and passing.

## What happened to the other four files

This folder previously held nine test files and **none of them ran**. Every one
errored on its first line, and with no CI in the repository nothing ever said
so. The README described a working suite.

Two separate faults:

**Four tests only needed a path.** They did `source("scripts/x.R")` and
`read.csv("sample_data/y.csv")`, which resolve from the repository root, while
testthat sets the working directory to this folder. `helper-paths.R` now finds
the root and every test resolves through `fs_path()`, so it works from either
place.

**Five tests were written against code that does not exist.** Not renamed, not
moved: absent.

| Test | Called | Reality |
|---|---|---|
| `test_care_time_summary.R` | `care_time_summary()` | no such function anywhere in the repository |
| `test_export_excel.R` | `export_summary_to_excel()` | no such function anywhere |
| `test_spatial_mapper.R` | `run_spatial_join()` | `custom_viz/map_visualisation_sf.R` is an 11-line demo that defines no functions |
| `test_sroi.R` | `calculate_sroi()` | `evaluation/sroi_calc.R` is a 5-line script that defines no functions |
| `test_survey_summary.R` | `survey_summary(data, "group", "value")` | `survey_tools/survey_summary.R` provides `create_survey_design()`, `survey_descriptives()` and `survey_proportions()` |

The first four were removed. You cannot test code that is not there, and a
stub kept in place is the same disease as a suite that never runs: it looks like
coverage. Write the function and the test comes back.

`test_survey_summary.R` was rewritten against the API that does exist, including
a check that the weighted mean differs from the unweighted one, so a bug that
silently drops the weights fails the suite.

`test_dhs_stunting.R` is new, covering `survey_tools/dhs_stunting.R`, which
arrived with no tests of its own.

## One repository bug this surfaced

`scripts/mel_reshape.R` could not be parsed. Its `names_pattern` was written
`"indicator_(\d)_(\d{4}Q\d)"`, and a single backslash is not a valid escape in
an R string, so `reshape_indicators()` had never been callable by anyone. The
regex itself was correct and only needed doubling. It now turns the 100-row wide
sample into 400 long rows.

## Data

Everything runs against `sample_data/` or against fixtures built inside the test
file. No real survey microdata is used, and none could be: the DHS licence does
not permit redistribution.
