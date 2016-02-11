
library(raster)
##1. Input data
#x <- matrix(rnorm(400), 20)
#y<- matrix(rnorm(400), 20)
print("chosse NDVI of MODIS of resolution equal to LST")
NDVIMODIS <- raster(file.choose())
print("choose LST of MODIS")
LSTMODIS <- raster(file.choose())
z <- brick(NDVIMODIS,LSTMODIS)
##2. Compute polynomial to estimate LST from NDVI
###2.1. Get hot edge pixels
####Bin NDVI from 0.1 to 1 by 0.05 intervals
intervals <- seq(0.1, 1, 0.05)
bins <- list()
for (i in 1:(length(intervals)-1)){
       bins[i] <- (intervals[i] <= NDVIMODIS) & (NDVIMODIS <= intervals[i+1])
}
####Select top 5% of each bin based on LST
HotEdgepixels <- data.frame()
for (i in 1:(length(intervals)-1)){
       Logical95 <- LSTMODIS[bins[[i]]] >= quantile(LSTMODIS[bins[[i]]], probs = 0.95) 
       HotEdgepixels <- rbind(HotEdgepixels, cbind(NDVIMODIS[bins[[i]]][Logical95], LSTMODIS[bins[[i]]][Logical95]))
}
colnames(HotEdgepixels) <- c("NDVI", "LST")
####Fit polynomial to hot edge
x <- HotEdgepixels$NDVI
y <- HotEdgepixels$LST
pol <- lm(y ~ x + I(x^2))
##3. Compute residuals using all data
residuals <- pol$coefficients[1] + pol$coefficients[2] * NDVIMODIS + pol$coefficients[3]* NDVIMODIS * NDVIMODIS


#preparing data for neural network. i.e. a table of 10 clumns.
# first nine residuals of a pixel and its surronding pixels 
#the tenth: LST of the pixels
##9 rasters to extract NDVI
reslist <- list()
for (i in 1:9){
       matrix <- matrix(0,3,3)
       matrix[i] <- 1
       #print(matrix)
       reslist[i] <- focal(residuals,matrix, mean, na.rm = FALSE)
}
reslist[10] <- LSTMODIS
forNN <- as.data.frame(brick(reslist))
names(forNN) <- sapply(1:9, function(i) paste("NDVI", as.character(i), sep = ""))
names(forNN)[10] <- "LST"

