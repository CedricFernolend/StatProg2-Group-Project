# 01_download.R — fetch raw COVID data into data/raw/ (run once; raw is read-only after).
library(here)

url <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"
download.file(url, destfile = here("data", "raw", "covid_us_states_nyt.csv"))

# Mental-health CSV: manual download from data.gov (see data/raw/LICENCE.txt).
# Population CSV: hand-built reference from 2020 Census (documented in LICENCE.txt).
message("COVID data downloaded to data/raw/.")
