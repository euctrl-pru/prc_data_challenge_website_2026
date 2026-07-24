# generate Quarto pages for each team

library(conflicted)
library(tidyverse)
library(here)
library(fs)

library(purrr)
library(quarto)

conflicts_prefer(dplyr::filter)

here("R", "helpers.R") |> source()

teams <- prepare_teams_df() |> arrange(team_name)
teams_test <- teams |>
  filter(row_number() < 4)

(pmap(
  teams,
  # teams |> filter(row_number() < 4),
  \(
    timestamp,
    team_name,
    team_type,
    team_country,
    team_affiliation,
    team_description,
    team_members_count,
    team_members
  ) {
    # quarto_render_move(
    #   input = "team_template.qmd",
    #   output_file = paste0(team_name, ".html"),
    #   output_format = "html",
    #   output_dir = "_test_teams",
    #   metadata = list(title = team_name),
    #   execute_params = list(
    #     timestamp = timestamp,
    #     team_name = team_name,
    #     team_type = team_type,
    #     team_country = team_country,
    #     team_affiliation = team_affiliation,
    #     team_description = team_description,
    #     team_members_count = team_members_count,
    #     # trick from
    #     # https://www.jhelvy.com/blog/2023-02-28-parameterized-pdfs-with-quarto/#passing-data-frames-as-parameters
    #     team_members = jsonlite::toJSON(team_members)
    #   )
    # )

    # paste0("teams/", team_name) |> fs::dir_create()

    cat(
      sprintf(
        '
---
title: %s
date: %s
subtitle: %s
acronyms:
  insert_loa: false
---

## Description and Rationale

%s

## Details

* Type: %s
* Country: %s

```{r echo=FALSE}
library(gt)

gt(%s) |> cols_label(id = md("**ID**"), forename = md("**Forename**"), surname ~ md("**Surname**"), affiliation ~ md("**Affiliation**"))
```
',
        team_name,
        timestamp |> format("%Y-%m-%d"),
        team_country,
        team_description,
        team_type,
        team_country,
        team_members |> datapasta::tribble_construct()
      ),
      file = paste0("teams/", team_name, '.qmd')
    )
  }
))
