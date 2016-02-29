
##3. Compute residuals using all data in a Raster
resid <- function(pol, NDVIMODIS){
       residuals <- pol$coefficients[1] + pol$coefficients[2] * NDVIMODIS - LSTMODIS
       #              + pol$coefficients[3]* NDVIMODIS^2
}

