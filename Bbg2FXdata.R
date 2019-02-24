# read in Bloomberg FX fixing data and 
# store as timeSeries object in file FX.RData

# assumes Bloomberg runs on 192.168.2.124
# assumes on that machine the following commands have been executed:
#   start C:\blp\API\bbcomm.exe
#   socat TCP4-LISTEN:18194,fork TCP4:localhost:8194
options(blpAutoConnect=TRUE, blpHost="192.168.2.124", blpPort=18194L)
# if Bloomberg runs on localhost, use instead
# options(blpAutoConnect=TRUE)

library(Rblpapi)
library(timeSeries)

source("RblpapiExtra.R")

# connection test:
# bdp("EUR Curncy", "PX_LAST")

currencies <- c("EURUSD", "USDJPY", "GBPUSD", "USDCHF", "USDCAD", "AUDUSD", 
                "NZDUSD", "USDSEK", "USDNOK", "USDDKK", "USDPLN", "USDCZK", 
                "USDHUF", "USDRUB", "USDZAR", "USDTRY", "USDILS", "USDCNH", 
                "USDINR", "USDSGD", "USDTHB", "USDMYR", "USDMXN", "USDBRL", 
                "USDCLP")
FX <- bbfix2timeSeries(currencies, as.Date("2007-02-28"), as.Date("2018-02-27"))

save(FX, file="FX.RData")