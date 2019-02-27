## Supporting functions


create_bar_chart <- function(df, userSel, plot_colors, margins) {
  plot_ly(df, x = ~Score, y = ~Hospital.Name, 
          type = "bar", color = ~Compared.to.National, colors = plot_colors, 
          hoverinfo = 'text', text = ~paste('State: ', State, 
                                            '<br> City: ', City,
                                            '<br> Score: ', Score)) %>%
    layout(title = paste("Metric value per hospital:", userSel$infection, userSel$metric), xaxis = list(title = "Value"), yaxis = list(title = ""), margin = margins) %>%
    config(displayModeBar = F) 
}