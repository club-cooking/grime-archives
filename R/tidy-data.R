
library(jsonlite)
library(dplyr)
library(purrr)

artists <- read_json("data-raw/grime-artists.json", simplifyVector = TRUE) 
write_json(artists, "data/artists.json", auto_unbox = TRUE)

releases <- read_json("data-raw/grime-releases.json", simplifyVector = TRUE)
write_json(releases, "data/releases.json", auto_unbox = TRUE)

tracks <- read_json("data-raw/grime-tracks.json", simplifyVector = TRUE)
tracks_df <- imap_dfr(tracks$tracklist, function(x, y) {
  
  x %>% 
    mutate(release_id = tracks$release_id[[y]]) %>% 
    select(release_id, everything())
})
tracks_df <- mutate(tracks_df, across(c(duration, position, type_, title), unlist))
write_json(tracks_df, "data/tracks.json", auto_unbox = TRUE)
