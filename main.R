#library(data.table)
library(raster)
print("chosse NDVI of MODIS of resolution equal to LST")
NDVIMODIS <- raster(file.choose())
print("choose LST of MODIS")
LSTMODIS <- raster(file.choose())

print("enter SPOT NDVI in 240m resolution")
SPOTNDVI240 <- raster(file.choose())
print("enter MODIS NDVI in 240m resolution")
MODISNDVI240 <- raster(file.choose())

print("Enter SPOT NDVI in 1.5m resolution")
SPOTNDVI15 <- raster(file.choose())

pol <- polynomail(NDVIMODIS, LSTMODIS)
residuals <- resid(pol, NDVIMODIS)
forNN <- fornn(NDVIMODIS, residuals)
nn <- nn(forNN)

lm <- Spot2Modis(SPOTNDVI240, MODISNDVI240)

max <- maxValue(SPOTNDVI15)
min <- minValue(SPOTNDVI15)
LSTSPOT <- focal(SPOTNDVI15, matrix(1,3,3), 
                 function(x) convert(x, min = min, max = max, nn = nn, lm = lm, pol = pol), 
                 filename = "SPOTLSTlm.tif", progress = "=")


