
# sets a nearby CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# List of required packages
pkgs <- c(
  "tidyverse",   # includes dplyr, tidyr, forcats, ggplot2
  "Metrics",
  "dismo",
  "gbm",
  "caret",
  "rpart",
  "smotefamily",
  "fastshap",
  "shapviz",
  "corrplot",
  "pdp",
  "interp",
  "here",
  "randomForest",
  "ape",
  "plotly"
)

# Identify packages not yet installed
installed <- rownames(installed.packages())
to_install <- setdiff(pkgs, installed)

# Install only missing packages
if (length(to_install) > 0) {
  message("Installing missing packages: ", paste(to_install, collapse = ", "))
  install.packages(to_install, dependencies = TRUE)
} else {
  message("All packages already installed 🎉")
}


