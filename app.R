options(encoding = 'UTF-8')
options(shiny.maxRequestSize=200*1024^2)
# name
projectName = "ocr"
# library
library(shiny)
library(shinydashboard)
library(DT)
library(readxl)
library(writexl)
library(stringr)

# source
source(file = "baiduAI.R")
source(file = "ocrUIS.R")
source(file = "feeUIS.R")
# body
sidebar <- dashboardSidebar(sidebarMenu(
  menuItem("增值税发票识别", tabName = "ocr"),
  menuItem("完税凭证识别", tabName = "fee")
  ))
body <- dashboardBody(tags$head(tags$style("section.content { overflow-y: hidden; }")),
                      tabItems(oUI(),feeUI()))
# Define server 
server <- function(input, output,session) {
  oServer()
  feeServer()
  }
# Define UI 
ui <- dashboardPage(dashboardHeader(title = projectName),sidebar,body)
# Run the application 
shinyApp(ui = ui, server = server)



