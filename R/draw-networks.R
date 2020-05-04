
# setup -------------------------------------------------------------------

library(jsonlite)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(ggraph)
library(tidygraph)
library(ggrepel)
library(igraph)
library(visNetwork)

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

# cut down the releases
tidy_releases_cut <- tidy_releases %>% 
  dplyr::filter(artist_name != "Various", community_have > 0)

# merge data sources
tracks_merged <- merge_data_sources(tidy_tracks, tidy_releases_cut, tidy_artists)

# create graph df
relations <- tracks_merged %>% 
  # only artists that have made a straight grime record
  mutate(style = suppressWarnings(str_c(style))) %>%
  group_by(artist_id) %>% 
  dplyr::filter(any(style == "Grime")) %>% 
  ungroup() %>% 
  rename(from=artist_name, to=extra_artist_name) %>% 
  # check no "various artists" feature
  dplyr::filter(from != "Various", to != "Various") %>% 
  as_tbl_graph(directed = FALSE) %>% 
  distinct(name, .keep_all = TRUE) %>% 
  # calculate centrality/group metrics
  mutate(n_records = centrality_degree(mode = "in"),
         n_have = centrality_degree(weights = community_have),
         name = str_trim(str_remove_all(name, pattern = "\\([^\\]]*\\)")),
         group = group_components()) %>% 
  # keep biggest connected graph
  dplyr::filter(group == 1, n_records > 1)

# viz ---------------------------------------------------------------------

# static 
relations %>% 
  ggraph(layout = 'stress') +
  geom_edge_link0(edge_colour = "grey66",edge_width = 0.5) + 
  geom_node_point(aes(size = n_records), shape = 21) +
  geom_node_text(aes(filter = n_records >= 2, label = name),
                 repel = TRUE,
                 color = "white", bg.color = "black", bg.r = 0.15,
                 family = "IBM Plex Sans Light") +
  theme_graph()

# focus
relations_cut <- relations %>% 
  activate(edges) %>% 
  dplyr::filter(edge_is_from(1) | edge_is_to(1))

# interactive
edges <-  as_data_frame(relations)
nodes <- select(edges, from, to) %>% 
  pivot_longer(everything()) %>% 
  distinct(value) %>% 
  rename(id=value)

visNetwork(nodes, edges, width="100%", height = "800px") %>%
  # visIgraphLayout(layout = "layout_with_graphopt") %>%
  visPhysics(stabilization = FALSE) %>%
  visEdges(smooth = FALSE)
