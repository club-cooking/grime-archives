# grime-archives

<!-- badges: start -->
[![Launch Rstudio Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/club-cooking/grime-archives/master?urlpath=rstudio)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

A dataset of UK Grime records as listed on [Discogs](https://www.discogs.com) between 2000 and 2021, along with the code to gather/update the data yourself (or copy for other genres). 

Data last updated 22nd November, 2021.

## Contents

The `data/` directory contains the data. Three files are included:

- `releases.json`: Metadata for Grime releases (AKA records)
- `tracks.json`: Metadata for individual Grime tracks, taken from the releases in `releases.json`
- `artists.json`: Metadata for Grime artists featured on the releases in `releases.json`

Code used to create this dataset can be found in `R/`. You can [test it out now, right in the browser, with Binder](https://mybinder.org/v2/gh/ewenme/grime-archives/master?urlpath=rstudio).

## Related work

This was heavily inspired by Karl Tryggvason's [Discogs Collection Statistics](https://github.com/Kalli/Discogs-Collection-Statistics) work, which gathers similar metadata for other genres.

## License

This project is open source and available under the [MIT License](LICENSE).
