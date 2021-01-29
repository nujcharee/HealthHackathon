library(geogrid)
library(tidyverse)
library(sf)
library(tmap)

url = "https://opendata.arcgis.com/datasets/f341dcfd94284d58aba0a84daf2199e9_2.geojson"

original_shapes <- st_read(url) %>% st_set_crs(27700)


nycc = filter(original_shapes, grepl('Hambleton|Harrogate|Selby|Ryedale|Craven|Scarborough|Richmondshire', msoa01nmw))

nycc$msoa01nmw = as.character(nycc$msoa01nmw)


# input_file <- system.file("extdata", "london_LA.json", package = "geogrid")
# original <- st_read(input_file) %>% st_set_crs(27700)

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}


nycc$SNAME = paste(substr(nycc$msoa01nmw, 1, 3), substrRight(nycc$msoa01nmw, 3))


# function to strip last 3 characters




original_shapes

rawplot <- tm_shape(nycc) +
  tm_polygons("st_areashape", palette = "viridis") 
rawplot

rawplot <- tm_shape(original) + 
  tm_polygons("HECTARES", palette = "viridis") 
rawplot

par(mfrow = c(2, 3), mar = c(0, 0, 2, 0))
for (i in 1:6) {
  new_cells <- calculate_grid(shape = nycc, grid_type = "hexagonal", seed = i)
  plot(new_cells, main = paste("Seed", i, sep = " "))
}


par(mfrow = c(2, 3), mar = c(0, 0, 2, 0))
for (i in 1:6) {
  new_cells <- calculate_grid(shape = nycc, grid_type = "regular", seed = i)
  plot(new_cells, main = paste("Seed", i, sep = " ")) 
}


new_cells_hex <- calculate_grid(shape = nycc, grid_type = "hexagonal", seed = 3)
resulthex <- assign_polygons(nycc, new_cells_hex)


hexplot <- tm_shape(resulthex) + 
  tm_polygons("st_areashape", palette = "white") 
hexplot


new_cells <- calculate_grid(shape = nycc, grid_type = "hexagonal", seed = 3)
plot(new_cells, main = paste("Seed", i, sep = " "))



