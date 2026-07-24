library(conflicted)
library(tidyverse)

phase1_start_25 <- as_datetime("2025-10-01T00:00:00Z")
phase1_end_25 <- as_datetime("2025-11-09T23:59:59Z")
phase2_start_25 <- as_datetime("2025-11-10T00:00:00Z")
phase2_end_25 <- as_datetime("2025-12-01T23:59:59Z")

phase1_start_24 <- as_datetime("2024-08-01T00:00:00Z")
phase1_end_24 <- as_datetime("2024-10-17T00:00:00Z")
phase2_start_24 <- as_datetime("2024-10-17T18:16:00Z")
phase2_end_24 <- as_datetime("2024-10-28T00:00:00Z")


cum_24 <- here::here("data", "cumulative_registration_dc2024.csv") |>
  read_csv() |>
  mutate(
    registration_date = if_else(
      registration_date == ymd("2024-07-28"),
      ymd("2024-07-31"),
      registration_date
    ),
    registration_date_orig = registration_date,
    registration_date = registration_date + (phase1_start_25 - phase1_start_24),
    future = FALSE,
    NULL
  )

cum_25 <- here::here("data", "cumulative_registration_dc2025.csv") |>
  read_csv() |>
  mutate(dc = 2025) |>
  select(dc, registration_date, n, future)

max_25 <- cum_25 |>
  slice(which.max(registration_date))
max_24 <- cum_24 |>
  slice(which.max(registration_date))

ggplot() +
  # 2024
  geom_step(
    data = cum_24,
    aes(x = registration_date, y = n, linetype = future),
    colour = "#008000",
    stat = "identity"
  ) +
  geom_text(
    data = max_24,
    aes(x = registration_date, y = n, label = n),
    size = 4,
    vjust = -0.5,
    colour = "#008000"
  ) +
  # 2025
  geom_step(
    data = cum_25,
    aes(x = registration_date, y = n, linetype = future),
    colour = "blue",
    stat = "identity"
  ) +
  geom_text(
    data = max_25,
    aes(x = registration_date, y = n, label = n),
    colour = "blue",
    size = 4,
    vjust = -0.5
  ) +
  annotate(
    geom = "segment",
    x = as_date(phase2_start_25),
    y = 35,
    xend = as_date(phase2_start_25),
    yend = max_25 |> pull(n),
    arrow = arrow(length = unit(2, "mm"))
  ) +
  annotate(
    geom = "text",
    x = as_date(phase2_start_25) - ddays(8),
    y = 25,
    label = paste0(
      "Start of final phase\n   (",
      as_date(phase2_start_25),
      ")"
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
