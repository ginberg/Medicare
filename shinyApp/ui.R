library(shinydashboard)
library(shinyBS)
  
dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    list(
      selectInput("stateFilter", 
                  label = "State:",
                  choices = stateChoices,
                  selected = 'All'),
      
      selectInput("cityFilter",
                  label = 'City:',
                  choices = cityChoices,
                  selected = 'All'),
      
      selectInput("infectionFilter",
                  label = 'Infection:',
                  choices = infectionChoices,
                  selected = 'MRSA'),
  
      selectInput("metricFilter",
                  label = 'Metric:',
                  choices = metricChoices,
                  selected = 'Patient Days'),
      sliderInput("maxResults", "Maximum results", min = SLIDER_MIN_VALUE, max = SLIDER_MAX_VALUE, value = SLIDER_INIT_VALUE),
      br(), br(),
      bsButton("plot", label  = "Plot",
               type   = "primary",
               value  = FALSE,
               style  = "primary",
               size   = "default",
               width  = "90%",
               icon   = icon("arrow-right")))),
  dashboardBody(
    box(title  = "Compare US Hospitals regarding infections",
                 width  = 12,
                 status = "info",
                 collapsible = T,
                 collapsed   = T,
                 includeMarkdown("info.md")
    ),
    box(width  = 12,
        status = "primary",
        collapsible = F,
        tabsetPanel(id='main',
          tabPanel('Barplot', p(),
            plotlyOutput("chart", width='100%', height = '800px')
          ),
          tabPanel('Map', p(),
            leafletOutput("map", height = "800px")
          ),
          tabPanel("Data", p(),      
            dataTableOutput("dataTable")
          )
        )
      )
    )
)