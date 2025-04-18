library(shiny)

ui <- fluidPage(titlePanel("Sample Shiny App"), sidebarLayout(sidebarPanel("Inputs"), mainPanel("Outputs")))
server <- function(input, output) {}
shinyApp(ui, server)