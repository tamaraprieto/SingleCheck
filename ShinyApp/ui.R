library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(markdown)

options(shiny.maxRequestSize = 2000*1024^2)

dashboardPage(skin = "black", 
  dashboardHeader(title = "SingleCheck"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Welcome", tabName = "welcome", icon = icon("smile-o")),
      menuItem("Input and parameters", tabName = "input", icon = icon("sliders")),
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
                    includeMarkdown("../README.md")#,
                #    ) # close box
                ) # close column
              ) # close fluidrow
      ), # close tabItem welcome
      tabItem(tabName= "input",   
              fluidRow(
                column(12, offset=0,
                ##h6("Introduce the values, press Apply Changes and then inspect the results by surfing the tabs"),
                #box(title = "Introduce google sheet information", color = "olive", solidHeader = TRUE,
                ## Gsheet link
                ##textInput("glink","Published gsheet link","https://docs.google.com/spreadsheets/d/e/2PACX-1vRE2ZaaSPFflGoXEHh_6d0ODd6s7JMwxYaIySGZ_TQrQJ1bJ2XlGDsxOEKyoCKPxOXqhx0J5cfc1LNr/pub?gid=1267448226&single=true&output=csv"),
                #textInput("glink","Published gsheet link","https://docs.google.com/spreadsheets/d/e/2PACX-1vRE2ZaaSPFflGoXEHh_6d0ODd6s7JMwxYaIySGZ_TQrQJ1bJ2XlGDsxOEKyoCKPxOXqhx0J5cfc1LNr/pub?gid=106591121&single=true&output=csv"),
                ## select categories
                #uiOutput("categories"),
                ## select group
                #uiOutput("group")
                #), # close box
                box(title = "Load the main file", color = "teal", solidHeader = TRUE,
                # FileQC
                fileInput("qc","Quality stats",placeholder="Please upload SingleCheck.txt")
                ## FilePreSeq
                #fileInput("ps","PreSeq output"),
                #fileInput("fastqc","Adapter content",
                #  accept = c("text/tsv","text/tab-separated-values,text/plain",".txt")),
                #fileInput("lc","Lorenz curves")
                  ) # close box
                ) # close column
            ) # close fluidrow
    ), # close tabItem input

      tabItem(tabName= "results",          
        fluidRow(
          tabBox(width = "100%",
             tabPanel("Summarizing table",
                      uiOutput("seqcov"),
                      div(style = 'overflow-x: scroll',withSpinner(DT::dataTableOutput("stats")))),
                      downloadButton('downloadSummaryTable', 'Download'),
                      #withSpinner(DT::dataTableOutput("stats"))),
             tabPanel("Explore your data",  h2("Variable description"), uiOutput("headerVars"), div(style = 'overflow-x: scroll',withSpinner(plotOutput("variables"))) #,
                      #verbatimTextOutput("mean"), br(),h2("Variable association"), uiOutput("varassoc"), withSpinner(plotOutput("boxplot")), verbatimTextOutput("stat_test")
                      )
             #,
             #tabPanel("Coverage uniformity", 
             #         h2("Preseq gc_extrap breadth of coverage inferences at different sequencing coverages (Daley & Smith, 2014)"),
             #         downloadButton('downloadPreSeq', 'Download'),
             #         plotOutput("PreSeq"), h2("Lorenz curves"), plotOutput("lcurves"),verbatimTextOutput("number_rows")),
             #tabPanel("Allelic imbalance"),
             #tabPanel("Summary plots", plotOutput("lcurves_groups"), plotOutput("all"))
            ) # close tabsetPanel
           #)# close mainPanel
          #) # close column
        ) # close fluidrow
        
      ) # close tabItem results


    ) # close tabItems
  ) # close dashboard body    
) # close dashboard page