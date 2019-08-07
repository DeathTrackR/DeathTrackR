library(tidyverse) # this includes dplyr for data wranling, ggplot2 for plotting, and tidyr for reshaping data
library(shiny)
library(plotrix) # for standard error function
library(shinythemes)
library(gridExtra)
library(colourpicker)
#library(DT)


df<-NA
aa<-FALSE
#calculating the mean and SEM

#shiny
#YL build structure
if (interactive()) {
  #build up ui
  ui <- fluidPage(theme = shinytheme("cerulean"),
                  titlePanel("Death TrackR"),
                  sidebarLayout(
                    sidebarPanel(
                      #file upload
                      fileInput("file1", "Import CSV File",
                                accept = c(
                                  "text/csv",
                                  "text/comma-separated-values,text/plain",
                                  ".csv"),
                      ),
                      #selector for graph type
                      selectInput("graph", "Choose a type of graph:",
                                  choice=c("Default","Stacked","Linear"),
                                  selected = "Default",
                                  multiple = FALSE),
                      uiOutput("loc"),#parameter selector holder
                      checkboxInput("time", label = "Set range of timepoint", value = FALSE),
                      uiOutput("time_range"),
                      checkboxInput("set", label = "Set Treatment", value = FALSE),
                      uiOutput("treat"),
                      #actionButton("add","Add"),
                      #actionButton("delete","Delete"),
                      actionButton('plot_button','Plot')

                    ),#end of siderbar panel
                    mainPanel(
                      #tabset for plot, summary and table
                      tabsetPanel(
                        tabPanel("Plot", plotOutput("plot"),downloadButton('save_p', 'Save')), 
                        tabPanel("Table", dataTableOutput("table"),downloadButton('save_t', 'Save')),
                        tabPanel("Summary", tableOutput("summary"),downloadButton('save_s', 'Save'))
                      )
                    )#end of main panel
                  )
  )#end of ui
  
  #build up server
  server <- function(input,output,session) {
    
    #function for uploading the file
    data <- reactive({
      inFile <- input$file1
      if (is.null(inFile))
        return(NULL)
      df <- read.csv(inFile$datapath, header = TRUE)
      df
    })
   
    #observeEvent for graph selector 
    observeEvent(c(input$graph,input$file1),{
      #initial page for graph selector
      if(input$graph=="Default"){
        #no other selector will show up
        output$loc<-renderUI({
        })
      }
      #parameter selectors for stacked graph
      else if(input$graph=="Stacked"){
        output$loc<-renderUI({
            selectInput("segment_var", "Choose segment variables:",
                        choices = colnames(data()),multiple = TRUE)
          })
      }
      #parameter selectors for linear graph
      else if(input$graph=="Linear"){
        output$loc<-renderUI({
          selectInput("variables", "Choose variables:",
                      choices = colnames(data()),multiple = TRUE)
        })
      }
      
    })#end of observeEvent for graph selector
    
    #Check if we need to set up groups of treatment
    observeEvent(input$set,{
      output$treat<-renderUI({
        if(input$set==TRUE){
          current(0)
          list(
            actionButton("add","Add"),
            actionButton("delete","Delete")
            )
          }
        })
      })
    
    #Check if we need to set up range of timepoint
    observeEvent(input$time,{
      output$time_range<-renderUI({
        if(input$time==TRUE){
          max_num <- as.integer(tail(unique(data()[,3]),n=1))
          sliderInput("slider", label = h5(strong("Time Point")), min = 1, 
                                  max = max_num, step=1,
                                  value = c(1, max_num))#file depend
        }
      })
    })
    
    #add button
    observeEvent(input$add, {
      newValue <- current() + 1
      current(newValue)
      insertUI(
        selector = "#add",
        where = "beforeBegin",
        ui = selectInput(paste("group",current(),sep=""), paste("Treatment:",current()),
                         list('well name'=unique(data()[,1])),multiple = TRUE)
      )
    })
    
    #delete button
    observeEvent(input$delete, {
      ui_todelete <- paste("div:has(>> #group",current(), ")",sep="")
      removeUI(
        selector = ui_todelete
      )
      newValue <- current() - 1
      current(newValue)
    })
    
    #table tabpanel output
    output$table <- renderDataTable({
      #display dataframe
      data()
    })
    
    #Get current number of treatments
    current <- reactiveVal(0)
    
    #Output all selected treatments(TEST!!!)
    output$summary <- renderTable({
      all_treat()
    })
    
    #Plot by choice
    
    #Helper method
    #Collect all treatment inputs
    all_treat <- reactive({
      result <- list(current())
      for (i in seq(current())) {
        treat<-c(input[[paste0("group",as.character(i))]])
        result[[i]] <- treat
      }
      result
    })
    
    
    
    
  }#end of server  

}#end of check the interactive
shinyApp(ui, server)

