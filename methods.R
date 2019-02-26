
endOfDay <- function(x) time(x)[substr(time(x), 12, 19)=="17:00:00"]
endOfWeek <- function(x) time(x)[(substr(time(x), 12, 19)=="17:00:00")&(dayOfWeek(time(x))=="Fri")]


#' Moment statistics
#' 
#' @param x A timeSeries object.
#' @param stat Difference \code{"diff"} or bi-power variation \code{"bipower"}.
#' @param k The power of the (absolute) moment.
#' @param N The number of observations over which the statistic is averaged.
#' @param resolution The calculation is done at the chosen resolution. See the 
#'        documentation of \code{timeSeries::timeSequence} for possible values.
#' @param omit.na Should NAs be omitted. 
#' @return For \code{stat="diff"} a timeSeries object with elements 
#'         $m_t = \frac{1}{N} \sum_{i=0}^{N-1} \left| x_{t-i} - x_{t-i-1} \right|^k.
#'         For \code{stat="bipower"} a timeSeries object with elements
#'         $m_t = \frac{1}{N} \sum_{i=0}^{N-1} \left| x_{t-i} - 2x_{t-i-1} + x_{t-i-2}\right|^k.
M <- function(x, stat=c("diff", "bipower"), k=2, N=40L, resolution="30 mins", omit.na=FALSE) {
  ifelse(omit.na, 
         X <- na.omit(x[timeSequence(time(x[1, ]), time(x[nrow(x), ]) , by=resolution), ]),
         X <- x[timeSequence(time(x[1, ]), time(x[nrow(x), ]) , by=resolution), ]
  )
  stat <- match.arg(stat)
  w <- switch(stat, diff=c(1.0, -1.0), bipower=c(1.0, -2.0, 1.0))
  V <- abs(filter(X, w, method="convolution", sides=1))^k
  phi <- rep(1.0/N, N)
  M <- filter(V, phi, method="convolution", sides=1)
  names(M) <- paste0("M.", names(x))
  return(M)
}


#' Hust exponent estimator
#' 
H <- function(x, stat=c("diff", "bipower"), k=2, resolution.high="30 mins", low=2, N.low=48) {
  resolution.low <- paste(low * as.numeric(sub("(\\w+).*", "\\1", resolution.high)), 
                          tail(strsplit(resolution.high,split=" ")[[1]],1))
  N.high <- N.low * low
  cat(paste("low resolution:",  resolution.low,  N.low,  "observations", "   ", 
            "high resolution:", resolution.high, N.high, "observations", "\n"))
  stat <- match.arg(stat)
  M.low  <- M(x, stat=stat, k=k, resolution=resolution.low,  N=N.low,  omit.na=TRUE)
  M.high <- M(x, stat=stat, k=k, resolution=resolution.high, N=N.high, omit.na=TRUE)
  M.high <- M.high[time(M.low), ]
  H <- (1.0/k)*log(M.low / M.high, base=low)
  names(H) <- paste0("H.", names(x))
  return(H)
}  
