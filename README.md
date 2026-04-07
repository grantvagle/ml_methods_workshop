# README for Machine Learning Methods Workshop

## Workshop facilitators

The workshop was developed by Grant Vagle, Jeremiah Shrovnal, and Lynn Waterhouse. Liv Nyffeler and Molly Tilsen provided feedback on workshop content and helped manage the event.

Funding for this workshop was provided by the Minnesota Environment and Natural Resources Trust Fund as recommended by the Legislative-Citizen Commission on Minnesota Resources (LCCMR).

## Workshop outline

1. What is machine learning? This workshop will focus on supervised machine learning
2. Classification and regression - focus on model evaluation and cross-validation
3. Random forests, handling correlated predictor variables, and basic model interpretation
4. Boosted regression trees, model tuning, and model interpretation with SHAP values


## Before you arrive

- Download and install R and RStudio: [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)
- If you're not familiar with the `tidyverse` or code piping, take a look [here](https://bookdown.org/yih_huynh/Guide-to-R-Book/tidyverse.html). We'll be using the `tidyverse` for data manipulation a lot in the workshop.
- Install packages if you don't already have them:
  - `dplyr`, `tidyr`, `forcats`, `ggplot2` (or install whole `tidyverse`)
  - `Metrics`
  - `dismo`
  - `gbm`
  - `caret`
  - `rpart`
  - `smotefamily`
  - `fastshap`
  - `shapviz`
  - `parallel`
  - `corrplot`
  
<!--
  ```
install.packages("tidyverse")
install.packages("Metrics")
install.packages("dismo")
install.packages("gbm")
install.packages("caret")
install.packages("rpart")
install.packages("smotefamily")
install.packages("fastshap")
install.packages("shapviz")
install.packages("parallel")
install.packages("corrplot")
```
-->

- Take a look around this repository

## How to use this repository

Not familiar with GitHub? No problem, download the `.zip` file by clicking the green "Code" button at the top of the page, then click "Download Zip". Once the download is finished, unzip the file and you can open the `.RProj` file in RStudio on your computer.

Comfortable with GitHub? You can `clone` or `fork` this repo to use it locally, or just download the `.zip` as above.


## Organization of this repository

`slides/`

  - Contains pdfs and powerpoints of all slides used in the workshop presentations.


`code/`

  - `01_cart_examples.qmd` - 1st set of example code for CART models, model evaluation, and cross-validation.
  - `02_randomforest_examples.qmd` - Example code for Random Forest models, including model tuning and handling correlated predictors, and basic model interpretation.
  - `03_BRTs_examples.qmd` - Example code for Boosted Regression Tree models, including model tuning and advanced model interpretation with SHAP values.


`data/`

  - Contains the datasets referenced in the code files.



