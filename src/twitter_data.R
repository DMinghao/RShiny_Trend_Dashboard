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
# Keywords
data <- searchTwitter ('snh48', n=5000)
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
# Function
getTwitterData <- function(keyword, fromDate = Sys.Date() - 365, toDate = Sys.Date()) {
  if (length(keyword) > 1 | fromDate >= toDate) {
    return(NULL)
  }
  searchTwitter(
    keyword,
    n = 500,
    lang = "en",
    since = NULL,
    until = NULL,
    locale = NULL,
    geocode = NULL,
    sinceID = NULL,
    maxID = NULL,
    resultType = NULL,
    retryOnRateLimit = 120
  )%>% strip_retweets %>% twListToDF()
}

data <- getTwitterData("snh48")

glimpse(data)
glimpse(data$text)

##### Top10/20/50 twitter
library(wordcloud2)
colors=c('red','blue','green','yellow','purple')
rankingtwitter <-d%>%
  select(c(1,3))
rkt<-rankingtwitter %>% arrange(desc(favoriteCount))
wordcloud2(rkt, size = 2 ,shape = 'star')
wordcloud2(rkt, size = 2, minRotation = -pi/2, maxRotation = -pi/2)
wordcloud2(rkt, size = 2, 
           color = "random-light", backgroundColor = "grey")
## Graph
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
                label = paste('Average:',
                              ceiling(mean(d.hour.date1$Total.Tweets)),
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
## per day
d.date2 = subset(x = d,date == '2021-07-10')

d.hour.date2 = data.frame(table(d$hour))
colnames(d.hour.date2) = c('Hour','Total.Tweets')
d.hour.date3 = rbind(d.hour.date1,d.hour.date2)
d.hour.date3$Date = c(rep(x = '2021-07-10',
                             len = nrow(d.hour.date1)),
                         rep(x = '2021-07-11',
                             len = nrow(d.hour.date2)))
d.hour.date3$Labels = c(letters,'A','B','C','D','E','F','G','H','I','G','K','L','M','N','O','P','Q','R'
                        ,'S','T','U','V')
d.hour.date3$Hour = as.character(d.hour.date3$Hour)
d.hour.date3$Hour = as.numeric(d.hour.date3$Hour)

for (i in 1:nrow(d.hour.date3)) {
  if (i%%2 == 0) {
    d.hour.date3[i,'Hour'] = ''
  }
  if (i%%2 == 1) {
    d.hour.date3[i,'Hour'] = d.hour.date3[i,'Hour']
  }
}
d.hour.date3$Hour = as.factor(d.hour.date3$Hour)

ggplot(d.hour.date3)+
  geom_bar(aes(x = Labels,
               y = Total.Tweets,
               fill = Date),
           stat = 'identity',
           alpha = 0.75,
           show.legend = TRUE)+
  geom_hline(yintercept = mean(d.hour.date3$Total.Tweets),
             col = I('black'),
             size = 1)+
  geom_text(aes(fontface = 'italic',
                label = paste('Average:',
                              ceiling(mean(d.hour.date3$Total.Tweets)),
                              'Tweets per hour'),
                x = 5,
                y = mean(d.hour.date3$Total.Tweets)+6),
            hjust = 'left',
            size = 3.8)+
  scale_x_discrete(limits = d.hour.date3$Labels,
                   labels = d.hour.date3$Hour)+
  labs(title = 'Total Tweets per Hours',
       subtitle = '10 - 11 July 2021',
       caption = 'Twitter Crawling 10 - 11 July 2021')+
  xlab('Time of Day')+
  ylab('Total Tweets')+
  ylim(c(0,100))+
  theme_bw()+
  theme(legend.position = 'bottom',
        legend.title = element_blank())+
  scale_fill_brewer(palette = 'Dark2')
