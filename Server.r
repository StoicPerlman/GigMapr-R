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

getCountryMap <- function (search){
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
  
  # get center of states for text position
  cnames <- data.frame(state.name, state.center)
  colnames(cnames) = c('region','long','lat')
  cnames$region = tolower(cnames$region)
  cnames <- merge(cnames, jobs, by="region")
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

getCloud <- function (text) {
  corpus <- Corpus(VectorSource(text))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  
  cloud <- TermDocumentMatrix(corpus)
  cloud <- as.matrix(cloud)
  cloud <- sort(rowSums(cloud),decreasing=TRUE)
  cloud <- data.frame(word = names(cloud), count=cloud,
                        row.names = seq_along(cloud), stringsAsFactors = FALSE)
  
  if ('csharp' %in% cloud$word) {
    cloud[cloud$word == 'csharp',]$word = 'c#'
  }
  
  return(wordcloud(cloud$word[1:75], cloud$count[1:75], colors = brewer.pal(8,'Dark2')))
}

getStateMap <- function(jobs, state) {
  state = 'PA'
  x = data.frame(jobs,stringsAsFactors = FALSE)
  
  cities = c()
  openFor = c()
  datePosted = c()
  fullLocation = c()
  company = c()
  src = c()
  states = c()
  jobkeys = c()
  lats = c()
  longs = c()
  ittr = 0
  for (i in x){
    openFor[ittr] = i[1]
    cities[ittr] = i[2]
    datePosted[ittr] = i[3]
    fullLocation[ittr] = i[4]
    company[ittr] = i[5] 
    src[ittr] = i[6]
    states[ittr] = i[7]
    jobkeys[ittr] = i[8]
    lats[ittr] = mean(zipcode[zipcode$city == i[2] & zipcode$state == i[7],]$latitude)
    longs[ittr] = mean(zipcode[zipcode$city == i[2] & zipcode$state == i[7],]$longitude)
    ittr = ittr + 1
  }
  jobs = data.frame(jobkey=jobkeys, company=company, city=cities, state=states, location=fullLocation, 
                    open_for=openFor, date_poste=datePosted, sorce=src, lat=lats, long=longs)
  
  points <- data.frame(ddply(data.frame(lat=lats, long=longs), .(lat, long), summarise, 
                             count = length(long)))
  points <- points[!is.nan(points$lat),]
  
  states = data.frame(short = state.abb, full = tolower(state.name), stringsAsFactors = FALSE)
  
  state_info <- map_data("state", region = states$full[states$short == state])
  
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


#getCountryMap('Project Manager')
jobs <- getStateInfo('C#','PA')
#getCloud(jobs$text)
getStateMap(jobs$jobs, 'PA')
