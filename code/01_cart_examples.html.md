---
title: "01 - CART code examples"
format: 
  html:
      keep-md: true
editor: visual
number-sections: true
number-depth: 3
toc: true
---

#### Installing and loading packages

The `install_wkshp_packages.R` script will check which packages need to be installed, and install them. So we use `source()` here to make sure they're all installed.


::: {.cell}

```{.r .cell-code}
source(here::here("code", "install_wkshp_packages.R"))
```

::: {.cell-output .cell-output-stderr}

```
All packages already installed 🎉
```


:::
:::


Then we'll load the packages for this file using `library()`.


::: {.cell}

```{.r .cell-code}
library(dplyr)
library(tidyr)
library(here)
library(ggplot2)
library(rpart)
library(Metrics)
library(smotefamily)
```
:::


#### Before we start, a couple notes on some frequently used code that may be new to some of you...

We use the pipe operator `|>` often in the code examples. Simply put, it brings the output of one line into the first argument of the next line. More details available [here](https://tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/) and [here](https://www.datacamp.com/tutorial/pipe-r-tutorial).

For example:


::: {.cell}

```{.r .cell-code}
c(3, 4, 5) |>
  mean()
```
:::


is the same as:


::: {.cell}

```{.r .cell-code}
mean(c(3, 4, 5))
```
:::


Another possibly unfamiliar practice is the `::` notation. This allows a user to specify which package a function should come from. Packages still must be installed, but `library(package_name)` is unnecessary with the `::` notation. For example, if we use `dplyr::mutate()` it's the same as using `mutate()` with the `dplyr` package loaded. We still put the packages used in the code examples in the `library()` calls at the top of each file, but use the `::` notation throughout, especially for lesser-known functions (like `Metrics::accuracy()` to note which package the `accuracy()` function came from).

# Example 1 - Penguins!

![Artwork by @allison_horst](images/lter_penguins.png)

In this example, we'll use the `penguins` dataset to build a couple of example models.

::: {.callout-note collapse="true" title="If you're not using an updated version of R: (need 4.5.0+)"}
If you're not using an updated version of R: (need 4.5.0+), you can either update R to the newest version (recommended), or install and load the `palmerpenguins` package using this code:


::: {.cell}

```{.r .cell-code}
# install.packages("palmerpenguins")
# library(palmerpenguins)
```
:::

:::

## Read in penguins data


::: {.cell}

```{.r .cell-code}
penguins <- penguins |>
  # remove NAs to avoid downstream issues
  tidyr::drop_na()
head(penguins)
```

::: {.cell-output .cell-output-stdout}

```
  species    island bill_len bill_dep flipper_len body_mass    sex year
1  Adelie Torgersen     39.1     18.7         181      3750   male 2007
2  Adelie Torgersen     39.5     17.4         186      3800 female 2007
3  Adelie Torgersen     40.3     18.0         195      3250 female 2007
4  Adelie Torgersen     36.7     19.3         193      3450 female 2007
5  Adelie Torgersen     39.3     20.6         190      3650   male 2007
6  Adelie Torgersen     38.9     17.8         181      3625 female 2007
```


:::

```{.r .cell-code}
str(penguins)
```

::: {.cell-output .cell-output-stdout}

```
'data.frame':	333 obs. of  8 variables:
 $ species    : Factor w/ 3 levels "Adelie","Chinstrap",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ island     : Factor w/ 3 levels "Biscoe","Dream",..: 3 3 3 3 3 3 3 3 3 3 ...
 $ bill_len   : num  39.1 39.5 40.3 36.7 39.3 38.9 39.2 41.1 38.6 34.6 ...
 $ bill_dep   : num  18.7 17.4 18 19.3 20.6 17.8 19.6 17.6 21.2 21.1 ...
 $ flipper_len: int  181 186 195 193 190 181 195 182 191 198 ...
 $ body_mass  : int  3750 3800 3250 3450 3650 3625 4675 3200 3800 4400 ...
 $ sex        : Factor w/ 2 levels "female","male": 2 1 1 1 2 1 2 1 2 2 ...
 $ year       : int  2007 2007 2007 2007 2007 2007 2007 2007 2007 2007 ...
```


:::
:::


### First, we'll split the training and test sets

We'll use a random 80% of rows for the training set, and the remaining 20% for the test set.


::: {.cell}

```{.r .cell-code}
nrow_train <- ceiling(0.8 * nrow(penguins)) # ceiling used to make it an integer

set.seed(424) # set a seed for consistent splits if re-run

penguins_train <- penguins |>
  # make row number a column to use as id
  dplyr::mutate(rownum = dplyr::row_number()) |>
  # slice random sample
  dplyr::slice_sample(n = nrow_train)

str(penguins_train)
```

::: {.cell-output .cell-output-stdout}

```
'data.frame':	267 obs. of  9 variables:
 $ species    : Factor w/ 3 levels "Adelie","Chinstrap",..: 3 3 1 3 2 1 3 2 3 1 ...
 $ island     : Factor w/ 3 levels "Biscoe","Dream",..: 1 1 2 1 2 2 1 2 1 2 ...
 $ bill_len   : num  47.5 42.9 36.8 42.6 49.2 40.8 50 51.3 47.7 39.2 ...
 $ bill_dep   : num  15 13.1 18.5 13.7 18.2 18.9 15.3 18.2 15 18.6 ...
 $ flipper_len: int  218 215 193 213 195 208 220 197 216 190 ...
 $ body_mass  : int  4950 5000 3500 4950 4400 4300 5550 3750 4750 4250 ...
 $ sex        : Factor w/ 2 levels "female","male": 1 1 1 1 2 2 2 2 1 2 ...
 $ year       : int  2009 2007 2009 2008 2007 2008 2007 2007 2008 2009 ...
 $ rownum     : int  235 171 127 182 285 90 175 273 215 141 ...
```


:::

```{.r .cell-code}
penguins_test <- penguins |>
  # make row number a column to use as id
  dplyr::mutate(rownum = dplyr::row_number()) |>
  # test set is what is left, ids not found in train
  dplyr::filter(!rownum %in% penguins_train$rownum)

str(penguins_test)
```

::: {.cell-output .cell-output-stdout}

```
'data.frame':	66 obs. of  9 variables:
 $ species    : Factor w/ 3 levels "Adelie","Chinstrap",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ island     : Factor w/ 3 levels "Biscoe","Dream",..: 3 3 1 2 2 2 1 1 1 1 ...
 $ bill_len   : num  40.3 39.2 40.5 40.9 39.2 42.3 39.6 35.7 41.3 37.6 ...
 $ bill_dep   : num  18 19.6 18.9 18.9 21.1 21.2 17.7 16.9 21.1 17 ...
 $ flipper_len: int  195 195 180 184 196 191 186 185 195 185 ...
 $ body_mass  : int  3250 4675 3950 3900 4150 4150 3500 3150 4400 3600 ...
 $ sex        : Factor w/ 2 levels "female","male": 1 2 2 2 2 2 1 1 2 1 ...
 $ year       : int  2007 2007 2007 2007 2007 2007 2008 2008 2008 2008 ...
 $ rownum     : int  3 7 25 29 31 44 45 55 56 57 ...
```


:::
:::


## CART model - regression example

For this first example model, let's try to predict body mass using flipper length and bill depth.

$$ \text{body mass} \sim  \text{flipper length} + \text{bill depth} $$

![Artwork by @allison_hurst](images/culmen_depth.png){width="50%" fig-align="left"}

For Classification and Regression Trees, we'll use the `rpart` package and the `rpart` function with the default parameters.


::: {.cell .column-page-right layout-align="left"}

```{.r .cell-code}
mod_mass <- rpart(body_mass ~ flipper_len + bill_dep,
                  data = penguins_train,
                  method = "anova")

# Visualize the tree
plot(mod_mass)
text(mod_mass, digits = 3)
```

::: {.cell-output-display}
![](01_cart_examples_files/figure-html/build_mod_mass-1.png){fig-align='left' width=1152}
:::
:::


To evaluate the model, we make predictions from the model for the rows in the test set, then visually assess the output and calculate performance metrics.


::: {.cell layout-align="center"}

```{.r .cell-code}
# save predictions as new column in penguins_test
penguins_test$predicted_mass <- predict(mod_mass, penguins_test)

# plot to visually assess
ggplot(data = penguins_test,
       aes(x = body_mass, y = predicted_mass)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = "dashed")
```

::: {.cell-output-display}
![](01_cart_examples_files/figure-html/predict_mod_mass-1.png){fig-align='center' width=768}
:::
:::


Notice that the `predicted_mass` values are only the ones on the bottom of the tree above, with just 6 unique values. For a simple regression tree like this one, this can limit the resolution of the predictions, but for more complicated trees (or when we aggregate multiple trees) that doesn't typically remain an issue.

### Calculating the Root Mean Squared Error (RMSE)

The root mean squared error (RMSE) tells us how close our predicted value is to our observed value, on average.

RMSE retains the same units as the dependent variable, so it should be interpreted with that context.

$$ RMSE = \sqrt{ \frac{\sum (\text{observed} - \text{predicted})^2 }{n} } $$


::: {.cell layout-align="center"}

```{.r .cell-code}
# root mean squared error manual calculation
sqrt( sum( (penguins_test$body_mass - penguins_test$predicted_mass)^2 ) / nrow(penguins_test) )
```

::: {.cell-output .cell-output-stdout}

```
[1] 422.8948
```


:::

```{.r .cell-code}
# or use the Metrics package
rmse <- Metrics::rmse(actual = penguins_test$body_mass, 
                      predicted = penguins_test$predicted_mass)
rmse
```

::: {.cell-output .cell-output-stdout}

```
[1] 422.8948
```


:::

```{.r .cell-code}
mean(penguins_test$body_mass)
```

::: {.cell-output .cell-output-stdout}

```
[1] 4293.561
```


:::

```{.r .cell-code}
rmse / mean(penguins_test$body_mass)
```

::: {.cell-output .cell-output-stdout}

```
[1] 0.09849513
```


:::
:::


This last value is called the Coefficient of Variation of the RMSE, which can allow for cross-dataset comparisons of model performance since it's scaled to the mean of the dependent variable.

### Comparing test set performance to training set performance

Just to demonstrate the need for independent test sets, here we calculate the RMSE for model predictions on the training dataset.


::: {.cell}

```{.r .cell-code}
penguins_train$fitted_mass <- predict(mod_mass, penguins_train)

Metrics::rmse(actual = penguins_train$body_mass, 
              predicted = penguins_train$fitted_mass)
```

::: {.cell-output .cell-output-stdout}

```
[1] 342.6651
```


:::
:::


As expected, the model performs better on data were used to train it. If we relied solely on evaluation metrics calculated on the training data, we would be over-estimating the predictive performance of the model when predicted for new data.

For other model algorithms, this becomes even more pronounced, so "proper" evaluation of model predictions is highly important and the details matter, but "proper" often changes meaning depending on the modeling context.

## CART model - classification example

For this second example, let's try to predict penguin sex using flipper length and bill depth.

$$ \text{sex} \sim \text{flipper length} + \text{bill depth} $$


::: {.cell layout-align="center"}

```{.r .cell-code}
mod_sex <- rpart(sex ~ flipper_len + bill_dep,
                 data = penguins_train,
                 method = "class")

# Visualize the tree
plot(mod_sex)
text(mod_sex, digits = 3)
```

::: {.cell-output-display}
![](01_cart_examples_files/figure-html/build_mod_sex-1.png){fig-align='center' width=768}
:::
:::


Again, we'll predict the model. But `rpart` provides predictions as probabilities for each class of the dependent variable, so we have some data manipulation to do.


::: {.cell layout-align="center"}

```{.r .cell-code}
# predictions come as probabilities of each class
predict(mod_sex, penguins_test) |>
  head()
```

::: {.cell-output .cell-output-stdout}

```
     female      male
1 0.9009901 0.0990099
2 0.2571429 0.7428571
3 0.2571429 0.7428571
4 0.2571429 0.7428571
5 0.2571429 0.7428571
6 0.2571429 0.7428571
```


:::

```{.r .cell-code}
# save predictions as new column in penguins_test
penguins_test$predicted_sex <- 
  # reduce predicted probabilities to just the predicted sex
  predict(mod_sex, penguins_test) |>
  as.data.frame() |>
  dplyr::mutate(predicted_sex = ifelse(female > male, "female", "male")) |>
  dplyr::pull(predicted_sex)
```
:::


Then we'll calculate the **confusion matrix**, which tells us how "confused" our model is. It's a table that shows the observed and predicted sex and the number of rows that get correctly/incorrectly predicted.


::: {.cell}

```{.r .cell-code}
# calculate the confusion matrix, manually
penguins_test |>
  dplyr::group_by(sex, predicted_sex) |>
  dplyr::summarize(count = dplyr::n(), .groups = "drop") |>
  tidyr::pivot_wider(id_cols = sex, names_from = predicted_sex,
                     names_prefix = "predicted_", values_from = count)
```

::: {.cell-output .cell-output-stdout}

```
# A tibble: 2 × 3
  sex    predicted_female predicted_male
  <fct>             <int>          <int>
1 female               26              4
2 male                  4             32
```


:::
:::


### Calculating prediction accuracy

Here, "accuracy" has a specific definition that means the proportion of rows classified correctly:

$$ Accuracy = \frac{\text{correct classifications}}{\text{total classifications}} $$

That means from our confusion matrix above, we can calculate accuracy by:

$$ Accuracy = \frac{26 + 32}{26 + 4 + 4 + 32} = \frac{58}{66} \approx 0.87 $$

Or, we can use the `Metrics` package:


::: {.cell}

```{.r .cell-code}
Metrics::accuracy(actual = penguins_test$sex,
                  predicted = penguins_test$predicted_sex)
```

::: {.cell-output .cell-output-stdout}

```
[1] 0.8787879
```


:::
:::


Accuracy is a simple to understand measure of performance, but it is limited in several ways. For this example, we'll stop here, but we'll talk about other performance metrics for classification in later examples.

### Another comparison of test set performance to training set performance


::: {.cell}

```{.r .cell-code}
penguins_train$fitted_sex <- # reduce predicted probabilities to just the predicted sex
  predict(mod_sex, penguins_train) |>
  as.data.frame() |>
  dplyr::mutate(fitted_sex = ifelse(female > male, "female", "male")) |>
  dplyr::pull(fitted_sex)


Metrics::accuracy(actual = penguins_train$sex, 
                  predicted = penguins_train$fitted_sex)
```

::: {.cell-output .cell-output-stdout}

```
[1] 0.835206
```


:::
:::


This time, the performance was actually worse for the training set than for the test set. This can happen, but is less likely than the opposite.

But it also shows that relying on just one test set can be limiting. Next we'll show a few more examples of how to evaluate models using other cross-validation methods.

# Example 2 - Unbalanced data

We often have messy, unbalanced, sample-size-limited datasets in ecology and environmental science, and we can handle this in a few different ways depending on our purpose.

Here, we'll work through an example with unbalanced data to show a useful approach for dealing with the reality of many of our datasets.

## Red fish recruitment example

We'll use recruitment data from a species of fish called "red fish" that lives in a fictional lake called "Superior Red Lake of the Woods" in Minnesota. The 100 years of data were "collected" via simulations generated with the help of [Claude](https://claud.ai).

![Red fish in Superior Red Lake of the Woods, "art" by Claude](images/superior_red_lake_of_the_woods.svg){width="50%" fig-align="left"}


::: {.cell}

```{.r .cell-code}
redfish_data <- read.csv(here::here("data", "redfish_recruitment.csv"))
str(redfish_data)
```

::: {.cell-output .cell-output-stdout}

```
'data.frame':	100 obs. of  6 variables:
 $ year             : int  1921 1922 1923 1924 1925 1926 1927 1928 1929 1930 ...
 $ spring_temp_c    : num  12 11.4 12.5 13.2 10.2 ...
 $ summer_temp_c    : num  19.7 18.9 20.4 18.8 17.8 ...
 $ bluefish_index   : num  0.882 1.721 0.811 2.472 3.945 ...
 $ recruitment      : chr  "good" "bad" "good" "good" ...
 $ redfish_abundance: num  8 12.7 15.3 11.2 10 7.4 9.8 9.5 8.4 6.3 ...
```


:::
:::


Successful "recruitment", for our purposes, occurs when an individual fish goes from an egg to an adult fish. Red fish recruitment is "good" most years, but "bad" in others, and the bad years really affect the overall population because the red fish is a short-lived species. "Good" recruitment is hypothesized to depend on spring and summer temperatures, and the abundance (index) of a potential competitor "blue fish".

We want to be able to predict whether recruitment will be good or bad for the future, based on these hypothesized predictors.

$$ \text{recruitment} \sim \text{spring temp} + \text{summer temp} + \text{blue fish index} $$ Because we want to predict the *future*, we probably shouldn't rely on a randomized test set , it's probably more appropriate to select our test set with time considered. Otherwise we'd be evaluating how to predict for a given year when we already know the future.

So we'll train a model using the first 80 years of data, then evaluate the model's ability to predict the next 20 years. In theory, if we then train the same model on all 100 years of data, we should have *similar* performance when we predict the future 20 years.


::: {.cell}

```{.r .cell-code}
range(redfish_data$year)
```

::: {.cell-output .cell-output-stdout}

```
[1] 1921 2020
```


:::

```{.r .cell-code}
year_split <- 2000

redfish_train <- redfish_data |>
  dplyr::filter(year <= 2000)

redfish_test <- redfish_data |>
  dplyr::filter(year > 2000)
```
:::


Then, like above, we'll build a CART model using the training data and measure the accuracy on the test set.


::: {.cell}

```{.r .cell-code}
mod_redfish_train <- rpart(
  recruitment ~ spring_temp_c + summer_temp_c + bluefish_index,
  data = redfish_train,
  method = "class"
)

# Visualize the tree
plot(mod_redfish_train)
text(mod_redfish_train, digits = 3)
```

::: {.cell-output-display}
![](01_cart_examples_files/figure-html/redfish_modbuild-1.png){width=672}
:::
:::



::: {.cell}

```{.r .cell-code}
redfish_test$pred_recruitment <- 
  # reduce predicted probabilities to just the predicted sex
  predict(mod_redfish_train, redfish_test) |>
  as.data.frame() |>
  dplyr::mutate(pred_recruitment = ifelse(good > bad, "good", "bad")) |>
  dplyr::pull(pred_recruitment)

redfish_test |>
  dplyr::group_by(recruitment, pred_recruitment) |>
  dplyr::summarize(count = dplyr::n(), .groups = "drop") |>
  tidyr::pivot_wider(id_cols = recruitment, names_from = pred_recruitment,
                     names_prefix = "predicted_", values_from = count)
```

::: {.cell-output .cell-output-stdout}

```
# A tibble: 2 × 3
  recruitment predicted_bad predicted_good
  <chr>               <int>          <int>
1 bad                     4              3
2 good                   NA             13
```


:::

```{.r .cell-code}
Metrics::accuracy(actual = redfish_test$recruitment,
                  predicted = redfish_test$pred_recruitment)
```

::: {.cell-output .cell-output-stdout}

```
[1] 0.85
```


:::
:::


Notice how our accuracy measure is dependent on just 20 rows of data, and because our data are not balanced, it's hard to tell if we're doing a good job predicting good and bad years from the confusion matrix. We even have a missing element of the confusion matrix that isn't represented in the predictions from our test set.

If we had an equal number of good and bad years, we could compare this accuracy metric to 0.5 (coin flip would be expected to get half of them correct). But because good years are more common than bad years, we actually have to compare this accuracy measure to an unfair coin...

As a more extreme example, let's say our balance of good vs bad years was actually 90 good years and 10 bad years...a model that predicts good years all the time would achieve a 90% accuracy(!). So any model that gets built would have to be compared relative to that standard in order to be considered "useful".

Back to our actual example, we can calculate the accuracy measure if we just predicted "good" every time for our test set:


::: {.cell}

```{.r .cell-code}
Metrics::accuracy(actual = redfish_test$recruitment,
                  predicted = rep("good", nrow(redfish_test)))
```

::: {.cell-output .cell-output-stdout}

```
[1] 0.65
```


:::
:::


So if we just said "good" every time, we'd be right 65 percent of the time (for the test set). So our model achieving 85 percent accuracy is an improvement, but not a huge improvement.

### Notes on how unbalanced data can affect models

We saw in the above example that unbalanced data can affect the *evaluation* of a model, making it harder for a model to be considered "useful" in terms of improving model accuracy in highly unbalanced datasets.

But when response variables are imbalanced, there are also fewer data points that correspond to that less-frequent class. If we were trying to predict red fish recruitment and 90% of the years were good, we'd be trying to use just 10 years of data to understand when recruitment is bad. So the "functional" sample size in unbalanced datasets is sometimes much smaller than it may seem.

In summary, data imbalance affects models in two ways: 1) by complicating the measurement of performance and 2) by reducing the sample size relevant to the question you're asking.

While we walked through this using a binary example (good vs bad), it gets even more complicated when your classification problem models even more categories (e.g., predicting which snack someone will eat).

Next, we'll show a technique that synthetically over-samples the minority class(es) to provide a balanced dataset for model training.

## Red fish recruitment continued...SMOTE Example

#### About SMOTE

SMOTE = Synthetic Minority Over-sampling Technique<sup>1</sup>

SMOTE augments datasets by over-sampling the minority class (bad recruitment in our red fish example) using a K-nearest neighbors approach. It takes each row in the minority class, finds its K (e.g., 5) nearest neighbors and uses them to simulate a new row that it labels with the minority class (e.g., "bad").

It helps avoid over-fitting compared to replicating the rows in the minority class, and helps provide a balanced dataset for model training.

One limitation is that it is limited to numeric variables because of the specifics of the nearest neighbors approach in the `smotefamily` package we'll use, so other packages or approaches would need to be used with categorical predictors (e.g., [PDtoolkit](https://github.com/andrija-djurovic/PDtoolkit)).

<sup>1</sup>Chawla et al. (2002). SMOTE: Synthetic Minority Over-sampling Technique. Journal of Artificial Intelligence Research 16: 321-357. <https://doi.org/10.1613/jair.953>

#### Our example with SMOTE

In our red fish example, we'll use SMOTE to over-sample bad recruitment years. There are some nuances regarding how to handle the test set, but we'll try not to get side-tracked.

For the purposes of this example, we'll use SMOTE on the training set only since we're using the year 2000 as a cutoff. If we used SMOTE on all of the data and then split the training and test sets, we would be including future information (in the form of neighbors that SMOTE uses) in our training set. So to maintain that separation of the future, we'll use SMOTE on the training set only. This means that we'll still have an un-balanced test set, but we'll have better balance in the training set (and a better sample size for the model training too).

This is *very* use-case dependent, so there are many possible ways to do this "correctly" in different situations.


::: {.cell}

```{.r .cell-code}
train_X <- redfish_train |>
  dplyr::select(spring_temp_c, summer_temp_c, bluefish_index)

train_smote <-
  smotefamily::SMOTE(X = train_X, target = redfish_train$recruitment,
                     K = 5, dup_size = 0)

# smote object
str(train_smote)
```

::: {.cell-output .cell-output-stdout}

```
List of 10
 $ data    :'data.frame':	132 obs. of  4 variables:
  ..$ spring_temp_c : num [1:132] 8.61 6.21 11.42 11.69 13.37 ...
  ..$ summer_temp_c : num [1:132] 17.6 16.1 18.9 12.2 12.6 ...
  ..$ bluefish_index: num [1:132] 12.93 6.86 1.72 1.95 17.95 ...
  ..$ class         : chr [1:132] "bad" "bad" "bad" "bad" ...
 $ syn_data:'data.frame':	52 obs. of  4 variables:
  ..$ spring_temp_c : num [1:52] 8.7 7.6 7.02 6.96 5.77 ...
  ..$ summer_temp_c : num [1:52] 16.3 17 16.6 21.7 16.2 ...
  ..$ bluefish_index: num [1:52] 10.37 10.37 8.9 12.61 5.61 ...
  ..$ class         : chr [1:52] "bad" "bad" "bad" "bad" ...
 $ orig_N  :'data.frame':	67 obs. of  4 variables:
  ..$ spring_temp_c : num [1:67] 12.01 12.54 13.21 10.19 8.82 ...
  ..$ summer_temp_c : num [1:67] 19.7 20.4 18.8 17.8 21.8 ...
  ..$ bluefish_index: num [1:67] 0.882 0.811 2.472 3.945 10.545 ...
  ..$ class         : chr [1:67] "good" "good" "good" "good" ...
 $ orig_P  :'data.frame':	13 obs. of  4 variables:
  ..$ spring_temp_c : num [1:13] 8.61 6.21 11.42 11.69 13.37 ...
  ..$ summer_temp_c : num [1:13] 17.6 16.1 18.9 12.2 12.6 ...
  ..$ bluefish_index: num [1:13] 12.93 6.86 1.72 1.95 17.95 ...
  ..$ class         : chr [1:13] "bad" "bad" "bad" "bad" ...
 $ K       : num 5
 $ K_all   : NULL
 $ dup_size: num 4
 $ outcast : NULL
 $ eps     : NULL
 $ method  : chr "SMOTE"
 - attr(*, "class")= chr "gen_data"
```


:::

```{.r .cell-code}
# previous training set
nrow(redfish_train)
```

::: {.cell-output .cell-output-stdout}

```
[1] 80
```


:::

```{.r .cell-code}
table(redfish_train$recruitment)
```

::: {.cell-output .cell-output-stdout}

```

 bad good 
  13   67 
```


:::

```{.r .cell-code}
# smote training set
nrow(train_smote$data)
```

::: {.cell-output .cell-output-stdout}

```
[1] 132
```


:::

```{.r .cell-code}
table(train_smote$data$class)
```

::: {.cell-output .cell-output-stdout}

```

 bad good 
  65   67 
```


:::
:::



::: {.cell}

```{.r .cell-code}
mod_redfish_train_smote <- rpart(
  class ~ spring_temp_c + summer_temp_c + bluefish_index,
  data = train_smote$data,
  method = "class"
)

# Visualize the tree
plot(mod_redfish_train_smote)
text(mod_redfish_train_smote, digits = 3)
```

::: {.cell-output-display}
![](01_cart_examples_files/figure-html/redfish_smote_build-1.png){width=672}
:::
:::



::: {.cell}

```{.r .cell-code}
redfish_test$pred_recruitment_smote <- 
  # reduce predicted probabilities to just the predicted sex
  predict(mod_redfish_train_smote, redfish_test) |>
  as.data.frame() |>
  dplyr::mutate(pred_recruitment = ifelse(good > bad, "good", "bad")) |>
  dplyr::pull(pred_recruitment)

redfish_test |>
  dplyr::group_by(recruitment, pred_recruitment_smote) |>
  dplyr::summarize(count = dplyr::n(), .groups = "drop") |>
  tidyr::pivot_wider(id_cols = recruitment, names_from = pred_recruitment_smote,
                     names_prefix = "predicted_", values_from = count)
```

::: {.cell-output .cell-output-stdout}

```
# A tibble: 2 × 3
  recruitment predicted_bad predicted_good
  <chr>               <int>          <int>
1 bad                     5              2
2 good                   NA             13
```


:::

```{.r .cell-code}
Metrics::accuracy(actual = redfish_test$recruitment,
                  predicted = redfish_test$pred_recruitment_smote)
```

::: {.cell-output .cell-output-stdout}

```
[1] 0.9
```


:::
:::


The accuracy and confusion matrix have changed with the SMOTE additional data rows! It's hard to tell if that's a meaningful improvement in this example, since adding the SMOTE adds complexity, but in some cases it can be extremely useful for getting models to converge and have useful predictions.

::: callout-note
## Thinking question

We have an NA in the confusion matrix for the test set, and generally a small number of rows in each element of the confusion matrix too. Should we use SMOTE on the test set to match the training set augmentation? Or is it better to keep the test set un-altered for proper evaluation?
:::

## Some more notes on unbalanced data - row weights

While we demonstrated SMOTE in the example above, there is another way to handle unbalanced data in the model training step, especially if you already have a sufficient sample size for the model algorithm you're using.

Many algorithms have an option to supply "weights" (sometimes called "case weights" or "row weights"). The relative weight for a row controls how likely that row is to be sampled within a specific step of the model algorithm.

In our example, we might down-weight the good recruitment years to balance our dataset so that we might be able to better separate the good from the bad in model training.

These are especially useful in species distribution models when using presence-only data or for rare-event prediction. For example, if you're trying to predict an outcome tied to rare weather events, you need to compare it to the entire range of possible weather events. In this situation, you could easily end up with 10,000, 1 million, or more "non-events" to compare with a sample of 100 or fewer observed events. So by down-weighting the non-events, the model training process can occur with a balanced dataset by considering the non-events less often that the observed events at different stages in the model algorithm's process.

A very small example on how to calculate weights for a rare-event prediction:


::: {.cell}

```{.r .cell-code}
# generate a fake dataset
rare_event_df <- data.frame(
  rare_event = sample(c("yes", "no"),
                      size = 10000,
                      prob = c(0.01, 1), replace = TRUE),
  pred1 = rnorm(10000),
  pred2 = rnorm(10000, mean = 100, sd = 50)
)

str(rare_event_df)
```

::: {.cell-output .cell-output-stdout}

```
'data.frame':	10000 obs. of  3 variables:
 $ rare_event: chr  "no" "no" "no" "no" ...
 $ pred1     : num  -0.956 -0.451 1.989 -0.392 0.196 ...
 $ pred2     : num  112 91.2 92.4 110.2 156.2 ...
```


:::

```{.r .cell-code}
table(rare_event_df$rare_event)
```

::: {.cell-output .cell-output-stdout}

```

  no  yes 
9909   91 
```


:::

```{.r .cell-code}
# calculate row weights
non_event_wts <- sum(rare_event_df$rare_event=="yes") / sum(rare_event_df$rare_event=="no")

rare_event_df <- rare_event_df |>
  dplyr::mutate(
    row_weights = ifelse(rare_event == "yes", 1, non_event_wts)
  )
```
:::


Then the sum of the row weights across the whole dataset shows the "balance" of the dataset in the eyes of the model algorithm.


::: {.cell}

```{.r .cell-code}
# look at sum of row weights, shows dataset balance
rare_event_df |>
  dplyr::filter(rare_event == "yes") |>
  dplyr::pull(row_weights) |>
  sum()
```

::: {.cell-output .cell-output-stdout}

```
[1] 91
```


:::

```{.r .cell-code}
rare_event_df |>
  dplyr::filter(rare_event == "no") |>
  dplyr::pull(row_weights) |>
  sum()
```

::: {.cell-output .cell-output-stdout}

```
[1] 91
```


:::
:::


Then the model training code would look something like:


::: {.cell}

```{.r .cell-code}
mod_rare_event <- rpart(
  rare_event ~ pred1 + pred2,
  data = rare_event_df,
  method = "class",
  weights = row_weights
)

plot(mod_rare_event)
text(mod_rare_event, digits = 3)
```

::: {.cell-output-display}
![](01_cart_examples_files/figure-html/rare_event_rpart-1.png){width=672}
:::
:::


This tree looks a little chaotic because the predictors were fully random and not related to the rare event. But should also serve as a warning to finding patterns where they don't necessarily exist...
