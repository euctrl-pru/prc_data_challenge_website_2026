# teams approved but not yet created:
# * missing email validation step?
# * invalid OSN account
library(withr)

conflicted::conflicts_prefer(dplyr::filter)

here::here("R", "helpers.R") |> source()
with_options(
  list(width = 10000, pillar.width = 10000, pillar.print_max = Inf),
  get_teams_raw() |>
    get_teams_limbo() |>
    tibble::remove_rownames() |>
    as.data.frame() |>
    print()
)
