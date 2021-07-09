if(!require(needs))
  install.packages("needs")
library(needs)

needs(RedditExtractoR, tidyverse)

keywords <- "trump"
subreddit <- NA

links <- reddit_urls(
  search_terms = keywords,
  regex_filter = "",
  subreddit = NA,
  cn_threshold = 0,
  page_threshold = 1,
  sort_by = "relevance",
  wait_time = 2
)

allContent <- list()

for (i in 1:length(links$URL)){
  allContent[[i]] <- reddit_content(links$URL[i])
}
glimpse(allContent)

# construct_graph(allContent[[3]])
# user_network(allContent[[3]])$plot
