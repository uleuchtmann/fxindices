# main file as working horse for the project: testing, development etc.

# read in EURUSD data
options(blpAutoConnect=TRUE, blpHost="192.168.2.130", blpPort=18194L)
library(Rblpapi)
con <- blpConnect()
library(timeSeries)
library(purrr)
source("RblpapiExtra.R")
EURUSD <- bbfix2timeSeries("EURUSD", as.Date("2007-03-01"), as.Date("2018-11-05"))
plot(EURUSD)
e <- log(EURUSD)



