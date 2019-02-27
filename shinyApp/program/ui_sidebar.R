# ----------------------------------------
# --       PROGRAM ui_sidebar.R         --
# ----------------------------------------
# USE: Create UI elements for the
#      application sidebar (left side on
#      the desktop; contains options) and
#      ATTACH them to the UI by calling
#      add_ui_sidebar_basic() or
#      add_ui_sidebar_advanced()
#
# NOTEs:
#   - All variables/functions here are
#     not available to the UI or Server
#     scopes - this is isolated
# ----------------------------------------

# -- IMPORTS --
suppressPackageStartupMessages(library(shinyjs))

# ----------------------------------------
# --     SIDEBAR ELEMENT CREATION       --
# ----------------------------------------

spacer <- tags$div(HTML("&nbsp;"))


# -- Create Basic Elements

add_ui_sidebar_basic(
  list(tags$br(),
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
      br(), br(),
      bsButton("plot", label  = "Plot/Update",
               type   = "primary",
               value  = FALSE,
               style  = "primary",
               size   = "default",
               width  = "90%",
               icon   = icon("arrow-right"))
    )
)

# -- Register Advanced Elements in the ORDER SHOWN in the UI
add_ui_sidebar_advanced(list(tags$br(),
                             sliderInput("maxResults", "Maximum results", min = SLIDER_MIN_VALUE, max = SLIDER_MAX_VALUE, value = SLIDER_INIT_VALUE),
                             tags$br(), tags$br()
                        ))