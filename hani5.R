library(raster)
x <- matrix(1:20, 4)
y<- matrix(21:40, 4)
x <- raster(x)
y <- raster(y)
z <- brick(x,y)
z
as.matrix(focal(x,matrix(1,3,3)), c)
