# team to assess for approval

library(conflicted)
library(tidyverse)
library(here)
library(fs)
library(withr)

conflicts_prefer(dplyr::filter)

here("R", "helpers.R") |> source()


with_options(
  list(width = 10000, pillar.width = 10000, pillar.print_max = Inf),
  get_teams_raw() |>
    get_teams_new() |>
    tibble::remove_rownames() |>
    as.data.frame() |>
    print()
)
