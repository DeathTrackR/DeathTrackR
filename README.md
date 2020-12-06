# DeathTrackR App 
This code contains the implementations and architectures for visualizing the transition of cell death in R-Shiny. Cell death is a fundamental cellular process that controls development, immune responses, and organ function, and is regulated by numerous biochemical pathways. Changes in pro-survival and pro-death signals can promote cancer, autoimmunity, neurological disease, and both acute and chronic inflammation. Identification of key cell death signaling pathways contributing to disease requires methods to track responses to different stimuli influencing cell lifespan.  The web app is hosted at https://croker.shinyapps.io/project/.

# Background about Cell death: 
Cell death can be categorized using different methodological approaches involving biochemical changes in cells, morphology, functional outcomes, genetics, sensitivity to pharmacological compounds, and immunological characteristics. 

# Dependencies: 
This package was built and tested using R-Shiny. It also depends on standard R packages of tidyverse, DT, plotrix for basic data loading and plotting utilities.

# Overview
DeathTrackR (https://croker.shinyapps.io/deathtrackr) is a user-directed visualization tool, built on the R Shiny package (Chang et al., 2020) that allows import of .csv files generated from automated analysis of live cell imaging datasets consisting of tiff stacks. The expected input data file format should contain named columns containing Well Name, Field Number, and Time Point, and variables associated with cell death. Currently, the package allows users to present the input data in three different formats: a stacked bar plot; a percent stacked bar plot; and a line plot.

The stacked graph displays cell transition states during the cell death process, and is the best choice  to visualize multiple cell death transition states and identify any large differences between samples. The percent stacked graph shows normalized proportions of cell transition states, and is designed to display the relationship of each variable to the entire population for visual comparison. The line graph display is best to visualize changes in individual cell death transition states occurring between genotypes, treatments, or disease states. For each type of graph, users select single or multiple variables for visualization from the dataset columns, such as a total cell count or population percentage. Mean and standard error are included in the display by default. Multiple treatments or samples can be visualized simultaneously in a multi-panel display, and then exported to .png, jpeg, or .pdf formats.

# Design & Workflow
The UI layout consists  of two major components: a sidebar for user inputs and a main area for the visual display output. The visual display output  area is subdivided into three tabsets, corresponding to a plot section, a table section, and a settings section where users can further customize the output graphs.
In the sidebar layout, users select  a .csv data file from a local machine to upload. After the file is uploaded, the user can choose a type of graph (stacked bar plot, percent stacked bar plot, or line plot) from the drop-down menu. After graph type selection, a new selection field appears in which the user can select variables for visualization. The user can then  customize each treatment by clicking the “add” button and selecting the well names to be included. The graphs will include all available time points from the dataset by default, but users can customize the range using the time point bar selector. To create the output graph, the user selects the “Plot” button on the bottom of the sidebar panel and the plot(s) are displayed in the output area under the plotting tabset. 
The main output area is where the plot and analysis results are displayed. Under the plot tabset, users can view the generated plot, and can customize the color for each variable by using the color picker function. Users can also manually enter the hex color code from the color picker field. The table section contains the summary of selected variables for each treatment group, corresponding to each specific time point. Mean and standard error are included by default. In the settings section, user can customize the application appearance with seventeen Shiny built-in themes (ex. darkly, journal, simplex) . Users can also adapt the font size for the title, axis, and label for the plot, as well as the width and height.

# Methods
In this section, we briefly talk about the tools necessary to implement the DeathTrackR application. The package was built and tested using Shiny (Chang et al., 2020) in  R 3.6.3 (R Core Team, 2020). It also depends on standard R packages of Tidyverse (Wickham et al., 2019) and plotrix (J L, 2016) for basic data loading and plotting utilities. Code is available at: https://github.com/DeathTrackR/DeathTrackR

Layout We built an interactive interface with the R Shiny package, which includes a number of facilities to lay out the UI components. The application includes a sidebar layout for the user input fields, and the main panel displays graphical and statistical output. In addition, datasets are imported directly to this R package for user-directed analysis of cell viability. 

Plot Our application primarily depends on two standard packages of Tidyverse for basic plotting utilities. One is dplyr (Wickham et al., 2018) for common data manipulation. dplyr is a grammar for data manipulation and provides useful functions such as filter, mutate, and gather. The group_by function helps us to perform operations by each user-selected group. The other package is ggplot2 (Wickham, 2016) for creating user-directed graphics. Some useful functions include geom_bar for a bar chart, geom_point for a linear char, and geom_errorbar for displaying error bars. In addition, we used std.error from plotrix (Lemon, 2006) to compute the standard error based on grouped data. And DT (Xie et al., 2020) package provides an interface to Javascript library DataTables to display tables on our web application window.

# Team members: 
Yushan Liu, Huilai Miao, Cathleen Pena, Linh Le, Hainan Xiong, Weiqi Ricky Peng. For questions (or suggestions and improvements), please contact us bcroker@ucsd.edu. This is a work in progress, so we welcome your feedback!

# License: 

# Acknowledgment: 
This work is supported by NHLBI grant 5R01HL124209-05, and overseen by Dr. Ben Croker and Stephanie Labou, UCSD.

# References: 
Galluzi, Lorenzo, et. al. “Molecular mechanisms of cell death: recommendations of the Nomenclature Committee on Cell Death 2018.” Cell Death and Differentiation 25, 486–541 (2018)

R Core Team (2020). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL https://www.R-project.org/.

Winston Chang, Joe Cheng, JJ Allaire, Yihui Xie and Jonathan McPherson (2020). shiny:
  Web Application Framework for R. R package version 1.4.0.2.
  https://CRAN.R-project.org/package=shiny

Wickham et al., (2019). Welcome to the tidyverse. Journal of Open Source Software, 4(43), 1686, https://doi.org/10.21105/joss.01686

Hadley Wickham, Romain François, Lionel Henry and Kirill Müller (2018). dplyr: A Grammar of Data Manipulation. R package version 0.7.6. https://CRAN.R-project.org/package=dplyr

Wickham H (2016). ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York. ISBN 978-3-319-24277-4, https://ggplot2.tidyverse.org.

J L (2006). “Plotrix: a package in the red light district of R.” R-News, 6(4), 8-12.

Yihui Xie, Joe Cheng and Xianying Tan (2020). DT: A Wrapper of the JavaScript Library
  'DataTables'. R package version 0.16. https://CRAN.R-project.org/package=DT
  
Lemon, J. (2006) Plotrix: a package in the red light district of R. R-News, 6(4):
  8-12.





