
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
  
  #load and process data
  myData <- reactive({
    if(is.null(input$file)) return(NULL)
    inFile <- input$file
    vcf <- read.table(inFile$datapath, sep = '\t', header = FALSE, stringsAsFactors = FALSE)
    return(
      data.frame(
        t(
          apply(vcf, 1, function(x){
            gt<-unlist(
              sapply(x[10:length(x)],function(y){
                strsplit(x = y, split = ":")[[1]][1]} #pull out genotypes
              )
            )
            n <- 2 * length(gt)
            gt[gt == './.'] <- NA # replace missing genotypes with NA
            a <- as.numeric(
              unlist(
                sapply(gt[!is.na(gt)],function(y){
                  c(substring(y, 1,1), substring(y,3,3)) # pull out alleles
                }
                )
              )
            )
            
            alt <- sum(a > 0)
            return(c(chr = as.numeric(x[1]),pos = as.numeric(x[2]),af = alt/n))
          }
          )
        )
      )
    )
  })
  
  # adjust strand
  create_freq <- reactive({
    vcf <- myData()
    if(is.null(vcf)) return(NULL)
    if(input$strand == '-'){
      pos <- vcf$pos * -1 
    } else {
      pos <- vcf$pos
    }
    
    return(data.frame(chr = vcf$chr, freq = vcf$af * 100, pos = pos))
  })
  
  # setup plot
  create_plot <- reactive({
    df <- create_freq()
    if(is.null(df)) return(NULL)
    p <- ggplot(df, aes(x = pos, y = freq)) +
      geom_line() + ylim(c(0,100)) + xlab("Position (bp)") + ylab("Percentage Samples with SNP (%)") + theme_bw()
    return(p)
  }) 
  
  # render plot
  output$distPlot <- renderPlot({
    p <- create_plot()
    df <- filtered()
    if(is.null(p)) return(NULL)
    if(!is.null(df) & !is.null(input$window) & input$window >= 10){
      p <- p + geom_rect(data = df, aes(xmin= pos,xmax = end, ymin = -Inf, ymax = Inf), colour = 'grey10', alpha = 0.1, linetype = 0, inherit.aes = FALSE)  
    }
    p
  })
  
  # filter regions
  filtered <- reactive({
    df <- create_freq()
    if(is.null(df)) return(NULL)
    df %>% filter(freq > 0) %>% select(pos) %>% 
      mutate(diff = c(diff(pos),0)) %>% 
      mutate(end = pos + diff) %>% 
      select (pos, end, diff) %>% 
      filter(abs(diff) >= input$window)
  })
  
  # create table of regions
  output$results <- renderTable(digits = 0,expr = {
    f <- filtered()
    if(is.null(f)) return(NULL)
    f$diff <- abs(f$diff)
    f
  })
  
})
