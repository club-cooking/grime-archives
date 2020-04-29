# setup -------------------------------------------------------------------

# load packages
library(discogger)
library(tidyverse)
library(janitor)
library(jsonlite)

# get local functions
source("R/functions.R")

# set discogs api token
discogs_api_token()

# style params
style = "Grime"
adjacent_styles = c(
  "UK Garage", "Dubstep", "Speed Garage", "RnB/Swing", "Dancehall", 
  "Ghetto", "Dub"
  )

# get data ----------------------------------------------------------------

# search discogs for all grime releases
release_counts <- get_discogs_style_releases(
  style = style, adjacent_styles = adjacent_styles
  )

# search discogs for grime "master" releases
master_counts <- get_discogs_style_masters(
  style = style, adjacent_styles = adjacent_styles
)

# get detailed release metadata for these records from discogs
record_details <- get_discogs_style_detail(release_counts)

# tidy up release metadata
release_meta <- tidy_style_releases(
  release_counts, master_counts, record_details
  )

# tidy up track-level metadata
track_meta <- tidy_style_tracks(release_meta, record_details)

# export ------------------------------------------------------------------

write_json(release_meta, "data/grime-releases.json")
write_json(track_meta, "data/grime-tracks.json")
