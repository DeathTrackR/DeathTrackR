# load packages
library(plotrix) # for standard error function
library(tidyverse) # this includes dplyr for data wranling, ggplot2 for plotting, and tidyr for reshaping data
library(shiny)

#import file
path <- file.choose()
print(path)

#read data 
data <- read.csv(path)
print(colnames(data))
unique(data$ï..Well.Name)

#Group the data
#group_by <- readline(prompt="Enter paramters: ")
#print(group_by)

#subset the data
#well_select<-scan()

#calculation (mean and SEM)

