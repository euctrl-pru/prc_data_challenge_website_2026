library(conflicted)
library(tidyverse)
library(here)
library(fs)

conflicts_prefer(dplyr::filter)

here("R", "helpers.R") |> source()

teams_raw <- get_teams_raw()

# all teams in spreadsheet...
teams <- teams_raw |> get_teams_all()

# team to assess for approval
teams_new <- teams_raw |> get_teams_new()


# teams approved but not yet created:
# * missing email validation step?
# * invalid OSN account
teams_limbo <- teams_raw |> get_teams_limbo()


teams_valid <- teams_raw |> get_teams_valid()

members <- teams_raw |> get_teams_members()
