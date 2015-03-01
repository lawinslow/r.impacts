

db_location = "C:/rimpacts/cran_usage.db"
rimpacts_root = 'C:/rimpacts'

conn = dbConnect(RSQLite::SQLite(), db_location, cache_size=-5e5)

dbListFields(conn, 'cran_usage')

#dbGetQuery(conn, 'CREATE INDEX package_indx ON cran_usage(package);')

packages = dbGetQuery(conn, 'SELECT DISTINCT package FROM cran_usage')$package
cran_packages = available.packages()[,'Package']

packages = packages[packages%in%cran_packages]

package_totals = data.frame(package=packages)
package_totals$total = NA

all_package_ts = data.frame()
#packages = c('rLakeAnalyzer', 'plyr', 'RLadyBug')

for(i in 1:length(packages)){
  ptm <- proc.time()
  package_name = packages[i]
  
  p_dir = file.path(rimpacts_root, 'cran', package_name)
  
  #if package dir doesn't exist, create outline
  if(!file.exists(p_dir)){
    dir.create(p_dir, recursive=TRUE)
  }
  
  #write all dl file
  res = dbGetQuery(conn, paste0('SELECT * FROM cran_usage WHERE package=\'', 
                                packages[i], '\''))
  
  daily_res = ddply(res, 'date', function(df){nrow(df)})
  
  all_file = file.path(p_dir, paste0('all_', package_name, '.csv.gz'))
  dl_file = file.path(p_dir, paste0('daily_', package_name, '.csv.gz'))
  
  write.csv(res, gzfile(all_file), row.names=FALSE, append=FALSE)
  
  write.csv(daily_res, gzfile(dl_file), row.names=FALSE, append=FALSE)
  
  daily_res$package = package_name
  all_package_ts = rbind(all_package_ts, daily_res)
  
  package_totals$total[i] = nrow(res)
  
  cat('Date:', packages[i], '\n')
  cat(proc.time() - ptm, '\n')
}

totals_path = file.path(rimpacts_root, 'pacakge_totals.csv')
write.csv(package_totals, totals_path, row.names=FALSE)

total = sum(package_totals$total)

#total = dbGetQuery(conn, 'SELECT count(*) FROM cran_usage')

dbDisconnect(conn)