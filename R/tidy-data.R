
library(jsonlite)
library(dplyr)

artists <- read_json("data-raw/grime-artists.json", simplifyVector = TRUE) %>% 
  write_json("data/artists.json", auto_unbox = TRUE)

releases <- read_json("data-raw/grime-releases.json", simplifyVector = TRUE) %>% 
  write_json("data/releases.json", auto_unbox = TRUE)

tracks <- read_json("data-raw/grime-tracks.json", simplifyVector = TRUE) %>% 
  write_json("data/tracks.json", auto_unbox = TRUE)
