library(conflicted)
library(tidyverse)

conflicts_prefer(dplyr::filter)

source(here::here("R", "helpers.R"))


phase1_start_25 <- as_datetime("2025-10-01T00:00:00Z")
phase1_end_25 <- as_datetime("2025-11-09T23:59:59Z")
phase2_start_25 <- as_datetime("2025-11-10T00:00:00Z")
phase2_end_25 <- as_datetime("2025-12-01T23:59:59Z")

phase1_start_24 <- as_datetime("2024-08-01T00:00:00Z")
phase1_end_24 <- as_datetime("2024-10-17T00:00:00Z")
phase2_start_24 <- as_datetime("2024-10-17T18:16:00Z")
phase2_end_24 <- as_datetime("2024-10-28T00:00:00Z")

phase1_start_26 <- as_datetime("2026-09-01T00:00:00Z")
phase1_end_26 <- as_datetime("2026-10-12T00:00:00Z")

date_shift_24 <- phase1_start_26 - phase1_start_24
date_shift_25 <- phase1_start_26 - phase1_start_25

cum_24 <- here::here("media", "cumulative_registration_dc2024.csv") |>
  read_csv() |>
  add_row(
    registration_date = as_date(phase2_end_24),
    dc = year(as_date(phase2_end_24)),
    n = NULL
  ) |>
  fill(n, .direction = "down") |>
  mutate(
    registration_date = registration_date + date_shift_24,
    dc = as.integer(dc),
    n = as.integer(n),
    future = FALSE,
    NULL
  )

cum_25 <- here::here("media", "cumulative_registration_dc2025.csv") |>
  read_csv() |>
  mutate(
    registration_date = registration_date + date_shift_25,
    dc = as.integer(dc),
    n = as.integer(n),
    future = FALSE,
    NULL
  )

cum_26 <- prepare_cumulative_teams() |>
  mutate(
    dc = as.integer(dc),
    n = as.integer(n),
    NULL
  )

max_25 <- cum_25 |>
  slice(which.max(registration_date))
max_24 <- cum_24 |>
  slice(which.max(registration_date))
max_26 <- cum_26 |>
  slice(which.max(registration_date))

ggplot() +
  #---------- 2024 ---------
  geom_step(
    data = cum_24,
    aes(x = registration_date, y = n, linetype = future),
    colour = "#008000",
    alpha = 0.5,
    stat = "identity"
  ) +
  geom_text(
    data = max_24,
    aes(x = registration_date, y = n, label = n),
    size = 3,
    vjust = -0.5,
    colour = "#008000",
    alpha = 0.5
  ) +
  annotate(
    geom = "segment",
    x = as_date(phase2_end_24) + date_shift_24,
    y = 35,
    xend = as_date(phase2_end_24) + date_shift_24,
    yend = max_24 |> pull(n),
    arrow = arrow(length = unit(2, "mm")),
    colour = "#008000",
    alpha = 0.5
  ) +
  annotate(
    geom = "text",
    x = as_date(phase2_end_24) + date_shift_24 - ddays(8),
    y = 20,
    label = paste0(
      "End DC 2024\n  (",
      round(phase2_end_24 - phase1_start_24),
      " days)"
    ),
    size = 2.5,
    hjust = "left"
  ) +
  #---------- 2025 ---------
  geom_step(
    data = cum_25,
    aes(x = registration_date, y = n, linetype = future),
    colour = "blue",
    alpha = 0.5,
    stat = "identity"
  ) +
  geom_text(
    data = max_25,
    aes(x = registration_date, y = n, label = n),
    colour = "blue",
    alpha = 0.5,
    size = 3,
    vjust = -0.5
  ) +
  annotate(
    geom = "segment",
    x = as_date(phase2_end_25) + date_shift_25,
    y = 35,
    xend = as_date(phase2_end_25) + date_shift_25,
    yend = max_25 |> pull(n),
    arrow = arrow(length = unit(2, "mm")),
    colour = "blue",
    alpha = 0.5
  ) +
  annotate(
    geom = "text",
    x = as_date(phase2_end_25) + date_shift_25 - ddays(8),
    y = 20,
    label = paste0(
      "End DC 2025\n  (",
      round(phase2_end_25 - phase1_start_25),
      " days)"
    ),
    size = 2.5,
    hjust = "left"
  ) +
  #---------- 2026 ---------
  geom_step(
    data = cum_26,
    aes(x = registration_date, y = n, linetype = future),
    colour = "black",
    alpha = 0.5,
    stat = "identity"
  ) +
  geom_text(
    data = max_26,
    aes(x = registration_date, y = n, label = n),
    colour = "black",
    # size = 3,
    vjust = -0.5
  ) +
  annotate(
    geom = "segment",
    x = as_date(phase1_end_26),
    y = max_26 |> pull(n) - 90,
    xend = as_date(phase1_end_26),
    yend = max_26 |> pull(n),
    arrow = arrow(length = unit(2, "mm")),
    colour = "black",
    alpha = 0.5
  ) +
  annotate(
    geom = "text",
    x = as_date(phase1_end_26) - ddays(8),
    y = max_26 |> pull(n) - 100,
    label = paste0(
      "End DC 2026\n  (",
      round(phase1_end_26 - phase1_start_26),
      " days)"
    ),
    hjust = "left"
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    # axis.text.x = element_blank(),
    # axis.ticks.x = element_blank(),
    legend.position = "none",
    NULL
  )
