library(shiny)

shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  fluidRow(
    fluidRow(
      column(12,
        div(style='width:100%;height:100%;padding-top:10px;',
          textInput("search", label = h3("Job Search")),
          actionButton("goButton", "Go!")
        )
      )
    ),
    fluidRow(
      column(12,
             plotOutput("map", height = '650px')
      )
    )
  )
))