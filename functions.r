library(rPython)
library(ggplot2)
library(maps)
library(ggmap)
library(zipcode)
library(tm)
library(wordcloud)
library(plyr)
data(zipcode)

python.load('./IndeedAPICalls.py')

getCountryInfo <- function(search) {
  jobs<-python.call('GetEachStateCount', search)

  jobs <- data.frame(region = names(jobs), count=jobs,
                     row.names = seq_along(jobs), stringsAsFactors = FALSE)

  all_states <- map_data("state")
  all_states <- subset(all_states, region!='district of columbia' )

  map_info <- merge(all_states, jobs, by="region")

  # reorder by count
  map_info <- data.frame(map_info[order(map_info$count, map_info$group),],
                         row.names = seq_along(map_info$count))
  # set color scheme by state
  itter <- 1
  regions <- map_info[!duplicated(map_info$region),]$region
  for (i in regions){
    map_info$color[map_info$region == i] = itter
    itter <- itter + 1
  }
  return(map_info)
}

getCountryStats <- function(map_info) {
  m <- mean(map_info$count)
  s <- sd(map_info$count)
  r <- unique(map_info[map_info$count %in% range(map_info$count),c('region','count')])
  m <- paste('Mean:', m)
  s <- paste('SDev:', s)
  min <- paste(r[r$count == min(r$count),1], '-', r[r$count == min(r$count),2])
  max = paste(r[r$count == max(r$count),1] , '-', r[r$count == max(r$count),2])
  r <- paste('Range:', min, 'to', max)
  return(paste(m,s,r,sep='<br />'))
}

getCountryMap <- function (map_info){
  # get center of states for text position
  cnames <- data.frame(state.name, state.center)
  colnames(cnames) = c('region','long','lat')
  cnames$region = tolower(cnames$region)

  # get counts from map_info merge to cnames
  counts = map_info[!duplicated(map_info$region),c('region','count')]
  cnames <- merge(cnames, counts, by="region")
  cnames <- subset(cnames, region!='alaska' )
  cnames <- subset(cnames, region!='hawaii' )
  # edit RI cuz its small
  cnames$lat[cnames$region=='rhode island'] = 41

  map <- ggplot(map_info, aes(x=long, y=lat, group=group)) +
    geom_polygon(aes(fill=color), colour = "black", size = 0.2)  +
    geom_text(data = cnames, aes(x = long, y = lat, label = count), size=5,inherit.aes=FALSE) +
    theme_bw() +
    theme(legend.position = "", text = element_blank(), line = element_blank()) +
    scale_fill_continuous(low="yellow", high="red")

  return(map)
}

getStateInfo <- function (search, state) {
  return(python.call('GetListings', search, state))
}

getStateStats <- function(jobs) {
  jobs = as.data.frame(t(data.frame(jobs, stringsAsFactors = F)))
  row.names(jobs) = NULL

  # clean dates and convert to age from today
  jobs$date <- lapply(jobs$date, strptime, format="%a, %d %b %Y %H:%M:%S")
  dateNow <- as.Date(Sys.Date())
  jobs$date <-lapply(jobs$date, difftime, time2 = dateNow, units = 'days')
  jobs$date <-lapply(jobs$date, abs)
  jobs$date <- as.numeric(jobs$date)

  m <- mean(jobs$date)
  s <- sd(jobs$date)
  r <- unique(jobs$date)
  m <- paste('Mean Post Age:', m, 'days')
  s <- paste('SDev Post Age:', s, 'days')
  r <- paste('Range Post Age:', min(jobs$date), 'to', max(jobs$date), 'days')

  c <- data.frame(ddply(data.frame(company=jobs$company), .(company), summarise,
                        count = length(company)))
  c <- head(c[order(c$count,decreasing = T),],10)
  c <- paste(c[,1], '-', c[,2])
  c <- paste(c, collapse = "<br />")
  c <- paste('<br />Top 10 Employers:<br />', c, sep='')
  return(paste(m,s,r,c,sep='<br />'))
}

getStateCloud <- function (text) {
  corpus <- Corpus(VectorSource(text))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))

  cloud <- TermDocumentMatrix(corpus)
  cloud <- as.matrix(cloud)
  cloud <- sort(rowSums(cloud),decreasing=TRUE)
  cloud <- data.frame(word = names(cloud), count=cloud,
                      row.names = seq_along(cloud), stringsAsFactors = FALSE)

  # replace # that was taken out in python
  # needed because corpus could not handle #
  if ('csharp' %in% cloud$word) {
    cloud[cloud$word == 'csharp',]$word = 'c#'
  }

  return(wordcloud(cloud$word[1:100], cloud$count[1:100],
                   colors = brewer.pal(8,'Dark2'), random.order = FALSE))
}

getStateMap <- function(jobs) {
  jobs <- as.data.frame(t(data.frame(jobs, stringsAsFactors = F)))
  row.names(jobs) = NULL

  # get average city lat and long as well as count of each city
  # this makes it so there is one big point over a city indead of a lot of small
  points <- zipcode[zipcode$state %in% jobs$state & zipcode$city %in% jobs$city,2:5]
  points = aggregate(cbind(longitude,latitude)~., points, mean)
  points = merge(jobs, points)
  points <- data.frame(ddply(data.frame(lat=points$lat, long=points$long), .(lat, long), summarise,
                             count = length(long)))
  points <- points[!is.nan(points$lat),]

  # state abbreviation to full map
  states = data.frame(short = state.abb, full = tolower(state.name), stringsAsFactors = FALSE)

  # state geographic data
  state_info <- map_data("state", region = states$full[states$short %in% jobs$state])

  map <- ggplot(state_info,aes(x=long,y=lat,group=group)) +
    geom_polygon(aes(fill='red')) +
    scale_size_continuous(range = c(2,10)) +
    geom_point(data=points, aes(x=long, y=lat), size = maxPoint(sqrt(points$count)*2, 20), colour="Green",
               fill="Green",pch=20, alpha = .8, inherit.aes=FALSE) +
    theme_bw() +
    theme(legend.position = "", text = element_blank(), line = element_blank())
  return(map)
}

maxPoint <- function(list, max) {
  list[list > max] = max
  return(list)
}