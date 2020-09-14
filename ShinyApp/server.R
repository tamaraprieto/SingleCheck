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
  qc<-fread(qc_table$datapath, header=TRUE, sep = "\t") %>% dplyr::select(-`Bin size`, -Delta)
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
dt<-reactive({
  dt<-DT::datatable(
    #qc(),
    qc() ,
    rownames = FALSE,
    filter = list(position = 'top', clear = FALSE),
    options = list(
      paging=FALSE)
    ) #close datatable
  
      dt %>% formatStyle('Sample', color = "mediumaquamarine", fontWeight = "bold" ) %>%
        formatStyle('Original sequencing depth', color = styleInterval(cuts=0.09999, values=c("red", "black")))
})


# Create an interactive table with QC stats
output$stats <- DT::renderDataTable({
  dt()
})


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
        tidyr::unnest(`Potential contaminants`)
        
      p<-ggplot(qc_bacteria) +
        geom_point(aes(x = Sample, y = `Potential contaminants`)) +
        labs(x="Sample") +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 90))
      p
      
      } else if (col_index() == 1) {
        list()
      } else {
        qc_common <- qc() %>%
          dplyr::slice(row_index()) %>%
          dplyr::select(c(1,col_index())) %>%
          dplyr::rename(value=colnames(qc())[col_index()])
        p<-ggplot(qc_common) +
          geom_col(aes(x = Sample, y = value)) +
          labs(x="Sample", y=colnames(qc())[col_index()]) +
          theme_linedraw() +
          theme(axis.text.x = element_text(angle = 90)) 
        p 
        
      }
}
#, height=400, width=reactive(
#    if (col_index() == which(colnames(qc()) == "Potential contaminants")) {
#      as.numeric(nrow(qc())*10 + 800)
#      }
#    else if (is.character(qc()[,col_index()])) {
#      as.numeric(length(levels(qc()[,col_index()]))*20 + 200)
#    }
#    else {
#      as.numeric(nrow(qc())*10 + 800)
#    }
#  )

)


# Variable association
output$boxplot <- renderPlot({
  column_index <- col_index()
  row_index <- row_index()
  assoc_index <- assoc_index()
  if (is.character(qc()[,column_index])) {
    if (assoc_index == which(colnames(qc()) == "Potential bacterial contamination")){
      list()
    } else if (is.character(qc()[,assoc_index])) {
      qc_extra_char<- qc()
      #qc_extra_char[,column_index]<-as.character(qc_extra_char[,column_index])
      #qc_extra_char[is.na(qc_extra_char[,column_index]),column_index] <- ""
      #empty<-which(qc_extra_char[,column_index] == "")
      #qc_extra_char[empty,column_index] <- " Not determined"
      #color_bar<-rep("grey", times=nrow(qc_extra_char))
      #color_bar[row_index] <- "mediumaquamarine"
      lala=300
      p<-ggplot(qc_extra_char) +
        geom_bar(aes_q(x=as.name(names(qc_extra_char)[column_index]), fill=as.name(names(qc_extra_char)[assoc_index()]))) +
        scale_fill_manual(values = c("darksalmon","darkorchid4"), na.value = "lightgrey") +
        theme(axis.text.x = element_text(angle = 90))
      p           
    } else if (is.numeric(qc()[,assoc_index])) {
      qc_extra_char<- qc()
      #qc_extra_char[,column_index]<-as.character(qc_extra_char[,column_index])
      #qc_extra_char[is.na(qc_extra_char[,column_index]),column_index] <- ""
      #empty<-which(qc_extra_char[,column_index] == "")
      #qc_extra_char[empty,column_index] <- " Not determined"
      color_bar<-rep("grey", times=nrow(qc_extra_char))
      color_bar[row_index] <- "mediumaquamarine"
      lala=300
      p<-ggplot(data=subset(qc_extra_char, !is.na(colnames(qc_extra_char)[column_index]))) +
        geom_boxplot(aes_q(x=as.name(names(qc_extra_char)[column_index]), y=as.name(names(qc_extra_char)[assoc_index]))) +
        geom_jitter(aes_q(x=as.name(names(qc_extra_char)[column_index]), y=as.name(names(qc_extra_char)[assoc_index]))) +
        scale_color_manual(values = c("lightgrey", "mediumaquamarine")) +
        theme(legend.position = "none",axis.text.x = element_text(angle = 90))
      p
    }
  } else if (is.numeric(qc()[,column_index])) {
    if (assoc_index == which(colnames(qc()) == "Potential bacterial contamination")){
      list()
    } else if (is.character(qc()[,assoc_index])) {
      qc_extra_char<- qc()
      color_bar<-rep("grey", times=nrow(qc_extra_char))
      color_bar[row_index] <- "mediumaquamarine"
      lala=300
      p<-ggplot(qc_extra_char) +
        geom_boxplot(aes_q(x=as.name(names(qc_extra_char)[assoc_index]), y=as.name(names(qc_extra_char)[column_index]))) +
        geom_jitter(aes_q(x=as.name(names(qc_extra_char)[assoc_index]), y=as.name(names(qc_extra_char)[column_index]), color=color_bar)) +
        scale_color_manual(values = c("lightgrey", "mediumaquamarine")) +
        theme(legend.position = "none",axis.text.x = element_text(angle = 90))
      p
    } else if (is.numeric(qc()[,assoc_index])) {
      samples_selected<-qc()[,1][row_index]
      qc_extra_hist<-qc()
      selected<-which(qc_extra_hist[,1] %in% samples_selected)
      custom_color<-rep.int("lightgrey", length(qc_extra_hist$Sample))
      custom_color[selected] <- "mediumaquamarine"
      y1<-qc_extra_hist[,column_index]
      y2<-qc_extra_hist[,assoc_index()]
      multiplier<-max(y1, na.rm = TRUE)/max(y2, na.rm = TRUE)
      y1<-y1/multiplier
      x<- qc_extra_hist[,"Sample"]
      x_ordered<-names(qc_extra_hist)[column_index]
      corr_data<-cbind.data.frame(x,x_ordered,y1,y2)
      p<-ggplot(corr_data, aes(x = reorder(x,y1))) +
        geom_point(aes(y=y1, color=as.character(input$headerVars))) +
        theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
        ylab(input$varassoc)
      p <- p + geom_point(aes(y=y2, color=input$varassoc)) +
        scale_y_continuous(sec.axis = sec_axis(~.*multiplier, name = input$headerVars)) +
        scale_color_manual(values=c("darksalmon","darkorchid4")) +
        theme(legend.position = "none",axis.title.y = element_text(colour=c("darksalmon")), axis.title.y.right = element_text(colour=c("darkorchid4"))) +
        labs(x = "Sample", colour = "Variables") #+
      #annotate("rect", xmin = c(row_index - 0.5), xmax = c(row_index + 0.5) , ymin = c(min(y1)), ymax = c(max(y1)), alpha = .2)
      p      
    }
  } else {
    list()
  }
}
#  , height=400, width=reactive(
#    if (col_index() == which(colnames(qc()) == "Potential bacterial contamination")) {
#      0
#    }
#    else if (is.character(qc()[,col_index()]) | colnames(qc())[col_index()] %in% input$cat) {
#      as.numeric(length(levels(qc()[,col_index()]))*20 + 200)
#    }
#    else {
#      #as.numeric(nrow(qc())*10 + 800)
#      1000
#    }
#  )
) # close renderplot



# text: output total and selected rows  
output$mean<- renderPrint({
  row_index = row_index()
  column_index <- col_index()
  if (is.character(qc()[,column_index]) | colnames(qc())[column_index] %in% input$cat) {
    cat("")
  }
  else if (is.numeric(qc()[,column_index])) {
    mycolumn<-qc()[,column_index]
    cat(names(qc())[column_index], "\n\n", sep="")
    cat("Total rows:",round(mean(mycolumn, na.rm=TRUE),2),'+/-',round(sd(mycolumn, na.rm=TRUE),2),'\n', sep=" ")
    #if (column_index != which(colnames(qc()) == "Potential bacterial contamination") | column_index !=  which(colnames(qc()) == input$group_sel)) {
    if (is.null(row_index) | length(row_index) == 0) {
      cat("None row selected")
    } else {
      mycolumn_rows<-qc()[row_index,column_index]
      cat(length(row_index),"rows selected:",round(mean(mycolumn_rows, na.rm=TRUE),2),'+/-',round(sd(mycolumn_rows, na.rm=TRUE),2),'\n', sep=" ")
    }
  }
  else {
    cat("")
  }
})




# text: statistical test for variable association
output$stat_test<- renderPrint({
  if (is.character(qc()[,col_index()])) {
    if (assoc_index() == which(colnames(qc()) == "Potential contaminants")){
      cat("")
    } else if (is.character(qc()[,assoc_index()])) {
      cat("char-char")
    } else if (is.numeric(qc()[,assoc_index])) {
      cat("Num-char\n")
      qc_extra_char<- qc()
      y=qc_extra_char[,assoc_index()]
      x=qc_extra_char[,col_index()]
      data_anova <- cbind.data.frame(x,y)
      data_anova.mod1 <- lm(y ~ x, data=data_anova)
      print(anova(data_anova.mod1))
      #cat(anova(data_anova.mod1))
    }
  } else if (is.numeric(qc()[,col_index()])) {
    if (assoc_index() == which(colnames(qc()) == "Potential bacterial contamination")){
      cat("test")
    } else if (is.character(qc()[,assoc_index()])) {
      qc_extra_char<- qc()
      x=qc_extra_char[,assoc_index()]
      y=qc_extra_char[,col_index()]
      data_anova <- cbind.data.frame(x,y)
      print(head(data_anova))
      data_anova.mod1 <- lm(y ~ x, data=data_anova)
      print(anova(data_anova.mod1))
      cat(anova(data_anova.mod1))
    } else if (is.numeric(qc()[,assoc_index()])) {
      cat ("Pearson correlation:\n")
      qc_extra_char<- qc()
      var_cor <-cor(x=qc_extra_char[,col_index()], y=qc_extra_char[,assoc_index()],method = "pearson")
      cat(var_cor)
    }
  } else {
    cat("test")
  }
})





   
#  # Plot adapter content within unmapped reads
#output$adapters <- renderPlot({
#    #SampleNames<-qc()$Sample[input$stats_rows_selected]
#    #adapter_sub<-subset(adapter(), Sample %in% SampleNames)
#     adapter_sub<- adapter()
#    ggplot(adapter_sub) +
#      geom_line(aes(as.numeric(`Read Position`), value, color=Sample)) +
#      theme(legend.position="none") +
#      ylim(0,100) +
#      labs(x="Position in read (bp)", y="% of reads") +
#      facet_grid(.~variable, scale='free_x')
#})  


## TAB amplification bias
output$number_rows<- renderPrint({
  #if(is.null(input$number_rows))     return('None row selected\n\n')
  number_rows = input$stats_rows_selected
  if (length(number_rows)) {
    cat('Number of rows selected in QC:\n\n')
    cat(length(number_rows),sep=" ")
  }
})




  
# Create function to save as an image the Preseq plot
PreSeq <- function(){
  SampleNames<-qc()$Sample[row_index()]
  PreSeq1<-subset(preseq(), Sample %in% SampleNames)
  ggplot(PreSeq1) +
    geom_line(aes(SequencingCoverage, ExpectedCoveredBases*100, color=Sample, linetype=Sample)) +
    geom_ribbon(aes(x=SequencingCoverage,ymin=minconf*100, ymax=maxconf*100, fill=Sample), alpha=0.2) +
    scale_linetype_manual(values = c(rep(c("dotted","dashed"), length(row_index())))) +
    labs(x="Sequencing depth (X)", y="Inferred coverage breadth (%)") +
    theme(legend.text = element_text(size=5)) +
    xlim(0,20) +
    ylim(0,100)
}

# Plot PreSeq predictions
output$PreSeq <- renderPlot({
  PreSeq()
})


  # Plot Lorenz curves by window
  
#  output$lcurves <- renderPlot({
#    SampleNames<-qc()$Sample[row_index()]
#    lc1<-subset(lc_table(), Sample %in% SampleNames)
#    #lc1$xt<-rep(seq(1, nrow(lc1)/length(SampleNames)), length(SampleNames))
#    #lc1$x<-lc1$xt/((nrow(lc1)-1)/length(SampleNames))
#    ggplot(lc1) +
#      geom_line(aes(x=Positions, y=Cum, color=Sample)) +
#      labs(x="Proportion of genome covered (cumulative)",y="Fraction of total reads")
#  })
  
  
  # Plot summary plot for the groups
  output$lcurves_groups <-renderPlot({
    row_index <- row_index()
    #row_index <- input$stats_rows_selected
    samples_selected<-qc()$Sample[row_index]
    group_selected<-input$group_sel
    groups<-qc()[row_index,which(colnames(qc()) == group_selected)]
    lc_subset<-lc_table()[which(lc_table()$Sample %in% samples_selected),]
    number<-as.integer(nrow(lc_subset)/length(samples_selected))
    lc_subset$Positions<-lc_subset$Positions/number
    Group<-rep(groups, each=as.integer(as.character(number)))
    lc_subset <-cbind.data.frame(lc_subset[,c(-1,-3)],Group,lc_subset[,3])
    #lc_subset<-aggregate(. ~ Positions+Group, data = lc_subset, FUN = function(x) c(mean=mean(x), sd=sd(x)))
    # do.call(data.frame is necessary in order to write mean and sd as independent columns)
    # The commented line is the same as the main line but only for mean 
    #lc_subset<-aggregate(lc_subset, list(Position=lc_subset$Positions, Group=lc_subset$groups1), mean)
    lc_subset<-do.call(data.frame,aggregate(. ~ Positions+Group, data = lc_subset, FUN = function(x) c(sd=mean_se(x))))
    colnames(lc_subset) <- c("Position", "Group", "Cum", "Sd1","Sd2")
    p1<-ggplot(lc_subset, aes(Position)) +
      geom_ribbon(aes(x=Position , ymin=as.numeric(Sd1), ymax=as.numeric(Sd2), fill=Group), alpha=0.2) +
      geom_line(aes(x=Position, y=as.numeric(Cum), colour=Group)) +
      #geom_abline(intercept = 0.00, slope = 1.00) +
      labs(colour = as.character(input$group_sel), x="Proportion of genome covered (cumulative)",y="Fraction of total reads") +
      guides(fill = 'none')
    p1
  })

  

# Download summary table
output$downloadSummaryTable <- downloadHandler(
  # Create name for the file
    filename = function() {
      paste(gsub(".txt",".wgSCheck.tsv",input$qc), sep = ".")
    },
  # Write the output
    content = function(file) {
      # Write to a file specified by the 'file' argument
      write.table(qc(), file, sep = '\t',
                  row.names = FALSE, quote = FALSE)
})  
  

output$downloadPreSeq <- downloadHandler(
  filename = function() { paste(input$ps, '.png', sep='') },
  content = function(file) {
    device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
    ggsave(file, plot = PreSeq(), device = device)
  }
)

## Download ggplot figure
#output$downloadPreSeq <- downloadHandler(
#  # Create name for the file
#  filename = function() {
#    gsub(".txt",".png",input$ps)
#  },
#  # Write the output
#  content = function(file) {
#    # Write to a file specified by the 'file' argument
#    ggsave(PreSeq(), file)
#  })   
  
  
  
})




