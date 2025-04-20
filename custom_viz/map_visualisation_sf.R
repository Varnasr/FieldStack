# Spatial visualization using sf and ggplot2
library(sf)
library(ggplot2)

# Example: Load sample shapefile (replace with your own)
nc <- st_read(system.file("shape/nc.shp", package="sf"))

ggplot(nc) +
  geom_sf(fill = "lightblue", color = "white") +
  theme_minimal() +
  labs(title = "Sample Map of North Carolina Counties")
