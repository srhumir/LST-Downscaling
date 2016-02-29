library(neuralnet)

#http://datascienceplus.com/fitting-neural-network-in-r/
#save initial data
forNNNA <- forNN
#omit NA because NN can not work with NA
forNN <- forNN[complete.cases(forNN),]
set.seed(900)
apply(forNN,2,function(x) sum(is.na(x)))
index <- sample(1:nrow(forNN),round(0.75*nrow(forNN)))
train <- forNN[index,]
test <- forNN[-index,]
maxs <- apply(forNN, 2, max) 
mins <- apply(forNN, 2, min)
scaled <- as.data.frame(scale(forNN$LSTResiduals, center = mins[10], scale = maxs[10] - mins[10]))

train_ <- cbind(forNN[,1:9],scaled)[index,]
test_ <- cbind(forNN[,1:9],scaled)[-index,]
names(train_) <- names(train)
names(test_) <- names(test)
n <- names(train_)
f <- as.formula(paste("LSTResiduals ~", paste(n[!n %in% "LSTResiduals"], collapse = " + ")))

nn <- neuralnet(f,data=train,hidden=c(5,3),linear.output=T, threshold = 0.01,        
                stepmax = 1e+07)

#the NN is ready we will test it by the test dataset
##computing the (scaled) predictions using test
pr.nn <- compute(nn,test[,1:9])
##bringing back the predictions from scaled to ordinary data
#pr.nn_ <- pr.nn$net.result*(max(forNN$LST)-min(forNN$LST))+min(forNN$LST)
##bringing back scaled test data to ordinary
#test.r <- (test_$LST)*(max(forNN$LST)-min(forNN$LST))+min(forNN$LST)

##Comute root mean square erro
RMSE.nn <- sqrt(sum((test - pr.nn)^2)/nrow(test))

RMSE.nn
