library(tidyverse) # this includes dplyr for data wranling, ggplot2 for plotting, and tidyr for reshaping data
library(shiny)
library(plotrix) # for standard error function
library(shinythemes)
library(gridExtra)
library(colourpicker)
library(plotly)
#library(DT)


df<-NA
aa<-FALSE

#shiny
if (interactive()) {
  #build up ui
  ui <- fluidPage(theme = shinytheme("cerulean"),
                  titlePanel("Ben Crocker Lab"),
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
                                  choice=c("linear","stacked"),
                                  selected = "linear",
                                  multiple = FALSE),
                      uiOutput("loc"),#parameter selector holder
                      uiOutput("time_range"),
                      checkboxInput("set", label = "Set Treatment", value = FALSE),
                      uiOutput("treat"),
                      actionButton('plot_button','Plot')

                    ),#end of siderbar panel
                    mainPanel(
                      #tabset for plot, summary and table
                      tabsetPanel(
                        tabPanel("Plot", plotlyOutput("plot",width = "100%",height = "600px"),uiOutput("color"),downloadButton('save_p', 'Save')), 
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
      if(input$graph=="linear"){
        #no other selector will show up
        output$loc<-renderUI({
          selectInput("stacked_var", "Choose a stacked variable:",
                      choices = colnames(data()),multiple = TRUE)
        })
      }
      #parameter selectors for stacked graph
      else if(input$graph=="stacked"){
        output$loc<-renderUI({
            selectInput("stacked_var", "Choose a stacked variable:",
                        choices = colnames(data()),multiple = TRUE)
          })
      }
      
      
    })#end of observeEvent for graph selector
    
    #create a subset of dataframe with selected variables
     data_filter <- reactive({
       #if the user have not selected variables, the table panel display the original dataframe
       if(is.null(input$stacked_var)){
         return(data())
       }
       else if(!("Time.Point" %in% input$stacked_var)){
         d<- data() %>% select(input$stacked_var)
         return(d)
       }
       
       data() %>%
         select(input$stacked_var) %>%
         filter(Time.Point %in% seq(input$slider[1]:input$slider[2])) # NOt sure if the time.point will all be integer or not
     })
     
    
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
    observeEvent(input$stacked_var,{
      if("Time.Point" %in% input$stacked_var){
        output$time_range<-renderUI({
         #if(input$time==TRUE){
            max_num <- as.integer(tail(unique(data()[,3]),n=1))
            sliderInput("slider", label = h5(strong("Time Point")), min = 1, 
                                    max = max_num, step=1,
                                    value = c(1, max_num))#file depend
         #}
      })
      }
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
      data_filter()
    })
    
    #Get current
    current <- reactiveVal(0)

    #plot graph
    observeEvent(input$plot_button,{
      result <- list(current())
      for (i in seq(current())) {
        #collect treatment wells for each group
        treat<-c(input[[paste0("group",as.character(i))]])
        result[[i]] <- treat
        #creat an empty dataframe with selected parameter as column names
        if (i==1){
          stack_df = cbind(data_filter()[FALSE,],data.frame(GROUP = factor()))
        }
        treat_df <- data_filter() %>%
          filter(ï..Well.Name %in% treat)
        #add a column named GROUP to store the group number of the wells
        treat_df$GROUP <- as.factor(i)
        stack_df<- rbind(stack_df,treat_df)
      }
        #plot a stacked graph if the user click stacked
        if(input$graph =="stacked"){
          df_cal <- stack_df%>%
            group_by(GROUP,Time.Point,ï..Well.Name)%>%
            summarize_all(list(~mean(.)))%>%
            as.data.frame()%>%
            gather(key = "variable", value = "value", -ï..Well.Name, -Time.Point,-GROUP)
          output$plot <- renderPlotly({
            p <- 
              ggplot(df_cal,aes(x = Time.Point, y = value, fill = variable)) +
              #making bars from only means
              geom_bar(stat = "identity")+theme_classic()+facet_wrap(~GROUP)
            ggplotly(p)
          })
        }
      #plot a line graph if user click linear
      else if(input$graph =="linear"){
        df_cal <- stack_df%>%
          group_by(GROUP,Time.Point,ï..Well.Name)%>%
          summarize_all(list(~mean(.)))%>%
          as.data.frame()%>%
          gather(key = "variable", value = "value", -ï..Well.Name, -Time.Point,-GROUP)
        output$plot <- renderPlotly({
          p <- 
            ggplot(df_cal,aes(x = Time.Point, y = value)) +
            #making bars from only means
            geom_point(aes(fill = GROUP))+geom_smooth()+theme_classic()+ scale_fill_manual(values=color_flag)+facet_wrap(~variable)
          ggplotly(p)
        })
      }
      })

    
    output$summary <- renderTable({
      summary(df_cal)
    })
    
    
  }#end of server  

}#end of check the interactive
shinyApp(ui, server)

