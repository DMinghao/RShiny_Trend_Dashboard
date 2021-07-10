if(!require(RedditExtractoR)) {
  install.packages("RedditExtractoR")
}
library(RedditExtractoR)

getRedditData <- function(keyword) {
  if (length(keyword) > 1) {
    return(NULL)
  }
  
  get_reddit(
    search_terms = keyword,
    regex_filter = "",
    subreddit = NA,
    cn_threshold = 1,
    page_threshold = 1,
    sort_by = "comments",
    wait_time = 0
  )
}


data <- getRedditData("trump")

glimpse(data)

newData <- data %>% 
  select(c(id, comment_score, controversiality, comment, title)) %>% 
  arrange(comment_score)

newData %>% glimpse()

data %>% 
  filter(structure == 1)

v <- newData$comment %>%
  VectorSource %>%
  Corpus %>%
  TermDocumentMatrix %>%
  as.matrix %>%
  rowSums  %>%
  sort(decreasing = TRUE)
d <- data.frame(word = names(v),
                freq = v,
                stringsAsFactors = FALSE)
glimpse(d)
