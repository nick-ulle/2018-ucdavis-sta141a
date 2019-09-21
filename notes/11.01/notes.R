# STA 141A
# Lecture 11 (Nov 1)
#
# See Piazza for office hours!

# Admin:
#   * Rubric grades posted
#   * Fill out feedback survey
#   * Participation comes from OH, Piazza, OR class (do at least 1)

# References:
#   * sf (see 1, 4, 5):
#     https://r-spatial.github.io/sf/

# Today:
#   * str_remove_all()
#   * Shapefiles (sf)
#   * Recap

# String Processing
# =================

# The computer science term for a piece of text is a "string".
#
# So for example:

"hi"

# is a string.
#
# The R type/class associated with strings is "character".

typeof("hi")

class("hi")

# The stringr package provides functions for searching and transforming
# strings.
#

# install.packages("stringr")
library(stringr)

x = c("cats are fun", "I like cats")
class(x)

# The str_remove_all() function removes one string from another.
#
# The PATTERN in the second argument is removed from the STRING in the first
# argument.
#
#              V--- STRING
str_remove_all(x, fixed("Cats", ignore_case = TRUE))
#                 ^--- PATTERN

str_remove_all(x, fixed("."))
str_remove_all(x, fixed("Cats"))

str_remove("Cats are so fun. I like Cats a lot.", "Cats")

str_remove_all("Cats are so fun. I like Cats a lot.", "Cats")


# Patterns in stringr use a language called "regular expressions" (or "regex"
# for short). In regex, many characters have a special meaning.
#
# For instance, a "." means any one character, so it's a wildcard.
#
# Since we haven't learned regex yet, you can turn regex off with the fixed()
# function:
str_detect("", ".")

str_detect("Cats", fixed("."))

# --------------------

# Today's Motivation:
# How do we go from lat, lon to places (or states, cities, etc)?

cl = readRDS("data/craigslist/old/cl_apartments.rds")
head(cl)

# Shapefiles & sf
# ===============
# Spatial data is made up of points, lines, and polygons.
#
# These are called "geometries" or "features".
#
# R's sf (simple features) package makes it easier to work with geometries.

install.packages("sf")
library(sf)

# The sf package can be difficult to install.
# install.packages("sf")

# There are many formats for storing spatial data. A few of these are:
#   * Esri Shapefile
#   * GeoJSON
#   * KML
#   * ...
#
# For example, the US Government publishes federal, state, and local boundaries
# online as shapefiles:
#
#   https://www.census.gov/cgi-bin/geo/shapefiles/index.php
#
# Many other governments (and people!) publish shapefiles as well.


# The read_sf() function can read most spatial formats.
places = read_sf("data/us_shapes/tl_2018_06_place/tl_2018_06_place.shp")
class(places)

head(places)

# In sf, each geometry is represented by a row in a data frame.
#
# The actual geometries are in the "geom" or "geometry" column.

head(places$NAME)

davis = places[places$NAME == "Davis", ]

library(ggplot2)

ggplot(davis) + geom_sf()


ggplot(places) + geom_sf()


# Get the coordinates for a post.
point = cl[1, c("longitude", "latitude")]
?st_point

# Turn the coordinates into a geometry (an "sf" object").
point = as.numeric(point)
point = st_point(point)

point
class(point)

# Check which place contains the point.

?st_contains
?st_crs
st_contains(places, point)

# By default, the `st_` functions return a "sparse" vector. This means the 0s
# or FALSEs in the vector are not stored in memory. Instead, the vector
# remembers where the non-zero elements are and only stores those.
#
# So instead of:
#
#   c(0, 0, 0, 1.2, 0, 0, 0, 3.1)
#
# R can store:
#
#   (#4 is 1.2), (#8 is 3.1)
#
# This saves space since only 4 numbers are stored instead of 8.
#
# However, if we actually want to print the vector, we need to ask the function
# for a regular vector, not a sparse vector.
st_contains(places, point, sparse = FALSE)


is_in = st_contains(places, point, sparse = FALSE)

# Now get the place name by subsetting:
which(is_in)
places$NAME[is_in]

# An alternative to st_contains() is st_within():
st_within(point, places)

# Week 5 Recap
# ============
# 
# Topics so far:
#   * R syntax, variables, arithemetic
#   * Paths & how to load files
#   * How to inspect data: head(), str(), ...
#   * R data types & statistical data types
#   * Subsets: $ vs [ vs [[
#   * R packages
#   * ggplot2
#   * How to choose statistics & graphics to explore data
#       + Aggregation / split-apply
#       + Pitfalls: Simpson's Paradox, ...
#       + Design considerations: overplotting, axes, ...
#   * How to merge data
#   * ggmap
#
#
dogs = readRDS("data/dogs/dogs_full.rds")

by_group = split(dogs$lifetime_cost, list(dogs$group, dogs$kids))
length(by_group)
names(by_group)

by_group[[1]]

mean(by_group[[1]], na.rm = T)

sapply(by_group, mean, na.rm = T)

aggregate(lifetime_cost ~ group, dogs, mean, na.rm = TRUE)
