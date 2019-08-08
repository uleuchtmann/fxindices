library(shiny)
# assumes Bloomberg runs on 192.168.2.112
# assumes on that machine the following commands have been executed:
#   start C:\blp\DAPI\bbcomm.exe
#   socat TCP4-LISTEN:18194,fork TCP4:localhost:8194
options(blpAutoConnect=TRUE, blpHost="192.168.2.112", blpPort=18194L)
# if Bloomberg runs on localhost, use instead
# options(blpAutoConnect=TRUE)
library(Rblpapi)
library(timeSeries)
source("../RblpapiExtra.R")

currencies <- c("USD", "EUR", "JPY", "GBP", "AUD",
                "CAD", "CHF", "CNH", "SEK", "NZD",
                "MXN", "SGD", "NOK", "TRY", "RUB",
                "ZAR", "PLN", "THB", "HUF", "CZK",
                "ILS", "RON")
startDate <- "2012-01-10"

importUSDrates <- function(currencies, startDate = "2012-01-10") {
  equotation <- c("EUR", "GBP", "AUD", "NZD")
  exrates <- bbfix2timeSeries(currencies[!currencies=="USD"], as.Date(startDate), as.Date(Sys.Date()))
  exrates <- exrates[complete.cases(exrates), ]
  USDrates <- cbind(timeSeries(rep(1.0, nrow(exrates)), time(exrates)),
                    exrates)
  names(USDrates) <- c("USD", names(exrates))
  for(i in equotation) USDrates[,i] <- 1.0 / USDrates[,i]
  return(USDrates)
}

calcIndices <- function(USDrates, normDate) {
  scaleTime <- max(time(USDrates)[time(USDrates) < as.timeDate(paste(normDate, "17:30"), zone="New_York")])
  scaled <- scale(USDrates, center = FALSE, scale = as.vector(USDrates[scaleTime, ]))
  vnorm <- function(x) norm(as.matrix(x))
  norms <- apply(scaled, 1, vnorm)
  for(j in 1:ncol(scaled)) scaled[, j] <- scaled[, j] / norms
  reverse <- scale(scaled, center=FALSE, scale = as.vector(scaled[scaleTime, ]))
  indices <- 100.0 / reverse
  return(indices)
}

ui <- fluidPage(
  
  titlePanel("Commerzbank Currency Indices"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("curncy1", h3("Base Currency"), 
                  choices = currencies, selected = "EUR"),
      selectInput("curncy2", h3("Quote Currency", style = "color:red"), 
                  choices = currencies, selected = "USD"),
      dateInput("normDate", h3("Normalization Date"), value = Sys.Date()-30, 
                min = startDate, max = Sys.Date()-1),
      dateRangeInput("plotRange", h3("Plot Range"), 
                     start = Sys.Date()-30, end = Sys.Date(),
                     min = startDate, max = Sys.Date())
      
    ),
    mainPanel(
      plotOutput("indicesPlot"),
      plotOutput("spotPlot")
    )
  )

)

server <- function(input, output) {
  
  USDrates <- importUSDrates(currencies, startDate = startDate)
  
  output$indicesPlot <- renderPlot({
    indices <- calcIndices(USDrates, input$normDate)
    selected <- c(input$curncy1, input$curncy2)
    startTimeDate <- as.timeDate(paste(input$plotRange[1], "17:30"), zone="New_York")
    endTimeDate <- min(as.timeDate(Sys.time()), as.timeDate(paste(input$plotRange[2], "17:30"), zone="New_York"))
    plot(window(indices[,selected], startTimeDate, endTimeDate), 
         plot.type = "s", main = "Currency Indices", xlab = "", ylab = "")
  })
  
  output$spotPlot <- renderPlot({
    spot <- USDrates[,input$curncy2] / USDrates[,input$curncy1]
    startTimeDate <- as.timeDate(paste(input$plotRange[1], "17:30"), zone="New_York")
    endTimeDate <- min(as.timeDate(Sys.time()), as.timeDate(paste(input$plotRange[2], "17:30"), zone="New_York"))
    plot(window(spot, startTimeDate, endTimeDate),
         main="Spot", xlab="", ylab="")
  })

}


# Run the application 
shinyApp(ui = ui, server = server)

