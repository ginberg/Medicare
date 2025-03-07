# ----------------------------------------
# --          PROGRAM global.R          --
# ----------------------------------------
# USE: Global variables and functions
#
# NOTEs:
#   - All variables/functions here are
#     globally scoped and will be available
#     to server, UI and session scopes
# ----------------------------------------

suppressPackageStartupMessages(library(RSQLite))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(ggmap))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(zipcode))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(leaflet))
suppressPackageStartupMessages(library(DT))
suppressPackageStartupMessages(library(plotly))
source("program/fxn/supporting_data.R")

# -- Setup your Application --
set_app_parameters(title = "Medicare - Compare US Hospitals regarding infections",
                   titleinfo = NULL,
                   loglevel = "DEBUG",
                   showlog = FALSE)

# -- PROGRAM --

###Input Filter Options
ALL_FILTER_NAME <- "All"
stateChoices = c(ALL_FILTER_NAME, sort(unique(df$State)))
cityChoices = c(ALL_FILTER_NAME, sort(unique(df$City)))
zipcodeChoices = c(ALL_FILTER_NAME, sort(unique(df$ZIP.Code)))
hospitalChoices = c(ALL_FILTER_NAME, sort(unique(df$Hospital.Name)))
#measureNameChoices = factor(c(sort(unique(df$Measure.Name))))
infectionChoices = factor(c(sort(unique(df$Infection))))
metricChoices = factor(c(sort(unique(df$Metric))))

# Change types
df$Measure.Name <- as.factor(df$Measure.Name)
df$Measure = as.factor(df$Infection)
df$Metric = as.factor(df$Metric)
df$Score <- as.numeric(df$Score)

# Slider properties
SLIDER_MIN_VALUE <- 0
SLIDER_MAX_VALUE <- 100
SLIDER_INIT_VALUE <- 25

# Datatable properties
MAX_ITEMS_PER_PAGE <- SLIDER_INIT_VALUE
TABLE_PAGING <- TRUE
LENGTH_MENU <- c(5, 10, 15, 20, 25, 50, 75, 100)
FORMAT_COLUMN <- "Compared.to.National"
FORMAT_COLUMN_VALUE <- "Better than the National Benchmark"
FORMAT_COLUMN_VALUE_WARN <- "Worse than the National Benchmark"
FORMAT_COLUMN_VALUES <- unique(df$Compared.to.National)
FORMAT_COLUMN_COLOR <- "lightblue"
FORMAT_COLUMN_COLOR_WARN <- "salmon"

FORMAT_COLUMN_COLOR_AVERAGE = 'lightgrey'
FORMAT_COLUMN_COLOR_NOT_AVAILABLE = 'darkgrey'
FORMAT_CHART_COLOR_LIST = c(FORMAT_COLUMN_COLOR, FORMAT_COLUMN_COLOR_AVERAGE, FORMAT_COLUMN_COLOR_WARN, FORMAT_COLUMN_COLOR_NOT_AVAILABLE)

# Custom javascript
jscode <- "shinyjs.collapse = function(boxid) {
    $('#' + boxid).closest('.box').find('[data-widget=collapse]').click();}"

btnjs <- '$(function() {
                var $els = $("[data-proxy-click]");
                $.each(
                    $els,
                    function(idx, el) {
                        var $el = $(el);
                        var $proxy = $("#" + $el.data("proxyClick"));
                        $el.keydown(function (e) { if (e.keyCode == 13) { $proxy.click(); } });
                    });
            });'

collapsedInput <- function(inputId, boxId) {
  tags$script(
    sprintf("$('#%s').closest('.box').on('hidden.bs.collapse', function () {Shiny.onInputChange('%s', true);})", boxId, inputId),
    sprintf("$('#%s').closest('.box').on('shown.bs.collapse', function () {Shiny.onInputChange('%s', false);})", boxId, inputId)
  )
}
