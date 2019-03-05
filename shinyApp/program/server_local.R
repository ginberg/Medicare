# ----------------------------------------
# --       PROGRAM server_local.R       --
# ----------------------------------------
# USE: Session-specific variables and
#      functions for the main reactive
#      shiny server functionality.  All
#      code in this file will be put into
#      the framework inside the call to
#      shinyServer(function(input, output, session)
#      in server.R
#
# NOTEs:
#   - All variables/functions here are
#     SESSION scoped and are ONLY
#     available to a single session and
#     not to the UI
#
#   - For globally scoped session items
#     put var/fxns in server_global.R
#
# FRAMEWORK VARIABLES
#     input, output, session - Shiny
#     ss_userid - BMS userID, authenticated
#     ss_userAction.Log - Reactive Logger S4 object
# ----------------------------------------

# -- IMPORTS --


# -- VARIABLES --

userSel <- reactiveValues()
userSel$state       <- NULL
userSel$city        <- NULL
userSel$infection   <- NULL
userSel$metric      <- NULL
userSel$max_results <- NULL
userSel$show_data   <- FALSE


# Get input data for measurement for hospital vs score
getMeasureData <- reactive({
  tmp = df %>% filter(!is.na(Score))
  
  if(userSel$state != ALL_FILTER_NAME){
    tmp <- tmp %>% filter(State == userSel$state)
  }
  if(userSel$city != ALL_FILTER_NAME){
    tmp <- tmp %>% filter(City == userSel$city)
  }
  if(userSel$infection != ALL_FILTER_NAME){
    tmp <- tmp %>% filter(Infection == userSel$infection)
  }
  if(userSel$metric != ALL_FILTER_NAME){
    tmp <- tmp %>% filter(Metric == userSel$metric)
  }
  
  tmp <- tmp %>% arrange(-Score)
  return(tmp %>% head(userSel$max_results))
})

## RENDER OUTPUT

# interactive plot
output$chart = renderPlotly({
  if (userSel$show_data) {
    df_filtered <- getMeasureData()
    req(nrow(df_filtered) > 0)
    
    # change to factor otherwise plotly doesn't display it in right order
    df_filtered$Hospital.Name <- factor(df_filtered$Hospital.Name, levels = rev(df_filtered$Hospital.Name))
    
    #margin
    margins <- list(l = 300, r = 0, b = 40, t = 40, pad = 4)
    
    # create a named vector of colors, so each value is associated with a color
    global_colors <- setNames(FORMAT_CHART_COLOR_LIST, FORMAT_COLUMN_VALUES)
    
    create_bar_chart(df_filtered,
                     userSel,
                     global_colors,
                     margins)
    # plot_ly(df_filtered, x = ~Score, y = ~Hospital.Name, 
    #         type = "bar", color = ~Compared.to.National, colors = global_colors, 
    #         hoverinfo = 'text', text = ~paste('State: ', State, 
    #                                           '<br> City: ', City,
    #                                           '<br> Score: ', Score)) %>%
    #   layout(title = paste("Metric value per hospital:", userSel$infection, userSel$metric), xaxis = list(title = "Value"), yaxis = list(title = ""), margin = m) %>%
    #   config(displayModeBar = F) 
  }
})

output$dataTable = renderDataTable({
  if (userSel$show_data) {
    df_filtered <- getMeasureData()
    result <- df_filtered %>% arrange(Measure.Name, -Score) %>%
      select(Measure.Name,latlon,Hospital.Name,Score,Compared.to.National,State,City,Address,Phone.Number)
    
    # Hide some columns
    hideCols <- grep("latlon|State|City", colnames(result)) - 1
    datatable(result, rownames = FALSE, extensions = 'Buttons', class = "compact",
              options = list(pageLength = MAX_ITEMS_PER_PAGE, 
                             lengthMenu = LENGTH_MENU,
                             paging = TABLE_PAGING,
                             pagingType='simple',
                             dom = 'Blfrtip',
                             columnDefs = list(list(visible = FALSE, targets = hideCols)), # hide columns
                             buttons = list(list(extend = 'csv', exportOptions = list(columns = ':visible')), list(extend = 'pdf', exportOptions = list(columns = ':visible')),
                                            list(extend = 'colvis', text='Show/Hide Columns', collectionLayout='fixed two-column'))
              )
    ) %>%
      formatStyle(FORMAT_COLUMN, target = 'row',
                  backgroundColor = styleEqual(c(FORMAT_COLUMN_VALUE, FORMAT_COLUMN_VALUE_WARN), c(FORMAT_COLUMN_COLOR, FORMAT_COLUMN_COLOR_WARN)))
  }
})

# map with all locations 
output$map <- renderLeaflet({
  if (userSel$show_data) {
    df_filtered <- getMeasureData()
    df_filtered$ScoreRel <- sqrt(df_filtered$Score / max(df_filtered$Score, na.rm = TRUE))
    leaflet()  %>%
      setView(lng = df_filtered[1,]$longitude, lat = df_filtered[1,]$latitude, zoom = 6) %>%
      addProviderTiles("Stamen.TonerLite", options = providerTileOptions(noWrap = TRUE)) %>% 
      addCircleMarkers(data = df_filtered, lat = ~latitude, lng = ~longitude, radius = ~ScoreRel*20, color = "#FF4742")
  }
})

# Show a popup at the given location
showPopup <- function(id, lat, lng) {
  df_filtered <- getMeasureData()
  row <- df_filtered[df_filtered$latitude == lat & df_filtered$longitude == lng,]
  content <- paste(
    "Hospital:", row$Hospital.Name, "<br>",
    "Score:", row$Score, "<br>")
  leafletProxy("map") %>% addPopups(lng, lat, content, layerId = id)
}

# -- MODULES --

# ----------------------------------------
# --          SHINY SERVER CODE         --
# ----------------------------------------

# When map is clicked, show a popup
observeEvent(input$map_marker_click, {
  leafletProxy("map") %>% clearPopups()
  event <- input$map_marker_click
  if (is.null(event))
    return()
  
  isolate({
    showPopup(event$id, event$lat, event$lng)
  })
})

# Update cities when selecting state
observeEvent(input$stateFilter, {
  df_filtered <- df
  if (!is.null(input$stateFilter) && input$stateFilter != ALL_FILTER_NAME){
    df_filtered <- df_filtered %>% filter(State == input$stateFilter)
  }
  updateSelectInput(session, "cityFilter", label = "City:", choices = append(ALL_FILTER_NAME, unique(df_filtered$City)))
}, ignoreInit = TRUE)

# Update metrics when selecting infection
observeEvent(input$infectionFilter, {
  df_filtered <- df
  if (!is.null(input$infectionFilter)){
    df_filtered <- df_filtered %>% filter(Infection == input$infectionFilter)
  }
  updateSelectInput(session, "metricFilter", label = "Metric:", choices = unique(df_filtered$Metric))
}, ignoreInit = TRUE)

# reset plot
observeEvent(c(input$stateFilter, input$cityFilter, input$infectionFilter, input$metricFilter, input$maxResults), {
  userSel$show_data   <- FALSE
})

# plot
observeEvent(input$plotButton, {
  userSel$state       <- input$stateFilter
  userSel$city        <- input$cityFilter
  userSel$infection   <- input$infectionFilter
  userSel$metric      <- input$metricFilter
  userSel$max_results <- input$maxResults
  userSel$show_data   <- TRUE
  
  if (is.null(input$isReadmeCollapsed) || !(input$isReadmeCollapsed)) {
    js$collapse("readmeBox")
  }
  
})