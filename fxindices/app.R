#

library(shiny)
library(timeSeries)

# assumes Bloomberg runs on 192.168.2.115
# assumes on that machine the following commands have been executed:
#   start C:\blp\DAPI\bbcomm.exe
#   socat TCP4-LISTEN:18194,fork TCP4:localhost:8194
options(blpAutoConnect=TRUE, blpHost="192.168.2.115", blpPort=18194L)
# if Bloomberg runs on localhost, use instead
# options(blpAutoConnect=TRUE)
library(Rblpapi)
source("RblpapiExtra.R")

currencies <- c("USD", "EUR", "JPY", "GBP", "AUD",
                "CAD", "CHF", "CNH", "SEK", "NZD",
                "MXN", "SGD", "NOK", "TRY", "RUB",
                "ZAR", "PLN", "THB", "HUF", "CZK",
                "ILS", "RON")

equotation <- c("EUR", "GBP", "AUD", "NZD")
exrate.names <- NULL
for(i in currencies[-1]) {
  if (i %in% equotation) {
    exrate.names <- append(exrate.names, paste0(i, "USD"))
  } else {
    exrate.names <- append(exrate.names, paste0("USD", i))
  }
}


load("FX.RData")
exrates <- FX[,exrate.names]
rm(FX)


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Commerzbank Currency Indices"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  last.obs <- end(exrates[complete.cases(exrates),])
  if (difftime(Sys.time(), last.obs, units="mins") > 35) {
    con <- blpConnect()
    exrates.new <- bbfix2timeSeries(names(exrates),
                                    as.Date(last.obs),
                                    as.Date(Sys.Date()), con=con)
    exrates <- rbind(exrates, 
                     exrates.new[!(as.character(time(exrates.new)) %in% as.character(time(exrates))),])
  }
  
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2] 
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

