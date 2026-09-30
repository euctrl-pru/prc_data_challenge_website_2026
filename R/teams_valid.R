suppressPackageStartupMessages(
  suppressMessages(
    suppressWarnings({
      library(conflicted)
      library(tidyverse)
      library(here)
      library(fs)
      library(withr)
    })
  )
)

conflicts_prefer(dplyr::filter, .quiet = TRUE)

here("R", "helpers.R") |> source()

get_teams_raw() |>
  get_teams_valid()
