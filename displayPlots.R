library(ggplot2)
library(grid)
library(gridExtra)

renderSourceOutput <- function(summary_df_S) {
  return(renderPlot({
    
    important_vars_text_S <- paste("Most Important Three Variables:", 
                                 paste(top_three_vars_S, collapse = ", "))
    
    text_plot <- ggplot() +
      annotate("text", x = 0.5, y = 0.5, label = "SOURCE", size = 6) +
      theme_void() +
      theme(plot.title = element_text(size = 20))
    
    main_plot <- ggplot(summary_df_S) +
      geom_rect(aes(
        xmin = xmin,
        xmax = xmax,
        ymin = -0.5,
        ymax = 0.5,
        fill = Class
      )) +
      
      # Display class names inside the bars (slightly above center)
      geom_text(
        aes(
          x = (xmin + xmax) / 2,
          y = 0.2, # Adjusted position
          label = Class
        ),
        color = "black",
        size = 7
      ) +
      
      # Display percentages inside the bars (slightly below center)
      geom_text(
        aes(
          x = (xmin + xmax) / 2,
          y = -0.2, # Adjusted position
          label = scales::percent(Probability, accuracy = 1)
        ),
        color = "white",
        size = 7
      ) +
      
      annotate("text", x = mean(c(min(summary_df_S$xmin), max(summary_df_S$xmax))), 
               y = -0.8, # Adjust this value to position the text as desired
               label = important_vars_text_S, 
               size = 6, 
               hjust = 0.5) +
      
      scale_fill_manual(values = c(
        "Upper" = "#00BA38",
        "Lower" = "#619CFF",
        "Mid" = "#F8766D"
      )) +
      theme_minimal() +
      theme(
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, vjust = 1.5) # Adjust the title position here
      ) +
      coord_cartesian(ylim = c(-1, 1)) +
      theme(plot.title = element_text(size = 20))
    
    grid.arrange(text_plot, main_plot, ncol = 2, widths = c(0.2, 0.8))
  }))
}

renderEndoscopyOutput <- function(summary_df_E) {
  return(renderPlot({
    important_vars_text_E <- paste("Most Important Three Variables:", 
                                   paste(top_three_vars_E, collapse = ", "))
    
    text_plot <- ggplot() +
      annotate("text", x = 0.5, y = 0.5, label = "URGENT ENDOSCOPY", size = 6) +
      theme_void() +
      theme(plot.title = element_text(size = 20))
    
    main_plot <- ggplot(summary_df_E) +
      geom_rect(aes(
        xmin = xmin,
        xmax = xmax,
        ymin = -0.5,
        ymax = 0.5,
        fill = Class
      )) +
      # Display class names inside the bars (slightly above center)
      geom_text(
        aes(
          x = (xmin + xmax) / 2,
          y = 0.2, # Adjusted position
          label = Class
        ),
        color = "black",
        size = 7
      ) +
      
      # Display percentages inside the bars (slightly below center)
      geom_text(
        aes(
          x = (xmin + xmax) / 2,
          y = -0.2, # Adjusted position
          label = scales::percent(Probability, accuracy = 1)
        ),
        color = "white",
        size = 7
      ) +
      
      annotate("text", x = mean(c(min(summary_df_E$xmin), max(summary_df_E$xmax))), 
               y = -0.8, # Adjust this value to position the text as desired
               label = important_vars_text_E, 
               size = 6, 
               hjust = 0.5) +
      
      scale_fill_manual(values = c("Yes" = "#00BA38", "No" = "#F8766D")) +
      theme_minimal() +
      theme(
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, vjust = 1.5) # Adjust the title position here
      ) +
      coord_cartesian(ylim = c(-1, 1)) +
      theme(plot.title = element_text(size = 20)) 
    
    grid.arrange(text_plot, main_plot, ncol = 2, widths = c(0.2, 0.8))
  }))
}

renderDispositionOutput <- function(summary_df_D) {
  return(renderPlot({
    summary_df_D <- summary_df_D %>%
      arrange(desc(Class))
    
    important_vars_text_D <- paste("Most Important Three Variables:", 
                                   paste(top_three_vars_D, collapse = ", "))
    
    text_plot <- ggplot() +
      annotate("text", x = 0.5, y = 0.5, label = "DISPOSITION", size = 6) +
      theme_void() +
      theme(plot.title = element_text(size = 20))
    
    main_plot <- ggplot(summary_df_D) +
      geom_rect(aes(
        xmin = xmin,
        xmax = xmax,
        ymin = -0.5,
        ymax = 0.5,
        fill = Class
      )) +
      # Display class names inside the bars (slightly above center)
      geom_text(
        aes(
          x = (xmin + xmax) / 2,
          y = 0.2, # Adjusted position
          label = Class
        ),
        color = "black",
        size = 7
      ) +
      
      # Display percentages inside the bars (slightly below center)
      geom_text(
        aes(
          x = (xmin + xmax) / 2,
          y = -0.2, # Adjusted position
          label = scales::percent(Probability, accuracy = 1)
        ),
        color = "white",
        size = 7
      ) +
      annotate("text", x = mean(c(min(summary_df_D$xmin), max(summary_df_D$xmax))), 
               y = -0.8, # Adjust this value to position the text as desired
               label = important_vars_text_D, 
               size = 6, 
               hjust = 0.5) +
      
      scale_fill_manual(
        values = c(
          "ICU" = "#00BA38",
          "Not ICU" = "#F8766D"
        )
      ) + # Assign colors as desired
      theme_minimal() +
      theme(
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, vjust = 1.5)
      ) +
      coord_cartesian(ylim = c(-1, 1)) +
      theme(plot.title = element_text(size = 20)) 
    
    grid.arrange(text_plot, main_plot, ncol = 2, widths = c(0.2, 0.8))
  }))
}
