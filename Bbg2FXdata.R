# read in Bloomberg FX fixing data and 
# store as timeSeries object in file FX.RData

# assumes Bloomberg runs on 192.168.2.115
# assumes on that machine the following commands have been executed:
#   start C:\blp\DAPI\bbcomm.exe
#   socat TCP4-LISTEN:18194,fork TCP4:localhost:8194
options(blpAutoConnect=TRUE, blpHost="192.168.2.115", blpPort=18194L)
# if Bloomberg runs on localhost, use instead
# options(blpAutoConnect=TRUE)

library(Rblpapi)
library(timeSeries)

source("RblpapiExtra.R")

# connection test:
bdp("EUR Curncy", "PX_LAST")

# select all exchange rates with BGNE source
currencies <- c("AUDUSD", "GBPUSD", "USDCAD", "USDCNH", "USDCZK",
                "USDDKK", "EURUSD", "USDHKD", "USDHUF", "USDINR", 
                "USDILS", "USDJPY", "USDMXN", "NZDUSD", "USDNOK", 
                "USDPLN", "USDRON", "USDRUB", "USDSGD", "USDZAR", 
                "USDSEK", "USDCHF", "USDTHB", "USDTRY")

# download as timeSeries object
# with the help of the 'bbfix2timeSeries' function
FX <- bbfix2timeSeries(currencies, as.Date("2007-02-28"), as.Date(Sys.Date()))

# clip off data points in the future
FX <- FX[as.POSIXct(time(FX)) < Sys.time(), ]

# save to file 'FX.RData'
save(FX, file="FX.RData")


