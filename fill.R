fillNA <- function(c){
       for (i in 1:length(c)){
              if (is.na(c[i])){
                     c[i] <- c[5]
              } 
       }
       c
}
