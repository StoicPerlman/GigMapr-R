library(shiny)
source('functions.r')

shinyServer(function(input, output, session)
{
  search <- eventReactive(input$goButton, {
    getCountryMap(input$search)
  })
  
  output$map <- renderPlot({
    search()
  })
})


