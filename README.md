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

## Use of AI tools

In line with the department's guidelines, we disclose that we used an AI assistant (Claude; ChatGPT) during this project.
