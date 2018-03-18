#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#******************************************************
#
# Set up the environment
#
#******************************************************
library(shiny)
library(NHLData)

#******************************************************
#
# Load in and prepare the data
#
#******************************************************
data("Sch0506")
data("Sch0607")
data("Sch0708")
data("Sch0809")
data("Sch0910")
data("Sch1011")
data("Sch1112")
data("Sch1213")
data("Sch1314")
data("Sch1415")
data("Sch1516")
AllGames <- rbind(Sch0506,Sch0607,Sch0708,Sch0809,Sch0910,
      Sch1011,Sch1112,Sch1213,Sch1314,Sch1415,Sch1516
      )
AllGames$Date <- as.Date(AllGames$Date)
Playoffs <- subset(AllGames,Playoff=="Y")
RegularSeason <- subset(AllGames,Playoff=="N")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("NHL Goal Differentials"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
            radioButtons("Playoffer",
                  label="Do you want to include playoff games",
                  choices = list("Regular Season"='RegG',"Playoffs"='PlayG',"All Games"='AllG'),
                  selected='AllG'
            ),
         sliderInput("YearRange",
                     "During Which Years",
                     min = as.Date("2005-08-01"),
                     max = as.Date("2017-01-01"),
                     value = as.Date(c("2005-08-01","2017-01-01")),
                     step=1)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("mygraph")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
      
      cols <- reactive({
            as.numeric(c(input$var))
            
      })
      mylabel <- reactive({
            if(input$Playoffer=='RegG'){
                  lable <- "Plot for Regular Season"
            }
            if(input$Playoffer=='PlayG'){
                  lable <- "Plot for Playoffs"
            }
            if(input$Playoffer=='AllG'){
                  lable <- "Plot for All Games"
            }
            lable
      })
      
      
      myFinalData <- reactive({
            #------------------------------------------------------------------
            # Select data according to selection of radio button
            if(input$Playoffer=='RegG'){
                  mydata <- RegularSeason
                  
            }
            
            if(input$Playoffer=='PlayG'){
                  mydata <- Playoffs
            }
            
            if(input$Playoffer=='AllG'){
                  mydata <- AllGames
            }
            #------------------------------------------------------------------
            # Get data rows for selected year
            mydata1 <- subset(mydata,Date >= as.Date(input$YearRange[1]))
            mydata1 <- subset(mydata1,Date <= input$YearRange[2])
            #mydata1 <- mydata[mydata$Date >= input$YearRange[1], ] # From Year
            #mydata1 <- mydata1[mydata1$Date <= input$YearRange[2], ] # To Year
            #------------------------------------------------------------------
            # Get data rows for selected year
            data.frame(mydata1)
            #------------------------------------------------------------------
            
      })
      

      
      # Prepare Plot 
      output$mygraph <- renderPlot({
            plotdata <- myFinalData()
            plot(x=plotdata$Date, y=plotdata$GDH, main=mylabel(), xlim=as.Date(c("2005-08-01","2017-01-01")), ylim=c(-10,10))
            fit <- lm(GDH~Date, data=plotdata)
            abline(fit,col="red")
      })
      
      
}

# Run the application 
shinyApp(ui = ui, server = server)

