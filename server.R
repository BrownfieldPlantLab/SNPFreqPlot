
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# Murray Cadzow and Ben Peters
# University of Otago
# November 2016
#

library(shiny)
library(ggplot2)
library(dplyr)
library(svglite)
options(shiny.maxRequestSize = 40 * 1024 ^2) # 40 Mb file limit
shinyServer(function(input, output, session) {
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
      geom_line() + ylim(c(0,100)) + theme_bw()
    
    #plot titles
    if(!is.null(input$plotTitle)){
      p <- p + ggtitle(input$plotTitle)
    }
    if(!is.null(input$xtitle) & input$xtitle != ""){
      p <- p + xlab(input$xtitle)
    } else {
      p <- p + xlab("Position (bp)") 
    }
    if(!is.null(input$ytitle) & input$ytitle != ""){
      p <- p + ylab(input$ytitle)
    } else {
      p <- p + ylab("Percentage Samples with SNP (%)")
    }
    #plot title font sizes
    p <- p + theme(plot.title = element_text(size = as.numeric(input$plotTitleSize), hjust = 0.5),
                   axis.title.x = element_text(size = as.numeric(input$xTitleSize)),
                   axis.text.x = element_text(size = as.numeric(input$xTitleSize) - 2),
                   axis.title.y = element_text(size = input$yTitleSize),
                   axis.text.y = element_text(size = as.numeric(input$yTitleSize) - 2)
    )
    
    #strand
    if(is.null(input$startpos) | !is.numeric(input$startpos)) return(p)
    if(input$strand == '-'){
      sp <- input$startpos * -1
    } else {
      sp <- input$startpos
    }
    if(abs(sp) >= min(abs(df$pos), na.rm=TRUE ) & abs(sp) <= max(abs(df$pos), na.rm=TRUE)){
      p <- p + geom_vline(xintercept=sp, colour = 'red')
    }
    
    return(p)
  }) 
  
  update_plot <- reactive({
    p <- create_plot()
    df <- filtered()
    sp <- NA
    if(is.null(p) | is.null(df)) return(NULL)
    
    if(!is.null(df) & !is.null(input$window) & input$window >= 10){
      p <- p + geom_rect(data = df, aes(xmin= pos,xmax = end, ymin = -Inf, ymax = Inf), colour = 'grey10', alpha = 0.1, linetype = 0, inherit.aes = FALSE)  
    }
    
    
    
    return(p)
  })
  
  # render plot
  output$distPlot <- renderPlot({
    p <- update_plot()
    if(is.null(p)) return(NULL)
    p
  })
  
  # filter regions
  filtered <- reactive({
    df <- create_freq()
    if(is.null(df)) return(NULL)
    df <- df %>% filter(freq > 0) %>% select(pos) %>% 
      mutate(diff = c(diff(pos),0)) %>% 
      mutate(end = pos + diff) %>% 
      select (pos, end, diff) %>% 
      filter(abs(diff) >= input$window)
    df$diff <- abs(df$diff)
    df
  })
  
  # create table of regions
  output$results <- renderTable(digits = 0,expr = {
    f <- filtered()
    if(is.null(f)) return(NULL)
    f
  })
  
  output$downloadTable <-downloadHandler(
    filename = function() { 
      if(is.null(input$tablefilename)){filename <- "data" 
      } else {
        filename <- input$tablefilename
      }
      paste(filename, '.csv', sep='') 
    },
    content = function(file) {
      write.csv(filtered(), file)
    })
  
  output$downloadPlot <- downloadHandler(
    filename = function(){
      if(is.null(input$plotfilename) | input$plotfilename == ""){
        plotfilename <- "figure"
      } else { 
        plotfilename <- input$plotfilename
      }
      paste0(plotfilename, '.',input$dev)
    },
    content = function(file){
      if(!is.null(input$dpi) & input$dpi > 0){
        dpi <- input$dpi
      } else { dpi <- 300}
      if(!is.null(input$width) & input$width > 0){
        width <- input$width
      } else { width = 480}
      if(!is.null(input$height) & input$height > 0){
        height <- input$height
      } else { height <- 480}
      ggsave(filename = file, plot= update_plot(), device = input$dev, width = width, height = height, dpi = dpi, units = input$units)
    }
  )
})
