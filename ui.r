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

        textInput("search", label = h3("Indeed Job Search")),
        span(class='input-group-btn',
          actionButton("goButton",'Search!')
        ),
        HTML('<a href="https://github.com/samjk14/IndeedMaps"><img style="z-index:100;position: absolute; top: 0; right: 0; border: 0;" src="https://camo.githubusercontent.com/365986a132ccd6a44c23a9169022c0b5c890c387/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f7265645f6161303030302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_red_aa0000.png"></a>')
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
