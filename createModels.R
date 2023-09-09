library(readr)
library(randomForest)

# Importing the data
train_data <- read_delim(
  "train_data.csv",
  delim = ";",
  escape_double = FALSE,
  trim_ws = TRUE
)

train_data$Disposition[train_data$Disposition != "1"] <- 2

data <- na.omit(train_data)

# Training the Model

# 1-Source 

# Formula
formula_S <- Source ~
  Hx_of_GIB + Hematochezia + Hematemesis + Melena +
  Syncope + Risk_for_Stress_Ulcer + Cirrhosis +
  ASA_NSAID + SBP + DBP + HR + Orthostatis + NG_Lavage + Rectal +
  Plt + Cr + BUN + INR

variables_S <- all.vars(formula_S)

# Training
# Define the number of explanatory variables
p_S <- length(variables_S) - 1  # assuming the response variable is also in the data

# Convert the response variable to a factor
data$Source <- as.factor(data$Source)

levels(data$Source) <- c("Upper", "Lower", "Mid") # O = Upper, 1 = Lower, 2 = Mid

# Fit the Random Forest model
model_S <- randomForest(
  formula_S, 
  data = data, 
  ntree = 500, 
  sampsize = nrow(data), 
  mtry = floor(sqrt(p_S)), 
  importance = TRUE
)

# Importance Table
importance_table_S <- importance(model_S)

# Assuming the table is stored in importance_table
# Sorting by MeanDecreaseAccuracy
sorted_importance_S <- importance_table_S[order(-importance_table_S[,"MeanDecreaseAccuracy"]), ]

# Get the names of the top 3 variables
top_three_vars_S <- rownames(sorted_importance_S)[1:3]

# Print the top three variables
print(top_three_vars_S)



# 2- Resuscitation

# The formula
formula_R <- Resuscitation ~
  Hx_of_GIB + Hematochezia + Hematemesis + Melena + Duration +
  Syncope + Unstable_CAD + 
  SBP + DBP + HR + Orthostatis + NG_Lavage + Rectal + Hct +
  Hct_Drop + Cr + BUN + INR

variables_R <- all.vars(formula_R)

# Training
# Define the number of explanatory variables
p_R <- length(variables_R) - 1  # assuming the response variable is also in the data

data$Resuscitation <- as.factor(data$Resuscitation)

levels(data$Resuscitation) <- c("Yes", "No")

model_R <-randomForest(
  formula_R, 
  data = data, 
  ntree = 500, 
  sampsize = nrow(data), 
  mtry = floor(sqrt(p_R)), 
  importance = TRUE
)

# Importance Table
importance_table_R <- importance(model_R)

# Assuming the table is stored in importance_table
# Sorting by MeanDecreaseAccuracy
sorted_importance_R <- importance_table_R[order(-importance_table_R[,"MeanDecreaseAccuracy"]), ]

# Get the names of the top 3 variables
top_three_vars_R <- rownames(sorted_importance_R)[1:3]

# Print the top three variables
print(top_three_vars_R)

# 3- Endoscopy

# Formula
formula_E <- Endoscopy ~
  Hematochezia + Hematemesis + Melena + Duration +
  Syncope + Risk_for_Stress_Ulcer + Cirrhosis +
  ASA_NSAID + SBP + DBP + HR + Orthostatis + NG_Lavage + Rectal + Hct +
  Hct_Drop + Plt + Cr + BUN + INR

variables_E <- all.vars(formula_E)
# Training
# Define the number of explanatory variables
p_E <- length(variables_E) - 1  # assuming the response variable is also in the data

data$Endoscopy <- as.factor(data$Endoscopy)

levels(data$Endoscopy) <- c("Yes", "No")

model_E <-
  randomForest(
    formula_E, 
    data = data, 
    ntree = 500, 
    sampsize = nrow(data), 
    mtry = floor(sqrt(p_R)), 
    importance = TRUE
  )

# Importance Table
importance_table_E <- importance(model_E)

# Assuming the table is stored in importance_table
# Sorting by MeanDecreaseAccuracy
sorted_importance_E <- importance_table_E[order(-importance_table_E[,"MeanDecreaseAccuracy"]), ]

# Get the names of the top 3 variables
top_three_vars_E <- rownames(sorted_importance_E)[1:3]

# Print the top three variables
print(top_three_vars_E)

# 4 - Disposition

# Formula
formula_D <- Disposition ~ Age +
  Hematochezia + Hematemesis + Melena + Duration +
  Syncope + Risk_for_Stress_Ulcer +
  SBP + DBP + HR + Orthostatis + NG_Lavage + Rectal + Hct +
  Hct_Drop + Plt + Cr + BUN + INR

variables_D <- all.vars(formula_D)

# Training
# Define the number of explanatory variables
p_D <- length(variables_D) - 1  # assuming the response variable is also in the data

data$Disposition <- as.factor(data$Disposition)

levels(data$Disposition) <- c("ICU", "Not ICU")

model_D <- randomForest(
  formula_D, 
  data = data, 
  ntree = 500, 
  sampsize = nrow(data), 
  mtry = floor(sqrt(p_D)), 
  importance = TRUE
)

# Importance Table
importance_table_D <- importance(model_D)

# Assuming the table is stored in importance_table
# Sorting by MeanDecreaseAccuracy
sorted_importance_D <- importance_table_D[order(-importance_table_D[,"MeanDecreaseAccuracy"]), ]

# Get the names of the top 3 variables
top_three_vars_D <- rownames(sorted_importance_D)[1:3]

# Print the top three variables
print(top_three_vars_D)

