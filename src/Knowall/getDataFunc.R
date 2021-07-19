if(!require(twitteR)) {
  install.packages("twitteR")
}
if (!require(gtrendsR)) {
  install.packages("gtrendsR")
}
if (!require(RedditExtractoR)) {
  install.packages("RedditExtractoR")
}
if (!require(mapdeck)) {
  install.packages("mapdeck")
}


readRenviron("./.Renviron")
consumer_key <- Sys.getenv("twitter_consumer_key")
consumer_secret <- Sys.getenv("twitter_consumer_secret")
access_token <- Sys.getenv("twitter_access_token")
access_secret <- Sys.getenv("twitter_access_secret")
mapbox_token <- Sys.getenv("mapbox_token")
set_token(mapbox_token)
# Connect to twitter
setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)


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

getRedditData <- function(keyword,
                          subreddit = NA,
                          sort_by = "comments") {
  if (length(keyword) > 1) {
    return(NULL)
  }
  
  page_threshold <- sort_by %>%
    switch ("new" = 3,
            "comments" = 1,
            "relevance" = 1)
  
  get_reddit(
    search_terms = keyword,
    regex_filter = "",
    subreddit = subreddit,
    cn_threshold = 0,
    page_threshold = page_threshold,
    sort_by = sort_by
  ) %>%
    mutate(post_date = as.Date(post_date, "%d-%m-%y")) %>%
    mutate(comm_date = as.Date(comm_date, "%d-%m-%y")) %>%
    mutate(subreddit = as.factor(subreddit)) %>%
    mutate(uniqueID = row_number()) %>%
    as_tibble()
}

getTwitterData <- function(keyword,
                           fromDate = Sys.Date() - 365,
                           toDate = Sys.Date(), n = 2000) {
  if (length(keyword) > 1 | fromDate >= toDate) {
    return(NULL)
  }
  
  outputDF <- searchTwitter(
    keyword,
    n = n,
    lang = "en",
    since = fromDate %>% format("%Y-%m-%d"),
    until = toDate %>% format("%Y-%m-%d"),
    locale = NULL,
    geocode = NULL,
    sinceID = NULL,
    maxID = NULL,
    resultType = NULL,
    retryOnRateLimit = 120
  ) %>% strip_retweets() %>% twListToDF()
  
  outputDF
}

