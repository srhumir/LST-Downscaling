
#preparing data for neural network. i.e. a table of 10 clumns.
# first nine NDVI of a pixel and its surronding pixels 
#the tenth: LST residuals of the pixels
fornn <- function(NDVIMODIS, residuals){
       forNN <- as.data.frame(getValuesFocal(NDVIMODIS,ngb = 3))
       names(forNN) <- sapply(1:9, function(i) paste("NDVI", as.character(i), sep = ""))
       forNN$LSTResiduals <- getValues(residuals)
       forNN <- subset(forNN, NDVI5 >= 0.15)
       forNN       
}

