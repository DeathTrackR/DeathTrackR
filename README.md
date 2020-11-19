# DeathTrackR App 
This code contains the implementations and architectures for visualizing the transition of cell death in R-Shiny. Cell death is a fundamental cellular process that controls development, immune responses, and organ function, and is regulated by numerous biochemical pathways. Changes in pro-survival and pro-death signals can promote cancer, autoimmunity, neurological disease, and both acute and chronic inflammation. Identification of key cell death signaling pathways contributing to disease requires methods to track responses to different stimuli influencing cell lifespan.  The web app is hosted at https://croker.shinyapps.io/project/.

# Background about Cell death: 
Cell death can be categorized using different methodological approaches involving biochemical changes in cells, morphology, functional outcomes, genetics, sensitivity to pharmacological compounds, and immunological characteristics. 

# Dependencies: 
This package was built and tested using R-Shiny. It also depends on standard R packages of tidyverse, DT, plotrix for basic data loading and plotting utilities.

# Description: 
Shiny is an R package that helps us to build an interactive interface directly in R. Datasets are imported directly to this R package for user-directed analysis of cell viability. The interface includes an import function to facilitate data extraction. Different graphical formats are available for the user depending on the desired graphical display.


The DeathTrackR app allows users to import .csv files generated from automated analysis of live cell imaging datasets consisting of tif stacks. These .csv files feature a header row, including timepoint, well name, and field number. The current package allows for data to be presented in two different formats:  a stacked bar graph and line graph. The stacked graphs display cell transition states during the cell death process, and are best to visualize multiple cell death transition states and large differences between samples. Line graphs are best to visualize changes in individual cell death transition states occurring between genotypes, treatments, or disease states. For each type of graph, users select the parameters required for visualization, including total cell counts or population percentages. Mean and standard error of the mean is a default display. Multiple treatments or samples can be visualized simultaneously in a multipanel display, and then exported to .png or .pdf formats. Additional features can be requested by contacting the developers of DeathTrackR. 


# Team members: 
Yushan Liu, Huilai Miao, Cathleen Pena, Linh Le, Hainan Xiong, Weiqi Ricky Peng. For questions (or suggestions and improvements), please contact us bcroker@ucsd.edu. This is a work in progress, so we welcome your feedback!

# License: 

# Acknowledgment: 
This work is supported by NHLBI grant 5R01HL124209-05, and overseen by Dr. Ben Croker and Stephanie Labou, UCSD.

# References: 
[1] Galluzi, Lorenzo, et. al. “Molecular mechanisms of cell death: recommendations of the Nomenclature Committee on Cell Death 2018.” Cell Death and Differentiation 25, 486–541 (2018)




