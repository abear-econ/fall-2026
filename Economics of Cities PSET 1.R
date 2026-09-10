# Economics of Cities PSET 1

setwd("/Users/adambear/Downloads")

library(sf)
library(dplyr)
library(ggplot2)
library(httr)

oil_fields  <- st_read("Oil_and_Gas_Field_Administrative_Boundaries/Oil_and_Gas_Field_Administrative_Boundaries.shp",
                       quiet = TRUE)

building_heights <- st_read("LARIAC6_Buildings_2020.gdb", layer = "LARIAC6_BUILDINGS_2020")

target_crs <- 3310 

oil_fields <- st_transform(oil_fields, target_crs)
building_heights <- st_transform(building_heights, target_crs)

building_heights <- building_heights |>
  filter(st_geometry_type(Shape) == "MULTIPOLYGON")

la_county <- st_read("County_Boundary/County_Boundary.shp", quiet = TRUE)
la_county <- st_transform(la_county, target_crs)


building_heights <- building_heights |>
  st_zm(drop = TRUE, what = "ZM") |>
  st_make_valid()

la_bbox <- st_bbox(la_county)
building_heights <- st_crop(building_heights, la_bbox)


building_heights <- st_simplify(building_heights, dTolerance = 5, preserveTopology = TRUE)

#oil_fields <- st_filter(oil_fields, la_county)
#building_heights <- st_filter(building_heights, la_county)

p <- ggplot() +
  geom_sf(data = la_county, fill = "grey96", color = "grey70", linewidth = 0.3) +
  geom_sf(data = building_heights, aes(fill = HEIGHT), color = NA) +
  scale_fill_viridis_c(name = "Building\nheight (ft)", option = "magma") +
  geom_sf(data = oil_fields, fill = "blue", alpha = 0.35, color = "darkblue", linewidth = 0.3) +
  labs(
    title = "Los Angeles County: Oil Fields and Building Heights",
    caption = "Sources: CalGEM (oil field boundaries), LA County GIS Data Portal"
  ) +
  theme_minimal() +
  theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())

