# FieldStack

Reusable R notebooks, scripts and tools for applied data work and evaluation,
built for use in the field across health, gender, climate and education
programmes in South Asia. Part of the [OpenStacks](https://openstacks.dev)
family. Status: Stable, per the family
[maintenance policy](https://github.com/Varnasr/OpenStacks-for-Change/blob/main/MAINTENANCE.md).

## Layout

R throughout. `scripts/` holds index and reshape functions, `evaluation/` and
`regression/` hold analysis code, `survey_tools/` holds sampling and weighted
estimation, `custom_viz/` and `visualisation/` hold plotting, `notebooks/` holds
Quarto documents, `sample_data/` holds small CSVs for the tests and examples.

Note that some files in `evaluation/` and `custom_viz/` are demonstration
scripts rather than libraries: they run top to bottom and define no functions.
`sroi_calc.R` and `map_visualisation_sf.R` are both of this kind. Check before
assuming a file exports something.

## Testing

`.github/workflows/tests.yml` runs the suite on pull requests and pushes to
main. No schedule: nothing here touches an external service.

```r
source("tests/run_all_tests.R")   # 6 files, 37 checks
```

Two things to know before adding a test.

**testthat runs from `tests/`, not the repository root.** Use `fs_path()` from
`tests/helper-paths.R` for every `source()` and every `read.csv()`. Writing
`source("scripts/x.R")` is how all nine of the original tests came to error on
their first line and stay broken indefinitely, because there was no CI to say so.

**Do not leave a test for code that does not exist.** Four of the originals
tested functions that had never been in this repository. A stub that cannot run
is not coverage, it is the appearance of coverage. Delete it, and bring it back
with the function.

## Watch out for

- **Backslashes in R strings.** `scripts/mel_reshape.R` carried
  `"indicator_(\d)_..."`, which is not a valid escape, so the file would not
  parse and `reshape_indicators()` was never callable. Regexes in R need them
  doubled.
- **DHS weights are relative.** `v005` is normalised to average one, not a
  population expansion weight. In `survey`, that means `deff = "replace"` rather
  than `deff = TRUE`, which otherwise returns values like 165 and 207 instead of
  1.11 and 0.83. It also makes `survey` warn that the sample is larger than the
  population, which on DHS is expected and is not a reason to rescale anything.
- **Subgroups are domains.** Use `svyby` on the whole design, or `subset()` on
  the design object. Filtering the data frame before `svydesign()` discards the
  clusters holding none of the subgroup and understates the standard error.
- **Declare only what you use.** `dhs_stunting.R` shipped with a `library(dplyr)`
  it never called, which is one more thing that can break an install.

## Related repositories

`survey_tools/dhs_stunting.R` is the analysis half of a chain that starts in
[InsightStack](https://github.com/Varnasr/InsightStack)'s
`data_starters/dhs-south-asia/`, coupled through a CSV rather than a dependency.
[EquityStack](https://github.com/Varnasr/EquityStack) `survey_estimation/` is the
Python counterpart, and the two agree to twelve significant figures on the same
data.

## Design references

For any UI or design refresh work on this repository or elsewhere in the family,
draw from **[kombai.com/gallery/web](https://kombai.com/gallery/web)** — the
owner's preferred reference for interface work that is genuinely well made. This
applies across all of Varna's repositories and sites, not only this one.

Two constraints worth knowing before proposing anything visual:

- Most stack repositories have no interface at all. This one has a single
  `index.html`; InsightStack and EquityStack ship no HTML whatsoever. The pages
  that exist are here, SignalStack, Experiments, openstacks.dev and the
  ImpactMojo properties.
- `Experiments` serves under a strict Content Security Policy allowlisting
  specific CDNs. A design pulling fonts or scripts from anywhere else fails there
  silently.
