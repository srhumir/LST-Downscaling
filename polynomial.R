#compute the degree two polynimial on hot edge of LST 
#converting NDVI to LST. We also draw plot to check
#if the hot edge pixels and ploynomial are acceptable
polynomail <- function(NDVIMODIS, LSTMODIS){
       ### Get hot edge pixels
       ####Bin NDVI from 0.1 to 1 by 0.05 intervals
       index <- complete.cases(getValues(NDVIMODIS),getValues(LSTMODIS))
       HotEdgepixels <- data.table(NDVI = getValues(NDVIMODIS)[index], LST = getValues(LSTMODIS)[index])
       NDVILST <- HotEdgepixels
       HotEdgepixels[,bin:= floor((NDVI+1)/.03)]
       qua <- with(HotEdgepixels,tapply(LST, bin, function(x)  quantile(x,probs = 0.9,na.rm = T)))
       a <- numeric()
       for (i in 1:length(HotEdgepixels$NDVI)){
              a[i] <- (HotEdgepixels$LST[i] >= qua[[as.character(HotEdgepixels$bin[i])]]) *
                     HotEdgepixels$NDVI[i]
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
       pol
}
##1. Input data
#x <- matrix(rnorm(400), 20)
#y<- matrix(rnorm(400), 20)
