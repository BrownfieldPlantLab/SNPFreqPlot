
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# Murray Cadzow
# University of Otago
# November 2016
#

library(shiny)
library(ggplot2)
library(dplyr)
options(shiny.maxRequestSize = 40 * 1024 ^2) # 40 Mb file limit
shinyServer(function(input, output) {
  output$fn <-renderText({if(!is.null(input$file)){paste("You have selected:",input$file[1])}})
  
  myData <- reactive({
    if(is.null(input$file)) return(NULL)
    
    inFile <- input$file
    vcf <- read.table(inFile$datapath, sep = '\t', header = FALSE)
    return(vcf)
  })
  
  gt_mat <- reactive({
    vcf<-myData()
    if(is.null(vcf)) return(NULL)
    gtcols <- 10:ncol(vcf)
    
    gt <- apply(vcf[,gtcols],1, function(x){
      y <- unlist(sapply(x, function(x){strsplit(x, ':')[[1]][1]}))
      return(y)
    } 
    )
    
    l <-levels(as.factor(gt))
    names(l) <- l
    l[grep('./.',l)] <- NA
    wt <- which(l == '0|0')
    l[!is.na(l)] <- 1 #0:(length(l[!is.na(l)])-1)
    l[wt] <- 0
    
    
    gt2 <- apply(gt, 1, function(x){
      for(n in names(l)){
        cols <- which(x == n)
        x[cols]<- l[which(names(l) == n)]
      }
      return(x)
    })
    gt2 <- apply(gt2,1,as.numeric)
    return(gt2)
  })
  
  create_freq <- reactive({
    gt_mat <- gt_mat()
    vcf <- myData()
    if(is.null(gt_mat) | is.null(vcf)) return(NULL)
    
    posSum <- apply(gt_mat, 2, function(x){sum(x, na.rm=TRUE)}) # sum rows
    freq <- posSum/ncol(gt_mat) *100
    
    if(input$strand == '-'){
      pos <- as.numeric(vcf$V2) * -1 
    } else {
      pos <- as.numeric(vcf$V2)
    }
    return(data.frame(freq = freq, pos = pos))
  })
 
  create_plot <- reactive({
    df <- create_freq()
    if(is.null(df)) return(NULL)
    p <- ggplot(df, aes(x = pos, y = freq)) +
     geom_line() + ylim(c(0,100)) + xlab("Position (bp)") + ylab("Percentage Samples with SNP (%)") + theme_bw()
    return(p)
  }) 
  
  output$distPlot <- renderPlot({
    
    p <- create_plot()
    df <- filtered()
    if(is.null(p)) return(NULL)
    if(!is.null(df) & !is.null(input$window) & input$window >= 10){
      # if(input$strand == '-'){
      #   df$pos <- df$pos * -1
      #   df$end <- df$pos * -1
      # }
      p <- p + geom_rect(data = df, aes(xmin= pos,xmax = end, ymin = -Inf, ymax = Inf), colour = 'grey10', alpha = 0.1, linetype = 0, inherit.aes = FALSE)  
    }
    p
  })

  
  filtered <- reactive({
    df <- create_freq()
    if(is.null(df)) return(NULL)
    df %>% filter(freq > 0) %>% select(pos) %>% 
      mutate(diff = c(diff(pos),0)) %>% 
      mutate(end = pos + diff) %>% 
      select (pos, end, diff) %>% 
      filter(abs(diff) >= input$window)
  })
  
  output$results <- renderTable(digits = 0,expr = {
    f <- filtered()
    if(is.null(f)) return(NULL)
    f
  })
  
})
