# SNPFreqPlot
A plotting app to visualise the SNPs across a region

## Install required packages:
```
if(!require("shiny")){
  install.packages("shiny")
}

if(!require("svglite")){
  install.packages("svglite")
}

if(!require("dplyr"){
  install.packages("dplyr")
}

if(!require("ggplot2")){
  install.packages("ggplot2")
}

```

## Run from within RStudio:
```
shiny::runGitHub(username = 'BrownfieldPlantLab', repo = 'SNPFreqPlot', ref = 'master')
```

To be able to save plots and tables you will need to run and then select "Open in Browser"
