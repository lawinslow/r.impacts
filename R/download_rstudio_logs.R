
library(plyr)
library(RSQLite)
source('append_to_package.R')
cache.location = 'E:/BigDatasets/RStudioUsage'
rimpacts_root = 'c:/rimpacts'
db_location = "C:/rimpacts/cran_usage.db"

conn = dbConnect(RSQLite::SQLite(), db_location, cache_size=-5e5)


# Here's an easy way to get all the URLs in R

start <- as.Date('2012-11-04')
#today <- as.Date(Sys.time())
today <- as.Date('2015-02-01')

all_days <- seq(start, today, by = 'day')

year <- as.POSIXlt(all_days)$year + 1900
#urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')
# You can then use download.file to download into a directory.

# If you only want to download the files you don't have, try:
#missing_days <- setdiff(all_days, tools::file_path_sans_ext(dir(), TRUE))

dat = data.frame()
#all.dat = data.frame()
overall.count = data.frame(day=all_days, count=NA)

for (i in 1:length(all_days)){
  ptm <- proc.time()
	#source url and file destination
	url = paste0('http://cran-logs.rstudio.com/', year[i], '/', all_days[i], '.csv.gz')
  file.loc <- file.path(cache.location, paste0(all_days[i], '.csv.gz'))
	
	if(!file.exists(file.loc)){
  	out = try(download.file(url, file.loc, method="internal"), silent=TRUE)
  	if(out!=0)next
	}
  
  tmp = read.csv(gzfile(file.loc), header=TRUE, as.is=TRUE)
	#all.dat = rbind(all.dat, tmp)
  tmp = tmp[!is.na(tmp$date),]
  tmp = tmp[!is.na(tmp$package),]
  tmp$ip_id = NULL
  
  dbWriteTable(conn, "cran_usage", tmp, append=TRUE)

	
  #upkg = unique(tmp$package)
  
  #append_to_package('rLakeAnalyzer', 
  #                  all_days[i], tmp[tmp$package == 'rLakeAnalyzer',])
  #append_to_package('plyr', 
  #                  all_days[i], tmp[tmp$package == 'plyr',])
  #append_to_package('RLadyBug', 
  #                  all_days[i], tmp[tmp$package == 'RLadyBug',])

  
  #for(j in 1:length(upkg)){
  #  append_to_package(upkg[j], 
  #                    all_days[i], tmp[tmp$package == upkg[j],])
  #}
  

	overall.count$count[i] = nrow(tmp)
  #unlink(file.loc)
  cat('Date:', all_days[i], '\n')
  cat(proc.time() - ptm, '\n')
}

dbDisconnect(conn)

dat = dat[!is.na(dat$date), ]

#Join old data with the new data

dat = unique(rbind(dat, past.data))
dat = dat[order(dat$date),]

write.csv(dat, 'rLakeAnalyzer.stats.csv')



dat$day = as.POSIXct(trunc(as.POSIXct(dat$date), units='days'))
dat$week = floor(as.POSIXlt(dat$date)$yday/7)
dat$year = as.POSIXlt(dat$date)$year + 1900

library(plyr)

tmp = ddply(dat[dat$package == 'rLakeAnalyzer', ], c('day'), function(dt)nrow(dt))
plot(tmp, type='o')

tmp = ddply(dat[dat$package == 'rLakeAnalyzer', ], c('year','week'), function(df)nrow(df))
plot(tmp$V1, type='o')

