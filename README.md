# SNPFreqPlot
A plotting app to visualise the SNPs across a region

To be run using R

## Install required packages:
```
if(!require("shiny")){
  install.packages("shiny")
}

if(!require("svglite")){
  install.packages("svglite") # may require some system libraries to be installed - check install messages if failing
}

if(!require("dplyr"){
  install.packages("dplyr")
}

if(!require("ggplot2")){
  install.packages("ggplot2")
}

```

## Run app from within RStudio:
```
shiny::runGitHub(username = 'BrownfieldPlantLab', repo = 'SNPFreqPlot', ref = 'master')
```

To be able to save plots and tables you will need to run and then select "Open in Browser"

## Usage

1. Use upload button to select a local uncompressed .vcf file (max file size 40 Mb)

2. Once uploaded the app may take a couple of minutes to process and display the plot

3. Configure the options as appropriate to modify the plot

4. Save plot and/or table








*Tested on Ubuntu 16.04.1 LTS*
* Rstudio v1.0.44
* R v3.3.2
 - shiny 0.14.1
 - dplyr 0.5.0
 - ggplot2 2.2.0
 - svglite 1.2.0
* Firefox v50.0.2
