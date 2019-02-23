# main file as working horse for the project: testing, development etc.

library(timeSeries)

# read in EURUSD data from Bloomberg
# options(blpAutoConnect=TRUE, blpHost="192.168.2.124", blpPort=18194L)
# library(Rblpapi)
# con <- blpConnect()
# source("RblpapiExtra.R")
# connection test:
# bdp("EUR Curncy", "PX_LAST")
# EURUSD <- bbfix2timeSeries("EURUSD", as.Date("2007-02-28"), as.Date("2018-11-05"))



# read in FX data from FX.Rdata, extract EURUSD
setRmetricsOptions(myFinCenter = "America/New_York")
load("FX.RData")
EURUSD <- window(FX[, "EURUSD"], "2007-02-28 17:30:00", "2019-01-08 08:30:00")
rm(FX)


time(FX[1, ])
time(FX[nrow(FX), ])
nrow(FX)
regTimeStamps <- timeSequence(time(FX[1, ]), time(FX[nrow(FX), ]), by="30 mins")
ones <- timeSeries(rep(1.0, length(regTimeStamps)), regTimeStamps)
nrow(ones)
foo <- cbind(ones, FX)
nrow(foo)

length(regTimeStamps)


# transformations
e <- log(EURUSD)




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

ind = sqrt(2.0 * Ve30 / Ve60)  
  
