
# setup -------------------------------------------------------------------

library(jsonlite)
library(ggraph)
library(tidygraph)
library(tidyr)
library(dplyr)
library(purrr)

# load data ---------------------------------------------------------------

releases <- read_json("data/grime-releases.json", simplifyVector = TRUE)
tracks <- read_json("data/grime-tracks.json", simplifyVector = TRUE)
artists <- read_json("data/grime-artists.json", simplifyVector = TRUE)

# wrangle -----------------------------------------------------------------

tidy_releases <- unnest_releases(releases)
tidy_tracks <- unnest_tracks(tracks)

# artists -----------------------------------------------------------------

# distinct grime artists
grime_artists <- distinct(grime_releases_tidy, name, id) %>% 
  dplyr::filter(!name %in% c("Various", "various", "Unknown Artist")) # rm Various

# get metadata for grime artists
grime_artists_info <- get_discogs_artist_meta(unique(grime_artists$id))

# merge -------------------------------------------------------------------

# try and join releases/tracks
foo <- left_join(grime_releases_tidy, grime_tracks_tidy, 
                 by = "release_id")

# viz ---------------------------------------------------------------------


