#!/usr/bin/Rscript --vanilla --slave

required.packages <- c("gdata", "zoo", "Cairo", "lattice")
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

heading <- function (s) {
  cat("\n\n** ")
  cat(s)
  cat("\n\n")
}

main <- function () {
  weather.df <- read.csv('./weather2010n.csv', as.is=TRUE)
  cycling.df <- read.xls("./cycling_cleaned.xls", as.is=TRUE)

  heading("Basic structure of the cycling.df:")
  str(cycling.df)

  heading("Basic structure of the weather.df:")
  str(weather.df)

  ## convert to timeseries, drop first garbage row of cycling data
  burrard.zoo <- zoo(data.frame(burrard=cycling.df$Burrard.Bridge[-c(1)]),
                     as.Date(cycling.df$Date[-c(1)]))
  weather.zoo <- zoo(data.frame(rain.mm=weather.df$Total.Rain..mm.,
                                snow.cm=weather.df[["Total.Snow..cm."]],
                                min.temp.c=weather.df$Min.Temp..C.,
                                max.temp.c=weather.df$Max.Temp..C.), 
                     as.Date(weather.df$Date.Time))

  heading("Z-ordered timeseries of Burrard Bridge ridership:")
  save.plot(xyplot(burrard.zoo), "burrard.png")

  heading("Z-ordered timeseries of weather data subset:")
  str(weather.zoo)
  
  heading("Stem-and-leaf plot of rain (mm):")
  stem(weather.zoo$rain.mm)

  heading("Stem-and-leaf plot of snow (cm):")
  stem(weather.zoo$snow.cm)

  ## align and merge the 2 timeseries
  combined.zoo <- merge.zoo(burrard.zoo, weather.zoo)
  combined.zoo <- combined.zoo[index(combined.zoo) < as.Date('2011-01-01')]

  str(combined.zoo)
  save.plot(xyplot(combined.zoo), "combined.png")
  heading("Summary stats on combined ts:")
  summary(combined.zoo)

  # do a simple lagged correlations on biking stats and the 4 weather factors
  save.plot(ccf(combined.zoo$burrard, combined.zoo$rain.mm), 'ccf_rain.png')
  save.plot(ccf(combined.zoo$burrard, combined.zoo$snow.cm), 'ccf_snow.png')
  save.plot(ccf(combined.zoo$burrard, combined.zoo$min.temp.c), 'ccf_min.png')
  save.plot(ccf(combined.zoo$burrard, combined.zoo$max.temp.c), 'ccf_max.png')
}

if (!interactive()) main()
