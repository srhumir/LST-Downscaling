# LST-Downscaling
We would like to downscale the LST acquired using MODIS to the resolution of SPOT. This method can be used for LST downscaling of other sensors too.

This work is based on
V.M. Bindhu, B. Narasimhan1, K.P. Sudheer, Development and verification of a non-linear disaggregation method (NL-DisTrad) to downscale MODIS land surface temperature to the spatial scale of Landsat thermal data to estimate evapotranspiration, Remote Sensing of Environment, 135, August 2013, pp 118-129.
- 

We do this based on NDVI. Pracctically we will convert NDVI to LST. This job is done in several steps.

1. Find a linear relationship between NDVI and LST of MODIS hust using "hot edge" pixels.
2. Using all pixels compute residuals of this linear model comparing actual LST.
3. Make a table consisting of NDVI of every pixel and its surronding pixels plus residual of that special pixel.
4. Make and train a Neural network with the table of the previous step which get the NDVI of a pixel and its surronding and estimate its residual. This will be used to develope the result of the linear model.
5. Find another linear model which convert NDVI of SPOT to NDVI of MODIS
6. Finally use all the steps above of the high resolution SPOT NDVI. Get the NDVI value of a pixel and its surrondings. Convert them to MODIS NDVI. COnvert the NDVI to LST using the linear model. Then compute the residual using the Neurak network and add it to the computed LST. 

##Files
The files mainley contain functions doing steps above. main.R uses the functions to do the job.
- polynomial.R Compute linear model between NDVI and LST.
- residulas.R Compute LST residuals based on the above model.
- forNN.R Prepare a data.table of NDVI and residuals to make neura network based on it.
- NeuralNetwork.R Design, train and test a neural network to get NDVI of nine pixels and estimate the residual.
- Spot2Modis.R Prepare a linear model to convert SPOT NDVI to MODIS NDVI
- convert.R Get 9 SPOT NDVI values. Assuming that the 5th one is for the pixe and others are for its surrondings. Convert it to LST by the linear model and enhance it by the residual which can be computed using the neural network.
- main.R Input the data. Run the functions in order with suitable data. Finally uses a focal on the high resolution SPOT NDVI and convert it to LST using convert function.
- mainParallel.R does the same as main.R using all but one cores of the system.