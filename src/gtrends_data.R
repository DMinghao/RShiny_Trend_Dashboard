if(!require(gtrendsR)) {
  install.packages("gtrendsR")
}

if (!require(tidyverse)) {
  install.packages("tidyverse")
}

if (!require(ggplot2)) {
  install.packages("ggplot2")
}

if (!require(plotly)) {
  install.packages("plotly")
}

if (!require(maps)) {
  install.packages("maps")
}

if (!require(mapdeck)) {
  install.packages("mapdeck")
}

if (!require(geojsonsf)) {
  install.packages("geojsonsf")
}

library(gtrendsR)
library(tidyverse)
library(ggplot2)
library(plotly)
library(maps)
library(mapdeck)
library(geojsonsf)
library(sf)

getGoogleTrendData <- function(keyword,
                               fromDate = Sys.Date() - 365,
                               toDate = Sys.Date()) {
  if (length(keyword) > 1 | fromDate >= toDate) {
    return(NULL)
  }
  
  
  gtrends(
    keyword = keyword,
    geo = "US",
    time = paste(fromDate, toDate, sep = " "),
    gprop = c("web", "news", "images", "froogle", "youtube"),
    category = 0,
    hl = "en-US",
    low_search_volume = FALSE,
    cookie_url = "http://trends.google.com/Cookies/NID",
    tz = 0,
    onlyInterest = FALSE
  )
}


data <- getGoogleTrendData("trump")

glimpse(data$interest_over_time)

glimpse(data$interest_by_country)
glimpse(data$interest_by_region)
glimpse(data$interest_by_dma)
glimpse(data$interest_by_city)
glimpse(data$related_topics)
glimpse(data$related_queries)

p <- ggplot(data$interest_over_time) +
  geom_line(aes(x = date, y = hits))

p %>%
  ggplotly()

state <- map_data("state")

data$interest_by_region %>%
  mutate(region = tolower(location)) %>%
  filter(region %in% state$region) %>%
  select(region, hits) -> my_df

ggplot(my_df) +
  geom_map(data = state,
           map = state,
           aes(x = long, y = lat, map_id = region))+
  geom_map(data = my_df,
           map = state,
           aes(fill = hits, map_id = region))

readRenviron("./.Renviron")
mapbox_token <- Sys.getenv("mapbox_token")
set_token(mapbox_token)

sf <- geojson_sf("./www/us-states.json")

new_sf <- sf %>%
  merge(
    data$interest_by_region %>% select(c(location, hits)),
    by.x = 'name',
    by.y = 'location',
    all = TRUE
  ) %>%
  select(-c(density)) %>%
  mutate(hits_scale = hits * 10) %>%
  mutate(info = paste("<b>", name, " - ", hits, "</b><br>")) %>%
  st_as_sf()


mapdeck(
  style = mapdeck_style('dark'),
  pitch = 45
) %>%
  add_polygon(
    data = new_sf,
    fill_colour = "hits",
    elevation_scale = 1000,
    elevation = "hits_scale",
    tooltip = "info",
    legend = TRUE,
    legend_format = list(fill_colour = as.integer)
  )


```{r}
data <- getGoogleTrendData("Ariana Grande")

glimpse(data$interest_over_time)
glimpse(data$interest_by_country)
glimpse(data$interest_by_region)
glimpse(data$interest_by_dma)
glimpse(data$interest_by_city)
glimpse(data$related_topics)
glimpse(data$related_queries)

p <- ggplot(data$interest_over_time) +
  geom_line(aes(x = date, y = hits))

p %>%
  ggplotly()

state <- map_data("state")

data$interest_by_region %>%
  mutate(region = tolower(location)) %>%
  filter(region %in% state$region) %>%
  select(region, hits) -> my_df

ggplot(my_df) +
  geom_map(data = state,
           map = state,
           aes(x = long, y = lat, map_id = region))+
  geom_map(data = my_df,
           map = state,
           aes(fill = hits, map_id = region))

readRenviron("./.Renviron")
mapbox_token <- Sys.getenv("mapbox_token")
set_token(mapbox_token)

sf <- geojson_sf("./www/us-states.json")

new_sf <- sf %>%
  merge(
    data$interest_by_region %>% select(c(location, hits)),
    by.x = 'name',
    by.y = 'location',
    all = TRUE
  ) %>%
  select(-c(density)) %>%
  mutate(hits_scale = hits * 10) %>%
  mutate(info = paste("<b>", name, " - ", hits, "</b><br>")) %>%
  st_as_sf()


mapdeck(
  style = mapdeck_style('dark'),
  pitch = 45
) %>%
  add_polygon(
    data = new_sf,
    fill_colour = "hits",
    elevation_scale = 1000,
    elevation = "hits_scale",
    tooltip = "info",
    legend = TRUE,
    legend_format = list(fill_colour = as.integer)
  )

```


```{r}
data <- getGoogleTrendData("World Cup")

glimpse(data$interest_over_time)
glimpse(data$interest_by_country)
glimpse(data$interest_by_region)
glimpse(data$interest_by_dma)
glimpse(data$interest_by_city)
glimpse(data$related_topics)
glimpse(data$related_queries)

p <- ggplot(data$interest_over_time) +
  geom_line(aes(x = date, y = hits))

p %>%
  ggplotly()

country <- map_data("state")

data$interest_by_region %>%
  mutate(region = tolower(location)) %>%
  filter(region %in% state$region) %>%
  select(region, hits) -> my_df

ggplot(my_df) +
  geom_map(data = state,
           map = state,
           aes(x = long, y = lat, map_id = region))+
  geom_map(data = my_df,
           map = state,
           aes(fill = hits, map_id = region))

readRenviron("./.Renviron")
mapbox_token <- Sys.getenv("mapbox_token")
set_token(mapbox_token)

sf <- geojson_sf("./www/us-states.json")

new_sf <- sf %>%
  merge(
    data$interest_by_region %>% select(c(location, hits)),
    by.x = 'name',
    by.y = 'location',
    all = TRUE
  ) %>%
  select(-c(density)) %>%
  mutate(hits_scale = hits * 10) %>%
  mutate(info = paste("<b>", name, " - ", hits, "</b><br>")) %>%
  st_as_sf()


mapdeck(
  style = mapdeck_style('dark'),
  pitch = 45
) %>%
  add_polygon(
    data = new_sf,
    fill_colour = "hits",
    elevation_scale = 1000,
    elevation = "hits_scale",
    tooltip = "info",
    legend = TRUE,
    legend_format = list(fill_colour = as.integer)
  )

```




