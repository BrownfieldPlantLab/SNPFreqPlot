
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# Murray Cadzow
# University of Otago
# November 2016
# 

library(shiny)




# Application title
shinyUI(
  fluidPage(
    titlePanel("Load VCF"),
    # Sidebar with a slider input for number of bins
    sidebarLayout(
      sidebarPanel(
        tabsetPanel(
          tabPanel("Load",
                   fileInput("file", label = h3("Select VCF")),
                   fileInput("bed", label = h3("Select BED (optional)")),
                   radioButtons('strand', label = 'Strand', c("Positive"='+', "Negative"='-' )),
                   numericInput('startpos', 'Position of start codon (bp)',value = NULL)
                   
                   
                   
          ),
          tabPanel("Options",
                   numericInput('window', 'Filter for number of consecutive bp with no snps',value = 1,min = 1 ),
                   textInput("plotTitle", label = "Plot Title"),
                   textInput("xtitle", label = "X Axis title"),
                   textInput("ytitle", label = "Y Axis Title")
          ),
          tabPanel('Save',
                   wellPanel(
                   textInput('plotfilename','Plot file prefix', value = NULL ),
                   radioButtons('dev', label = "File type", c('png'='.png', 'pdf'='.pdf', 'svg'='.svg')),
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


