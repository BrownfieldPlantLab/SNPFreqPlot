
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# Murray Cadzow and Ben Peters
# University of Otago
# November 2016
# 

library(shiny)




# Application title
shinyUI(
  fluidPage(
    titlePanel("SNPfreqPlot"),
    # Sidebar with a slider input for number of bins
    sidebarLayout(
      sidebarPanel(
        tabsetPanel(
          tabPanel("Load",
                   fileInput("file", label = h3("Select VCF")),
                   #fileInput("bed", label = h3("Select BED (optional)")),
                   radioButtons('strand', label = 'Strand', c("Positive"='+', "Negative"='-' )),
                   numericInput('startpos', 'Highlight position of start codon (bp)',value = NULL)
                   
                   
                   
          ),
          tabPanel("Options",
                   numericInput('window', 'Filter for number of consecutive bp with no snps',value = 1 ),
                   textInput("plotTitle", label = "Plot Title", value = NULL),
                   selectInput("plotTitleSize", label = "Plot Title Font Size", multiple = FALSE, choices = as.list(seq(8,42, by =2)), selected = 18),
                   textInput("xtitle", label = "X Axis title", value = NULL),
                   selectInput("xTitleSize", label = "X Title Font Size", multiple = FALSE, choices = as.list(seq(8,42, by =2)), selected = 16),
                   textInput("ytitle", label = "Y Axis Title", value = NULL),
                   selectInput("yTitleSize", label = "Y Title Font Size", multiple = FALSE, choices = as.list(seq(8,42, by =2)), selected = 16),
                   numericInput('start_xlim', label = "Zoom plot - |Start bp|",value=NULL, min = 0),
                   numericInput('end_xlim', label = 'Zoom plot - |End bp|', value=NULL, min = 0)
          ),
          tabPanel('Save',
                   wellPanel(
                     textInput('plotfilename','Plot file prefix', value = NULL ),
                     radioButtons("units", label = "Units", c("in"="in", "cm"="cm", "mm"="mm"), inline=TRUE),
                     numericInput("width", "Width", value = 9, min = 0, max=50),
                     numericInput("height","Height", value = 6, min=0, max = 50),
                     numericInput("dpi", "dpi", value = 300),
                     radioButtons('dev', label = "File type", c('png'='png', 'pdf'='pdf', 'svg'='svg'),inline = TRUE),
                     downloadButton('downloadPlot', label = 'Save Plot')),
                   
                   wellPanel("Save Table",
                             downloadButton('downloadTable', 'Download Table')
                   )
          )
        )
      ),
      # Show a plot of the generated distribution
      mainPanel(
        textOutput("fn"),
        br(),
        plotOutput('distPlot'),
        br(),
        br(), br(),
        tableOutput('results')
        
      )
    )
    
  )
  
)


