# assumes Bloomberg runs on 192.168.2.112
# assumes on that machine the following commands have been executed:
#   start C:\blp\DAPI\bbcomm.exe
#   socat TCP4-LISTEN:18194,fork TCP4:localhost:8194
options(echo = FALSE, blpAutoConnect = TRUE, blpHost = "192.168.2.112", blpPort = 18194L)
# if Bloomberg runs on localhost, use instead
# options(echo = FALSE, blpAutoConnect = TRUE)
library(Rblpapi)
library(timeSeries)
source("RblpapiExtra.R")

currencies <- c("USD", "EUR", "JPY", "GBP", "AUD",
                "CAD", "CHF", "CNH", "SEK", "NZD",
                "MXN", "SGD", "NOK", "TRY", "RUB",
                "ZAR", "PLN", "THB", "HUF", "CZK",
                "ILS", "RON")
startDate <- "2012-01-10"

exrates <- bbfix2timeSeries(currencies[!currencies=="USD"], as.Date(startDate), as.Date(Sys.Date()))
exrates <- exrates[complete.cases(exrates), ]
save(exrates, file="exrates.RData")
cat(paste("exrates.RData created with data from", start(exrates), "to", end(exrates), "\n"))
Sys.sleep(300)

repeat {
  if(substr(Sys.time(), 15, 16) %in% c("03", "33")) {
    exrates.new <- bbfix2timeSeries(currencies[!currencies=="USD"], as.Date(Sys.Date()-1), as.Date(Sys.Date()))
    exrates.new <- exrates.new[(time(exrates.new)>end(exrates)) & complete.cases(exrates.new), ]
    exrates <- rbind(exrates, exrates.new)
    names(exrates) <- names(exrates.new)
    save(exrates, file="exrates.RData")
    cat(paste("exrates.RData updated to", end(exrates), "\n"))
    Sys.sleep(300)
  }
}

load("exrates.RData")
tail(exrates[,"EUR_EUR_EUR"], n=100)
