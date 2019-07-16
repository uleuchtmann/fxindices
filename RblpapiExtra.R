# functions to facilitate easy download of FX data from Bloomberg

bbfix2timeSeries <- function(currencies, startDate, endDate, con=defaultConnection()) {
  # reads in Bloomberg 30-minutes FX fixing data 
  # and exports them as a regular timeSeries object.
  # 
  # args: 
  #   currencies: vector of ISO currency codes or code pairs
  #   startDate, endDate: Date objects, restrict time window of data to download
  #                       The time series start at 17:30 NY time on the day before startDate 
  #                       and ends at 23:30 NY time on endDate. 
  #   con: the blpConnect connecion. [defaultConnection()]
  # 
  # returns: timeSeries object of 30-minutes data of Bloomberg fixing rates.
  #   The function uses Bloomberg's NY fixings.
  #   The (time) zone and FinCenter attributes of the timeSeries are "New_York".
  #   Missing values on non-trading days (incl. weekends).
  # 
  # usage:
  #   spot <- readbbfix(c("EURUSD", "USDJPY", "GBPUSD"), as.Date("2018-06-01"), as.Date("2018-06-28"))
  # 
  # depends: Rblpapi, timeSeries
  #
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
  rates <- Reduce(cbind, lapply(currencies, function(x) sort(Reduce(rbind, tsList[sub(" .*$", "", names(tsList))==x]))))
  names(rates) <- currencies
  # correction of Bbg's DST bug:
  timeStamps <- timeSequence(time(rates[1, ]), time(rates[nrow(rates), ]), by="30 mins", zone="New_York", FinCenter="New_York")
  ones <- timeSeries(rep(1.0, length(timeStamps)), timeStamps)
  rates.c <- merge(timeSeries(rep(1.0, length(timeStamps)), timeStamps), rates)[timeStamps, currencies]
  return(rates.c)
}


bdh2xts <- function(series, field = "PX_LAST", start.date = NULL, end.date = NULL, 
                    per  = c(NULL, "d", "w", "m", "q", "y"), 
                    adj  = c("a", "c", "f"), 
                    days = c("w", "c", "a"), 
                    fill = c("na", "c"), 
                    con=defaultConnection()){
  # reads in Bloomberg time series (daily and lower frequency)
  # and stores them in an xts object
  # 
  # args:
  #   series: vector of Bloomberg tickers to download
  #   field: the Bloomberg field to download ["PX_LAST"]. There can be only one field per 
  #          function call.
  #   start.date, end.date: define range of data to download
  #   per:  periodicity selection. [none] | "d" | "w" | "m" | "q" | "y"
  #   adj:  periodicity adjustment. ["a"] | "c" | "f"
  #   days: non-trading days fill option. ["w"] | "c" | "a"
  #   fill: non-trading-day fill metod. ["na"] | "c"
  #   con: the blpConnect() connection. [defaultConnection()]
  # 
  # depends: Rblpapi, xts

  # check for filed argument
  if(length(field)!=1)
    stop("Requires one but only one field!")
  
  options <- NULL
  
  # periodicity selection:
  per.lib <- c("d"="DAILY","w"="WEEKLY","m"="MONTHLY","q"="QUARTERLY","y"="YEARLY")
  per <- match.arg(per)
  if(!is.null(per)) 
    options <- c("periodicitySelection"=per.lib[[per]])

  # periodicity adjustment:
  adj.lib <- c("a"="ACTUAL", "c"="CALENDAR", "f"="FISCAL")
  adj <- match.arg(adj)
  options <- c(options, "periodicityAdjustment"=adj.lib[[adj]])

  # non-trading day fill options:
  days.lib <- c("w"="NON_TRADING_WEEKDAYS", "c"="ALL_CALENDAR_DAYS", "a"="ACTIVE_DAYS_ONLY")
  days <- match.arg(days)
  options <- c(options, "nonTradingDayFillOption"=days.lib[[days]])

  # non-trading day fill method:
  fill.lib <- c("c"="PREVIOUS_VALUE", "na"="NIL_VALUE")
  fill <- match.arg(fill)
  options <- c(options, "nonTradingDayFillMethod"=fill.lib[[fill]])

  thedata <- bdh(series, field, start.date=start.date, end.date=end.date, options=options, con=con)
  thexts <- Reduce(cbind, lapply(thedata, function(x) xts(x[[2]], x[["date"]])))
  colnames(thexts) <- gsub("\\s*\\w*$", "", series)
  return(thexts)
}
