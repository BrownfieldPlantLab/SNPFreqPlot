
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

shinyUI(fluidPage(

  # Application title
  titlePanel("Plot VCF"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput("file", label = h3("Select VCF")),
      fileInput("bed", label = h3("Select BED (optional)")),
      radioButtons('strand', label = 'Strand', c("Positive"='+', "Negative"='-' )),
      numericInput('startpos', 'Position of start codon (bp)',value = NULL),
      numericInput('window', 'Filter for number of consecutive bp with no snps',value = 1,min = 1 ),
      
      h2('Save Plot'),
      textInput('plotfilename','Plot file prefix', value = NULL ),
      radioButtons('dev', label = "File type", c('png'='.png', 'pdf'='.pdf', 'svg'='.svg')),
      submitButton(text = 'Save')
      ),
    # Show a plot of the generated distribution
    mainPanel(
      textOutput("fn"),
      br(), br(),
      plotOutput('distPlot'),
      br(), br(),
      tableOutput('results')
    )
  )
))
