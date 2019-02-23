library(shinydashboard)
library(shinyBS)
library(shinyjs)

dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    list(
      selectInput("infectionFilter",
                  label = 'Infection:',
                  choices = infectionChoices,
                  selected = 'MRSA'),
      
      selectInput("metricFilter",
                  label = 'Metric:',
                  choices = metricChoices,
                  selected = 'Patient Days'),
      selectInput("stateFilter", 
                  label = "State:",
                  choices = stateChoices,
                  selected = 'All'),
      
      selectInput("cityFilter",
                  label = 'City:',
                  choices = cityChoices,
                  selected = 'All'),
      sliderInput("maxResults", "Maximum results", min = SLIDER_MIN_VALUE, max = SLIDER_MAX_VALUE, value = SLIDER_INIT_VALUE),
      br(), br(),
      bsButton("plot", label  = "Plot/Update",
               type   = "primary",
               value  = FALSE,
               style  = "primary",
               size   = "default",
               width  = "90%",
               icon   = icon("arrow-right")))),
  dashboardBody(
    useShinyjs(), 
    extendShinyjs(text = jscode, functions = c('collapse')),
    box(id     = "readmeBox",
        title  = "Compare US Hospitals regarding infections - README",
        width  = 12,
        status = "info",
        collapsible = T,
        collapsed   = F,
        tags$head(tags$script(HTML(btnjs))),
        includeMarkdown("info.md")
    ),
    collapsedInput(inputId = "isReadmeCollapsed", boxId = "readmeBox"),
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