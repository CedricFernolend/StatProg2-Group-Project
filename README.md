# StatProg2 Group Project - COVID-19 infection rates and mental-health need

Group project for the **Statistical Programming 2** course at LMU (SoSe 2026).

## Group members

-   Cedric Fernolend
-   Peiyue Liu

## Repository structure

| Path | What it holds |
|---------------------|---------------------------------------------------|
| `Dataset_Research/Project_Proposal.qmd` | The project proposal (research questions, analysis plan, workflow). Render for the submitted webpage. |
| `Dataset_Research/Covid_MentalHealth_analysis.qmd` | Core runnable analysis: builds the joined data and answers the two research questions. |
| `Dataset_Research/Mental_Health_last_4_weeks.qmd` | Exploratory IDA of the Household Pulse mental-health dataset alone. |
| `Dataset_Research/US Supply Chain Risk Analysis.qmd` | IDA of a dataset we considered and rejected (kept for transparency). |
| `Data/` | Raw datasets (see below). |

## Datasets and licences

| Dataset | File | Source | Licence |
|-------------------|-----------------|-----------------|-------------------|
| Mental Health Care in the Last 4 Weeks (Household Pulse Survey) | `Data/Mental_Health_Care_in_the_Last_4_Weeks.csv` | US Census Bureau / NCHS (CDC), via [data.gov](https://catalog.data.gov/dataset/mental-health-care-in-the-last-4-weeks) | Public domain (U.S. Government Work) |
| COVID-19 cases & deaths by US state | `Data/covid_us_states_nyt.csv` | New York Times, [github.com/nytimes/covid-19-data](https://github.com/nytimes/covid-19-data) | Free use with attribution, non-commercial (academic use) |
| US state population, 2020 Census | `Data/us_state_population_2020.csv` | US Census Bureau, 2020 Decennial Census | Public domain (U.S. Government Work) |

Raw data is kept **as downloaded**. All cleaning happens in the analysis scripts, never in the source files.

## Reproducing the analysis

Requires R with `tidyverse` (`readr`, `dplyr`, `tidyr`, `ggplot2`) and `dplyr` (≥ 1.1.0). Open the project and render either Quarto document, e.g.:

``` r
quarto::quarto_render("Dataset_Research/Covid_MentalHealth_analysis.qmd")
```

Package versions will be pinned with `renv` (`renv::restore()`) once the lockfile is committed.

## Data and variables

This project combines three data sources: the Household Pulse mental-health-care dataset, the New York Times state-level COVID-19 dataset, and a 2020 US state population table. The analysis uses only the columns listed below.

### Household Pulse mental-health data

| Variable | Meaning | Unit / format | Use in analysis |
|---|---|---|---|
| `Indicator` | Type of mental-health-care measure reported in the survey | Text category | Used to select the outcome indicator |
| `Group` | Population grouping used by the survey | Text category | We use `By State` for RQ1 and `National Estimate` for RQ2 |
| `State` | State or national geography of the estimate | State name | Used to join state-level observations and identify national estimates |
| `Time Period Start Date` | Start date of the survey window | Date | Renamed to `win_start` |
| `Time Period End Date` | End date of the survey window | Date | Renamed to `win_end` |
| `Value` | Estimated percentage of adults for the selected indicator | Percent | Renamed to `unmet_need` for the main outcome |
| `Suppression Flag` | Marks estimates suppressed because they are statistically unreliable | Text / flag | Used to understand missing values |

### COVID-19 data

| Variable | Meaning | Unit / format | Use in analysis |
|---|---|---|---|
| `date` | Date of the COVID-19 observation | Date | Matched to survey windows |
| `state` | US state | State name | Joined to mental-health and population data |
| `cases` | Cumulative confirmed COVID-19 cases | Count | Differenced to calculate daily new cases |

The NYT COVID file also includes variables such as `deaths` and `fips`, but these are not used in the analysis.

### Population data

| Variable | Meaning | Unit / format | Use in analysis |
|---|---|---|---|
| `state` | US state | State name | Joined to COVID data |
| `population` | 2020 resident population | Count of residents | Used to calculate new COVID cases per 100,000 residents |

### Derived variables

| Variable | Meaning | Unit / format | How it is calculated |
|---|---|---|---|
| `new_cases` | Daily new COVID-19 cases | Count | `cases - lag(cases)` within each state, floored at 0 |
| `new_per100k` | Daily new COVID-19 cases per 100,000 residents | Cases per 100,000 residents | `new_cases / population * 100000` |
| `covid_rate` | COVID-19 intensity during a survey window | Cases per 100,000 residents during the window | Sum of `new_per100k` across all dates inside the survey window |
| `unmet_need` | Adults who needed counseling or therapy but did not get it | Percent of adults | `Value` for the selected Household Pulse indicator |

### Missing values

In the Household Pulse dataset, some estimates are suppressed because they are statistically unreliable. These suppressed estimates appear as missing values in `Value` and are indicated by the `Suppression Flag`. Because these values are missing due to reliability concerns rather than random chance, we treat them as likely MNAR. The analysis drops suppressed estimates using `!is.na(Value)`.

For the COVID-19 and population datasets, we check missing values in the columns used in the analysis. The columns `date`, `state`, and `cases` in the COVID dataset, and `state` and `population` in the population dataset, have no missing values in the analysis checks.

## Use of AI tools

In line with the department's guidelines, we disclose that we used an AI assistant (Claude; ChatGPT) during this project.
