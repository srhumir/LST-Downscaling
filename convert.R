##this function is about to be used in focal to convert SpotNDVI to LST
##Get nine values of focal. Reaturn NA is the NDVI is NA or <.15. Otherwise convert
##SpotNDVI to Modis environment using lm. Then convert NDVI to LST using pol.
##finally ise nn to add residuals.
convert <- function(SpotNDVI, min, max, nn, lm, pol){
       if (is.na(SpotNDVI[5]) | SpotNDVI[5] < .15) return(NA)
       #to modis environment
       modisLike <- lm$coefficients[1] + lm$coefficients[2] * SpotNDVI 
       #to lst
       lst <- pol$coefficients[1] + pol$coefficients[2] * modisLike[5] +
              pol$coefficients[3]* modisLike[5]^2
       #start nn. scale the modislike
       scaled <- scale(modisLike, center = min, scale = max - min)
       #run nn
       residual <- compute(nn,modisLike)
       lst + (residual*(max - min) + min)
}