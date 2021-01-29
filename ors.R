library(openrouteservice)
library(tidyverse)
library(leaflet)

ors_api_key("5b3ce3597851110001cf6248b92a7819ed874347b1921da6d3132be8")


home_base <- data.frame(lon =-1.264884, lat = 53.72337)

vehicles = vehicles(
  id = 1:4,
  profile = "driving-car",
  start = home_base,
  end = home_base,
  capacity = 4,
#  skills = list(c(1, 14), c(2, 14)),
  time_window = c(28800, 43200)
)


locations <- list(c(-1.264884, 53.72337),
                  c(-2.014493, 53.961901),
                  c(-1.513392, 54.129257),
                  c(-1.535855, 53.993561),
                  c(-0.789362, 54.139186),
                  c(-0.779487, 54.245909),
                  c(-1.066854, 54.245021),
                  c(-0.933439, 54.269955))

jobs = jobs(
  id = 1:8,
  service = 300,
  amount = 1,
  location = locations,
#  skills = list(1, 1, 2, 2, 14, 14,2,2,14,14,1,1,1)
)

res <- ors_optimization(jobs, vehicles, options = list(g = TRUE))


lapply(res$routes, with, {
  list(
    geometry = googlePolylines::decode(geometry)[[1L]],
    locations = lapply(steps, with, if (type=="job") location) %>%
      do.call(rbind, .) %>% data.frame %>% setNames(c("lon", "lat"))
  )
}) -> routes

## Helper function to add a list of routes and their ordered waypoints
addRoutes <- function(map, routes, colors) {
  routes <- mapply(c, routes, color = colors, SIMPLIFY = FALSE)
  f <- function (map, route) {
    with(route, {
      labels <- sprintf("<b>%s</b>", 1:nrow(locations))
      markers <- awesomeIcons(markerColor = color, text = labels, fontFamily = "arial")
      map %>%
        addPolylines(data = geometry, lng = ~lon, lat = ~lat, col = ~color) %>%
        addAwesomeMarkers(data = locations, lng = ~lon, lat = ~lat, icon = markers)
    })
  }
  Reduce(f, routes, map)
}

leaflet() %>%
  addTiles() %>%
 addAwesomeMarkers(data = home_base, icon = awesomeIcons("home")) %>%
  addRoutes(routes, c("purple", "green"))

