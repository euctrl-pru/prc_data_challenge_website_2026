library(conflicted)
library(dplyr)
library(here)
library(purrrlyr)

conflicts_prefer(dplyr::filter)

here("R", "helpers.R") |> source()

teams_raw <- get_teams_raw()

teams_valid <- teams_raw |> get_teams_valid()

members <- teams_raw |> get_teams_members()

ttt <- teams_valid |>
  left_join(members) |>
  mutate(
    forename = if_else(consent == "No", "xyzzy", forename),
    surname = if_else(consent == "No", "XYZZY", surname),
    affiliation = if_else(is.na(affiliation), "Unknow", affiliation),
    NULL
  )

#########################
# GENERATE Teams' pages #
#########################
ttt |>
  group_by(team_name) |>
  purrrlyr::by_row(generate_team_page)
