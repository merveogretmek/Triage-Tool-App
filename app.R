library(shiny)
library(randomForest)
library(readr)
library(ggplot2)
library(dplyr)
library(rsconnect)
library(pins)

# Source the models.R file
source("createModels.R")
source('makePredictions.R')
source('displayPlots.R')

# CSS Styles
styles <- HTML(
  "
  .flex-container {
    display: flex;
    align-items: center;
    height: 40px;
    margin-bottom: 5px;
  }
  .flex-container .shiny-input-label {
    flex: 1;
    margin-right: 10px;
    font-size: 1.4em !important;  # Increase the font size for labels
  }
  .flex-container .shiny-input-container {
    flex: 1;  # Adjusted flex to reduce input width
  }
  input[type='text'] { 
    font-size: 1.3em !important;  # Increase the font size for text input area
    width: 80%;  # Adjust width as necessary
  }
  .shiny-bound-input, .selectize-input {
    font-size: 1.3em !important;  # Increase the font size for dropdowns
  }
  input[type='radio'] + label { 
    font-size: 1.3em !important;  # Increase the font size for radio button labels
  }
  .plainTextOutput {
    background-color: transparent !important;
    border: none !important;
    padding: 0 !important;
    color: inherit;
  }
  .full-width-line {
    border-top: 2px solid darkgrey;
    position: absolute;
    left: 0;
    right: 0;
    width: 100vw;
    z-index: 10;
  }
  body {
    font-family: 'Roboto', sans-serif;
  }
  .large-text {
            font-size: 20px;        # adjust the font size as required
            margin-top: 5px;       # decrease margin from the top
            margin-bottom: 15px;   # increase margin from the bottom
        }
"
)

# Utility function for common tags
divFlexContainer <- function(
    label,
    input,
    inputType,
    choices = NULL,
    inline = FALSE,
    value = NULL
) {
  # Check if inputType is 'radioButtons' and 'No' is one of the choices
  # If so, set default value to 'No'
  default_val <- if (inputType == "radioButtons" && "No" %in% choices) "No" else value
  
  tags$div(
    class = c("flex-container", if (inputType == "textInput") "plainTextOutput"),
    tags$label(label, class = "shiny-input-label"),
    switch(
      inputType,
      textInput = textInput(input, "", value = default_val),
      radioButtons = radioButtons(input, "", choices = choices, inline = inline, selected = default_val),
      selectInput = selectInput(input, "", choices = choices, selected = default_val),
      numericInput = numericInput(input, "", value = default_val)
    )
  )
}


# Utility function for infoTool
infoTooltip <- function(message) {
  tags$span(
    style = "margin-left: 5px; cursor: pointer;", 
    title = message,
    class = "glyphicon glyphicon-info-sign",
    `data-toggle` = "tooltip",
    `data-placement` = "right"
  )
}


# UI
ui <- fluidPage(
  tags$style(styles),
  
  # For infoTool
  tags$head(
    tags$script(
      "$(document).ready(function(){
      $('[data-toggle=\"tooltip\"]').tooltip(); 
    });"
    )
  ),
  
  tags$div(
    style = "width: 90%; max-width: 1200px; margin: auto;",
    h1(
      "A TOOL TO DIAGNOSE & TRIAGE PATIENTS TO URGENT ENDOSCOPY",
      style = "background-color: #053B50; text-align:center; margin: 0; color: white; padding: 10px"),
    tags$hr(style = "background-color: #053B50; height: 10px; margin: 0; border: none;"),
    tags$head(
      tags$script(
        "$(document).on('click', '#refresh', function () { location.reload(); });"
      )
    ),
    tags$hr(style = "border-color: grey; height: 2px;"),
    tags$div(
      h2(
        "Demographic", style = "font-weight: bold;"
      ),
      style = "background-color: #EEEEEE; margin: 0; padding: 15px"
    ),
    fluidRow(
      column(
        6,
        divFlexContainer("Patient Initials:", "Patient_Init", "textInput", value = " "),
        divFlexContainer(
          "Gender:",
          "Sex",
          "radioButtons",
          choices = c("Male", "Female"),
          inline = TRUE
        )
      ),
      column(
        6,
        divFlexContainer(
          "Site:",
          "Site",
          "selectInput",
          choices = c("1", "2", "3", "4", "5")
        ),
        divFlexContainer("Age:", "Age", "numericInput", value = 30)
      ),
      style = "background-color: #EEEEEE;  margin: 0; padding: 10px"
    ),
    tags$hr(style = "border-color: grey; height: 2px;"),
    tags$div(
      h2(
        HTML(paste0("Clinical Data:", 
                    tags$span(infoTooltip("History of Hematochezia, Hematemesis, and Melena have to be reliable (e.g. witnessed by a healthcare professional)."), 
                              style = "font-size: 0.6em;"))), 
        style = "font-weight: bold;"
      ),
      style = "background-color: #EEEEEE; margin: 0; padding: 15px"
    ),
    fluidRow(
      column(
        6,
        
        # Hematemesis
        divFlexContainer(
          "Hematemesis:",
          "Hematemesis",
          "selectInput",
          choices = c("None", "Small Blood", "Copious Blood/Clots")
        ),
        
        # Melena
        divFlexContainer(
          "Melena:",
          "Melena",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # Hematochezia
        divFlexContainer(
          "Hematochezia:",
          "Hematochezia",
          "selectInput",
          choices = c("None", "Copious Blood/Clots", "Small Blood")
        ),
        
        # Duration
        divFlexContainer(
          "Duration:",
          "Duration",
          "selectInput",
          choice = c("< 1 Day", "1-2 Days", "> 2 Days")
        ),
        
        # Last Bowel Movement
        divFlexContainer(
          "Last Bowel Movement:",
          "Last_BM", # will be added later
          "selectInput",
          choice = c("< 1 Day", "1-2 Days", "> 2 Days")
        ),
        
        # Syncope/PreSyncope
        divFlexContainer(
          "Syncope/Presyncope:",
          "Syncope",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # Prior GIB
        divFlexContainer(
          "Prior GIB:",
          "Hx_of_GIB",
          "selectInput",
          choices = c("None", "Upper", "Mid", "Lower")
        ),
        
        # Anticoagulation
        divFlexContainer(
          "Anticoagulation/ASA/NSAID:",
          "ASA_NSAID",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # Cirrhosis
        divFlexContainer(
          "Cirrhosis:",
          "Cirrhosis",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # CRF
        divFlexContainer(
          "CRF:",
          "CRF",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # Unstable CAD
        divFlexContainer(
          HTML(paste0("Unstable CAD:", infoTooltip("Unstable angina/CHF"))),
          "Unstable_CAD",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # COPD
        divFlexContainer(
          "COPD:",
          "COPD",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # PPI
        divFlexContainer(
          "PPI:",
          "PPI",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # Risk For Stress Ulcer
        divFlexContainer(
          "Risk for Stress Ulcer:",
          "Risk_for_Stress_Ulcer",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
        
        # Orthostatis
        divFlexContainer(
          "Orthostatis:",
          "Orthostatis",
          "radioButtons",
          choices = c("Yes", "No"),
          inline = TRUE
        ),
      ),
        
      column(
        6,
        
        # HR
        divFlexContainer("Heart Rate:", "HR", "numericInput", value = 75),
        
        #SBP
        divFlexContainer("Systolic BP:", "SBP", "numericInput", value = 120),
        
        # Diastolic BP
        divFlexContainer("Diastolic BP:", "DBP", "numericInput", value = 80),
        
        # NG Lavage
        divFlexContainer(
          "NG Lavage:",
          "NG_Lavage",
          "selectInput",
          choices = c("N/A","Bile", "Coffee Grounds", "Ongoing Hemorrhage")
        ),
        
        # Rectal Exam
        divFlexContainer(
          "Rectal:",
          "Rectal",
          "selectInput",
          choices = c(
            "Brown Stool",
            "Melanotic Stool",
            "Small Red Blood",
            "Ongoing Hemorrhage"
          )
        ),
        
        # Hematocrit
        divFlexContainer("Hematocrit (%):", "Hct", "numericInput", value = 40),
        
        # Hematocrit Drop
        divFlexContainer("Hematocrit Drop:", "Hct_Drop", "numericInput", value = 5),
        
        # Platelets
        divFlexContainer("Platelet Count:", "Plt", "numericInput", value = 150),
        
        # BUN
        divFlexContainer("Blood Urea Nitrogen (mg/dl):", "BUN", "numericInput", value = 20),
        
        # Cr
        divFlexContainer("Creatinine (mg/dl):", "Cr", "numericInput", value = 1.0),
        
        # INR
        divFlexContainer("INR:", "INR", "numericInput", value = 1.0)
      ),
        
      style = "background-color: #EEEEEE;  margin: 0; padding: 10px"
    ),
    tags$hr(style = "border-color: grey; height: 2px;"),
    tags$div(
      h2(
        "Physician Diagnosis", style = "font-weight: bold;"
      ),
      style = "background-color: #EEEEEE; margin: 0; padding: 15px"
    ),
    tags$div(
      h3(
        "Provide your best input below. Model provides its output on the following screen."
      ),
      style = "background-color: #EEEEEE; margin: 0; padding: 15px;"
    ),
    fluidRow(
    column(6,
             divFlexContainer("Source of bleeding:", "Source", "selectInput", 
                              choices = c("Upper (Esophagus to Ampulla)", "Mid (Ampulla to ICV)", "Lower (ICV to Rectum)")),
           tags$hr(style = "background-color: #EEEEEE; height: 30px; margin: 0; border: none;"),
             divFlexContainer(HTML(paste0("Need for emergent endoscopy (%):", 
                                          infoTooltip("Likelihood that this patient has active bleeding or a lesion requiring endoscopic treatment"))), 
                              "Endoscopy", "numericInput", value = 0),
             ),
    column(6,
           divFlexContainer("Need for emergent resuscitation:", "Resuscitation", "radioButtons", choices = c("Yes", "No"), inline = TRUE),
           tags$hr(style = "background-color: #EEEEEE; height: 30px; margin: 0; border: none;"),
           divFlexContainer("Disposition:", "Disposition", "selectInput", choices = c("ICU", "Not ICU")),
           ),
    style = "background-color: #EEEEEE;  margin: 0; padding: 10px"
  ),
  
  tags$hr(style = "background-color: #EEEEEE; height: 10px; margin: 0; border: none;"),
  

  
  tags$hr(style = "background-color: #EEEEEE; height: 30px; margin: 0; border: none;"),
  tags$hr(style = "border-color: grey; height: 2px;"),
  tags$div(
    style = " text-align: center;",
    actionButton("predict", "Compute"),
    actionButton("refresh", "Refresh Page")
  ),
  tags$div(
    h2(
      "Model Predictions", style = "font-weight: bold;"
    ),
    style = "margin: 0; padding: 15px"
  ),
  
  tags$div(
    style = "display: flex; flex-direction: column; align-items: center;",
    plotOutput("rf_plot_S", height = "300px", width = "80%"),
    plotOutput("rf_plot_E", height = "300px", width = "80%"),
    plotOutput("rf_plot_D", height = "300px", width = "80%")
  ),
  
  
  uiOutput("dynamicUI")
))


server <- function(input, output, session) {
  
  newdata <<- NULL
  
  output$currentTime <- renderText({
    Sys.time() %>% format("%Y-%m-%d %H:%M:%S")
  })
  
  # Render content for dynamicUI
  output$dynamicUI <- renderUI({
  })
  
  newdata <- reactiveVal(NULL)
  
  observeEvent(input$predict, {
    # Collect input values
    newdata <- data.frame(
      TimeStamp = Sys.time(),
      Patient_Init = input$Patient_Init,
      Age = input$Age,
      Sex = input$Sex,
      Hx_of_GIB = input$Hx_of_GIB,
      Hematochezia = input$Hematochezia,
      Hematemesis = input$Hematemesis,
      Melena = input$Melena,
      Duration = input$Duration,
      Syncope = input$Syncope,
      Unstable_CAD = input$Unstable_CAD,
      COPD = input$COPD,
      CRF = input$CRF,
      Risk_for_Stress_Ulcer = input$Risk_for_Stress_Ulcer,
      Cirrhosis = input$Cirrhosis,
      ASA_NSAID = input$ASA_NSAID,
      PPI = input$PPI,
      SBP = input$SBP,
      DBP = input$DBP,
      HR = input$HR,
      Orthostatis = input$Orthostatis,
      NG_Lavage = input$NG_Lavage,
      Rectal = input$Rectal,
      Hct = input$Hct,
      Hct_Drop = input$Hct_Drop,
      Plt = input$Plt,
      Cr = input$Cr,
      BUN = input$BUN,
      INR = input$INR,
      Source = input$Source,
      Resuscitation = input$Resuscitation,
      Endoscopy = input$Endoscopy,
      Disposition = input$Disposition
    )
    
    
    # Predictions
    summary_df_S <- predictSource(newdata, model_S)
    summary_df_E <- predictEndoscopy(newdata, model_E)
    summary_df_D <- predictDisposition(newdata, model_D)
    
    # Plots
    output$rf_plot_S <- renderSourceOutput(summary_df_S) 
    output$rf_plot_E <- renderEndoscopyOutput(summary_df_E) 
    output$rf_plot_D <- renderDispositionOutput(summary_df_D)
    
    observeEvent(input$refresh, {
      # Set the newdata reactive value to NULL when refresh is clicked
      newdata(NULL)
      
    })
    

  })

}


shinyApp(ui, server)
