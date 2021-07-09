if(!require(needs))
  install.packages("needs")
library(needs)

needs(gtrendsR, tidyverse)

keywords <- c("trump", "biden")

nWords <- length(keywords)

data <- gtrends(keywords)
glimpse(data$interest_over_time)
glimpse(data$interest_by_country)
glimpse(data$interest_by_region)
glimpse(data$interest_by_dma)
glimpse(data$interest_by_city)
glimpse(data$related_topics)
glimpse(data$related_queries)
