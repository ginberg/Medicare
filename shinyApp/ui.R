library(shinydashboard)
  
dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    list(
      selectInput("stateFilter", 
                  label = "State:",
                  choices = stateChoices,
                  selected = 'CA'),
      
      selectInput("cityFilter",
                  label = 'City:',
                  choices = cityChoices,
                  selected = 'LOS ANGELES'),
      
      selectInput("infectionFilter",
                  label = 'Infection:',
                  choices = infectionChoices,
                  selected = 'MRSA'),
  
      selectInput("metricFilter",
                  label = 'Metric:',
                  choices = metricChoices,
                  selected = 'Patient Days'),
      sliderInput("maxResults", "Maximum results", min = SLIDER_MIN_VALUE, max = SLIDER_MAX_VALUE, value = SLIDER_INIT_VALUE))),
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
            fluidRow(plotlyOutput("chart",width='100%', height = '800px'))
          ),
          tabPanel('Map', p(),
            fluidRow(leafletOutput("map", height = "800px"))
          ),
          tabPanel("Data", p(),      
            fluidRow(dataTableOutput("dataTable"))
          )
        )
      )
    )
)