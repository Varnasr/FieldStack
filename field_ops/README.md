# field_ops

Field operations: catching bad data while the team is still in the district.

The rest of this repository analyses data somebody else collected. This part is
about the fortnight when the data is being made, which is the only window in
which most problems can still be fixed. A duplicated household ID found on day
three is a phone call. The same duplicate found at analysis is a hole in the
sample that cannot be filled, because the team has gone and the respondent
cannot be re-identified.

Base R throughout, no packages. That is deliberate: this is the code that runs
on whatever laptop is in the district office, on a connection that will not
install anything.

## The evening run

```r
source("field_ops/daily_report.R")

field_daily_report(
  "exports/round1_2026-01-15.csv",
  id = "hh_id", enumerator = "enum_id",
  required = c("consent", "respondent_name", "hh_size"),
  ranges   = list(age = c(0, 110), hh_size = c(1, 30), acres = c(0, 50)),
  start = "start", end = "end",
  battery = paste0("attitude_", 1:8),
  gps = list(lat = "lat", lon = "lon", cluster = "village", radius_m = 2000),
  outcome_vars = c("hh_size", "monthly_spend", "owns_land"),
  within = "village",
  outdir = "reports/"
)
```

Two files come out: a per-case list to act on tomorrow, and a per-enumerator
summary for the morning meeting.

## What each check is for

**High-frequency checks** (`high_frequency_checks.R`)

| Function | Catches |
|---|---|
| `hfc_duplicates` | The same ID twice: a double submission, or two households given one ID |
| `hfc_missing` | Blanks in questions that are never legitimately skipped |
| `hfc_range` | Values outside a plausible bound you declare |
| `hfc_duration` | An interview completed in a quarter of the time it takes. The single most useful fabrication check there is, and free, because the timestamps are recorded anyway |
| `hfc_outside_hours` | Interviews stamped at 02:40, which is a wrong device clock or a form filled in later |
| `hfc_constant` | Straightlining: every item in a battery answered identically |
| `run_hfc` | All of the above, stacked into one table sorted with errors first |

**Enumerator monitoring** (`enumerator_monitoring.R`)

`enumerator_summary` for workload and missingness, `enumerator_outliers` for
means that differ from everyone else's, `enumerator_daily_load` for the day
somebody submitted twelve interviews.

**Back checks** (`back_checks.R`)

`back_check_compare` against a supervisor's re-interview subsample.

**GPS** (`gps_checks.R`)

`haversine` for distance, `gps_distance_from_cluster` for interviews recorded
far from where they were assigned, `gps_duplicate_locations` for households
sharing a coordinate to the metre.

**Reading the export** (`read_odk.R`)

`read_odk` and `odk_split_multiple`.

## Five things that decide whether this works

**Enumerators are almost never randomly assigned to areas.** An enumerator whose
households report much lower consumption may be fabricating, or may have been
sent to the poorest block in the district. Nothing here can tell those apart,
and the difference between them is somebody's job. Pass `within` so each person
is compared only against others who worked the same village or stratum; where
assignment really was randomised within a cluster, that removes the confounding
entirely. A flag is a reason to look and to listen to the explanation. It is not
evidence.

**Classify back-check questions before comparing them.** Type 1 should never
differ between two competent interviews (sex of the head, whether the roof is
concrete, land owned). Type 2 legitimately may (income last month, a subjective
rating). Type 3 is expected to. Reporting one undifferentiated error rate across
all three makes an honest enumerator asking hard recall questions look worse
than a careless one asking easy ones, so `back_check_compare` refuses to compute
an overall rate and reports by type.

**Set a tolerance on anything anyone estimated.** Exact equality is the wrong
test for recalled land, expenditure or income: two honest interviews will differ
a little. A zero tolerance on a rupee figure reports a 90 per cent error rate
and tells you nothing.

**Timezone.** ODK stamps UTC. An ordinary 09:00 interview in Bihar is 03:30 UTC,
so a working-hours check left in UTC flags the entire survey and a team learns
within a week to ignore the report. `hfc_outside_hours` takes `tz` and defaults
to `Asia/Kolkata`.

**Phone GPS is 20 to 50 metres out routinely**, worse under tree cover or between
buildings. A radius threshold under about 100 m flags honest work. Where the
form captured an accuracy field, pass it and the threshold widens per point
instead of one radius serving both a clear sky and a forest.

**Nothing here corrects anything.** A check that silently fixes data is worse
than no check: the correction is invisible at analysis and the enumerator never
learns. Flag, report, let a person decide.

## Only required questions belong in `required`

A question behind a skip pattern is legitimately blank for most respondents.
Listing it produces hundreds of false flags, and the cost of that is not the
noise, it is that the field team stops reading the report. That is the failure
mode this whole directory has to survive.

## Verification

`tests/test_field_ops.R`, 82 checks, in the suite that runs on every pull
request. They test both directions, because a field check has an asymmetric cost
structure: a missed fabrication is a corrupted dataset nobody knows is
corrupted, and a false flag is a wasted accusation.

So for each check there is a test that it fires on the case it exists for, and
a test that it stays quiet on the honest case that looks similar. The
working-hours check is verified to pass a 03:30 UTC interview when told the
fieldwork was in India and to flag the same row when left in UTC. The
leave-one-out benchmark is verified to exclude the enumerator being judged. The
`within` comparison is verified to stop flagging when the only difference
between two enumerators is which village they were sent to. Haversine is checked
against one degree of latitude (111,195 m) and against the published
Delhi-Mumbai great-circle distance.

## Sources

IPA, *Best Practices for Data and Code Management*, 2020, section 4, for the
high-frequency check battery.

J-PAL, *Conducting back checks*, 2020, for the type 1/2/3 classification and the
usual thresholds.
