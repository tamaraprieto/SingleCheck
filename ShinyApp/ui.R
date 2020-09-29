library(shiny)
library(shinydashboard)
library(shinycssloaders)
#library(markdown)

options(shiny.maxRequestSize = 2000*1024^2)

dashboardPage(skin = "black", 
  dashboardHeader(title = "SingleCheck"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Documentation", tabName = "welcome", icon = icon("github")),
      menuItem("Input", tabName = "input", icon = icon("sliders")),
      menuItem("Results", tabName = "results", icon = icon("pie-chart"))
    ) # close sidebarmenu
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      tabItem(tabName= "welcome",   
              fluidRow(
                column(12, offset=0,
                includeMarkdown("../README.md"),
                h2("More information"),
                p("Click ",tags$a(href="https://github.com/tamaraprieto/SingleCheck", "here"), "to access to the github repository", icon = icon("github"))
                ) # close column
            ) # close fluidrow
    ), # close tabItem input
    tabItem(tabName= "input",   
            fluidRow(
              column(12, offset=0,
              box(title = "Load the main file", color = "teal", solidHeader = TRUE,
                  # FileQC
                  fileInput("qc","Quality stats",placeholder="Please upload SingleCheck.txt")
                  ) # close box
              ) # close column
            ) # close fluidrow
    ), # close tabItem welcome
      tabItem(tabName= "results",          
        fluidRow(
          tabBox(width = "100%",
             tabPanel("Summarizing table",
                      uiOutput("seqcov"),
                      div(style = 'overflow-x: scroll',withSpinner(DT::dataTableOutput("stats"))), 
                      downloadButton( outputId='downloadSummaryTable', label = 'Download')
                      ),
             tabPanel("Explore your data",
                      uiOutput("headerVars"), 
                      div(style = 'overflow-x: scroll',withSpinner(plotlyOutput("plotlyvariables")))#,
                      #div(style = 'overflow-x: scroll',withSpinner(plotOutput("variables")))
                      )
            ) # close tabsetPanel
           #)# close mainPanel
          #) # close column
        ) # close fluidrow
        
      ) # close tabItem results
    ) # close tabItems
  ) # close dashboard body    
) # close dashboard page