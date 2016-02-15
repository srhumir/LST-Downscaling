NDVISPOT <- raster(file.choose())
MODIS <- raster(file.choose())
MODISC <- crop(MODIS, NDVISPOT, filename = "NDVIMODIS960area.tif")
writeRaster(MODISC, filename = "LSTMODISarea.tif")
