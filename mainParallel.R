#library(data.table)
library(raster)
library(data.table)
library(parallel)
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

percentfocal <- 0
ncell <- ncell(SPOTNDVI15)
max <- maxValue(SPOTNDVI15)
min <- minValue(SPOTNDVI15)
maxLST <- maxValue(LSTMODIS)
minLST <- minValue(LSTMODIS)

# Calculate the number of cores
no_cores <- detectCores() - 1
SPOTNDVI15list <- splitraster(SPOTNDVI15, no_cores)

# Initiate cluster
cl <- makeCluster(no_cores)
clusterExport(cl,c("percentfocal","SPOTNDVI15list", "min", "max", "minLST","maxLST","lm", "pol", "ncell",
                   "convert", "nn", "fillNA"))
clusterEvalQ(cl, library(raster))
clusterEvalQ(cl, library(neuralnet))
Sys.time()
SpotLSTlist <- parLapply(cl,1:length(SPOTNDVI15list),
          function(i) focal(SPOTNDVI15list[[i]], matrix(1,3,3),
                            function(x) convert(x, min = min, max = max, 
                                                minLST = minLST, maxLST = maxLST,
                                                nn = nn, lm = lm, pol = pol,
                                                ncell = ncell), 
                            pad = TRUE,
                            filename = paste("./temp/",i,".tif", sep = ""), 
                            overwrite = TRUE))
Sys.time()
stopCluster(cl)
SPOTLST15 <- do.call(merge, SpotLSTlist)
writeRaster(SPOTLST15, filename = "SPOTLSTtestmulti5.tif")


