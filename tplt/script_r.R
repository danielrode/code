#!/usr/bin/env Rscript
# author: Daniel Rode
# name:
# tags:
# dependencies:
#   ...
# version: 1
# created:
# updated: -


# Description:
# ...
# ...


# Parse command line arguments
# TODO this was snip copied from another script and needs to be made general
pos_args = character()
max_threads = DEFAULT_MAX_THREADS
dtm_path = NA  # If no DTM path is given, lidR will generate its own
collection_cache_path = NA
debug_save_extents = FALSE

args = commandArgs(trailingOnly = TRUE)
counter = 1
while (TRUE) {
  a = args[counter]
  if (is.na(a)) {
    break
  } else if (!startsWith(a, "-")) {
    pos_args = c(pos_args, a)
    counter = counter + 1
  } else if (a == "-d" || a == "--dtm-path") {
    dtm_path = args[counter + 1]
    counter = counter + 1
  } else if (a == "-t" || a == "--max-threads") {
    max_threads = as.integer(args[counter + 1])
    counter = counter + 1
  } else if (a == "-c" || a == "--collection-cache-path") {
    # Path to RDS file that contains a cached/pre-generated lidR
    # LAS_CATALOG object
    collection_cache_path = args[counter + 1]
    counter = counter + 1
  } else if (a == "--debug-save-extents") {
    debug_save_extents = TRUE
  } else {
    stop("Invalid flag: ", a)
  }
}

if (length(pos_args) != 6) {
  cat(HELP_TEXT)
  quit(status = 1)
}
ctg_pth = pos_args[1]
out_dir = pos_args[2]
tile_bound_min_x = as.numeric(pos_args[3])
tile_bound_min_y = as.numeric(pos_args[4])
tile_length = as.numeric(pos_args[5])
tile_buffer = as.numeric(pos_args[6])

cat("Args: ")
dput(args)

if (! file.exists(ctg_pth)) {
  stop("Path does not exist: ", ctg_pth)
}
dir.create(out_dir, showWarnings = FALSE, recursive = FALSE, mode = "0700")
tile_bound_max_x = tile_bound_min_x + tile_length
tile_bound_max_y = tile_bound_min_y + tile_length


# TODO
# add try-error example, but use `is` instead of `class() ==`
