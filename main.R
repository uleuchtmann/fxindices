# main file as working horse for the project: testing, development etc.

# read in EURUSD data
options(blpAutoConnect=TRUE, blpHost="192.168.2.130", blpPort=18194L)
library(Rblpapi)
con <- blpConnect()
library(timeSeries)
library(purrr)
source("RblpapiExtra.R")
EURUSD <- bbfix2timeSeries("EURUSD", as.Date("2007-02-28"), as.Date("2018-11-05"))
setFinCenter(EURUSD) <- "GMT"
plot(EURUSD)


# transformations
# 30-minutes data
e30  <- window(log(EURUSD), "2007-03-01 00:00:00", "2018-10-31 23:30:00") 
De30 <- window(100.0 * diff(log(EURUSD)), 
               "2007-03-01 00:00:00", "2018-10-31 23:30:00") 
Ve30 <- window((100.0*filter(log(EURUSD), 
                             c(1,-2,1), method="convolution", sides=1))^2.0,
               "2007-03-01 00:00:00", "2018-10-31 23:30:00") 
# 60-minutes data 
e60  <- window(log(EURUSD[seq(2,length(EURUSD),2), ]), 
               "2007-03-01 00:00:00", "2018-10-31 23:30:00")
De60 <- window(100.0 * diff(log(EURUSD[seq(2,length(EURUSD),2), ])), 
               "2007-03-01 00:00:00", "2018-10-31 23:30:00")
Ve60 <- window((100.0*filter(log(EURUSD[seq(2,length(EURUSD),2), ]), 
                             c(1,-2,1), method="convolution", sides=1))^2.0, 
               "2007-03-01 00:00:00", "2018-10-31 23:30:00")
  
  
