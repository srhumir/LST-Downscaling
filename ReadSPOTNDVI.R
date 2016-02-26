library(data.table)
library(raster)
##read spotndvi and surrondings
##make a data.table which keep the spotndvi of each pixels and all of
##its surrondings. NDVI5 is the pixel. 
##then you shoud convert NDVIs to MODIS NDVI and finally LST.
##kepping surrondings is to use in NN
## to save memory, just unique values are saved. Converting it back to raster
##is another chalenge.
SPOTNDVI15 <- raster(matrix(c(1:400, -20:-1), 21,20))


SPOTNDVI15dt <- data.table( NDVI1 = numeric(), NDVI2 = numeric(), NDVI3 = numeric(), NDVI4 = numeric(), NDVI5 = numeric(), NDVI6 = numeric(), NDVI7 = numeric(), NDVI8 = numeric(), NDVI9 = numeric())
r1 <- numeric(nrow(SPOTNDVI15)+2) *NA
r2 <- r1
r3 <- round(getValues(SPOTNDVI15, row = 1), digits = 2)
r3 <- c(r3[length(r3)],r3,r3[1])
for (j in 2:(nrow(SPOTNDVI15)+1)){
        if(j <= nrow(SPOTNDVI15)){
                r1 <- r2
                r2 <- r3
                r3 <- round(getValues(SPOTNDVI15, row = j), digits = 2)
                r3 <- c(r3[length(r3)],r3,r3[1])
        }else{
                r1 <- r2
                r2 <- r3
                r3 <- numeric(nrow(SPOTNDVI15)+2) * NA
        }
        l = list()
        for (i in 2:(length(r1)-1)){
                if (r2[i] < .15 | is.na(r2[i])) next()
                l[[i-1]] <- data.table(r1[i-1], r1[i], r1[i+1],
                                       r2[i-1], r2[i], r2[i+1],
                                       r3[i-1], r3[i], r3[i+1])
        }
        SPOTNDVI15dt <- unique(rbindlist(c(list(SPOTNDVI15dt),l)))
        #SPOTNDVI15dt <- (rbindlist(c(list(SPOTNDVI15dt),l)))
        percent <- floor((j*100)/nrow(SPOTNDVI15))
        percentold <- floor(((j-1)*100)/nrow(SPOTNDVI15))
        if (percent > percentold){
                print(paste(as.character(percentold), "%"))
        }
}
SPOTNDVI15dt

SPOTNDVI15dt <- cbind(SPOTNDVI15dt,.1+ 1.2*SPOTNDVI15dt)
names(SPOTNDVI15dt)[10:18] <- paste(names(SPOTNDVI15dt)[10:18], "MODISi", sep = "")
SPOTNDVI15dt[, LST_ := 0.1+0.2*SPOTNDVI15dt$NDVI5MODISi+0.3*SPOTNDVI15dt$NDVI5MODISi^2]
SPOTNDVI15dt[,residuals := compute(nn,SPOTNDVI15dt[,10:18])]
SPOTNDVI15[, LST := SPOTNDVI15dt$LST_+SPOTNDVI15dt$residuals]

getValuesFocal(SPOTNDVI15, ngb = 3)


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


