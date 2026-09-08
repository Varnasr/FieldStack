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

The house style now exists as a file: `assets/css/stack.css`. Its tokens, type and
border conventions are taken from **openstacks.dev**, which is the one page in the
family the owner considers well designed. Use it rather than writing new CSS, and
change it in one place if it needs changing.

The rules it encodes, so you do not undo them by accident: 2px borders and **no
shadows**, **no border-radius**, Bricolage Grotesque in uppercase for display,
Work Sans for prose, JetBrains Mono for labels and numbers, and colour bands
(`.band.white`, `.ash`, `.navy`, `.teal`, `.brick`, `.black`) rather than cards
floating on a page. Saffron `#f2a541` is the single accent and carries the focus
ring. No emoji anywhere.

For anything the house style does not already answer,
draw from **[kombai.com/gallery/web](https://kombai.com/gallery/web)** — the
owner's preferred reference for interface work that is genuinely well made. This
applies across all of Varna's repositories and sites, not only this one.

### Publishing traps, learned the hard way

**A folder only becomes a page if it holds a `README.md`.** GitHub Pages runs
`jekyll-readme-index`, which turns that README into the folder's index. A folder
without one returns 404. This repository has no nested-duplicate folders;
InsightStack has twelve of them (`spss_scripts/spss_scripts/`, `latex/latex/`
and so on), where the README sits one level down and the top-level path 404s
while the deeper one works. Check before assuming the trap applies here.

**Do not link-check with `python -m http.server`.** It generates directory
listings, so every folder link returns 200 locally and a third of them 404 in
production. That mistake shipped once. Build with Jekyll and check that the
built output actually contains `<dir>/index.html`.

**Source folders link to GitHub, not to the site.** Uniform, never 404s, and
honest about what they are. The designed surface is the landing page, the
calculators and the data-starter guides; everything else is code.

**`_layouts/default.html` is why a click-through still looks like the site.**
Before it existed, `_config.yml` set `theme: minima` and any rendered README
opened in a stock theme. Keep the layout, keep `defaults` applying it, and do
not reintroduce a theme.

**Descriptions are visible, not hover titles.** A `title` attribute shows on no
touch device and is announced unreliably by screen readers.

**Check the landing page on a phone, not only in the link checker.** `.row span`
in `stack.css` carries `white-space: nowrap` so the short language tag ("Python,
R") keeps to one line. Adding a description as another span inside `.row` makes
it inherit that, and the page then scrolls sideways: 1384px against a 390px
viewport, invisible on a desktop and the first thing a phone shows. The nowrap is
now scoped to `.row .t span`. After any change to a landing page, load it at
390x844 and compare `documentElement.scrollWidth` against `clientWidth`.

**Write for the person with the problem, not for the folder.** "Causal inference:
DiD, PSM, IV/2SLS, RDD and sensitivity analysis" is accurate and tells a reader
nothing about when to open it. Lead with the question ("Did the programme work,
and can you defend the answer?"), then name the methods so someone who already
knows what they want can still find it.

What actually has an interface, counted rather than assumed (2026-09-08, after
all three landing pages shipped):

| Repository | HTML | Published at |
|---|---|---|
| InsightStack | 9 files: a root `index.html`, six calculators in `calculators/`, a Taguette export page, and `_layouts/default.html` | https://varnasr.github.io/InsightStack/ |
| FieldStack | a root `index.html` and `_layouts/default.html` | https://varnasr.github.io/FieldStack/ |
| EquityStack | a root `index.html` and `_layouts/default.html` | https://varnasr.github.io/EquityStack/ |

All three now run GitHub Pages with `jekyll-readme-index` and **no theme**. An
older version of this table said InsightStack used `minima` and EquityStack was
unpublished; both were true once and neither is now.

The six calculators are the largest design surface in the stack family and the
obvious place to start. Beyond the stacks: SignalStack, Experiments,
openstacks.dev and the ImpactMojo properties.

One constraint that catches people: `Experiments` serves under a strict Content
Security Policy allowlisting specific CDNs, so a design pulling fonts or scripts
from anywhere else fails there silently. Read its `netlify.toml` before adding
any external asset.
