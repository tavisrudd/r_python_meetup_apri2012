#!/usr/bin/Rscript --vanilla --slave

required.packages <- c("gdata", "zoo", "xts", "Cairo", "ggplot2", "lattice"
                       #, "timeDate"
                       )
for (pkg in required.packages) {
  if (! pkg %in% rownames(installed.packages())) {
    install.packages(pkg, repos=c("http://cran.us.r-project.org"))
  }
  suppressMessages(require(pkg, character.only=TRUE))
}

save.plot <- function (p, filename="chart.png", width=8, height=6) {
  .dev <- CairoPNG(filename=filename, width=width*100, height=height*100, bg="white")
  print(p)
  dev.off(.dev)
}



main <- function () {
  weather.df <- read.csv('./weather2010n.csv', as.is=TRUE)
  cycling.df <- read.xls("cycling_cleaned.xls", as.is=TRUE)

  
  cat("\n\n*** basic structure of the cycling.df:\n")
  str(cycling.df)

  cat("\n\n*** basic structure of the weather.df:\n")
  str(weather.df)

  ## convert to timeseries
  burrard.zoo <- zoo(cycling.df$Burrard.Bridge[-c(1)],
                     as.Date(cycling.df$Date[-c(1)]))
  weather.zoo <- zoo(data.frame(rain.mm=weather.df$Total.Rain..mm.,
                                snow.cm=weather.df[["Total.Snow..cm."]],
                                min.temp.c=weather.df$Min.Temp..C.,
                                max.temp.c=weather.df$Max.Temp..C.), 
                     as.Date(weather.df$Date.Time))

  cat("\n\nZ-ordered timeseries of Burrard Bridge ridership:\n")
  save.plot(xyplot(burrard.zoo), "burrard.png")

  cat("\n\nZ-ordered timeseries of weather data subset:\n")
  str(weather.zoo)
  
  cat("\n\nStem-and-leaf plot of rain (mm)):\n")
  stem(weather.zoo$rain.mm)

  cat("\n\nStem-and-leaf plot of snow (cm)):\n")
  stem(weather.zoo$snow.cm)

  ## align and merge the 2 timeseries
  combined.zoo <- merge.zoo(burrard.zoo, weather.zoo)
  str(combined.zoo)
  save.plot(xyplot(combined.zoo), "combined.png")
  
}

if (!interactive()) main()
