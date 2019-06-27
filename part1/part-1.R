#import file
path <- file.choose()
print(path)

#read data as dataframe
data <- read.csv(path)
data <- data.frame(data)
print(colnames(data))

#subset the data by selection
columns_select <- scan()

