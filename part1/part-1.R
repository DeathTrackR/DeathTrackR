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

#shiny
#ui <- fluidPage("Ben Lab")
#server <- function(input,output){}
#shinyApp(ui=ui,server=server)

## Only run examples in interactive R sessions
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
        tags$hr(),
        checkboxInput("header", "Header", TRUE)
      ),
      mainPanel(
        #tabset for plot, summary and table
        tabsetPanel(
          tabPanel("Plot", plotOutput("plot")), 
          tabPanel("Table", tableOutput("table")),
          tabPanel("Summary", verbatimTextOutput("summary")) 
        )
      )
    )
  )
  
  server <- function(input, output) {
    output$contents <- renderTable({
      # input$file1 will be NULL initially. After the user selects
      # and uploads a file, it will be a data frame with 'name',
      # 'size', 'type', and 'datapath' columns. The 'datapath'
      # column will contain the local filenames where the data can
      # be found.
      inFile <- input$file1
      
      if (is.null(inFile))
        return(NULL)
      
      read.csv(inFile$datapath, header = input$header)
    })
  }
  
  shinyApp(ui, server)
}

