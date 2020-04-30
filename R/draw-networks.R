
# setup -------------------------------------------------------------------

library(discogger)
library(jsonlite)
library(ggraph)
library(tidygraph)
library(tidyr)
library(dplyr)
library(purrr)

discogs_api_token()

# load data ---------------------------------------------------------------

grime_releases <- read_json("data/grime-releases.json", simplifyVector = TRUE) %>% 
  unnest_longer(artists) 

grime_tracks <- read_json("data/grime-tracks.json", simplifyVector = TRUE) %>% 
  unnest_longer(tracklist)

# wrangle -----------------------------------------------------------------

# fix grime releases
artists <- mutate_all(grime_releases$artists, unlist)
grime_releases_tidy <- grime_releases %>% 
  select(-artists) %>% 
  bind_cols(artists)

# fix grime tracks
tracks <- mutate_at(
  grime_tracks$tracklist, vars(-extraartists, -artists), unlist
  )
grime_tracks_tidy <- grime_tracks %>% 
  select(-tracklist) %>% 
  bind_cols(tracks) %>% 
  mutate(release_id = unlist(release_id)) %>% 
  unnest_longer(extraartists)

# add features to tracks
features <- grime_tracks_tidy$extraartists
features <- map(features, function(x) {
  
    x[sapply(x, is.null)] <- NA
    x
})
features <- mutate_all(grime_tracks_tidy$extraartists, unlist)

grime_tracks_tidy <- grime_tracks_tidy %>% 
  mutate(extra_artist_name = unlist(features$name),
         extra_artist_id = unlist(features$id),
         extra_artist_role = unlist(features$role)) %>% 
  select(-extraartists, -artists)

# artists -----------------------------------------------------------------

# distinct grime artists
grime_artists <- distinct(grime_releases_tidy, name, id) %>% 
  dplyr::filter(!name %in% c("Various", "various", "Unknown Artist")) # rm Various

# get metadata for grime artists
grime_artists_info <- map(grime_artists$id, discogs_artist)

# merge -------------------------------------------------------------------

# try and join releases/tracks
foo <- left_join(grime_releases_tidy, grime_tracks_tidy, 
                 by = "release_id")

# viz ---------------------------------------------------------------------


