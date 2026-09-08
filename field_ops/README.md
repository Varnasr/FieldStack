# field_ops

Checks to run against a survey export while the team is still in the field.
Base R, no packages, so it runs on any laptop in a district office.

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

## Checks

**High-frequency checks** (`high_frequency_checks.R`)

| Function | Flags |
| --- | --- |
| `hfc_duplicates` | The same ID twice |
| `hfc_missing` | Blanks in questions that are never skipped |
| `hfc_range` | Values outside a declared range |
| `hfc_duration` | Interviews completed in a fraction of the expected time |
| `hfc_outside_hours` | Interviews stamped outside working hours |
| `hfc_constant` | Every item in a battery answered identically |
| `run_hfc` | All of the above in one table, errors first |

**Enumerator monitoring** (`enumerator_monitoring.R`): `enumerator_summary`
for workload and missingness, `enumerator_outliers` for means that differ from
everyone else's, `enumerator_daily_load` for submissions per day.

**Back checks** (`back_checks.R`): `back_check_compare` against a supervisor's
re-interview sample.

**GPS** (`gps_checks.R`): `haversine`, `gps_distance_from_cluster`,
`gps_duplicate_locations`.

**Reading the export** (`read_odk.R`): `read_odk` and `odk_split_multiple`.

## Settings that matter

**`within`.** Enumerators are rarely assigned to areas at random, so an
enumerator whose households report low consumption may have been sent to the
poorest block. Pass `within` so each enumerator is compared only with others
who worked the same village or stratum. A flag is a reason to ask; it is not
evidence.

**Back-check question types.** Type 1 should not differ between two competent
interviews (sex of the household head, roof material, land owned). Type 2 may
(last month's income, a rating). Type 3 is expected to. `back_check_compare`
reports an error rate per type and no pooled rate.

**Tolerance.** Set one for any recalled amount. Exact equality on a rupee
figure reports a 90 per cent error rate.

**Timezone.** ODK stamps UTC. A 09:00 interview in Bihar is 03:30 UTC.
`hfc_outside_hours` takes `tz` and defaults to `Asia/Kolkata`.

**GPS radius.** Phone GPS is routinely 20 to 50 metres out, and worse under
tree cover. A radius under about 100 m flags honest work. Pass the form's
accuracy field where there is one.

**`required`.** List only questions that are never skipped. A question behind
a skip pattern is blank for most respondents and produces false flags.

Nothing here changes data. Each check flags; a person decides.

## Tests

`tests/test_field_ops.R`, 82 checks, run on every pull request. For each check
there is a test that it fires on the case it exists for and a test that it
stays quiet on a similar honest case. The working-hours check passes a 03:30
UTC interview when told the fieldwork was in India and flags it when left in
UTC. The leave-one-out benchmark excludes the enumerator being judged. The
`within` comparison stops flagging when the only difference between two
enumerators is the village they were sent to. Haversine is checked against
one degree of latitude (111,195 m) and the Delhi-Mumbai great-circle distance.

## Sources

IPA, *Best Practices for Data and Code Management*, 2020, section 4.

J-PAL, *Conducting back checks*, 2020.
