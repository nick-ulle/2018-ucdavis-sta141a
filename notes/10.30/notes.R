# STA 141A
# Lecture 10 (Oct 30)
#
# See Piazza for office hours!

# References:
#   * ggmap: 
#     https://journal.r-project.org/archive/2013-1/kahle-wickham.pdf
#   * sf (see 1, 4, 5):
#     https://r-spatial.github.io/sf/



# Previous Lecture
# ================
#
# Which carriers have the most on-time flights?

air = read.csv("data/airline/2018.01_air_delays.csv")

air$ontime = (air$ARR_DELAY <= 0)

library(ggplot2)

# For bar plots, if you use the `fill` aesthetic and `stat(prop)`, set `group`
# to the same feature as `fill`.
#
ggplot(air, aes(OP_UNIQUE_CARRIER, y = stat(prop), fill = ontime,
    group = ontime)) +
  geom_bar(position = "dodge")


# Ref: ggplot2 (Wickham 2016) 3.5.4 "Matching Aesthetics to Graphic Objects"

# 9E appears to have 0.7 NAs

tbl = table(air$ontime, air$OP_UNIQUE_CARRIER, useNA = 'always')
prop.table(tbl, 1)

# --> Where are the airports at? Which are the busiest?


# Airport Data
# ============

# Airport info:
#
#   https://openflights.org/data.html
#

ap = read.csv("data/airline/airports.dat")

# From the website:
names = c("ID", "Name", "City", "Country", "IATA", "ICAO",
  "Latitude", "Longitude", "Altitude", "Timezone", "DST",
  "Tz", "Type", "Source")

names(ap) = names

# Save the data set as an RDS file for future use.
saveRDS(ap, "data/airline/airports.rds")



# Making Maps With ggmap
# ======================

# Flashback to previous lecture -- how to install ggmap:
install.packages("devtools")
devtools::install_github("dkahle/ggmap", ref = "tidyup")

library(ggmap)

citation("ggmap") # or for other packages as well

# Download a map.
m = get_stamenmap()

# Create a map layer.
ggmap(m)

?get_stamenmap

bbox = c(
-121.790225, 38.518210, # bottom left
-121.695120, 38.571458 # top right
)

m = get_stamenmap(bbox, zoom = 15) # default zoom = 10

ggmap(m)

# To get a bounding box:
#
#   http://boundingbox.klokantech.com/
#

bbox = c(-130.31,24.41,-63.25,49.7)
m = get_stamenmap(bbox, zoom = 5)

ggmap(m)


# For Stamen Maps, several different map types are available.
#
# See ?get_stamenmap and http://maps.stamen.com/
m = get_stamenmap(bbox, zoom = 3, maptype = "toner-lite")
ggmap(m)


# Let's add the airports.

# Without the map, we would write:
ggplot(ap) + geom_point(aes(Longitude, Latitude))

# But now instead we write:
ggmap(m) + geom_point(aes(Longitude, Latitude), ap)


# We can subset the data to just US airports, if that's what we're interested
# in.

us = ap[ap$Country == "United States", ]
head(us)

ggmap(m) +
  geom_point(aes(Longitude, Latitude), us, alpha = 0.25,
             size = 0.5)

# What are the busiest airports (Jan 2018)?
# ap -- airports
# air -- flights in Jan 2018
# maps -- of US

# Look at air data.
# Count flights for each airport?
str(air)

# Airlines are a closed system -- the planes generally
# don't escape.
#
# Do any planes "disappear" or "appear" in this data set?
#
# Do any planes move around without schedule flights?
#
# So we can just count departures or arrivals (but not both).
departures = as.data.frame(table(air$ORIGIN))
head(departures)
names(departures) = c("airport", "count")


dep_ap = merge(departures, ap, by.x = "airport", by.y = "IATA")
head(dep_ap)
nrow(dep_ap)

nrow(departures)

# What are the 3 airports that disappeared?
setdiff(departures$airport, dep_ap$airport)

match("USA", ap$IATA)

departures[departures$airport == "USA", ]

dep_ap = merge(departures, ap, by.x = "airport", by.y = "IATA", all.x = TRUE)
nrow(dep_ap)
nrow(departures)

dep_ap[dep_ap$airport  == "USA", ]

bbox = c(-130.31,24.41,-63.25,49.7)
m = get_stamenmap(bbox, zoom = 3, maptype = "toner-lite")

ggmap(m) +
  geom_point(aes(Longitude, Latitude, size = count, color = count), dep_ap,
             alpha = 0.25)

# Now we have a map of busiest airports
# Could use subsets to deal with overplotting

# Map Sources
#
# Function            | Status
# ------------------- | ------
# get_stamenmap()     | Works with coordinates.
# get_googlemap()     | Works with coordinates. API key needed for searches.
# get_openstreetmap() | Buggy, see https://github.com/dkahle/ggmap/issues/172
# get_cloudmademap()  | Not working; CloudMade bought by a another company.
#
# get_map() is a wrapper for all of these. By default, the same as
# get_googlemap().

location = rev(c(38.499850, -98.362930))
map = get_googlemap(location, zoom = 3)

m = get_googlemap()
ggmap(m)

loc = c(-121.740092, 38.544885)
m = get_googlemap(loc)
ggmap(m)

# Won't work without API key:
get_googlemap("Davis, CA")
