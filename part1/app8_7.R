library(tidyverse) # this includes dplyr for data wranling, ggplot2 for plotting, and tidyr for reshaping data
library(shiny)
library(plotrix) # for standard error function
library(shinythemes)
library(gridExtra)
library(colourpicker)
library(plotly)
library(shinyjs)
#library(DT)
df<-NA
aa<-FALSE

# Function that produces default gg-colours is taken from this discussion:
# https://stackoverflow.com/questions/8197559/emulate-ggplot2-default-color-palette
gg_fill_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

#shiny
#YL build structure
if (interactive()) {
  #build up ui
  ui <- fluidPage(#theme = shinytheme("cerulean"),
    
    useShinyjs(),   # use js in shiny
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
          tabPanel("Plot", uiOutput('colors'),
                   plotlyOutput("plot",width = "100%",height = "100%")), 
          tabPanel("Table", dataTableOutput("table"),downloadButton('save_t', 'Save')),
          tabPanel("Summary", tableOutput("summary"),downloadButton('save_s', 'Save')),
          tabPanel("Settings",fluidRow(
            themeSelector(),
            sliderInput("font_size", "Font Size:", min = 80, max = 110 , value = 100)
          ))
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
      df <- read.csv(inFile$datapath, header = TRUE,fileEncoding="UTF-8-BOM")
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
                      choices = tail(colnames(data()),-3),multiple = TRUE)
        })
      }
      #parameter selectors for linear graph
      else if(input$graph=="Linear"){
        output$loc<-renderUI({
          selectInput("variables", "Choose variables:",
                      choices = tail(colnames(data()),-3),multiple = TRUE)
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
    
    #Color
    output$colors <- renderUI({
      if(input$graph=="Stacked"){
        lev <- sort(unique(input$segment_var))
      }
      else if(input$graph=="Linear"){
        lev <- sort(unique(input$variables))
      }
      else{
        lev <- c()
      }
      cols <- gg_fill_hue(length(lev))
      
      # New IDs "colX1" so that it partly coincide with input$select...
      lapply(seq_along(lev), function(i) {
        colourpicker::colourInput(inputId = paste0("col", lev[i]),
                                  label = paste0("Choose color for ", lev[i]), 
                                  value = cols[i]
        )        
      })
    })
    #Plot by choice
    observeEvent(input$plot_button,{
      # read file
      inFile <- input$file1
      df <<- read.csv(inFile$datapath,header=TRUE,fileEncoding="UTF-8-BOM")
      
      treat.names = all_treat()
      #1) Stacked Graph
      if(input$graph=='Stacked'){
        
        params = input$segment_var
        
        i<-1
        d = NULL
        for (treat in treat.names){
          
          df1_long<<-sub.table.all(df,treat,params)
          d1<- df1_long %>%
            mutate(group = i) %>%
            filter(Time.Point>=input$slider[1],Time.Point<=input$slider[2])
          d <- bind_rows(d,d1)
          i<-i+1
        }
        
        output$plot <- renderPlotly({
          p <- 
            ggplot(d,aes(x=Time.Point,y=mean, fill=key))+
            geom_bar(stat = "identity") +
            theme(strip.background = element_blank(), 
                  strip.placement = "outside", legend.position = "right") +
            theme_classic()+
            facet_grid(group~.,scales="free")+
            labs (x="Time(sec)",y="mean value")+
            scale_fill_manual(values = all_colors())
          
          
          ggplotly(p)
          
        })
      }
      
      ## Linear Plot
      else if(input$graph=="Linear"){
        params = input$variables
        treat.names = all_treat()
        
        i<-1
        d = NULL
        for (treat in treat.names){
          
          df1_long<<-sub.table.all(df,treat,params)
          d1<- df1_long %>%
            mutate(group = i) %>%
            filter(Time.Point>=input$slider[1],Time.Point<=input$slider[2])
          d <- bind_rows(d,d1)
          i<-i+1
        }
        
        output$plot <- renderPlotly({
          p <- 
            ggplot(d,aes(x=Time.Point,y=mean))+
            geom_point(aes(color=key),position=position_dodge(0.3)) +
            theme(strip.background = element_blank(), 
                  strip.placement = "outside", legend.position = "right") +
            theme_classic()+
            geom_errorbar(
              aes(ymin = mean-se, ymax=mean+se, color="error bar"),
              position = position_dodge(0.3), width = 0.2
            )+
            facet_grid(group~.,scales="free")+
            labs (x="Time(sec)",y="mean value",title="Linear")+
            scale_color_manual(values=all_colors())
          ggplotly(p)
        })
        
      }
    })
    
    
    ### Put all helper methods down here ###
    
    
    #1.function for uploading the file
    data <- reactive({
      inFile <- input$file1
      if (is.null(inFile))
        return(NULL)
      df <- read.csv(inFile$datapath, header = TRUE,fileEncoding="UTF-8-BOM")
      df
    })
    
    # 2.take sub-table by selected 'Well Name' and Params(cols). Add mean and std error for each columns var.
    # In current version, we're using #6, which returns a enlongated(see function 'gather') version of data frame
    # msg me if any confusion (Ricky)
    sub.table <- function(names, params){
      inFile <- input$file1
      if (is.null(inFile))
        return(NULL)
      params1<-append(params,"Time.Point",after=0)
      df1 <- df %>%
        filter('Well.Name' %in% names) %>%
        select(params1) %>%
        group_by(Time.Point) %>%
        summarise_all(list(~mean(.),~std.error(.)))
      
      df1
    }
    
    # 3. return names of all treatments as list of vectors
    all_treat <- function(){
      result <- list(current())
      for (i in seq(current())) {
        treat<-c(input[[paste0("group",as.character(i))]])
        result[[i]] <- treat
      }
      #x <- reactiveValuesToList(result)
      #x
      
      result
    }
    
    # 4. return sub table with mean, called in #6
    sub.table.mean <- function(df,names, params){
      params1<-append(params,c("Time.Point"),after=0)
      df1<- df %>%
        filter(Well.Name %in% names) %>%
        select(params1) %>%
        group_by(Time.Point) %>%
        summarise_all(list(~mean(.)))
      df1
    }
    
    # 5. return sub table with se, called in #6
    sub.table.se <- function(df,names, params){
      params1<-append(params,c("Time.Point"),after=0)
      df1<- df %>%
        filter(Well.Name %in% names) %>%
        select(params1) %>%
        group_by(Time.Point) %>%
        summarise_all(list(~std.error(.)))
      
      df1
    }
    
    # 6. return a long format data frame with mean and se (can add other statistics later)
    # I recommend run local first to see how the returned table looks like
    sub.table.all <- function(df, names, params){
      # call #4 and #5, see above
      df1.mean<-sub.table.mean(df,names,params)
      df1.se<-sub.table.se(df,names,params)
      
      df1_long.se <- df1.se %>%
        gather(key='key',value='se',-Time.Point)
      df1_long.mean <- df1.mean %>%
        gather(key='key',value='mean',-Time.Point)
      
      df1_long <- merge(df1_long.mean,df1_long.se)
      
      df1_long
    }
    
    #7.Collect all colors inputs
    all_colors <- reactive({
      result <- list()
      if(input$graph=="Stacked"){
        lev <- sort(unique(input$segment_var))
      }
      else if(input$graph=="Linear"){
        lev <- sort(unique(input$variables))
      }
      else{
        lev <- c()
      }
      for(i in lev){
        #collect treatment wells for each group
        color<-c(input[[paste0("col", i)]])
        result <- c(result, color)
      }
      
      if(input$graph=="Linear"){
        result <- c(result, "black")
        
      }
      result
    })
    
    themeSelector <- function() {
      div(
        div(
          selectInput("shinytheme-selector", "Choose a theme",
                      c("default", shinythemes:::allThemes()),
                      selectize = FALSE
          )
        ),
        tags$script(
          "$('#shinytheme-selector')
          .on('change', function(el) {
          var allThemes = $(this).find('option').map(function() {
          if ($(this).val() === 'default')
          return 'bootstrap';
          else
          return $(this).val();
          });
          // Find the current theme
          var curTheme = el.target.value;
          if (curTheme === 'default') {
          curTheme = 'bootstrap';
          curThemePath = 'shared/bootstrap/css/bootstrap.min.css';
          } else {
          curThemePath = 'shinythemes/css/' + curTheme + '.min.css';
          }
          // Find the <link> element with that has the bootstrap.css
          var $link = $('link').filter(function() {
          var theme = $(this).attr('href');
          theme = theme.replace(/^.*\\//, '').replace(/(\\.min)?\\.css$/, '');
          return $.inArray(theme, allThemes) !== -1;
          });
          // Set it to the correct path
          $link.attr('href', curThemePath);
          });"
        )
      )
    }
    
    # Change font size. Listening on the slider under settings tab
    observeEvent(input$font_size, {
      runjs(paste0('$("*").css("font-size","', input$font_size, '%")'))
    })
    
  }#end of server  
}#end of check the interactive
shinyApp(ui, server)
