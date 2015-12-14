library(shiny)

getStateListItem <- function(s) {
  tags$li(tags$a(href='#','data-value'= s, 'data-toggle'='tab', s))
}

getStateList <- function() {
  states = state.name[state.name != 'Hawaii' & state.name != 'Alaska']
  lapply(states, getStateListItem)
}

getNav <- function(navId) {
  tagList(
    fluidRow(
      column(12, class = 'well',
        tags$ul(id = navId,
               class = 'nav nav-pills nav-stacked shiny-tab-input shiny-bound-input',
               tags$li(class='navbar-brand', 'States'),
               tags$li(class='active', 
                       tags$a(href='#','data-value'='US', 'data-toggle'='tab','US')),
               getStateList()
               
        )
      )
    )
  )
}

shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  fluidRow(
    column(12,
      div(style='width:100%;height:100%;padding-top:10px;',
         textInput("search", label = h3("Job Search")),
         actionButton("goButton", "Go!")
      )
    )
  ),
  fluidRow(
    div(class = 'col-sm-2',
        getNav('nav')
    ),
    column(10,
      fluidRow(
        column(12,
          plotOutput('map', height = '600px')
        ),
        column(12,
          column(6,
            h3('Stats'),
            htmlOutput('stats')
          ),
          column(6,
            plotOutput('cloud', width = '100%')
          )
        )
      )
    )
  )
))
