if(!require(gtrendsR)) {
  install.packages("gtrendsR")
}
library(gtrendsR)

if(!require(tidyverse)) {
  install.packages("tidyverse")
}
library(tidyverse)

getGoogleTrendData <- function(keyword, fromDate = Sys.Date() - 365, toDate = Sys.Date()) {
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
