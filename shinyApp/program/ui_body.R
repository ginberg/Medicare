# ----------------------------------------
# --          PROGRAM ui_body.R         --
# ----------------------------------------
# USE: Create UI elements for the
#      application body (right side on the
#      desktop; contains output) and
#      ATTACH them to the UI by calling
#      add_ui_body()
#
# NOTEs:
#   - All variables/functions here are
#     not available to the UI or Server
#     scopes - this is isolated
# ----------------------------------------

# -- IMPORTS --



# ----------------------------------------
# --      BODY ELEMENT CREATION         --
# ----------------------------------------

# -- Create Elements
body1 <-box(id     = "readmeBox",
            title  = "README",
            width  = 12,
            status = "info",
            collapsible = T,
            collapsed   = F,
            useShinyjs(), 
            extendShinyjs(text = jscode, functions = c('collapse')),
            tags$head(tags$script(HTML(btnjs))),
            includeMarkdown("info.md")
          )

isCollapsed <- collapsedInput(inputId = "isReadmeCollapsed", boxId = "readmeBox")

body2 <- box(width  = 12,
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
             ))


# -- Register Elements in the ORDER SHOWN in the UI
add_ui_body(list(body1, isCollapsed, body2))
