# setup -------------------------------------------------------------------

# load packages
library(discogger)
library(dplyr)
library(purrr)
library(janitor)
library(jsonlite)

# get local functions
source("R/functions.R")

# set discogs api token
discogs_api_token()

# parameters
style = "Grime"
adjacent_styles = c("UK Garage", "UK Funky", "Dubstep")
country = "uk"

# get data ----------------------------------------------------------------

# search discogs for all grime releases
release_counts <- get_discogs_style_releases(
  style = style, adjacent_styles = adjacent_styles, country = country
  )

# search discogs for grime "master" releases
master_counts <- get_discogs_style_masters(
  style = style, adjacent_styles = adjacent_styles, country = country
)

# get detailed release metadata for these records from discogs
record_details <- get_discogs_style_detail(release_counts)

# tidy up release metadata
release_meta <- tidy_style_releases(
  release_counts, master_counts, record_details
  )

# tidy up track-level metadata
track_meta <- tidy_style_tracks(release_meta, record_details)

# get unique artist IDs
artist_ids <- get_unique_artists(release_meta$artists)

# get detailed artist metadata
artist_meta <- get_discogs_artist_meta(artist_ids)

# export ------------------------------------------------------------------

write_json(release_meta, "data-raw/grime-releases.json")
write_json(track_meta, "data-raw/grime-tracks.json")
write_json(artist_meta, "data-raw/grime-artists.json")
