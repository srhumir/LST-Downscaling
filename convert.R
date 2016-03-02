##this function is about to be used in focal to convert SpotNDVI to LST
##Get nine values of focal. Reaturn NA is the NDVI is NA or <.15. Otherwise convert
##SpotNDVI to Modis environment using lm. Then convert NDVI to LST using pol.
##finally ise nn to add residuals.
convert <- function(SpotNDVI, min, max, nn, lm, pol, ncell){
       percentfocal <<- percentfocal +1
       #print(percentfocal)
       if (floor(percentfocal*100/ncell) > ((percentfocal-1)*100/ncell)){
              print(paste(floor(percentfocal*100/ncell),"%"))
       }
       SpotNDVI <- as.vector(SpotNDVI)
       if (is.na(SpotNDVI[5]) | SpotNDVI[5] < .03) return(NA)
       modisLike <- lm$coefficients[1] + lm$coefficients[2] * SpotNDVI 
       #to modis environment
       #to lst
       lst <- pol$coefficients[1] + pol$coefficients[2] * modisLike[5] 
#+              pol$coefficients[3]* modisLike[5]^2
       #start nn. scale the modislike
       scaled <- scale(modisLike, center = min, scale = max - min)
       #run nn
       residual <- compute(nn,t(as.data.frame(modisLike)))$net.result
       lst + (residual*(max - min) + min)
}