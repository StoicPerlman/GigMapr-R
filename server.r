library(shiny)
source('functions.r')

shinyServer(function(input, output, session)
{
  values <- reactiveValues(jobs=NULL, btnClick=0)

  observeEvent(input$goButton, {
    output$map <- renderPlot({
      if (input$nav == 'US' && input$search != '')
      {
        values$jobs = getCountryInfo(input$search)
        getCountryMap(values$jobs)
      }
      else if (input$nav != 'US' && input$search != '')
      {
        values$jobs = getStateInfo(input$search, input$nav)
        getStateMap(values$jobs$jobs)
      }
      else
        return()
    })

    output$cloud <- renderPlot({
      if (input$nav != 'US' && input$search != '')
      {
        getStateCloud(values$jobs$text)
      }
      else
        return()
    })

    output$stats <- renderText({
      if (input$nav == 'US' && input$search != '')
      {
        getCountryStats(values$jobs)
      }
      else if (input$nav != 'US' && input$search != '')
      {
        getStateStats(values$jobs$jobs)
      }
      else
        return()
    })
  })
})