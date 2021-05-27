
library(jsonlite)
library(dplyr)

artists <- read_json("data-raw/grime-artists.json", simplifyVector = TRUE) %>% 
  write_json("data/artists.json", auto_unbox = TRUE)
