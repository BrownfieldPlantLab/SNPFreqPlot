
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Plot VCF"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput("file", label = h3("Select VCF")),
      radioButtons('strand', label = 'Strand', c("Positive"='+', "Negative"='-' )),
      numericInput('startpos', 'Position of start codon (bp)',value = NULL)

    ),

    # Show a plot of the generated distribution
    mainPanel(
      textOutput("fn"),
      plotOutput('distPlot')
    )
  )
))
