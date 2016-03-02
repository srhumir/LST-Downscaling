#split the raster into several parts to be used in parallel computation
splitraster <- function(raster, s){
       ext <- extent(raster)
       xstep <- (ext[2] - ext[1])/s
       ystep <- (ext[4] - ext[3])/s
       t <- s-1
       l <- list()
       for (i in 0:t){
              for (j in 0:t){
                     ext2 <- extent(ext[1] + i * xstep, ext[1] + (i+1) * xstep,
                                    ext[3] + j * ystep, ext[3] + (j+1) * ystep)
                     l[paste(as.character(i), as.character(j), sep = ",")] <- 
                            crop(raster, ext2, filename = 
                                        paste("./temp/","ndvi",i,",",j,".tif", sep = ""), 
                                 overwrite = TRUE)
              }
       }
       l
}