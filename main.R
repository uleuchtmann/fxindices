# main file as working horse for the project: testing, development etc.

# read in EURUSD data
options(blpAutoConnect=TRUE, blpHost="192.168.2.130", blpPort=18194L)
library(Rblpapi)
blpConnect()
library(timeSeries)
library(purrr)
source("RblpapiExtra.R")
bbfix2timeSeries("EURUSD", as.Date("2017-01-01"), as.Date("2017-12-31"))

