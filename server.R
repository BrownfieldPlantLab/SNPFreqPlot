
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)
options(shiny.maxRequestSize = 40 * 1024 ^2) # 40 Mb file limit
shinyServer(function(input, output) {
  output$fn <-renderText({if(!is.null(input$file)){paste("You have selected:",input$file[1])}})
  
  output$distPlot <- renderPlot({
    if(is.null(input$file)){
      return(NULL)
    }
    inFile <- input$file
    vcf <- read.table(inFile$datapath, sep = '\t', header = FALSE)
    gtcols <- 10:ncol(vcf)
    
    gt <- apply(vcf[,gtcols],1, function(x){
      y <- unlist(sapply(x, function(x){strsplit(x, ':')[[1]][1]}))
      return(y)
    } 
    )
    
    l <-levels(as.factor(gt))
    names(l) <- l
    l[grep('./.',l)] <- NA
    l[!is.na(l)] <- 0:(length(l[!is.na(l)])-1)
    
    
    gt2 <- apply(gt, 1, function(x){
      for(n in names(l)){
        cols <- which(x == n)
        x[cols]<- l[which(names(l) == n)]
      }
      return(x)
    })
    gt2 <- apply(gt2,1,as.numeric)
    posSum <- apply(gt2, 2, function(x){sum(x, na.rm=TRUE)}) # sum rows
    freq <- posSum/ncol(gt2) *100
    
    
    
    if(input$strand == '-'){
      pos <- as.numeric(vcf$V2) * -1 
    } else {
      pos <- as.numeric(vcf$V2)
    }
    ggplot(data.frame(freq = freq, pos = pos), aes(x = pos, y = freq)) +
      geom_line() + ylim(c(0,100)) + xlab("Position (bp)") + ylab("Percentage Samples with SNP (%)") + theme_bw()

   
  })

})
