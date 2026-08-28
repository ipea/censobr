library(piggyback)



parquet_files <- list.files('./data/',
                            full.names = T,
                            recursive = T, pattern = '_v0.3.0.parquet')

piggyback::pb_upload(file = parquet_files,
                     repo = 'ipea/censobr',
                     tag = 'v0.3.0')
