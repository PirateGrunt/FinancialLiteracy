http://www.census.gov/cgi-bin/geo/shapefiles2013/main
http://www.epa.gov/enviro/html/codes/nc.html

library(maptools)
library(sp)
setwd("~/GitHub/FinancialLiteracy/Data/tl_2013_37_tract")
spdfNC = readShapePoly("tl_2013_37_tract")

spdfUWGT = subset(spdfNC, COUNTYFP %in% c("063", "101", "135", "183"))

plot(spdfUWGT)

setwd("~/GitHub/FinancialLiteracy/Data/ACS_11_5YR_B17005")
dfCensus = read.csv("ACS_11_5YR_B17005.csv", skip = 1)

marginOfError = grep("margin", colnames(dfCensus), ignore.case = TRUE)

dfCensus = dfCensus[, -marginOfError]
rm(marginOfError)

colnames(dfCensus) = gsub(".", "", colnames(dfCensus), fixed = TRUE)
colnames(dfCensus) = gsub("Estimate", "", colnames(dfCensus), fixed = TRUE)

dfIncome = dfCensus[, c("Id2", "Total")]

library(RColorBrewer)
myPalette = brewer.pal(9,"Blues")

#set breaks for the 9 colors 
library(classInt)
brks = classIntervals(dfIncome$Total, n=9, style="quantile")
brks = brks$brks

BrewBlue = myPalette[findInterval(dfIncome$Total, brks, all.inside=TRUE)]
dfIncome$Color = BrewBlue

mojo = merge(spdfUWGT, dfIncome, by.x = "GEOID", by.y = "Id2", all.x = TRUE)

plot(mojo, col=mojo$Color, axes=F)

dfUWGT = mojo@data
