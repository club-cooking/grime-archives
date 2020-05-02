
# setup -------------------------------------------------------------------

library(jsonlite)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(ggraph)
library(tidygraph)

source("R/functions.R")

# load data ---------------------------------------------------------------

releases <- read_json("data/grime-releases.json", simplifyVector = TRUE)
tracks <- read_json("data/grime-tracks.json", simplifyVector = TRUE)
artists <- read_json("data/grime-artists.json", simplifyVector = TRUE)

# wrangle -----------------------------------------------------------------

# unnest nested objects
tidy_releases <- unnest_releases(releases)
tidy_tracks <- unnest_tracks(tracks)
tidy_artists <- unnest_artists(artists)

# merge data sources
tracks_merged <- merge_data_sources(tidy_tracks, tidy_releases, tidy_artists)

# create graph df
relations <- tracks_merged %>% 
  mutate(style == str_c(style)) %>%
  group_by(artist_id) %>% 
  dplyr::filter(any(style == "Grime"), min(year) < 2005) %>% 
  ungroup() %>% 
  rename(from=artist_name, to=extra_artist_name) %>% 
  as_tbl_graph() %>% 
  mutate(n_records = centrality_degree(mode = 'in'),
         n_have = centrality_degree(weights = community_have),
         name = str_trim(str_remove_all(name, pattern = "\\([^\\]]*\\)")))

# viz ---------------------------------------------------------------------

ggraph(relations, layout = "fr") +
  geom_edge_link(alpha = 0.25) +
  geom_node_point(aes(size = n_have))
  # geom_node_text(
  #   aes(label = name, size = n_have), repel = TRUE,
  #   color = "white", bg.color = "black", bg.r = 0.2,
  #   family = "IBM Plex Sans Light"
  # )

