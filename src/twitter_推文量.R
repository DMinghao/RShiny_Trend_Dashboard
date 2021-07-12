if(!require(twitteR)){install.packages("twitteR")}
if(!require(tm)){install.packages("tm")}
if(!require(syuzhet)){install.packages("syuzhet")}
library(twitteR)
if(!require(openssl)){install.packages("openssl")}
if(!require(httpuv)){install.packages("httpuv")}
library(tidyverse)
if(!require(tm)){install.packages("tm")}
library(tm)

readRenviron("./.Renviron")
consumer_key <- Sys.getenv("twitter_consumer_key")
consumer_secret <- Sys.getenv("twitter_consumer_secret")
access_token <- Sys.getenv("twitter_access_token")
access_secret <- Sys.getenv("twitter_access_secret")
# Connect to twitter
setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)

# Function
getTwitterData <- function(keyword, fromDate = Sys.Date() - 365, toDate = Sys.Date(), n = 500) {
  if (length(keyword) > 1 | fromDate >= toDate) {
    return(NULL)
  }
  searchTwitter(
    keyword,
    n = n,
    lang = "en",
    since = fromDate,
    until = toDate,
    locale = NULL,
    geocode = NULL,
    sinceID = NULL,
    maxID = NULL,
    resultType = NULL,
    retryOnRateLimit = 120
  )%>% strip_retweets %>% twListToDF()
}

data <- getTwitterData("trump")

glimpse(data)

# Keywords
data <- searchTwitter ('SNH48', n=5000)
d <-data %>% strip_retweets %>% twListToDF()
# tdm/dtm
df <- data.frame(V1 = d, stringsAsFactors = FALSE)
names(df)[8] <- "doc_id"
names(df)[1] <- "text"
names(df)
mycorpus <- Corpus(DataframeSource(df))
tdm <- TermDocumentMatrix(mycorpus, control = list(removePunctuation = TRUE, stopwords = TRUE))
inspect(tdm)
dtm <-DocumentTermMatrix(mycorpus,control = list(weighting = function(x) weightTfIdf(x,normalize = FALSE),stopwords = TRUE))
inspect(dtm)
dtm$dimnames
as.matrix(dtm$dimnames)


#twitter ?????????
library(ggplot2)
library(lubridate)
d$created = ymd_hms(d$created,tz = 'Asia/Jakarta')
d$date = date(d$created)
d$hour = hour(d$created)

d.date1 = subset(x = d,date == '2021-07-11')

d.hour.date1 = data.frame(table(d$hour))
colnames(d.hour.date1) = c('Hour','Total.Tweets')

ggplot(d.hour.date1)+
  geom_bar(aes(x = Hour,
               y = Total.Tweets,
               fill = I('blue')),
           stat = 'identity',
           alpha = 0.75,
           show.legend = FALSE)+
  geom_hline(yintercept = mean(d.hour.date1$Total.Tweets),
             col = I('black'),
             size = 1)+
  geom_text(aes(fontface = 'italic',
                label = paste('Average:', ceiling(mean(d.hour.date1$Total.Tweets)),
                              'Tweets per hour'),
                x = 8,
                y = mean(d.hour.date1$Total.Tweets)+20),
            hjust = 'left',
            size = 4)+
  labs(title = 'Total Tweets per Hours ',
       subtitle = '11 July 2021',
       caption = 'Twitter Crawling 10 - 11 July 2021')+
  xlab('Time of Day')+
  ylab('Total Tweets')+
  scale_fill_brewer(palette = 'Dark2')+
  theme_bw()

#????????????



