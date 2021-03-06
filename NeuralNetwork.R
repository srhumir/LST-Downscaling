nn <- function(forNN){
       library(neuralnet)
       #http://datascienceplus.com/fitting-neural-network-in-r/
       #save initial data
       forNNNA <- forNN
       #omit NA because NN can not work with NA
       forNN <- forNN[complete.cases(forNN),]
       set.seed(300)
       print(apply(forNN,2,function(x) sum(is.na(x))))
       index <- sample(1:nrow(forNN),round(0.75*nrow(forNN)))
       train <- forNN[index,]
       test <- forNN[-index,]
       maxs <- apply(forNN, 2, max) 
       mins <- apply(forNN, 2, min)
       scaled <- as.data.frame(scale(forNN, center = mins, scale = maxs - mins))
       train_ <- scaled[index,]
       test_ <- scaled[-index,]
       n <- names(train_)
       f <- as.formula(paste("LSTResiduals ~", paste(n[!n %in% "LSTResiduals"], collapse = " + ")))
       nn <- neuralnet(f,data=train_,hidden=c(5,3),linear.output=T)
       #the NN is ready we will test it by the test dataset
       ##computing the (scaled) predictions using test
       pr.nn <- compute(nn,test_[,1:9])
       ##bringing back the predictions from scaled to ordinary data
       pr.nn_ <- pr.nn$net.result*(max(forNN$LST)-min(forNN$LST))+min(forNN$LST)
       ##bringing back scaled test data to ordinary
       test.r <- (test_$LST)*(max(forNN$LST)-min(forNN$LST))+min(forNN$LST)
       ##Comute root mean square erro
       RMSE.nn <- sqrt(sum((test.r - pr.nn_)^2)/nrow(test_))
       print(RMSE.nn)
       nn       
}
