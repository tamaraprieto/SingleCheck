library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(reshape2)
library(data.table)
library(htmltools)
library(grid)
library(shinycssloaders)
library(plotly)


shinyServer(function(input, output) {


qc <- reactive ({
  qc_table<-input$qc
  qc<-fread(qc_table$datapath, header=TRUE, sep = "\t") %>% 
    dplyr::select(-`Bin size`, -Delta, -MAD) %>%
    dplyr::rename(`Breadth (%)`= Breadth)
  qc$`Potential contaminants` <- gsub(",$","",gsub("-[^,]+","",gsub("[A-z]+-\\(class\\)\\{class\\}-[0-9|\\.]+-[0-9|\\.]+-[0-9|\\.]+,*" , "",qc$`Potential contaminants`)))
  qc
})



# Display multiple choice to select variable to plot
output$headerVars <- renderUI({
  header_variables <-colnames(qc())[-1]
  "ui2" = selectInput(inputId ="headerVars", label="Select a variable to plot", choices=header_variables)
})


# Display multiple choice to select variable to associate with
output$varassoc <- renderUI({
  available_variables <-colnames(qc())[-1]
  available_variables <- subset(available_variables,!(available_variables %in% input$headerVars))
  "ui3" = selectInput(inputId ="varassoc", label="Select a variable to display association with", choices= available_variables)
})



# Create data.table
dt <- reactive({
  qc_mod <- qc()
  dt<-DT::datatable(
    qc_mod,
    rownames = FALSE,
    filter = list(position = 'top', clear = FALSE),
    options = list(
      paging=FALSE)
    ) #close datatable
  
      dt %>% 
        formatStyle('Sample', color = "mediumaquamarine", fontWeight = "bold" ) %>%
        formatStyle('Analysis depth', color = styleInterval(cuts=0.10001, values=c("black", "red")))
})


# Create an interactive table with QC stats
output$stats <- DT::renderDataTable(
  dt(), server = TRUE, escape = FALSE, filter='top', selection = 'none'
)


# Set value of rows selected. Select column to display using multiple choice.
row_index <- reactive({
  row_index<- input$stats_rows_selected 
  # select of rows for the plot if none selected
  if (length(row_index) == 0){
    row_index <- 1:nrow(qc())
  }
  row_index
})
col_index <- reactive ({
  header_variables <-colnames(qc())
  col_index <- which(header_variables==input$headerVars)
})


assoc_index <- reactive ({
  header_variables <-colnames(qc())
  assoc_index<-which(header_variables==input$varassoc)
})


# Plot variables from Stats
output$variables <- renderPlot({
    if (col_index() == (which(colnames(qc()) == "Potential contaminants"))) {
      
      qc_bacteria <- qc() %>%
        dplyr::slice(row_index()) %>%
        dplyr::select(c(1,col_index())) %>%
        transform(`Potential contaminants` = strsplit(`Potential contaminants`, ",")) %>%
        tidyr::unnest(`Potential contaminants`) %>%
        tidyr::separate(`Potential contaminants`,into=c("Genus","Abundancy","CovergaeDepthGenomes","Reads","Similarity"),sep="-") %>%
        dplyr::mutate( Abundancy = as.numeric(Abundancy)) %>%
        dplyr::mutate( Similarity = as.numeric(Similarity)) %>%
        tidyr::drop_na(Abundancy)
        
      p<-ggplot(qc_bacteria) +
        geom_point(aes(x = Sample, y = Genus, size= Abundancy, color=Similarity)) +
        labs(x="Sample",y="Potential contaminants",size="Relative abundancy  \n(calculated from unmapped reads\nwithin the orginal BAM file)", color="Similarity with\ngene markers") +
        theme_linedraw() +
        scale_color_gradient2(low="red", mid="yellow", high="forestgreen", midpoint=95) + # , limits=c(90,100)) +
        theme(axis.text.x = element_text(angle = 90),
              legend.position = "bottom")
      p
      
      } else if (col_index() == 1) {
        list()
      } else {
        qc_common <- qc() %>%
          dplyr::slice(row_index()) %>%
          dplyr::select(c(1,col_index())) %>%
          dplyr::rename(value=colnames(qc())[col_index()])
        p<-ggplot(qc_common,aes(x = Sample, y = value)) +
          geom_point() +
          geom_line() +
          labs(x="Sample", y=colnames(qc())[col_index()]) +
          scale_y_continuous(trans = 'log10') +
          theme_linedraw() +
          theme(axis.text.x = element_text(angle = 90)) 
        p 
        
      }
}
)


# Download summary table
output$downloadSummaryTable <- downloadHandler(
  # Create name for the file
    filename = function() {
      paste(gsub(".txt",".AppResults.tsv",input$qc), sep = ".")
    },
  # Write the output
    content = function(file) {
      # Write to a file specified by the 'file' argument
      write.table(qc()[row_index(),], file, sep = '\t',
                  row.names = FALSE, quote = FALSE)
})  
  
  
  
})




