library(tidyverse) # this includes dplyr for data wranling, ggplot2 for plotting, and tidyr for reshaping data
library(shiny)
library(plotrix) # for standard error function
#library(DT)


df<-NA
aa<-FALSE

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
                      checkboxInput("checkOne", label = "Time Series", value = FALSE),
                      selectInput("wells", "Choose a well:",
                                  "",multiple = TRUE),
                      selectInput("para","Choose parameters:",
                                  "",multiple = TRUE),
                      # uiOutput("selecters"),
                      
                      uiOutput("loc"), # placeholder for time series selector if time series data selected
                      selectInput("field", "Choose a field:",
                                  NULL,multiple = FALSE),
                      #checkboxGroupInput("calculation", label = "Calculation",choices = c("Mean","SEM"))
                      uiOutput("calculation"),
                      actionButton('plot_button','Plot')
                    ),
                    mainPanel(
                      #tabset for plot, summary and table
                      tabsetPanel(
                        tabPanel("Plot", plotOutput("plot"),downloadButton('Save', 'save')), 
                        tabPanel("Table", dataTableOutput("table")),
                        tabPanel("Summary", textOutput("summary"))
                      )
                    )
                  )
  )
  server <- function(input, output,session) {
    # set the selector choices based on wells and parameters in input dataset
    observeEvent(input$file1,{
      df<<- read_csv(input$file1$datapath)
      output$loc<-renderUI({
        df<- read_csv(input$file1$datapath)
        # slider range for timepoint
        max_num <- as.integer(tail(unique(df[,3]),n=1))
        sliderInput("slider", label = h5(strong("Time Point")), min = 1, 
                    max = max_num, step=1,
                    value = c(1, max_num)
                    )
      })
      #updateSelectInput(session, 'time point', choices = list(1,2,3,4,5) )
      updateSelectInput(session,"wells",choices = unique(df[,1]))
      updateSelectInput(session,"field",choices = unique(df[,2]))
      updateSelectInput(session,"para",choices = colnames(df))
      # time points selection: need soft selection later
      #unique(select(df, `Time Point`)))
    })
    
    # If user choose to display time series data
    observeEvent(input$checkOne,{
      
      # select time series data
      if (input$checkOne == TRUE){
        # render blank
        output$calculation <- renderUI({
        })
        output$loc<-renderUI({
        })
        output$table <- renderDataTable({
          #import file
          #filter the dataset based on parameter and wells users interested in
          data
        })
        
      }else{
        
        if(!is.na(df)){
          output$loc<-renderUI({
            max_num <- as.integer(tail(unique(df[,3]),n=1))
            sliderInput("slider", label = h5(strong("Time Point")), min = 1, 
                        max = max_num,step=1, 
                        value = c(1, max_num)
            )
          })
        }
        output$calculation <- renderUI({
          checkboxGroupInput("calculation", label = "Calculation",choices = c("Mean","SEM"))
        })
        
      }
      
    })
    
      
    
    observeEvent(input$plot_button,{
      if(!is.na(df) && input$checkOne){
        dat <- df %>%
          filter(`Well Name` %in% input$wells, `Field Number` %in% input$field) %>%
          select(one_of(input$para),`Time Point`)
        
        # Plotting time series
        output$plot <- renderPlot({
          # for( i in seq(1,length(input$para))) {
          #   ggplot(data=dat) +
          #   geom_smooth(aes(x=`Time Point`,y=input$para[i]))
          # }
          # aa <- input$para[1]
          # ggplot(data=dat,aes(x=`Time Point`)) +
          #   geom_smooth(aes(y=aa))
          dat %>%
            gather(variable,value,-`Time Point`) %>%
            ggplot(aes(`Time Point`, value)) +
            geom_point() +
            geom_smooth()+
            facet_wrap(~variable)
        })
        
      }
      output$table <- renderDataTable({
        #import file
        #filter the dataset based on parameter and wells users interested in
        dat
      })
      
      output$summary <- renderText({
        summary(dat)
      })
    })
        
        
      
        
      
    # output$table <- renderDataTable({
    #   #import file
    #   #filter the dataset based on parameter and wells users interested in
    #   table()
    # })
    table <- reactive({
      df<-read_csv(input$file1$datapath)
      if(is.null(input$wells)){
        return(df)
      }
      else{df %>%
          select(input$para,`Well Name`,`Time Point`)%>%
          filter('Well Name' %in% input$wells)}
    })
    
    observeEvent(input$calculation,{
     
      if(input$calculation =="Mean"){
        df_cal <- table()%>%
          group_by(`Well Name`,`Time Point`)%>%
          summarize_all(list(~mean(.)))%>%
          as.data.frame()%>%
          gather(key = "variable", value = "value", `Well Name`, -`Time Point`)
        output$plot <- renderPlot({
          df_cal%>%
            ggplot() +
            #making bars from only means
            geom_bar(aes(x = `Time Point`, y = value, fill = variable), 
                     stat = "identity")
        })
      }
      else if(input$calculation =="SEM"){
        df_cal <- table()%>%
          group_by(`Well Name`,`Time Point`)%>%
          summarize_all(list(~std.error(.)))%>%
          as.data.frame()%>%
          gather(key = "variable", value = "value", -`Well Name`, -`Time Point`)
        output$plot <- renderPlot({
          df_cal%>%
            ggplot() +
            #making bars from only means
            geom_bar(aes(x = `Time Point`, y = value, fill = variable), 
                     stat = "identity")
        })
        
      }
    })
  }  
  
}
shinyApp(ui, server)


