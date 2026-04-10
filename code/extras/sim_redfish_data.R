




##### FROM CLAUDE WITH FOLLOWING PROMPT: 
# I'm trying to simulate a dataset for use in a workshop. I'd like the dataset
# to have multiple predictors with an unbalanced categorical (0/1) response
# variable.
#
# Our hypothetical scenario is as follows:
#
# There is a lake called "Superior Red Lake of the Woods" where "red fish"
# lives. Recruitment (survival from egg to adult) is good most years, but bad in
# some years, and the overall population stability is severely impacted by bad
# recruitment years because it is a short-lived fish. We're trying to predict
# red fish recruitment based on weather variables like spring water temperatures
# and summer water temperatures, and also on the abundance of a potential
# competitor species "blue fish". Let's say we have around 100 years of data.
#
# Could you provide example R code (preferably using the tidyverse and caret
# packages) that builds this type of dataset?



# ============================================================
# Simulated Dataset: Red Fish Recruitment in Superior Red Lake of the Woods
# ============================================================
# Scenario:
#   - ~100 years of annual data
#   - Binary response: good (1) vs. bad (0) recruitment year
#   - Recruitment is USUALLY good, but bad years are impactful
#   - Predictors: spring water temp, summer water temp, blue fish abundance
# ============================================================

library(tidyverse)
library(caret)

set.seed(421)

n_years <- 100

# ── 1. Simulate Predictor Variables ──────────────────────────────────────────

# Spring water temperature (°C): warmer springs generally help recruitment
spring_temp <- rnorm(n_years, mean = 10, sd = 2.5)

# Summer water temperature (°C): moderate summers are best;
# very hot summers stress fish (non-linear effect possible)
summer_temp <- rnorm(n_years, mean = 20, sd = 3)

# Blue fish abundance index (competitors): higher = more competition pressure
# Right-skewed — most years moderate, occasional high-abundance years
bluefish_index <- rgamma(n_years, shape = 2, rate = 0.4)

# ── 2. Build the Linear Predictor for Recruitment Probability ─────────────────
#
# Ecological logic:
#   + Warmer springs → better larval survival → higher p(good recruitment)
#   + Moderate summers are best; extreme heat is bad
#     → modeled with a quadratic term (peak around 20°C)
#   - Higher blue fish abundance → competition → lower p(good recruitment)
#
# We tune the intercept so that ~75-80% of years are "good" recruitment years
# (unbalanced toward 1, with bad years being the minority)

summer_temp_centered <- summer_temp - 20   # center at optimal temp

log_odds <- (
  0.5                             # intercept: baseline tilt toward "good"
  + 0.35 * spring_temp              # warmer spring = better
  - 0.08 * summer_temp_centered^2  # quadratic: peak at ~20°C summer temp
  - 0.30 * bluefish_index           # more competitors = worse
)

p_good <- plogis(log_odds)          # convert log-odds to probability [0,1]

# ── 3. Simulate Binary Response Variable ─────────────────────────────────────

recruitment <- rbinom(n_years, size = 1, prob = p_good)

# Check class balance (should be roughly 70-80% good years)
cat("Recruitment class balance:\n")
print(table(recruitment))
cat(sprintf("Proportion of good years: %.1f%%\n\n", mean(recruitment) * 100))




# 3.5 Add red fish abundance column for second example

log_abundance_mean <- (
  4.4                          # intercept → exp(4.4) ≈ 81 fish/ha baseline
  - 0.04 * spring_temp          # weak negative (opposite to recruitment)
  - 0.06 * summer_temp          # stronger negative linear effect
  - 0.12 * bluefish_index       # competition suppression
)

# Simulate with log-normal noise (realistic: variance scales with mean,
# no negative values, right-skewed distribution typical of abundance data)
abundance_raw <- exp(log_abundance_mean + rnorm(n_years, mean = 0, sd = 0.25))

# Add a simple lag-1 autoregressive smoothing pass to introduce
# year-to-year temporal correlation (phi ≈ 0.35)
phi <- 0.35
abundance_ar <- numeric(n_years)
abundance_ar[1] <- abundance_raw[1]
for (i in 2:n_years) {
  abundance_ar[i] <- phi * abundance_ar[i - 1] + (1 - phi) * abundance_raw[i]
}















# ── 4. Assemble the Dataset ───────────────────────────────────────────────────

redfish_data <- tibble(
  year            = 1921:(1921 + n_years - 1),
  spring_temp_c   = round(spring_temp, 2),
  summer_temp_c   = round(summer_temp, 2),
  bluefish_index  = round(bluefish_index, 3),
  recruitment     = factor(recruitment, levels = c(0, 1),
                           labels = c("bad", "good")),
  redfish_abundance = round(abundance_ar, 1)
)

glimpse(redfish_data)

# ── 5. Exploratory Summaries ─────────────────────────────────────────────────

cat("\n--- Summary by recruitment outcome ---\n")
redfish_data %>%
  group_by(recruitment) %>%
  summarise(
    n              = n(),
    mean_spring_c  = mean(spring_temp_c),
    mean_summer_c  = mean(summer_temp_c),
    mean_bluefish  = mean(bluefish_index)
  ) %>%
  print()

# ── 6. Quick Visualizations ──────────────────────────────────────────────────

# Predictor distributions by recruitment outcome
redfish_data %>%
  pivot_longer(cols = c(spring_temp_c, summer_temp_c, bluefish_index),
               names_to = "predictor", values_to = "value") %>%
  ggplot(aes(x = value, fill = recruitment)) +
  geom_density(alpha = 0.55) +
  facet_wrap(~predictor, scales = "free") +
  scale_fill_manual(values = c("bad" = "#d62728", "good" = "#1f77b4")) +
  labs(title = "Predictor distributions by recruitment outcome",
       subtitle = "Superior Red Lake of the Woods — Red Fish",
       x = NULL, y = "Density", fill = "Recruitment") +
  theme_minimal(base_size = 13)

# Recruitment over time
redfish_data %>%
  mutate(recruit_num = as.integer(recruitment == "good")) %>%
  ggplot(aes(x = year, y = recruit_num)) +
  geom_col(aes(fill = recruitment), width = 0.8) +
  scale_fill_manual(values = c("bad" = "#d62728", "good" = "#1f77b4")) +
  labs(title = "Recruitment success over time",
       subtitle = "Superior Red Lake of the Woods — Red Fish",
       x = "Year", y = "Recruitment (1 = good)", fill = "Recruitment") +
  theme_minimal(base_size = 13)


redfish_data %>%
  mutate(recruit_num = as.integer(recruitment == "good")) %>%
  ggplot(aes(x = year, y = redfish_abundance)) +
  geom_line() +
  scale_fill_manual(values = c("bad" = "#d62728", "good" = "#1f77b4")) +
  labs(title = "Red fish abundance over time",
       subtitle = "Superior Red Lake of the Woods — Red Fish",
       x = "Year", y = "Abundance index") +
  theme_minimal(base_size = 13)




write.csv(redfish_data, "data/redfish_recruitment.csv", row.names = FALSE)






