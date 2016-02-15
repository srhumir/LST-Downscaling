#here we find a linear model to convert SPOTNDVI to MODIS NDVI in 240m resolution
#then we use this model to convert SPOT NDVI of 1.5m resolution to MODIS environment
##get data
print("enter SPOT NDVI in 240m resolution")
SPOTNDVI240 <- raster(file.choose())
print("enter MODIS NDVI in 240m resolution")
MODISNDVI240 <- raster(file.choose())
print("enter SPOT NDVI in 1.5m resolution")
SPOTNDVI15 <- raster(file.choose())
##crop MODIS by raster to have same dimenstion for linear model to be computable
MODISNDVI240 <- crop(MODISNDVI240, SPOTNDVI240)
##omit NA value
index  <- complete.cases(getValues(MODISNDVI240), getValues(SPOTNDVI240))
##make linear model between MODIS NDVI and SPOT NDVI
y <- getValues(SPOTNDVI240)[index]
x<- getValues(MODISNDVI240)[index]
lm <- lm(y ~ x)
rm(list = c("x","y")) 

##read spotndvi and surrondings
##make a data.table which keep the spotndvi of each pixels and all of
##its surrondings. NDVI5 is the pixel. 
##then you shoud convert NDVIs to MODIS NDVI and finally LST.
##kepping surrondings is to use in NN
## to save memory, just unique values are saved. Converting it back to raster
##is another chalenge.

enter here the codes you have written on paper


##convert SPOT NDVI to MODIs environment
SPOTNDVI15dt <- data.table(SPOTNDVI = unique(round(getValues(SPOTNDVI15,  row = 1), digits = 2)))
for (i in 2:16648){
      SPOTNDVI15dt <- data.table(SPOTNDVI = unique(c(SPOTNDVI15dt$SPOTNDVI, 
                                                      round(getValues(SPOTNDVI15,  row = i), digits = 2))))
      print(paste(as.character((i*100/16648)),"%"))
}

##this one shoud be faster becaus is multicore
#library(multicore)
#l <- mclapply(1:nrows(SPOTNDVI15), function(i) 
#              { data.table(SPOTNDVI = unique(round(getValues(SPOTNDVI15,  row = i), digits = 2)))
#              })



#SPOTNDVI15dt <- data.table(SPOTNDVI = getValues(SPOTNDVI15, ))
#SPOTNDVI15MODIS <- lm$coefficients[1] + lm$coefficients[2] * SPOTNDVI15

##This system works for NDVI >= 0.15. So we remove smaller NDVIs and work with data table for speed.
  


##convert to MODIS environment
SPOTNDVI15dt[, NDVIMODIS := lm$coefficients[1] + lm$coefficients[2] * SPOTNDVI]
##Compute LST using pol
SPOTNDVI15dt[, LST_ := pol$coefficients[1] + pol$coefficients[2] * NDVIMODIS +
             pol$coefficients[3]* NDVIMODIS^2]
##produce a tif file
focal(SPOTNDVI15)




SPOTLST_ <- pol$coefficients[1] + pol$coefficients[2] * SPOTNDVI15MODIS +
  pol$coefficients[3]* SPOTNDVI15MODIS^2
writeRaster(SPOTLST_, filename = "SPOTLSTbeforeNN.tif")


##Prepare data to give to NN prepared in NeuralNetwork.R for computing residuals.
reslist <- list()
for (i in 1:9){
  matrix <- matrix(0,3,3)
  matrix[i] <- 1
  #print(matrix)
  reslist[i] <- focal(SPOTLST_,matrix, mean, na.rm = FALSE)
}
NDVIforNN <- as.data.frame(brick(reslist))
names(NDVIforNN) <- sapply(1:9, function(i) paste("NDVI", as.character(i), sep = ""))