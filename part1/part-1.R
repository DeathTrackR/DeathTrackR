# load packages
library(plotrix) # for standard error function
library(tidyverse) # this includes dplyr for data wranling, ggplot2 for plotting, and tidyr for reshaping data
library(shiny)
library(DT)

#import file
#path <- file.choose()
#print(path)

#read data 
#data <- read.csv(path)
#print(colnames(data))
#unique(data$Ã¯..Well.Name)
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
                    "",multiple = TRUE),
        selectInput("para","Choose parameters:",
                    "",multiple = TRUE),
        # uiOutput("selecters"),
        selectInput("fields", "Choose a field:",
                    NULL,multiple = TRUE),
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
  
  server <- function(input, output,session) {
    # set the selector choices based on wells and parameters in input dataset
    observeEvent(input$file1,{
      df<- read.csv(input$file1$datapath)
      updateSelectInput(session,"wells",choices = unique(df[,1]))
      updateSelectInput(session,"para",choices = names(df))
    })
    
    output$table <- renderDataTable({
    #import file
      #filter the dataset based on parameter and wells users interested in
      table()
    })
    table <- reactive({
      df<-read.csv(input$file1$datapath)
      if(is.null(input$wells)){
        return(df)
      }
      else{df %>%
        select(input$para)%>%
        filter(ï..Well.Name %in% input$wells)}
      })
    
    observeEvent(input$calculation,{
      if(input$calculation =="Mean"){
        df_cal <- table()%>%
          group_by(ï..Well.Name,Time.Point)%>%
          summarize_all(list(~mean(.)))%>%
          as.data.frame()%>%
          gather(key = "variable", value = "value", -ï..Well.Name, -Time.Point)
        output$plot <- renderPlot({
          df_cal%>%
            ggplot() +
            #making bars from only means
            geom_bar(aes(x = Time.Point, y = value, fill = variable), 
                     stat = "identity")
        })
      }
      if(input$calculation =="SEM"){
        df_cal <- table()%>%
          group_by(ï..Well.Name,Time.Point)%>%
          summarize_all(list(~std.error(.)))%>%
          as.data.frame()%>%
          gather(key = "variable", value = "value", -ï..Well.Name, -Time.Point)
        output$plot <- renderPlot({
          df_cal%>%
            ggplot() +
            #making bars from only means
            geom_bar(aes(x = Time.Point, y = value, fill = variable), 
                     stat = "identity")
        })
      }
    })
    #plot
    # output$plot <- renderPlot({
    #   df_cal%>%
    #     ggplot() +
    #     #making bars from only means
    #     geom_bar(aes(x = Time.Point, y = value, fill = parameter), 
    #              stat = "identity")
    #     
    # })
    
  }
  
  
  shinyApp(ui, server)
}

