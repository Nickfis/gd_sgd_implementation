rm(list=ls())
library('MASS')
########################################## GENERATE DATA ##################################################
generateData <- function(n, dimensions, mu=0){
  muwdiebu <- rep(0, dimensions)
  onesies <- rep(1,dimensions)
  dividies <- seq(1,dimensions)
  diagonally <- onesies/dividies
  Sigma <- diag(x=diagonally, nrow=dimensions, ncol=dimensions)
  trainingdata<-as.data.frame(mvrnorm(n = n, mu=muwdiebu, Sigma=Sigma))
  constant <- rep(1, n)
  trainingdata <- cbind(constant, trainingdata)
  # naming the variables 
  for (i in 1:ncol(trainingdata)){
    names(trainingdata)[i] <- paste0("X",(i-1))
  }
  y <- apply(trainingdata,1, FUN=sum)+rnorm(nrow(trainingdata),mean=0, sd=1)
  trainingdata <- cbind(trainingdata, y)
  return(trainingdata)
}

#################################### OLS MODEL #########################################################
createOLS <- function(df){
  # OLS Model
  y <- df$y
  X <- as.matrix(df[,-(ncol(df))])
  hi <- Sys.time() # before training the model
  #ols_model<-lm(data=trainingdata, y~.) # training the model
  betas_lm <- round(solve(t(X) %*% X) %*% t(X) %*% y, 5)
  na <- Sys.time() # after training the model 
  diff <- na-hi # total amount of time elapsed
  all_info <- list()
  all_info[1] <-list(betas_lm)
  all_info[2] <- diff
  names(all_info)<- c('Betas of OLS Model', 'Time Elapsed')
  return(all_info)
  #return(betas_lm)
}


############################################# Gradient Descent ###############################################
# first create the function that will return us our gradient because this will be called as long
# as the gradient does not converge to the previous gradient
gradient <- function(df, theta) {
  y <- as.matrix(df$y) # take column of y's from training set
  X <- as.matrix(df[,-(ncol(df))]) # create design matrix
  m <- nrow(X)
  gradient <- (1/m)* (t(X) %*% ((X %*% t(theta)) - y))
  return(t(gradient))
}

createGD <- function(df, alpha){ 
  # GD model
  y <- as.matrix(df$y) # take column of y's from training set
  X <- as.matrix(df[,-(ncol(df))]) # create design matrix
  m <- nrow(y) # needed for j function later
  hi <- Sys.time() # before training the model
  #'''HERE COMES THE GRADIENT DESCENT'''
  betas_gd <- matrix(rep(0,(ncol(X))), nrow=1) # initializing GD vector
  listbeta <- matrix(0,nrow=m, ncol=ncol(X))
  for (i in 1:m) { # here introduce the stopping condition, since we will run it until n.
                  # with n being the number of rows in the matrix (observations)
    betas_gd <- betas_gd - alpha  * gradient(df, betas_gd)
    listbeta[i,] <- betas_gd
    # maybe split x and y up before and not do it again and again
  }
  betas_gd <- colMeans(listbeta)
  na <- Sys.time() # after training the model 
  diff <- na-hi # total amount of time elapsed
  all_info <- list()
  all_info[1] <-list(t(betas_gd))
  all_info[2] <- diff
  names(all_info)<- c('Betas of GD Model', 'Time Elapsed')
  return(all_info)
  #return(betas_lm)
}

createGD_decr <- function(df){ 
  # GD model
  y <- as.matrix(df$y) # take column of y's from training set
  X <- as.matrix(df[,-(ncol(df))]) # create design matrix
  m <- nrow(y) # needed for j function later
  hi <- Sys.time() # before training the model
  #'''HERE COMES THE GRADIENT DESCENT'''
  betas_gd <- matrix(rep(0,(ncol(X))), nrow=1) # initializing GD vector
  listbeta <- matrix(0,nrow=m, ncol=ncol(X))
  for (i in 1:m) { # here introduce the stopping condition, since we will run it until n.
    # with n being the number of rows in the matrix (observations)
    alpha=1/sqrt(i)
    betas_gd <- betas_gd - alpha  * gradient(df, betas_gd)
    listbeta[i,] <- betas_gd
    # maybe split x and y up before and not do it again and again
  }
  betas_gd <- colMeans(listbeta)
  na <- Sys.time() # after training the model 
  diff <- na-hi # total amount of time elapsed
  all_info <- list()
  all_info[1] <-list(t(betas_gd))
  all_info[2] <- diff
  names(all_info)<- c('Betas of GD Model', 'Time Elapsed')
  return(all_info)
  #return(betas_lm)
}

############################################## STOCHASTIC GRADIENT DESCENT #######################################################
# first create the function that will return us our gradient because this will be called as long
# as the gradient does not converge to the previous gradient
sgradient <- function(df, theta, row) {
  y <- as.matrix(df$y) # take column of y's from training set
  X <- as.matrix(df[,-(ncol(df))]) # create design matrixy
  #sgradient <- (1/nrow(X))* (y[row]-t(theta)%*%X[row,])%*%X[row,]
  sgradient <- ((theta%*%X[row,]) %*% X[row,]) - (X[row,] * y[row])
  return(sgradient)
}

createSGD <- function(df,alpha){
   # SGD model
   y <- as.matrix(df$y) # take column of y's from training set
   X <- as.matrix(df[,-(ncol(df))]) # create design matrix
   m <- nrow(y) # needed for j function later
   hi <- Sys.time() # before training the model
   #'''HERE COMES THE STOCHASTIC GRADIENT DESCENT'''
   betas_sgd <- matrix(rep(0,(ncol(X))), nrow=1) # initializing GD vector
   # "you may try various values for this constant"
   listbeta <- matrix(0,nrow=m, ncol=ncol(X))
   # for(elem in 1:m){ JOAN
   #   betas_sgd<-betas_sgd-2*alpha[elem]*((t(betas_sgd)%*%X[elem,])*X[elem,]-X[elem,]*y[elem])
   #   listbeta[elem]<- betas_sgd
   # }

    for (i in 1:m) { # running it for iterations = number of observations
      # with m being the number of rows in the matrix (observations)
      betas_sgd <- betas_sgd - 2*alpha  * sgradient(df, betas_sgd, row=i)
      listbeta[i,]<-betas_sgd
      # maybe split x and y up before and not do it again and again
    }
   betas_sgd<-colMeans(listbeta)
   na <- Sys.time() # after training the model
   diff <- na-hi # total amount of time elapsed
   all_info <- list()
   all_info[1] <-list(t(betas_sgd))
   all_info[2] <- diff
   names(all_info)<- c('Betas of SGD Model', 'Time Elapsed')
   return(all_info)
}

######################## SGD DECREASE ############################
createSGD_decr <- function(df){
  # SGD model
  y <- as.matrix(df$y) # take column of y's from training set
  X <- as.matrix(df[,-(ncol(df))]) # create design matrix
  m <- nrow(y) # needed for j function later
  hi <- Sys.time() # before training the model
  #'''HERE COMES THE STOCHASTIC GRADIENT DESCENT'''
  betas_sgd <- matrix(rep(0,(ncol(X))), nrow=1) # initializing GD vector
  # "you may try various values for this constant"
  listbeta <- matrix(0,nrow=m, ncol=ncol(X))
  # for(elem in 1:m){ JOAN
  #   betas_sgd<-betas_sgd-2*alpha[elem]*((t(betas_sgd)%*%X[elem,])*X[elem,]-X[elem,]*y[elem])
  #   listbeta[elem]<- betas_sgd
  # }
  
  for (i in 1:m) { # running it for iterations = number of observations
    # with m being the number of rows in the matrix (observations)
    alpha <- 1/sqrt(i)
    betas_sgd <- betas_sgd - 2*alpha  * sgradient(df, betas_sgd, row=i)
    listbeta[i,]<-betas_sgd
    # maybe split x and y up before and not do it again and again
  }
  betas_sgd<-colMeans(listbeta)
  na <- Sys.time() # after training the model
  diff <- na-hi # total amount of time elapsed
  all_info <- list()
  all_info[1] <-list(t(betas_sgd))
  all_info[2] <- diff
  names(all_info)<- c('Betas of SGD Model', 'Time Elapsed')
  return(all_info)
}


##################################### PREDICTION FUNCTION AND MSE CALCULATION ################################
mse_pred <- function(betas,testdata){ 
  y_test <- as.matrix(testdata$y) # take column of y's from training set
  X <- as.matrix(testdata[,-(ncol(testdata))]) # create design matrix
  betas <- as.numeric(unlist(betas))
  y_pred=X%*%betas
  mse <- mean(((y_test-y_pred)^2))
  return(mse)
}


########################################## ACTUAL CALCULATIONS #############################################
# first create datasets for training:
### switch through values for n & d
# -> for each dataset we will calculate the betas of each of the three models
# -> now doing this, we just have to through one training set with the same number of dimensions
#     but a set value for the observations to calculate the MSE from!
# -> for every model create a matrix with the n & d values as column and row names and put in the 
#     MSE for each potential combination of values.
# -> do the exact same thing for the runtime, which can be found in result_XX[2]

# Create data
trainingdata <- generateData(n=500, dimensions=10) # stuff works
testdata <- generateData(n=1000, dimensions=10) # dimensions have to be equal, observations constnt

# Create models
result_ols<- createOLS(trainingdata)
result_gd<- createGD(trainingdata, 0.05) #gives you the coefficients for prediction and the difference it took training
result_sgd <- createSGD(trainingdata)

result_ols

# Prediction error
mse_ols <- mse_pred(result_ols[1], testdata)
mse_gd<-mse_pred(result_gd[1], testdata)
mse_sgd <- mse_pred(result_sgd[1], testdata)

mse_ols
mse_gd
mse_sgd


######################################## ACTUAL LOOPS CREATING MATRICES TO PLOT FROM ###################################################################
# dimensions, keeping the observation steady at 1000
n=1000
d=c(1,3,5,10,25,50,100,150,200,300,400,500,750)
alpha=0.1


############################## PERFORMANCE OF MODELS IN ALL DIMENSIONS #######################################
mse_d <- matrix(rep(0,length(d)*5), nrow=length(d), ncol=5)
time_d<- matrix(rep(0,length(d)*5), nrow=length(d), ncol=5)

for (i in 1:length(d)){
  trainingdata <- generateData(n=1000, dimensions=d[i]) # creating the training data
  # now training all three models
  result_ols<- createOLS(trainingdata)
  result_gd<- createGD(trainingdata, alpha=alpha) #gives you the coefficients for prediction and the difference it took training
  result_sgd <- createSGD(trainingdata, alpha=alpha)
  result_gd_decr <- createGD_decr(trainingdata)
  result_sgd_decr <- createSGD_decr(trainingdata)
  ### NOW I GOT ALL THE RELEVANT MODELS, NOW I NEED THE MSE
  testdata <- generateData(n=1500, dimensions=d[i])  # n will always be 1500 for this
  print(i)
  mse_d[i,1]<-mse_pred(result_ols[1], testdata)
  mse_d[i,2]<-mse_pred(result_gd[1], testdata)
  mse_d[i,3]<-mse_pred(result_sgd[1], testdata)
  mse_d[i,4]<-mse_pred(result_gd_decr[1], testdata)
  mse_d[i,5]<-mse_pred(result_sgd_decr[1], testdata)
  time_d[i,1]<-result_ols[[2]]
  time_d[i,2]<-result_gd[[2]]
  time_d[i,3]<-result_sgd[[2]]
  time_d[i,4]<-result_gd_decr[[2]]
  time_d[i,5]<-result_sgd_decr[[2]]
}

colnames(mse_d)<- c("OLS-Model", "GD-Model", "SGD-Model", "GD-Model decr.", "SGD-Model dec.")
colnames(time_d) <- c("OLS-Model", "GD-Model", "SGD-Model", "GD-Model decr.", "SGD-Model dec.")
rownames(mse_d)<- as.character(d)
rownames(time_d)<- as.character(d)
mse_d <- as.data.frame(melt(mse_d))
time_d<-as.data.frame(melt(time_d))
names(mse_d) <- c("d", "Model", "MSE")
names(time_d)<- c("d", "Model", "Runtime")

d_mse_plot<-ggplot(data=mse_d, aes(x=d,y=MSE))+geom_line(aes(col=Model))+ coord_cartesian(ylim=c(0.5,5))+
  ggtitle("MSE of the five different models against different values of d")+ theme(legend.position="bottom")+
  guides(col=guide_legend(nrow=2,byrow=TRUE))
d_mse_plot

d_runtime_plot <- ggplot(data=time_d, aes(x=factor(d),y=factor(Model), fill=Runtime)) + geom_tile()+
  scale_fill_gradient(low = 'green', high = "red")+ ggtitle("Runtime different models regarding dimensions")+
  theme(legend.position='bottom')+xlab("Number of dimensions in training set")+ylab("Model")+
  labs(fill='Runtime in seconds') 

d_runtime_plot

time_d

########################## CHECKING FOR NUMBER OF OBSERVATIONS TO TRAIN ON######################################
n=c(15,30,50,100,200,500,1000,1500,3000,5000)
d=5
alpha=0.1


############################## PERFORMANCE OF MODELS IN ALL N VALUES #######################################
mse_n <- matrix(rep(0,length(n)*5), nrow=length(n), ncol=5)
time_n<- matrix(rep(0,length(n)*5), nrow=length(n), ncol=5)

for (i in 1:length(n)){
  trainingdata <- generateData(n=n[i], dimensions=d) # creating the training data
  # now training all three models
  result_ols<- createOLS(trainingdata)
  result_gd<- createGD(trainingdata, alpha=alpha) #gives you the coefficients for prediction and the difference it took training
  result_sgd <- createSGD(trainingdata, alpha=alpha)
  result_gd_decr <- createGD_decr(trainingdata)
  result_sgd_decr <- createSGD_decr(trainingdata)
  ### NOW I GOT ALL THE RELEVANT MODELS, NOW I NEED THE MSE
  testdata <- generateData(n=1500, dimensions=d)  # n will always be 1500 for this
  print(i)
  mse_n[i,1]<-mse_pred(result_ols[1], testdata)
  mse_n[i,2]<-mse_pred(result_gd[1], testdata)
  mse_n[i,3]<-mse_pred(result_sgd[1], testdata)
  mse_n[i,4]<-mse_pred(result_gd_decr[1], testdata)
  mse_n[i,5]<-mse_pred(result_sgd_decr[1], testdata)
  time_n[i,1]<-result_ols[[2]]
  time_n[i,2]<-result_gd[[2]]
  time_n[i,3]<-result_sgd[[2]]
  time_n[i,4]<-result_gd_decr[[2]]
  time_n[i,5]<-result_sgd_decr[[2]]
}

colnames(mse_n)<- c("OLS-Model", "GD-Model", "SGD-Model", "GD-Model decr.", "SGD-Model dec.")
colnames(time_n) <- c("OLS-Model", "GD-Model", "SGD-Model", "GD-Model decr.", "SGD-Model dec.")
rownames(mse_n)<- as.character(n)
rownames(time_n)<- as.character(n)
mse_n <- as.data.frame(melt(mse_n))
time_n<-as.data.frame(melt(time_n))
names(mse_n) <- c("n", "Model", "MSE")
names(time_n)<- c("n", "Model", "Runtime")



n_mse_plot<-ggplot(data=mse_n, aes(x=n,y=MSE))+geom_line(aes(col=Model))+ coord_cartesian(xlim=c(0,700),ylim=c(0.5,5))+
  ggtitle("MSE of the five different models against different values of n")+ theme(legend.position="bottom")+
  guides(col=guide_legend(nrow=2,byrow=TRUE))+xlab("Number of observations in training set")

n_mse_plot
#### x axis cut off because aterwards no major change in mse anymore.

n_runtime_plot <- ggplot(data=time_n, aes(x=factor(n),y=factor(Model), fill=Runtime)) + geom_tile()+
  scale_fill_gradient(low = 'green', high = "red")+ ggtitle("Runtime different models regarding observations")+
  theme(legend.position='bottom')+xlab("Number of observations in training set")+ylab("Model")+
  #scale_fill_discrete(name="Runtime in seconds")
  labs(fill='Runtime in seconds') 

n_runtime_plot

mse_d
