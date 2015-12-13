library(shiny)
source('functions.r')

shinyServer(function(input, output, session)
{
  searchUS <- eventReactive(input$goButton, {
    getCountryMap(input$search)
  })
  
  searchState<- eventReactive(input$goButton, {
    jobs = getStateInfo(input$search, input$nav)
    getStateMap(jobs$jobs)
  })
  
  observe({
    input$goButton
    output$map <- renderPlot({
      if (input$nav == 'US' && input$search != '')
        searchUS()
      else if (input$nav != 'US'  && input$search != '')
        searchState()
      else
        return()
    })
  })
})


