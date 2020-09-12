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
  qc<-fread(qc_table$datapath, header=TRUE, sep = "\t")
})
  

#genome_territory <- reactive ({
#  qc_table<-input$qc
#  genome_territory<- as.numeric(scan(qc_table$datapath, nlines = 1))
#})

#gsheet <- reactive ({
#  csv<-input$glink
#  gsheet<-fread(csv, header=TRUE, na.strings=c("NA","N/A","null", "","-"))
#})
#
#
## Mark categorical variables
#output$categories <- renderUI({
#  names<-colnames(gsheet())[-1]
#  checkboxGroupInput(inputId = "cat", label="Mark the variables which are categorical, e.g. cell type or amplification kit", names)
#})


## Change categorical variables to class character
#gsheet_mod <- reactive ({
#  gsheet<-gsheet() 
#  not_selecte_cols<-subset(colnames(gsheet),!(colnames(gsheet) %in% input$cat)) # select columns that are not forcely categorical
#  gsheet<- gsheet[, lapply(.SD, as.character), by=not_selecte_cols] # change all the columns (.SD) which are not in by to character 
#})


## Select column in gdrive to use for grouping samples (to simplify plots)
#output$group <- renderUI({
#  if (is.null(input$cat)) {
#    names<-colnames(gsheet())[-1]
#    radioButtons(inputId = "group_sel", choices = names, label="Categorical variable to display")
#  } else {
#    radioButtons(inputId = "group_sel", choices = input$cat, label="Categorical variable to display")
#  }
#})

#preseq <- reactive ({
#  inFile<-input$ps
#  PreSeq<-fread(inFile$datapath, header=TRUE, sep="\t")
#  colnames(PreSeq)[2] <- "SequencingCoverage"
#  colnames(PreSeq)[4]<- "minconf"
#  colnames(PreSeq)[5]<- "maxconf"
  
#  SequencingCoverage<-PreSeq$SequencingCoverage/genome_territory()
#  ExpectedCoveredBases<-PreSeq$ExpectedCoveredBases/genome_territory()
#  minconf<-PreSeq$minconf/genome_territory()
#  maxconf<-PreSeq$maxconf/genome_territory()
#  PreSeq<-cbind.data.frame(PreSeq[,1],SequencingCoverage,ExpectedCoveredBases, minconf, maxconf)
  
#})


#fastqc <- reactive ({
#  inFile<-input$fastqc
#  fastqc<-fread(inFile$datapath, header=FALSE, skip=1, sep="\t", fill = TRUE, stringsAsFactors = FALSE)
#})  

#adapt <- reactive({
#  inFile<-input$fastqc
#  adapt<-fastqc()[which(fastqc()$V2 == "ADAPT"),]
#  names<-unlist(as.vector(strsplit(readLines(inFile$datapath, n = 1),split="\t")))
#  colnames(adapt)<-names
#  adapt
#})

   
## Display slider input in results to select sequencing depth
#output$seqcov <- renderUI({
#  maxseqcov<-round(max(preseq()$SequencingCoverage))
#  "ui1" = sliderInput("seqcov", "Display Preseq breadth estimates for the following sequencing coverage in the table below:",0,maxseqcov,5)
#})

qc_extra  <- reactive ({
  #preseq1<-preseq()
  #lowernum<- input$seqcov - 0.00001
  #higherfiveX<-preseq1$SequencingCoverage[which(preseq1$SequencingCoverage > lowernum)]
  #uppernum<-higherfiveX[2]
  #SequencingCoverage<-preseq1[which(preseq1$SequencingCoverage > lowernum & preseq1$SequencingCoverage < uppernum),c(1,4,3,5)]
  #SequencingCoverage$ExpectedCoveredBases<-round(SequencingCoverage$ExpectedCoveredBases*100,4)
  #SequencingCoverage$minconf<-round(SequencingCoverage$minconf*100,4)
  #SequencingCoverage$maxconf<-round(SequencingCoverage$maxconf*100,4)
  #colnames(SequencingCoverage)[3]<- paste("Preseq breadth mean estimate at",input$seqcov,"X",sep=" ")
  #colnames(SequencingCoverage)[2]<- paste("Preseq breadth estimate lower limit of 95% CI ",input$seqcov,"X",sep=" ")
  #colnames(SequencingCoverage)[4]<- paste("Preseq breadth estimate upper limit of 95% CI at",input$seqcov,"X",sep=" ")
  #qc_extra<-merge.data.frame(gsheet_mod(),qc(),by = "Sample")
  #qc_extra<-merge.data.frame(qc_extra,SequencingCoverage,by = "Sample")
  qc_extra <- qc()
  })


## Display multiple choice to select variable to plot
#output$headerVars <- renderUI({
#  header_variables <-colnames(qc_extra())[-1]
#  "ui2" = selectInput(inputId ="headerVars", label="Select a variable to plot", choices=header_variables)
#})


## Display multiple choice to select variable to associate with
#output$varassoc <- renderUI({
#  available_variables <-colnames(qc_extra())[-1]
#  available_variables <- subset(available_variables,!(available_variables %in% input$headerVars))
#  "ui3" = selectInput(inputId ="varassoc", label="Select a variable to display association with", choices= available_variables)
#})

#adapter <- reactive ({
#      inFile<-input$ad
#      adapt<-fread(inFile$datapath, header=TRUE, sep="\t", check.names = FALSE)
#      # There is only one value for every two consecutive bases in a read after the 10th position. 
#      # In order to represent it, we selected the mean of the two bases (10-11 -> 10.5)
#      adapt$`Read Position`<-gsub("-.*", ".5",adapt$`Read Position`)
#      adapt_melted<-melt(adapt, id.vars = c("Sample", "Read Position"))
#})



#output$overrepr <- renderPlot({
#  overrepr<-fastqc()[which(fastqc()$V2 == "OVERREPR"),c(1:6)]
#  colnames(overrepr) <- c("Sample","plot","Sequence", "times", "Percentage", "Hit")
#  SampleNames<-qc_extra()$Sample[input$stats_rows_selected]
#  overrepr<-subset(overrepr, Sample %in% SampleNames)
#  p<-ggplot(data=overrepr) +
#    geom_bar(aes(x=Sample,y=Percentage, fill=Sequence),stat="identity") +
#    theme(legend.position = "none", axis.text.x = element_text(angle = 90)) +
#    labs(x="")
#  p
#})


#output$adapt <- renderPlot({
#  SampleNames<-qc_extra()$Sample[input$stats_rows_selected]
#  adapt<-subset(adapt(), Sample %in% SampleNames)
#  adapt<-melt.data.table(adapt, id.vars=c("Sample", "ADAPT", "Read Position"))
#  p<-ggplot(data=adapt) +
#    geom_bar(aes(x=Sample,y=as.numeric(value), fill=variable),stat="identity", position="dodge") +
#    theme(axis.text.x = element_text(angle = 90)) +
#    labs(x="", y="Percentage", fill="Adapter") +
#    ylim(0,100)
#  p
#})


#output$kmers <- renderPlot({
#  kmers<-fastqc()[which(fastqc()$V2 == "KMER"),c(1:7)]
#  colnames(kmers) <- c("Sample", "plot", "kmer", "count", "pvalue", "Position", "Obs.Exp")
#  SampleNames<-qc_extra()$Sample[input$stats_rows_selected]
#  kmers<-subset(kmers, Sample %in% SampleNames)
#  #kmers$positions<-kmers$V7
#  #kmers$observations<-kmers$V6
#  p<-ggplot(kmers) +
#    geom_point(aes(as.numeric(Position), as.numeric(Obs.Exp),color=Sample)) +
#    theme(legend.position = "none") +
#    labs(x="Read position", y=expression('log'[2]*frac('obs','exp')))
#  p
#})


#lc_table <- reactive ({
#  inFile<-input$lc
#  lc<-fread(inFile$datapath, header=TRUE)
#})


# Create data.table
dt<-reactive({
  dt<-DT::datatable(
    #qc_extra(),
    qc(),
    rownames = FALSE,
    filter = list(position = 'top', clear = FALSE),
    options = list(
      paging=FALSE)
    ) #close datatable
  
      dt %>% formatStyle('Sample', color = "red", fontWeight = "bold" ) 
      #%>% formatStyle('Sequencing depth used in Preseq inferences', color = styleInterval(cuts=0.09999, values=c("mediumaquamarine", "black")))
})


# Create an interactive table with QC stats and extra info
output$stats <- DT::renderDataTable({
  dt()
})



row_index <- reactive ({
  row_index <- input$stats_rows_selected
})

col_index <- reactive ({
  header_variables <-colnames(qc_extra())
  column_index<-which(header_variables==input$headerVars)
})


assoc_index <- reactive ({
  header_variables <-colnames(qc_extra())
  assoc_index<-which(header_variables==input$varassoc)
})


# Plot variables from Stats
output$variables <- renderPlot({
  column_index <- col_index()
  row_index <- row_index()
    if (column_index == which(colnames(qc_extra()) == "Potential bacterial contamination")){
      qc_extra_mod<-qc_extra()
      empty<-which(qc_extra_mod[,column_index] == "")
      qc_extra_mod[empty,column_index] <- " None contamination detected"
      #Split by , to create a list of lists
      splitted_column <- strsplit(qc_extra_mod[,column_index], ",", fixed=TRUE)
      #count number of elements in each list and create a vector with the results
      n <- sapply(splitted_column, length)
      #repeat the correspondent sample name as many times as number of elements per sample
      id <- rep(qc_extra_mod$Sample, times = n)
      #Convert list of lists into a vector
      splitted_column_vector <- unlist(splitted_column)
      #Combine into a data frame
      bactery <- data.frame(Sample = id, Bacteries = splitted_column_vector)
      custom_color<-rep.int("lightgrey", length(bactery$Sample))
      custom_bold<-rep.int("plain", length(qc_extra_mod$Sample))
      SampleNames<-qc_extra_mod$Sample[row_index]
      selected<-which(bactery$Sample %in% SampleNames)
      custom_color[selected] <- "mediumaquamarine"
      custom_bold[row_index] <- "bold"
      lala=as.numeric(nrow(qc_extra())*10)
      p<-ggplot(bactery) +
        geom_point(aes(x = Sample, y = Bacteries),color=custom_color, fill=custom_color) +
        labs(x="Sample", y=as.name(names(qc_extra_mod[column_index]))) +
        theme(axis.text.x = element_text(face=custom_bold ,angle = 90))
      p
      } else if (column_index == 1) {
        list()
      } else if (is.character(qc_extra()[,column_index]) || colnames(qc_extra())[column_index] %in% input$cat) {
        qc_extra_char<- qc_extra()
        #qc_extra_char[,column_index]<-as.character(qc_extra_char[,column_index])
        #qc_extra_char[is.na(qc_extra_char[,column_index]),column_index] <- ""
        #empty<-which(qc_extra_char[,column_index] == "")
        #qc_extra_char[empty,column_index] <- " Not determined"
        color_bar<-rep("grey", times=nrow(qc_extra_char))
        color_bar[row_index] <- "mediumaquamarine"
        lala=300
        p<-ggplot(qc_extra_char) +
          geom_bar(aes_q(x=as.name(names(qc_extra_char)[column_index]), fill=color_bar)) +
          scale_fill_manual(values = c("lightgrey", "mediumaquamarine")) +
          theme(legend.position = "none",axis.text.x = element_text(angle = 90))
        p
      } else if (is.numeric(qc_extra()[,column_index])) {
        samples_selected<-qc_extra()[,1][row_index]
        qc_extra_hist<-qc_extra()
        qc_extra_hist<-qc_extra_hist[!is.na(qc_extra_hist[,column_index]),]
        qc_extra_hist <- qc_extra_hist[order(qc_extra_hist[,column_index]),] 
        selected<-which(qc_extra_hist[,1] %in% samples_selected)
        custom_color<-rep.int("lightgrey", length(qc_extra_hist$Sample))
        custom_color[selected] <- "mediumaquamarine"
        p<-ggplot(qc_extra_hist) +
          geom_bar(aes_q(x = substitute(reorder(x,n), list(x=as.name("Sample"),n=as.name(names(qc_extra_hist)[column_index]))), y = as.name(names(qc_extra_hist)[column_index])), stat="identity", fill=custom_color) +
          labs(x="Sample", y=as.name(names(qc_extra_hist)[column_index])) +
          theme(axis.text.x = element_text(angle = 90))
        subplot<-ggplot(qc_extra_hist) +
          geom_bar(aes_q(x = substitute(reorder(x,n), list(x=as.name("Sample"),n=as.name(names(qc_extra_hist)[column_index]))), y = as.name(names(qc_extra_hist)[column_index])), stat="identity", fill=custom_color, color=custom_color) +
          labs(x="Sample", y=as.name(names(qc_extra_hist)[column_index])) +
          theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title.y = element_blank(), axis.title.x = element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
          scale_y_continuous(position = c("left"))
        vp <- viewport(width = 0.05, height = 0.3, x = 0.995, y = 0.43, just = c("right",
                                                        "bottom"))

        full <- function() {
          print(p)
          print(subplot, vp = vp)
        }
        full()
      } else {
        list()
      }
}, height=400, width=reactive(
    if (col_index() == which(colnames(qc_extra()) == "Potential bacterial contamination")) {
      as.numeric(nrow(qc_extra())*10 + 800)
      }
    else if (is.character(qc_extra()[,col_index()]) | colnames(qc_extra())[col_index()] %in% input$cat) {
      as.numeric(length(levels(qc_extra()[,col_index()]))*20 + 200)
    }
    else {
      as.numeric(nrow(qc_extra())*10 + 800)
    }
  ))


# text: output total and selected rows  
output$mean<- renderPrint({
  row_index = row_index()
  column_index <- col_index()
  if (is.character(qc_extra()[,column_index]) | colnames(qc_extra())[column_index] %in% input$cat) {
    cat("")
  }
  else if (is.numeric(qc_extra()[,column_index])) {
    mycolumn<-qc_extra()[,column_index]
    cat(names(qc_extra())[column_index], "\n\n", sep="")
    cat("Total rows:",round(mean(mycolumn, na.rm=TRUE),2),'+/-',round(sd(mycolumn, na.rm=TRUE),2),'\n', sep=" ")
    #if (column_index != which(colnames(qc_extra()) == "Potential bacterial contamination") | column_index !=  which(colnames(qc_extra()) == input$group_sel)) {
    if (is.null(row_index) | length(row_index) == 0) {
      cat("None row selected")
    } else {
      mycolumn_rows<-qc_extra()[row_index,column_index]
      cat(length(row_index),"rows selected:",round(mean(mycolumn_rows, na.rm=TRUE),2),'+/-',round(sd(mycolumn_rows, na.rm=TRUE),2),'\n', sep=" ")
    }
  }
  else {
    cat("")
  }
})


# Variable association
output$boxplot <- renderPlot({
  column_index <- col_index()
  row_index <- row_index()
  assoc_index <- assoc_index()
  if (is.character(qc_extra()[,column_index])) {
    if (assoc_index == which(colnames(qc_extra()) == "Potential bacterial contamination")){
      list()
    } else if (is.character(qc_extra()[,assoc_index])) {
      qc_extra_char<- qc_extra()
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
    } else if (is.numeric(qc_extra()[,assoc_index])) {
      qc_extra_char<- qc_extra()
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
  } else if (is.numeric(qc_extra()[,column_index])) {
    if (assoc_index == which(colnames(qc_extra()) == "Potential bacterial contamination")){
      list()
    } else if (is.character(qc_extra()[,assoc_index])) {
      qc_extra_char<- qc_extra()
      color_bar<-rep("grey", times=nrow(qc_extra_char))
      color_bar[row_index] <- "mediumaquamarine"
      lala=300
      p<-ggplot(qc_extra_char) +
        geom_boxplot(aes_q(x=as.name(names(qc_extra_char)[assoc_index]), y=as.name(names(qc_extra_char)[column_index]))) +
        geom_jitter(aes_q(x=as.name(names(qc_extra_char)[assoc_index]), y=as.name(names(qc_extra_char)[column_index]), color=color_bar)) +
        scale_color_manual(values = c("lightgrey", "mediumaquamarine")) +
        theme(legend.position = "none",axis.text.x = element_text(angle = 90))
      p
    } else if (is.numeric(qc_extra()[,assoc_index])) {
      samples_selected<-qc_extra()[,1][row_index]
      qc_extra_hist<-qc_extra()
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
  }, height=400, width=reactive(
    if (col_index() == which(colnames(qc_extra()) == "Potential bacterial contamination")) {
      0
    }
    else if (is.character(qc_extra()[,col_index()]) | colnames(qc_extra())[col_index()] %in% input$cat) {
      as.numeric(length(levels(qc_extra()[,col_index()]))*20 + 200)
    }
    else {
      #as.numeric(nrow(qc_extra())*10 + 800)
      1000
    }
  ))
  

# text: statistical test for variable association
output$stat_test<- renderPrint({
  column_index <- col_index()
  row_index <- row_index()
  assoc_index <- assoc_index()
  if (is.character(qc_extra()[,column_index])) {
    if (assoc_index == which(colnames(qc_extra()) == "Potential bacterial contamination")){
      cat("")
    } else if (is.character(qc_extra()[,assoc_index])) {
      cat("char-char")
    } else if (is.numeric(qc_extra()[,assoc_index])) {
      cat("Num-char\n")
      qc_extra_char<- qc_extra()
      y=qc_extra_char[,assoc_index]
      x=qc_extra_char[,column_index]
      data_anova <- cbind.data.frame(x,y)
      data_anova.mod1 <- lm(y ~ x, data=data_anova)
      print(anova(data_anova.mod1))
      #cat(anova(data_anova.mod1))
    }
  } else if (is.numeric(qc_extra()[,column_index])) {
    if (assoc_index == which(colnames(qc_extra()) == "Potential bacterial contamination")){
      cat("test")
    } else if (is.character(qc_extra()[,assoc_index])) {
      qc_extra_char<- qc_extra()
      x=qc_extra_char[,assoc_index]
      y=qc_extra_char[,column_index]
      data_anova <- cbind.data.frame(x,y)
      print(head(data_anova))
      data_anova.mod1 <- lm(y ~ x, data=data_anova)
      print(anova(data_anova.mod1))
      cat(anova(data_anova.mod1))
    } else if (is.numeric(qc_extra()[,assoc_index])) {
      cat ("Pearson correlation:\n")
      qc_extra_char<- qc_extra()
      var_cor <-cor(x=qc_extra_char[,column_index], y=qc_extra_char[,assoc_index],method = "pearson")
      cat(var_cor)
    }
  } else {
    cat("test")
  }
})





   
#  # Plot adapter content within unmapped reads
#output$adapters <- renderPlot({
#    #SampleNames<-qc_extra()$Sample[input$stats_rows_selected]
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
  SampleNames<-qc_extra()$Sample[row_index()]
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

  # Plot Lorenz curves
  
#  output$lcurves <- renderPlot({
#    SampleNames<-qc_extra()$Sample[input$stats_rows_selected]
#    lc1<-subset(lc_table(), Sample %in% SampleNames)
#    lc1$xt<-rep(seq(1, nrow(lc1)/length(SampleNames)), length(SampleNames))
#    lc1$x<-lc1$xt/((nrow(lc1)-1)/length(SampleNames))
#    ggplot(lc1) +
#      geom_line(aes(x=x, y=Cum, color=Sample)) +
#      labs(x="Proportion of genome covered (cumulative)",y="Fraction of total reads")
#  })
  
  # Plot Lorenz curves by window
  
  output$lcurves <- renderPlot({
    SampleNames<-qc_extra()$Sample[row_index()]
    lc1<-subset(lc_table(), Sample %in% SampleNames)
    #lc1$xt<-rep(seq(1, nrow(lc1)/length(SampleNames)), length(SampleNames))
    #lc1$x<-lc1$xt/((nrow(lc1)-1)/length(SampleNames))
    ggplot(lc1) +
      geom_line(aes(x=Positions, y=Cum, color=Sample)) +
      labs(x="Proportion of genome covered (cumulative)",y="Fraction of total reads")
  })
  
  
  # Plot summary plot for the groups
  output$lcurves_groups <-renderPlot({
    row_index <- row_index()
    #row_index <- input$stats_rows_selected
    samples_selected<-qc_extra()$Sample[row_index]
    group_selected<-input$group_sel
    groups<-qc_extra()[row_index,which(colnames(qc_extra()) == group_selected)]
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
      write.table(qc_extra(), file, sep = '\t',
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




