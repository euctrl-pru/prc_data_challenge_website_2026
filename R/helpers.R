library(conflicted)
library(googlesheets4)
library(googledrive)
library(tidyverse)
library(dplyr)
library(janitor)


# prepare teams data frame
prepare_teams_df <- function() {
  teams_raw <- get_teams_raw()

  teams_valid <- teams_raw |>
    get_teams_valid() |>
    mutate(
      team_country = if_else(
        team_country == "Ireland {Republic}",
        "Ireland",
        team_country
      ),
      team_affiliation = if_else(
        team_consent == "No",
        "Undisclosed",
        team_affiliation
      ),
      team_members_count = extra_members + 1,
      NULL
    ) |>
    select(
      -c(
        status,
        team_consent,
        team_uuid,
        agreement,
        extra_members,
        account,
        how_learnt
      )
    )

  team_members <- teams_raw |>
    get_teams_members() |>
    mutate(
      forename = if_else(consent == "No", "Xyzzy", forename),
      surname = if_else(consent == "No", "XYZZY", surname),
      affiliation = if_else(consent == "No", "Undisclosed", affiliation),
      affiliation = if_else(is.na(affiliation), "Unknow", affiliation),
      NULL
    ) |>
    select(-c(email, consent, address))

  teams_valid |>
    left_join(team_members) |>
    nest(team_members = team_members |> select(-team_name) |> colnames())
}


# generate QMD page for one team
generate_team_page <- function(team) {
  t <- team |> filter(row_number() == 1)
  page <- "---
acronyms:
  insert_loa: false
---
## {name}


### Description and Rationale

{description}

### Details
  
  * Number of team members: {num}
  * Type: {type}
  * Affiliation: {affiliation}
  * Country: {country}

  "

  str_glue(
    page,
    name = t["team_name"],
    description = t["team_description"],
    affiliation = t["team_affiliation"],
    type = t["team_type"],
    country = t["team_country"],
    num = t["extra_members"] |> as.integer() |> magrittr::add(1L)
  ) |>
    write_lines(here("teams", paste0(t["team_name"], ".qmd")))
}


get_teams_members <- function(teams_raw) {
  teams_valid <- teams_raw |> get_teams_valid()
  teams_raw |>
    dplyr::filter(team_name %in% (teams_valid |> pull(team_name))) |>
    dplyr::select(team_name, matches("_\\d+$")) |>
    pivot_longer(
      cols = matches("_\\d+$"),
      names_to = c("attrib", "id"),
      names_pattern = "(.*)_(.*)",
      values_to = "val"
    ) |>
    pivot_wider(
      names_from = attrib,
      values_from = val
    ) |>
    filter(if_any(c(forename, surname, email), ~ !is.na(.x))) |>
    dplyr::mutate(id = as.integer(id)) |>
    arrange(team_name, id)
}

# teams approved but not yet created:
# * missing email validation step?
# * invalid OSN account
get_teams_limbo <- function(teams_raw) {
  teams_raw |>
    dplyr::filter(status == "approved", is.na(team_name)) |>
    dplyr::mutate(account = as.character(account)) |>
    dplyr::select(timestamp, email_1, forename_1, surname_1, account)
}

# get new teams requests to be assessed/approved
get_teams_new <- function(teams_raw) {
  teams_raw |>
    dplyr::filter(is.na(status), is.na(team_name)) |>
    dplyr::select(timestamp, email_1, forename_1, surname_1)
}

# get valid teams
get_teams_valid <- function(teams_raw) {
  teams_raw |>
    dplyr::filter(status == "approved", !is.na(team_name)) |>
    dplyr::mutate(team_consent = consent_1) |>
    dplyr::select(-matches("_\\d+$"))
}

# get teams' correspondents email
get_team_correspondents <- function(teams_raw) {
  teams_raw |>
    dplyr::filter(status == "approved", !is.na(team_name)) |>
    dplyr::mutate(
      team_consent = consent_1,
      team_correspondent = email_1
    ) |>
    dplyr::select(-matches("_\\d+$"))
}


get_teams_all <- function(teams_raw) {
  teams_raw |>
    dplyr::select(-matches("_\\d+$"))
}

# just read the google sheet values from the submission form
get_teams_raw <- function() {
  teams_gsheet <- "1nrV_N0T8141dI6cFty6-EA1v7tWeqxzZWo_Bi3dACIk"

  # In CI (or any headless environment) authenticate with a service account
  # whose JSON key path is given by GOOGLE_SHEETS_SA_JSON; the sheet must be
  # shared with that service account's email. Locally, fall back to the
  # interactive OAuth flow.
  sa_json <- Sys.getenv("GOOGLE_SHEETS_SA_JSON")
  if (nzchar(sa_json)) {
    googlesheets4::gs4_auth(
      path = sa_json,
      scope = "https://www.googleapis.com/auth/drive"
    )
  } else {
    googlesheets4::gs4_auth(
      email = "enrico.spinielli@gmail.com",
      scope = "https://www.googleapis.com/auth/drive"
    )
  }
  googlesheets4::read_sheet(teams_gsheet, sheet = "better_colnames") |>
    dplyr::filter(
      !account %in%
        c("johnf-test2")
    ) |>
    dplyr::mutate(address_1 = unlist(address_1)) |>
    dplyr::select(-matches("clean")) |>
    dplyr::relocate(
      timestamp,
      status,
      team_name,
      team_uuid,
      dplyr::everything(),
      matches("_\\d+$")
    )
}


# from https://github.com/jhelvy/jph/blob/master/R/quarto_render_move.R
#' `quarto::quarto_render()`, but output file is moved to `output_dir`
#'
#' The default `quarto::quarto_render()` function can only render outputs
#' to the current working directory. This is a wrapper that moves the rendered
#' output to `output_dir`.
#' @param input Path to the input qmd file.
#' @param output_file The name of the output file. If using `NULL` then the
#' output filename will be based on filename for the input file.
#' @param output_dir Path to the output directory.
#' @param ... Other args passed to `quarto::quarto_render()`
#' @export
quarto_render_move <- function(
  input,
  output_file = NULL,
  output_dir = NULL,
  ...
) {
  # Get all the input / output file names and paths
  x <- quarto::quarto_inspect(input)
  output_format <- names(x$formats)
  output <- x$formats[[output_format]]$pandoc$`output-file`
  if (is.null(output_file)) {
    output_file <- output
  }
  input_dir <- dirname(input)
  if (is.null(output_dir)) {
    output_dir <- input_dir
  }
  output_path_from <- file.path(input_dir, output)
  output_path_to <- file.path(output_dir, output_file)

  # Render qmd file to input_dir
  quarto::quarto_render(input = input, ... = ...)

  # If output_dir is different from input_dir, copy the rendered output
  # there and delete the original file
  if (input_dir != output_dir) {
    # Try to make the folder if it doesn't yet exist
    if (!dir.exists(output_dir)) {
      dir.create(output_dir)
    }

    # Now move the output to the output_dir and remove the original output
    file.copy(
      from = output_path_from,
      to = output_path_to,
      overwrite = TRUE
    )
    file.remove(output_path_from)

    # If the output_dir is the same as input_dir, but the output_file
    # has a different name from the input file, then just rename it
  } else if (output_file != output) {
    file.rename(from = output_path_from, to = output_path_to)
  }
}
