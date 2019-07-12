# load packages
library(plotrix) # for standard error function
library(tidyverse) # this includes dplyr for data wranling, ggplot2 for plotting, and tidyr for reshaping data
library(shiny)

#import file
#path <- file.choose()
#print(path)

#read data 
#data <- read.csv(path)
#print(colnames(data))
#unique(data$ï..Well.Name)
#unique(data$Field.Number)
#unique(data$Time.Point)

#Group the data
#group_by <- readline(prompt="Enter paramters: ")
#print(group_by)

#subset the data
#well_select<-scan()

#calculation (mean and SEM)
myparameters <- list()
for (i in LETTERS[1:8]){
  for(j in c("1-3","4-6","7-9","10-12")){
    print(paste(i,j))
    myparameters <- append(myparameters,paste(i,j))
  }
}

#shiny
if (interactive()) {
  
  ui <- fluidPage(titlePanel("Ben Lab"),
    sidebarLayout(
      sidebarPanel(
        #file upload
        fileInput("file1", "Import CSV File",
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv"),
                  ),
        #selector
        selectInput("wells", "Choose a well:",
                    list('#well'=as.list(myparameters)),multiple = TRUE),
        selectInput("fields", "Choose a field:",
                    list('#field'=seq(1,3)),multiple = TRUE),
        checkboxGroupInput("calculation", 
                    label = "Calculation",choices = c("Mean","SEM"))
        
      ),
      mainPanel(
        #tabset for plot, summary and table
        tabsetPanel(
          tabPanel("Plot", plotOutput("plot"),downloadButton('Save', 'save')), 
          tabPanel("Table", dataTableOutput("table")),
          tabPanel("Summary", verbatimTextOutput("summary")) 
        )
      )
    )
  )
  
  server <- function(input, output) {
    output$table <- renderDataTable({
      #import file
      inFile <- input$file1
      
      if (is.null(inFile))
        return(NULL)
      
      read.csv(inFile$datapath, header = TRUE)
    })
    
    #plot
    output$plot <- renderPlot({

    })
  }
  
  
  shinyApp(ui, server)
}

