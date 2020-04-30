# search discogs for all style releases
get_discogs_style_releases <- function(
  style, adjacent_styles=NULL, country=NULL, min_have=NULL
) {
  
  stopifnot(is.character(style))
  
  if (is.null(country)) {
    
    style_releases <- discogs_search(
      params = list(
        type='release', per_page=100, sort='have', style=style
      )
    )
  }
  
  else {
    
    style_releases <- discogs_search(
      params = list(
        type='release', per_page=100, sort='have', style=style,
        country=country
      )
    )
  } 
  
  # cutting out duplicate entries...
  style_releases <- style_releases$content %>%
    # remove releases w/o master release
    dplyr::filter(master_id > 0) %>%
    # remove duplicate master releases
    distinct(master_id, .keep_all = TRUE) %>%
    # bind release w/o master release
    bind_rows(
      dplyr::filter(style_releases$content, master_id == 0)
    ) %>%
    # remove duplicate releases
    distinct(id, .keep_all = TRUE)
  
  # keep records at least n ppl own
  if (is.numeric(min_have)) {
    
    style_releases <- dplyr::filter(style_releases, community.have >= min_have)
  }
  
  # keep (adjacent) styles only!
  if (!is.null(adjacent_styles)) {
    
    style_releases <- style_releases[map_lgl(style_releases$style, function(x) {
      all(x %in% c(style, adjacent_styles))
    }), ]
  }
  
  style_releases
  
}

# search discogs for all style masters
get_discogs_style_masters <- function(
  style, adjacent_styles=NULL, country=NULL
) {
  
  stopifnot(is.character(style))
  
  if (is.null(country)) {
    
    discogs_search(
      params = list(
        type='master', per_page=100, sort='have', style=style
      )
    )
  }
  
  else {
    
    discogs_search(
      params = list(
        type='master', per_page=100, sort='have', style=style,
        country=country
      )
    )
  } 
}

# get detailed metadata for a discogs "style"
get_discogs_style_detail <- function(x) {
  
  style_records <- x
  
  lapply(
    1:nrow(style_records), function(x) {
      
      # get master release metadata, if available
      if (style_records[x, ]$master_id == 0) {
        discogs_release(style_records[x, ]$id)
      } else {
        discogs_release_master(style_records[x, ]$master_id)
      }
    })
}

# get unique artist IDs
get_unique_artists <- function(x) {
  
  artist_ids <- map(x, function(y) unlist(y[["id"]]))
  
  unique(unlist(artist_ids))
}

# get artists metadata
get_discogs_artist_meta <- function(x) {
  
  artist_info <- map(x, possibly(discogs_artist, NA_real_))
  
  artists_ok <- keep(grime_artists_info, ~length(.x) == 3)
  
  map(artists_ok, function(x) x[["content"]])
}

# tidy style metadata at release-level
tidy_style_releases <- function(x, style_masters, style_details) {
  
  x %>%
    # update have/want counts with masters
    left_join(
      select(style_masters$content, master_id, community.have, community.want),
      by = "master_id") %>%
    mutate(
      community.have = if_else(is.na(community.have.y), community.have.x, community.have.y),
      community.want = if_else(is.na(community.want.y), community.want.x, community.want.y)
    ) %>%
    # # add artist metadata fields
    mutate(
      title_short = map_chr(
        style_details, function(x) x[["content"]][["title"]]
      ),
      artists = map(
        style_details, function(x) x[["content"]][["artists"]]
      ),
      data_quality = map_chr(
        style_details, function(x) x[["content"]][["data_quality"]]
      )
    ) %>%
    # drop some cols
    select(release_id=id, everything(), -barcode, -starts_with("user_data"),
           -community.have.x, -community.have.y, -community.want.x,
           -community.want.y) %>%
    # tidy column headers
    clean_names()
}

# tidy track-level metadata
tidy_style_tracks <- function(x, style_records_detail) {
  
  track_meta <- map(seq_along(style_records_detail), function(y) {
    
    list(
      release_id = x$release_id[y],
      tracklist = style_records_detail[[y]][["content"]][["tracklist"]]
    )
  })
}

# unnest releases data
unnest_releases <- function(x) {
  
  releases <- unnest_longer(x, artists)
  
  artists <- mutate_all(releases$artists, unlist)
  
  releases %>% 
    select(-artists) %>% 
    bind_cols(artists)
}

# unnest tracks data
unnest_tracks <- function(x) {
  
  tracklists <- unnest_longer(x, tracklist)
  
  tracks <- mutate_at(
    tracklists$tracklist, vars(-extraartists, -artists), unlist
  )
  tracklists_tidy <- tracklists %>% 
    select(-tracklist) %>% 
    bind_cols(tracks) %>% 
    mutate(release_id = unlist(release_id)) %>% 
    unnest_longer(extraartists)
  
  # add features to tracks
  features <- tracklists_tidy$extraartists
  features <- map(features, function(y) {
    
    y[sapply(y, is.null)] <- NA
    y
  })

  tracklists_tidy %>% 
    mutate(extra_artist_name = unlist(features$name),
           extra_artist_id = unlist(features$id),
           extra_artist_role = unlist(features$role)) %>% 
    select(-extraartists, -artists)
}

# unnest artists data
# unnest_artists <- function(x) {
#   
#   }
