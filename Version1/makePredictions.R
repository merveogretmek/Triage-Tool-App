library(dplyr)

# Source
predictSource <- function(newdata, model_S) {
  predicted_probs_S <- predict(model_S, newdata, type = "prob")
  
  mean_probs_S <- colMeans(predicted_probs_S)
  
  summary_df_S <- data.frame(Class = c("Upper", "Lower", "Mid"),
                             Probability = as.numeric(mean_probs_S))
  
  summary_df_S <- summary_df_S %>%
    arrange(desc(Class)) %>%
    mutate(xmin = cumsum(Probability) - Probability,
           xmax = cumsum(Probability))
  return(summary_df_S)
}

# Resuscitation
predictResuscitation <- function(newdata, model_R) {
  predicted_probs_R <- predict(model_R, newdata, type = "prob")
  
  summary_df_R <- data.frame(Class = c("Yes", "No"),
                             Probability = c(mean(predicted_probs_R[, 1]), mean(predicted_probs_R[, 2])))
  
  summary_df_R$xmin <- c(0, summary_df_R$Probability[1])
  summary_df_R$xmax <- c(summary_df_R$Probability[1], 1)
  return(summary_df_R)
}

# Endoscopy
predictEndoscopy <- function(newdata, model_E) {
  predicted_probs_E <- predict(model_E, newdata, type = "prob")
  
  summary_df_E <- data.frame(Class = c("Yes", "No"),
                             Probability = c(mean(predicted_probs_E[, 1]), mean(predicted_probs_E[, 2])))
  
  summary_df_E$xmin <- c(0, summary_df_E$Probability[1])
  summary_df_E$xmax <- c(summary_df_E$Probability[1], 1)
  return(summary_df_E)
}

# Disposition
predictDisposition <- function(newdata, model_D) {
  predicted_probs_D <- predict(model_D, newdata, type = "prob")
  
  mean_probs <- as.data.frame(colMeans(predicted_probs_D))
  colnames(mean_probs) <- "Probability"
  mean_probs$Class <- rownames(mean_probs)
  
  # Ensure Class is a factor and in the order we want it to be
  mean_probs$Class <- factor(mean_probs$Class, levels = c("ICU", "Not ICU"))
  
  # Order by Class, calculate xmin and xmax
  summary_df_D <- mean_probs %>%
    arrange(Class) %>%
    mutate(xmin = lag(cumsum(Probability), default = 0),
           xmax = cumsum(Probability))
  
  return(summary_df_D)
}


