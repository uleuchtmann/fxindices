readbbfix <- function(currencies, startDate, endDate) {
  require(Rblpapi)
  require(timeSeries)
  require(purrr)
  con <- blpConnect()
  n <- length(currencies)
  timeTags <- paste0("F",formatC(rep(0:23,rep(2,24)), width=2, format="d", flag="0"),c("0","3"))
  timeStrs <- paste0(substring(timeTags,2,3),":",substring(timeTags,4,4),"0:00")
  Tags <- paste(expand.grid(timeTags, currencies)[,2], expand.grid(timeTags, currencies)[,1], "Curncy")
  BBout <- bdh(Tags, "PX_LAST", startDate, endDate, include.non.trading.days=TRUE)
  BBout.s <- BBout[sapply(Tags, function(y,x) which(names(x)==y), BBout)]
  makeTS <- function(x,y) ifelse(y > "17:00:00",
                                 return(timeSeries(x$PX_LAST, paste(as.character(x$date - 1), y), zone="New_York", FinCenter="New_York")),
                                 return(timeSeries(x$PX_LAST, paste(as.character(x$date),     y), zone="New_York", FinCenter="New_York")))
  tsList <- mapply(makeTS, BBout.s, rep(timeStrs, n), SIMPLIFY=FALSE)
  TSlist <- list()
  for(i in 1:n) TSlist[[i]] <- reduce(tsList[names(tsList[(1+48*(i-1L)):(48+48*(i-1L))])], merge)
  rates <- reduce(TSlist, cbind)
  names(rates) <- currencies
  blpDisconnect(con)
  return(rates)
}

library(Rblpapi)
library(timeSeries)
library(purrr)

spot <- readbbfix(c("EURUSD", "USDJPY", "GBPUSD"), as.Date("2018-06-01"), as.Date("2018-06-28"))
tail(spot, n=48)
plot(spot)

