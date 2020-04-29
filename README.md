# grime-archives

<!-- badges: start -->
[![Launch Rstudio Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ewenme/grime-archives/master?urlpath=rstudio)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

A dataset of UK Grime records listed on [Discogs](https://www.discogs.com) between 2000 and 2020, along with the code to gather/update the data yourself.

## Contents

The `data/` directory contains the data (last updated 29th April, 2020). Two files are included:

- `grime-releases.json`: Metadata for Grime releases (AKA records)
- `grime-tracks.json`: Metadata for individual Grime tracks (from the records in `grime-releases.json`)

Code used to create this dataset is found in `R/get-data.R`.

## Author

- [Ewen](https://www.ewen.io)

## License

This project is open source and available under the [MIT License](LICENSE).