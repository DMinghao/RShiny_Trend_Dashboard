if(!require(twitteR)){install.packages("twitteR")}
if(!require(tm)){install.packages("tm")}
if(!require(syuzhet)){install.packages("syuzhet")}
library(twitteR)
if(!require(openssl)){install.packages("openssl")}
if(!require(httpuv)){install.packages("httpuv")}
library(tidyverse)
if(!require(tm)){install.packages("tm")}
library(tm)
if(!require(plotly)){install.packages("plotly")}
library(plotly)

readRenviron("./.Renviron")
consumer_key <- Sys.getenv("twitter_consumer_key")
consumer_secret <- Sys.getenv("twitter_consumer_secret")
access_token <- Sys.getenv("twitter_access_token")
access_secret <- Sys.getenv("twitter_access_secret")
# Connect to twitter
setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)
# Keywords
data <- searchTwitter ('SNH48', n=10000)
d <-data %>% strip_retweets %>% twListToDF()
# tdm/dtm
df <- data.frame(V1 = d, stringsAsFactors = FALSE)
names(df)[8] <- "doc_id"
names(df)[1] <- "text"
names(df)
mycorpus <- Corpus(DataframeSource(df))
tdm <- TermDocumentMatrix(mycorpus, control = list(removePunctuation = TRUE, stopwords = TRUE))
inspect(tdm)

# Function
getTwitterData <- function(keyword, fromDate = Sys.Date() - 365, toDate = Sys.Date()) {
  if (length(keyword) > 1 | fromDate >= toDate) {
    return(NULL)
  }
  length <- toDate - fromDate 
  twetPerDay <- 1000
  
  outputDF <- data_frame()
  
  for(i in 1:length){
    currDate <- fromDate + i
    outputDF <<- outputDF %>% rbind(
      searchTwitter(
        keyword,
        n = twetPerDay,
        lang = "en",
        since = currDate %>% format("%Y-%m-%d"),
        until = currDate %>% format("%Y-%m-%d"),
        locale = NULL,
        geocode = NULL,
        sinceID = NULL,
        maxID = NULL,
        resultType = NULL,
        retryOnRateLimit = 120
      )%>% strip_retweets %>% twListToDF()
    )
  }
  
  outputDF
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
rkt <- rkt %>% mutate(text = gsub('http\\S+\\s*', "", text))

wordcloud2(rkt, size = 2 ,shape = 'star')
wordcloud2(rkt, size = 2, minRotation = -pi/2, maxRotation = -pi/2)
wordcloud2(rkt, size = 2, 
           color = "random-light", backgroundColor = "grey")
## Graph Hour
library(ggplot2)
library(lubridate)
d$created = ymd_hms(d$created,tz = 'Asia/Jakarta')
d$date = date(d$created)
d$week = week(d$created)
d$hour = hour(d$created)
d$month = month(d$created)

# d.date1 = subset(x = d,date == '2021-07-11')
# d.week1 = subset(x = d,week == '27')
# d.month1 = subset(x = d, month == '7')
d.day.week1 = data.frame(table(d$date))
colnames(d.day.week1)[1] <- "Days"
colnames(d.day.week1)[2] <- "Total.Tweets"
d.week.month1 = data.frame(table(d$week))
colnames(d.week.month1)[1] <- "Weeks"
colnames(d.week.month1)[2] <- "Total.Tweets"
d.hour.date1 = data.frame(table(d$hour))
colnames(d.hour.date1) = c('Hour','Total.Tweets')

p <- ggplot(d.hour.date1)+
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
p %>% ggplotly()

## week
t<-ggplot(d.day.week1)+
  geom_bar(aes(x = Days,
               y = Total.Tweets,
               fill = I('blue')),
           stat = 'identity',
           alpha = 0.75,
           show.legend = FALSE)+
  geom_hline(yintercept = mean(d.day.week1$Total.Tweets),
             col = I('black'),
             size = 1)+
  geom_text(aes(fontface = 'italic',
                label = paste('Average:',
                              ceiling(mean(d.day.week1$Total.Tweets)),
                              'Tweets per Day'),
                x = 8,
                y = mean(d.day.week1$Total.Tweets)+20),
            hjust = 'left',
            size = 4)+
  labs(title = 'Total Tweets per Days ',
       subtitle = 'weeks 2021',
       caption = 'Twitter Crawling 10 - 11 July 2021')+
  xlab('Day of Week')+
  ylab('Total Tweets')+
  scale_fill_brewer(palette = 'Dark2')+
  theme_bw()
t %>% ggplotly()
## Month
o <-ggplot(d.week.month1)+
  geom_bar(aes(x = Weeks,
               y = Total.Tweets,
               fill = I('blue')),
           stat = 'identity',
           alpha = 0.75,
           show.legend = FALSE)+
  geom_hline(yintercept = mean(d.week.month1$Total.Tweets),
             col = I('black'),
             size = 1)+
  geom_text(aes(fontface = 'italic',
                label = paste('Average:',
                              ceiling(mean(d.week.month1$Total.Tweets)),
                              'Tweets per Week'),
                x = 8,
                y = mean(d.week.month1$Total.Tweets)+20),
            hjust = 'left',
            size = 4)+
  labs(title = 'Total Tweets per Week ',
       subtitle = 'Month 2021',
       caption = 'Twitter Crawling 10 - 11 July 2021')+
  xlab('Week of Month')+
  ylab('Total Tweets')+
  scale_fill_brewer(palette = 'Dark2')+
  theme_bw()
o%>%ggplotly()
## per day
d.date2 = subset(x = d,date == '2021-07-11')

d.hour.date2 = data.frame(table(d$hour))
colnames(d.hour.date2) = c('Hour','Total.Tweets')
d.hour.date3 = rbind(d.hour.date1,d.hour.date2)
d.hour.date3$Date = c(rep(x = '2021-07-11',
                             len = nrow(d.hour.date1)),
                         rep(x = '2021-07-12',
                             len = nrow(d.hour.date2)))
# d.hour.date3$Labels = c(letters, 'A','B','C','D','E','F','G','H','I','G','K','L','M','N','O','P','Q','R'
#                         ,'S','T','U','V')
d.hour.date3$Labels = c('A','B')
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

##Sentiment analysis
library(tidyverse)

tidy_tweets <- tibble(
  screen_name = data %>% map_chr(~.x$screenName),
  tweetid = data %>% map_chr(~.x$id),
  created_timestamp = seq_len(length(data)) %>% map_chr(~as.character(data[[.x]]$created)),
  is_retweet = data %>% map_chr(~.x$isRetweet),
  text = data %>% map_chr(~.x$text)
) %>%
  mutate(created_date = as.Date(created_timestamp)) %>%
  filter(is_retweet == FALSE,
         substr(text, 1,2) != "RT")


tidy_tweets
library(tidytext)

tweet_words <- tidy_tweets %>%
  select(tweetid,
         screen_name,
         text,
         created_date) %>%
  unnest_tokens(word, text)
tweet_words
stop_words  
my_stop_words <- tibble(
  word = c(
    "https",
    "t.co",
    "rt",
    "amp",
    "rstats",
    "gt"
  ),
  lexicon = "twitter"
)
all_stop_words <- stop_words %>%
  bind_rows(my_stop_words)

suppressWarnings({
  no_numbers <- tweet_words %>%
    filter(is.na(as.numeric(word)))
})

no_stop_words <- no_numbers %>%
  anti_join(all_stop_words, by = "word")

tibble(
  total_words = nrow(tweet_words),
  after_cleanup = nrow(no_stop_words)
)

top_words <- no_stop_words %>%
  group_by(word) %>%
  tally %>%
  arrange(desc(n)) %>%
  head(10)

top_words

nrc_words <- no_stop_words %>%
  inner_join(get_sentiments("nrc"), by = "word")

nrc_words 
nrc_words %>%
  group_by(sentiment) %>%
  tally %>%
  arrange(desc(n))
nrc_words %>%
  group_by(tweetid) %>%
  tally %>%
  ungroup %>%
  count %>%
  pull
library(ggjoy)

ggplot(nrc_words) +
  geom_joy(aes(
    x = created_date,
    y = sentiment, 
    fill = sentiment),
    rel_min_height = 0.01,
    alpha = 0.7,
    scale = 3) +
  theme_joy() +
  labs(title = "Twitter #rstats sentiment analysis",
       x = "Tweet Date",
       y = "Sentiment") + 
  scale_fill_discrete(guide=FALSE)

