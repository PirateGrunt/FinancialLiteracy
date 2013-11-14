http://www.census.gov/main/www/access.html
http://www.census.gov/geo/maps-data/data/tiger-data.html
http://factfinder2.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=ACS_11_5YR_S0802&prodType=table
http://www.jstatsoft.org/v37/i06/paper

library(maptools)
library(sp)
setwd("~/GitHub/FinancialLiteracy/Data/State_2010Census_DP1")
spdfStates = readShapePoly("State_2010Census_DP1")
df = spdfStates@data
library(plyr)
df = rename(df, replace = c("NAME10" = "State"))

polys = SpatialPolygons(spdfStates@polygons)
spdfStates = SpatialPolygonsDataFrame(polys, df)
rm(polys, df)

lower48 = subset(spdfStates, State != "Hawaii")
lower48 = subset(lower48, State != "Alaska")
lower48 = subset(lower48, State != "Puerto Rico")

rm(spdfStates)
plot(lower48, axes = FALSE)

setwd("~/GitHub/FinancialLiteracy/Data/ACS_12_1YR_DP03")
dfState = read.csv("ACS_12_1YR_DP03.csv", skip = 1)
dfState = rename(dfState, replace = c("Geography" = "State"))
View(dfState)

marginOfError = grep("margin", colnames(dfState), ignore.case = TRUE)

dfState = dfState[, -marginOfError]
rm(marginOfError)

estimate = grep("estimate", colnames(dfState), ignore.case = TRUE)
dfState = dfState[, -estimate]
rm(estimate)

dfPoverty = dfState[, c(3, 122)]
colnames(dfPoverty)[2] = "PovertyPct"

uniquePct = unique(dfPoverty$PovertyPct)

library(RColorBrewer)
nColors = length(uniquePct)
myPalette = brewer.pal(9,"Blues")
# df = data.frame(noise = 1:9, color = myPalette, stringsAsFactors = FALSE)
# 
# plot(df, col = df$color, pch=19)
# plot(df, col = "#08519C", pch=19)
# plot(df, col = myPalette[7], pch=19)
# plot(df$noise, df$noise, col = myPalette, pch=19)
# plot(df$noise, df$noise, col = df$color, pch=19)

#BrewBlue = colorRampPalette(myPalette)(nColors)

#set breaks for the 9 colors 
library(classInt)
brks = classIntervals(dfPoverty$PovertyPct, n=9, style="quantile")
brks = brks$brks

BrewBlue = myPalette[findInterval(uniquePct, brks, all.inside=TRUE)]
dfColors = data.frame(PovertyPct = uniquePct, BrewBlue = BrewBlue, stringsAsFactors = FALSE)

plot(dfColors$PovertyPct, col = dfColors$BrewBlue, pch=19)

dfPoverty = merge(dfPoverty, dfColors)
rm(dfColors, BrewBlue, brks, myPalette, nColors, uniquePct)

lower48Poverty = merge(lower48, dfPoverty)

plot(lower48Poverty, col=lower48Poverty$BrewBlue, axes=F)
View(lower48Poverty$HeatColor)
plot(lower48Poverty)
