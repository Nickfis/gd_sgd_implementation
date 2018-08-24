# gd_sgd_implementation

This applied part was part of the fourth problem set from the Machine Learning Course in the Data Science Master at BGSE. 

Using self-generated training data, three models are used in order to explain the variance in the response $Y$. As goodness-of-fit value the MSE is used.
We look at the ordinary least squares solution to the regression problem and then look at the gradient descent and stochastic gradient descent algorithm. 
Here it is also important to look at the running time of the different algorithms.
Expected is that the SGD has the shortest running time, but will probably show an unstable MSE with a lower amount of training samples. 
OLS should do better as long as the design matrix is relatively small, while gradient descent should be the better option as soon as the dimensions grow. 