

append_to_package = function(package_name, date, df){
  
  p_dir = file.path(rimpacts_root, 'cran', package_name)
  
  #if package dir doesn't exist, create outline
  if(!file.exists(p_dir)){
    dir.create(p_dir, recursive=TRUE)
  }

  
  #write all dl file
  all_file = file.path(p_dir, paste0('all_', package_name, '.csv.gz'))
  write_append_csv(all_file, df)
  
  
  #Write daily file
  dl_file = file.path(p_dir, paste0('daily_', package_name, '.csv.gz'))
  dl_count = nrow(df)
  
  #write summary stats
  write_append_csv(dl_file, data.frame(date=as.character(date), downloads=dl_count))
  
  
  #write new SVG
  
  #write new graphs
  #graph_file = file.path(p_dir, 'package_graph.png')
  #ts_data = dl_rec
  #ts_data$date = as.Date(ts_data$date)
  #png(graph_file)
  #plot(ts_data$date, ts_data$V1, ylab='Downloads', xlab='', type='l')
  #dev.off()
}


write_append_csv = function(fname, df){
  
  if(file.exists(fname)){
    dl_rec = read.csv(gzfile(fname), header=TRUE, as.is=TRUE)
    dl_rec = rbind(dl_rec, df)
    write.csv(dl_rec, gzfile(fname), row.names=FALSE, col.names=TRUE)
    
  }else{
    write.csv(df, gzfile(fname), row.names=FALSE, col.names=TRUE)
  }
}

