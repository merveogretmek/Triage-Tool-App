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

3. Add or Prepare Your Training Data

- The file `createModels.R` references a CSV dataset named `train_data.csv`.
- Ensure you have a suitable dataset in place if you plan to retrain the models. Place it in your app directory before running `createModels.R`.

4. Run the Application

- Open `app.R` in RStudio or run the command below in your R console:

```r
shiny::runApp("path/to/your/app.R")
```

- The application will launch in your web browser.
- Fill in the clinical data in the UI, then click **Compute** to get predictions, or **Refresh Page** to clear inputs.

## How It Works

1. User Input
- Clinicians enter demographic and clinical data (hematemesis, melena, vital signs, lab values, etc.).
- Physician diagnosis fields are also available (e.g., best estimate for the bleeding source, endoscopy necessity, disposition).

2. Model Predictions
- When **Compute** is clicked, the Shiny server assembles these inputs into a single data frame, then passes the data frame to the four prediction functions in `makePredictions.R`.
- Each function applies the pre-trained Random Forest (loaded from `createModels.R`) to generate predicted probabilities for each outcome.

3. Results Visualization
- The predicted probabilities are mapped into a stacked bar plot via the custom plotting functions in `displayPlots.R`.
- Each plot also displays the **three most important features** for its respective model.

## Disclaimers

This project is intended as a demonstration of a clinical prediction Shiny app using Random Forest models. It is not meant to serve as a replacement for real clinical judgment or as an approved medical device.

If you use actual patient data, ensure compliance with healthcare privacy laws and regulations.


Contributions, issues, and feature requests are welcome! Feel free to check the Issues page for tasks that need help or submit your own issue/PR.
