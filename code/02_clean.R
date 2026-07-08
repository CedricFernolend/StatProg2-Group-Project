# 02_clean.R
# Reads raw data, applies cleaning, writes tidy datasets to data/processed/.

library(tidyverse)
library(here)

OUTCOME_INDICATOR <- "Needed Counseling or Therapy But Did Not Get It, Last 4 Weeks"

# ---- Mental health: light clean (parse survey-window dates, keep everything) ----
# Kept un-filtered and with NAs intact so the EDA can still screen missingness.
mh_clean <- read_csv(here("data", "raw", "Mental_Health_Care_in_the_Last_4_Weeks.csv"),
                     show_col_types = FALSE) |>
  mutate(start_date = as.Date(`Time Period Start Date`, "%m/%d/%Y"),
         end_date   = as.Date(`Time Period End Date`,   "%m/%d/%Y"))

write_csv(mh_clean, here("data", "processed", "mental_health_clean.csv"))

# ---- Outcome slices used by the report ----
outcome_by <- function(df, group, state_filter = NULL) {
  d <- df |> filter(Group == group, Indicator == OUTCOME_INDICATOR, !is.na(Value))
  if (!is.null(state_filter)) d <- filter(d, State == state_filter)
  d |> transmute(state = State, win_start = start_date,
                 win_end = end_date, unmet_need = Value)
}
mh     <- outcome_by(mh_clean, "By State")
mh_nat <- outcome_by(mh_clean, "National Estimate", "United States")

# ---- COVID: cumulative -> daily new cases, normalised per 100k ----
pop <- read_csv(here("data", "raw", "us_state_population_2020.csv"), show_col_types = FALSE)

covid_daily <- read_csv(here("data", "raw", "covid_us_states_nyt.csv"), show_col_types = FALSE) |>
  arrange(state, date) |>
  mutate(new_cases = pmax(cases - lag(cases), 0), .by = state) |>
  inner_join(pop, by = "state") |>
  mutate(new_per100k = new_cases / population * 1e5)

# ---- Join COVID intensity into each survey window (state level) ----
joined <- covid_daily |>
  inner_join(distinct(mh, state, win_start, win_end),
             by = join_by(state, between(date, win_start, win_end))) |>
  summarise(covid_rate = sum(new_per100k), .by = c(state, win_start, win_end)) |>
  inner_join(mh, by = c("state", "win_start", "win_end"))

# ---- National series ----
us_pop <- sum(pop$population)
national <- covid_daily |>
  inner_join(distinct(mh_nat, win_start, win_end),
             by = join_by(between(date, win_start, win_end))) |>
  summarise(covid_rate = sum(new_cases) / us_pop * 1e5, .by = c(win_start, win_end)) |>
  right_join(mh_nat, by = c("win_start", "win_end"))

write_csv(joined,   here("data", "processed", "covid_mentalhealth_joined.csv"))
write_csv(national, here("data", "processed", "covid_mentalhealth_national.csv"))

message("Wrote 3 files to data/processed/.")

