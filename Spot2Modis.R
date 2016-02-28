#here we find a linear model to convert SPOTNDVI to MODIS NDVI in 240m resolution
#then we use this model to convert SPOT NDVI of 1.5m resolution to MODIS environment
##get data
Spot2Modis <- function(SPOTNDVI240, MODISNDVI240){
       ##crop MODIS by raster to have same dimenstion for linear model to be computable
       MODISNDVI240 <- crop(MODISNDVI240, SPOTNDVI240)
       SPOTNDVI240 <- crop(SPOTNDVI240, MODISNDVI240)
       ##omit NA value
       index  <- complete.cases(getValues(MODISNDVI240), getValues(SPOTNDVI240))
       ##make linear model between MODIS NDVI and SPOT NDVI
       y <- getValues(SPOTNDVI240)[index]
       x <- getValues(MODISNDVI240)[index]
       lm <- lm(y ~ x)
       lm       
}
