library(conflicted)
library(tidyverse)
library(here)
library(fs)
library(withr)

conflicts_prefer(dplyr::filter)

here("R", "helpers.R") |> source()

# withr::with_options(
#   list(width = 10000),
#   get_teams_raw() |> get_teams_valid()
# )

get_teams_raw() |> get_teams_valid()
