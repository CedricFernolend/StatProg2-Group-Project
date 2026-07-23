# StatProg2 Group Project — COVID-19 infection rates and mental-health need

Group project for the **Statistical Programming 2** course at LMU (SoSe 2026).

**Live site:** <https://cedricfernolend.github.io/StatProg2-Group-Project/>

We link **state-level COVID-19 case rates** to the US population's **unmet need for mental-health support**, asking whether places hit harder by the pandemic reported higher unmet need for counseling. Both measures are joined by US state and survey window (Aug 2020 – Apr 2022).

## Group members

-   Cedric Fernolend
-   Peiyue Liu

## Research questions and headline findings

**RQ1 — Across US states, is a higher COVID-19 case rate associated with higher unmet mental-health need?** Yes, but weakly. The association is positive and statistically significant (slope 5.4 × 10⁻⁴, 95% CI \[3.4, 7.5\] × 10⁻⁴, *p* \< 0.001) yet explains only \~1.6% of variance. The significance largely reflects the large sample (*n* = 1,676 state-windows) rather than a strong effect. The result survives inverse-variance weighting for survey precision.

**RQ2 — Did need and COVID co-move nationally over time?** Not consistently. In levels the correlation is moderate (*r* = 0.38), but in first differences it vanishes (*r* = 0.05), indicating the level correlation is largely a common-trend artefact. The relationship also breaks down during the Omicron surge, when case rates tripled while unmet need did not rise.

Both analyses are **observational and use state-level aggregates**, so they describe associations between populations and support no causal claim.

## Repository structure

| Path | What it holds |
|------------------------------------|------------------------------------|
| `code/01_download.R` | Downloads the raw COVID data into `data/raw/`. |
| `code/02_clean.R` | Cleans and joins the raw data; writes `data/processed/`. |
| `data/raw/` | Read-only raw datasets + `LICENCE.txt` (provenance record). |
| `data/processed/` | Cleaned datasets produced by `code/02_clean.R`. |
| `index.qmd` | Website home page. |
| `proposal.qmd` | Project proposal — research questions, IDA, analysis plan. |
| `report.qmd` | Main report: results, interpretation and limitations. |
| `eda-mentalhealth.qmd` | Exploratory analysis of the mental-health dataset. |
| `group_reflection.qmd` | Group reflection, branch strategy and LLM usage. |
| `*Individual contribution.qmd` | Per-member contribution statements. |
| `_quarto.yml` | Quarto website config (renders to `docs/`). |
| `docs/` | Rendered website — published output, do not edit by hand. |
| `renv.lock` | Pinned package versions for reproducibility. |

## Datasets and licences

| Dataset | File | Source | Licence |
|------------------|------------------|------------------|------------------|
| Mental Health Care in the Last 4 Weeks (Household Pulse Survey) | `data/raw/Mental_Health_Care_in_the_Last_4_Weeks.csv` | US Census Bureau / NCHS (CDC), via [data.gov](https://catalog.data.gov/dataset/mental-health-care-in-the-last-4-weeks) | Public domain (U.S. Government Work) |
| COVID-19 cases & deaths by US state | `data/raw/covid_us_states_nyt.csv` | New York Times, [github.com/nytimes/covid-19-data](https://github.com/nytimes/covid-19-data) | Free use with attribution, non-commercial (academic use) |
| US state population, 2020 Census | `data/raw/us_state_population_2020.csv` | US Census Bureau, 2020 Decennial Census | Public domain (U.S. Government Work) |

## Reproducing the analysis

Package versions are pinned with `renv`. Requires R (with `dplyr` ≥ 1.1.0 for the range join used in cleaning).

``` r
# 1. Restore the exact package versions
renv::restore()

# 2. Build the data (run in this order)
source("code/01_download.R")   # fetches raw COVID data -> data/raw/
source("code/02_clean.R")      # cleans + joins -> data/processed/*.csv

# 3. Render the website
quarto::quarto_render()        # -> docs/
```

The `.qmd` documents read only from `data/processed/`, so steps 1–2 must run before rendering. If you add a package, run `renv::snapshot()` and commit the updated `renv.lock`.

## Data and variables

This project combines three data sources: the Household Pulse mental-health-care dataset, the New York Times state-level COVID-19 dataset, and a 2020 US state population table. The analysis uses only the columns listed below.

### Household Pulse mental-health data

| Variable | Meaning | Unit / format | Use in analysis |
|------------------|------------------|------------------|------------------|
| `Indicator` | Type of mental-health-care measure reported in the survey | Text category | Used to select the outcome indicator |
| `Group` | Population grouping used by the survey | Text category | We use `By State` for RQ1 and `National Estimate` for RQ2 |
| `State` | State or national geography of the estimate | State name | Used to join state-level observations and identify national estimates |
| `Time Period Start Date` | Start date of the survey window | Date | Renamed to `win_start` |
| `Time Period End Date` | End date of the survey window | Date | Renamed to `win_end` |
| `Value` | Estimated percentage of adults for the selected indicator | Percent | Renamed to `unmet_need` for the main outcome |
| `Suppression Flag` | Marks estimates suppressed because they are statistically unreliable | Text / flag | Used to understand missing values |

### COVID-19 data

| Variable | Meaning | Unit / format | Use in analysis |
|------------------|------------------|------------------|------------------|
| `date` | Date of the COVID-19 observation | Date | Matched to survey windows |
| `state` | US state | State name | Joined to mental-health and population data |
| `cases` | Cumulative confirmed COVID-19 cases | Count | Differenced to calculate daily new cases |

### Population data

| Variable | Meaning | Unit / format | Use in analysis |
|------------------|------------------|------------------|------------------|
| `state` | US state | State name | Joined to COVID data |
| `population` | 2020 resident population | Count of residents | Used to calculate new COVID cases per 100,000 residents |

### Derived variables

| Variable | Meaning | Unit / format | How it is calculated |
|------------------|------------------|------------------|------------------|
| `new_cases` | Daily new COVID-19 cases | Count | `cases - lag(cases)` within each state, floored at 0 |
| `new_per100k` | Daily new COVID-19 cases per 100,000 residents | Cases per 100,000 residents | `new_cases / population * 100000` |
| `covid_rate` | COVID-19 intensity during a survey window | Cases per 100,000 residents during the window | Sum of `new_per100k` across all dates inside the survey window |
| `unmet_need` | Adults who needed counseling or therapy but did not get it | Percent of adults | `Value` for the selected Household Pulse indicator |

### Missing values

In the Household Pulse dataset, some estimates are suppressed because they are statistically unreliable. These suppressed estimates appear as missing values in `Value` and are indicated by the `Suppression Flag`. Because these values are missing due to reliability concerns rather than random chance, we treat them as likely MNAR. The analysis drops suppressed estimates using `!is.na(Value)`.

In practice the impact on our results is small: the state-level subset used for RQ1 is a near-complete grid of 51 states × 33 windows, with only 7 of 1,683 values missing (0.42%). Missingness is more substantial for subgroup-level estimates (13–14%), which we do not analyse.

For the COVID-19 and population datasets, we check missing values in the columns used in the analysis. The columns `date`, `state`, and `cases` in the COVID dataset, and `state` and `population` in the population dataset, have no missing values in the analysis checks.

## Use of AI tools

In line with the department's guidelines, we disclose that we used AI assistants (Claude / Claude Code; ChatGPT) during this project — for locating and sourcing the COVID dataset, drafting and simplifying R code, editing prose in the proposal, report and README, and checking our work against the course requirements. All AI-assisted code and text was reviewed, run and verified by a group member, who remains responsible for the final content.
