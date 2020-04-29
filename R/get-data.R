
# setup -------------------------------------------------------------------

library(discogger)
library(tidyverse)
library(janitor)
library(jsonlite)

discogs_api_token()

# get data ----------------------------------------------------------------

# search discogs for all grime releases (# ppl have descending order)
grime_release_counts <- discogs_search(
  params = list(
    type='release', per_page=100, sort='have', style='Grime'
  )
)

# search discogs for grime "master" releases (# ppl have descending order)
grime_master_counts <- discogs_search(
  params = list(
    type='master', per_page=100, sort='have', style='Grime'
  )
)

# cutting out duplicate entries...
grime_records <- grime_release_counts$content %>%
  # remove releases w/o master release
  dplyr::filter(master_id > 0) %>%
  # remove duplicate master releases
  distinct(master_id, .keep_all = TRUE) %>%
  # bind release w/o master release
  bind_rows(
    dplyr::filter(grime_release_counts$content, master_id == 0)
  ) %>%
  # remove duplicate releases
  distinct(id, .keep_all = TRUE)
  # keep records at least 5 ppl own
  # dplyr::filter(community.have >= 5)

# keep (adjacent) UK styles only!
grime_records <- grime_records[map_lgl(grime_records$style, function(x) {
  all(x %in% c(
    "Grime", "UK Garage", "Dubstep", "Speed Garage", "RnB/Swing",
    "Dancehall", "Ghetto", "Dub"
    ))
}), ]

# get detailed release metadata for these records from discogs
grime_records_details <- lapply(
  1:nrow(grime_records), function(x) {

    # get master release metadata, if available
    if (grime_records[x, ]$master_id == 0) {
      discogs_release(grime_records[x, ]$id)
    } else {
      discogs_release_master(grime_records[x, ]$master_id)
    }
  })

# wrangling ---------------------------------------------------------------

grime_releases <- grime_records %>%
  # update have/want counts with masters
  left_join(
    select(grime_master_counts$content, master_id, community.have, community.want),
    by = "master_id") %>%
  mutate(
    community.have = if_else(is.na(community.have.y), community.have.x, community.have.y),
    community.want = if_else(is.na(community.want.y), community.want.x, community.want.y)
    ) %>%
  # # add artist metadata fields
  mutate(
    title_short = map_chr(
      grime_records_details, function(x) x[["content"]][["title"]]
    ),
    artists = map(
      grime_records_details, function(x) x[["content"]][["artists"]]
      ),
    data_quality = map_chr(
      grime_records_details, function(x) x[["content"]][["data_quality"]]
      )
    ) %>%
  # drop some cols
  select(release_id=id, everything(), -barcode, -starts_with("user_data"),
         -community.have.x, -community.have.y, -community.want.x,
         -community.want.y) %>%
  # tidy column headers
  clean_names()

# collate track metadata fields
grime_tracks <- grime_releases %>%
  select(release_id) %>%
  mutate(tracklist = map(
    grime_records_details, function(x) x[["content"]][["tracklist"]]
  ))

# export ------------------------------------------------------------------

write_json(grime_releases, "data/grime-releases.json")
write_json(grime_tracks, "data/grime-tracks.json")
