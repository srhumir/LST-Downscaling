library(neuralnet)

#http://datascienceplus.com/fitting-neural-network-in-r/
set.seed(500)
apply(forNN,2,function(x) sum(is.na(x)))
index <- sample(1:nrow(forNN),round(0.75*nrow(forNN)))
train <- forNN[index,]
test <- forNN[-index,]
maxs <- apply(forNN, 2, max) 
mins <- apply(forNN, 2, min)
scaled <- as.data.frame(scale(forNN, center = mins, scale = maxs - mins))

train_ <- scaled[index,]
test_ <- scaled[-index,]
n <- names(train_)
f <- as.formula(paste("LST ~", paste(n[!n %in% "LST"], collapse = " + ")))

nn <- neuralnet(f,data=train_,hidden=c(5,3),linear.output=T)
pr.nn <- compute(nn,test_[,1:9])
pr.nn_ <- pr.nn$net.result*(max(forNN$LST)-min(forNN$LST))+min(forNN$LST)
test.r <- (test_$LST)*(max(forNN$LST)-min(forNN$LST))+min(forNN$LST)

MSE.nn <- sum((test.r - pr.nn_)^2)/nrow(test_)

print(paste(MSE.lm,MSE.nn))
