library(data.table)
library(raster)
##1. Input data
#x <- matrix(rnorm(400), 20)
#y<- matrix(rnorm(400), 20)
print("chosse NDVI of MODIS of resolution equal to LST")
NDVIMODIS <- raster(file.choose())
print("choose LST of MODIS")
LSTMODIS <- raster(file.choose())
#z <- brick(NDVIMODIS,LSTMODIS)
##2. Compute polynomial to estimate LST from NDVI
###2.1. Get hot edge pixels
####Bin NDVI from 0.1 to 1 by 0.05 intervals
index <- complete.cases(getValues(NDVIMODIS),getValues(LSTMODIS))
HotEdgepixels <- data.table(NDVI = getValues(NDVIMODIS)[index], LST = getValues(LSTMODIS)[index])
NDVILST <- HotEdgepixels
HotEdgepixels[,bin:= floor((NDVI+1)/.03)]
qua <- with(HotEdgepixels,tapply(LST, bin, function(x)  quantile(x,probs = 0.9,na.rm = T)))
for (i in 1:length(HotEdgepixels$NDVI)){
  a[i] <- (HotEdgepixels$LST[i] >= qua[[as.character(HotEdgepixels$bin[i])]]) * HotEdgepixels$NDVI[i]
}
HotEdgepixels[, hotedge :=  a ]
HotEdgepixels[, hotedge:= as.logical(hotedge)]

HotEdgepixels <- subset(HotEdgepixels, hotedge & NDVI > .15)
#draw plot for comparison
plot(NDVILST$NDVI, NDVILST$LST)
points(HotEdgepixels$NDVI, HotEdgepixels$LST, pch = 17, col = "red")
####Fit polynomial to hot edge
x <- HotEdgepixels$NDVI
y <- HotEdgepixels$LST
pol <- lm(y ~ x + I(x^2))
#draw a plot to check
v <- seq(-1,1, by = 0.05)
w <- pol$coefficients[1] + pol$coefficients[2] * v +
  pol$coefficients[3]* v^2 
points(v,w, pch = 15, col = "green")
##3. Compute residuals using all data
residuals <- pol$coefficients[1] + pol$coefficients[2] * NDVIMODIS +
             pol$coefficients[3]* NDVIMODIS * NDVIMODIS - LSTMODIS


#preparing data for neural network. i.e. a table of 10 clumns.
# first nine residuals of a pixel and its surronding pixels 
#the tenth: LST of the pixels
##9 rasters to extract NDVI
reslist <- list()
forNN <- data.table(NDVI1= numeric(length = length(getValues(residuals))))
for (i in 1:9){
       matrix <- matrix(0,3,3)
       matrix[i] <- 1
       print(matrix)
       forNN[,paste("NDVI", as.character(i), sep = "") := getValues(focal(residuals,matrix, mean, na.rm = FALSE))]
}
forNN[,LSTResiduals := getValues(residuals)]
forNN <- subset(forNN, NDVI5 >= 0.15)

