# A Shiny App for Diagnosing & Triage of Patients to Urgent Endoscopy

This repository contains a Shiny application designed to help clinicians predict:

1. Source of bleeding (upper, mid, or lower GI).
2. Need for urgent endoscopy.
3. Appropriate patient disposition (ICU vs. non-ICU).

The tool uses Random Forest models trained on clinical data to provide probabilistic outputs for each prediction.

## Contents

- `app.R`
The main Shiny application file. t sets up the user interface (UI) for data entry and model output visualizations and defines the server logic that responds to user inputs.

- `createModels.R`
Contains the scripts for training four separate Random Forest models:
1. `model_S` for predicting the source of bleeding.
2. `model_R` for predicting resuscitation needs.
3. `model_E` for predicting urgent endoscopy needs.
4. `model_D` for predicting patient disposition.

This file reads `train_data.csv` (not included in this repository) to train and generate these models.

- `displayPlots.R`
Provides functions (`renderSourceOutput()`, `renderEndoscopyOutput()`, and `renderDispositionOutput()`) to generate custom ggplot-based plots for visualizing each model's predictions and most important variables.

- `makePredictions.R`
Defines functions to run new data points (collected from the UI) through the trained Random Forest models. These functions generate summary data frames with predicted probabilities, which are then used by `displayPlots.R` to create the visual outputs.

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/merveogretmek/triage-tool-app.git
```

2. Install the required R packages

Make sure you have R version 4.0 or above and the following libraries installed:

```r
install.packages(c(
  "shiny",
  "randomForest",
  "readr",
  "ggplot2",
  "dplyr",
  "rsconnect",
  "pins"
))
```
