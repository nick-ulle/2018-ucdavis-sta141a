# STA 141A
# Lecture 9 (Oct 25)
#
# See Piazza for office hours!

# References:
#   * R4DS Chapter 13 "Relational Data"
#   * ggmap: 
#     https://journal.r-project.org/archive/2013-1/kahle-wickham.pdf



# What kinds of questions can we ask (or answer) with the airlines data?
#
# * What airports are most likely to have delays? Or least likely?
# * Check for seasonal delays (but we would need data on more months)
# * What area or region is most likely to have delays?
# * What are the main causes of delay?
#     * How often does weather cause a delay?
# * Does a delay on one flight cause later delays (for the same plane)?


# Airline Example 1 --------------------

air = read.csv("data/airline/2018.01_air_delays.csv")

# Which carriers have the most on-time flights?

# Big-picture strategy: Count the number of on-time flights for each carrier
#
# -> What is an "on-time flight"? We need to define this.
#     * We could look at (CRS_ARR - ACTUAL_ARR), or any _DELAY
#     * We can define on-time in different ways, depending on our perspective:
#         - customer perspective: anything <= 0 delay is on-time
#         - airport perspective: only 0 delay
#         - ...
#
# Let's use ARR_DELAY and take the customer perspective
#

air$ontime = (air$ARR_DELAY <= 0)

# First try, a table:
table(air$ontime, air$OP_UNIQUE_CARRIER)

# Second try, a bar plot:
library(ggplot2)
ggplot(air, aes(ontime, fill = OP_UNIQUE_CARRIER)) +
  geom_bar(position = "dodge")

# Third try, another bar plot:
ggplot(air, aes(OP_UNIQUE_CARRIER, fill = ontime)) +
  geom_bar(position = "dodge")


# The plot might be easier to read if we show proportions.
#
# How can we show proportions?


# Strategy 1: Compute Manually
# ====================

# Number of on-time flights:
sum(air$ontime)

# Number of on-time flights, by carrier:
ontime = aggregate(ontime ~ OP_UNIQUE_CARRIER, air, sum)

# Total number of flights per carrier:
total = as.data.frame(table(air$OP_UNIQUE_CARRIER))
names(total) = c("carrier", "flights")

# To compute proportions, we could do this:
ontime$ontime / total$flights 

# But what if the rows in ontime don't match the rows in total?
#
# Safer to use the merge() function, which matches the rows:
#
m = merge(ontime, total, by.x = "OP_UNIQUE_CARRIER", by.y = "carrier")
#         x       y      ^- to match x               ^- to match y

m$prop = m$ontime / m$flights

ggplot(m, aes(OP_UNIQUE_CARRIER, prop)) + geom_bar(stat = "identity")

# How can we reorder the categories?
#
# 1. Sort the data frame:
m = m[order(m$prop), ]

# 2. Reorder the levels:
m$OP_UNIQUE_CARRIER = factor(m$OP_UNIQUE_CARRIER, levels = m$OP_UNIQUE_CARRIER)

# Alternatively, we could just use reorder():
m$OP_UNIQUE_CARRIER = reorder(m$OP_UNIQUE_CARRIER, m$prop)

ggplot(m, aes(OP_UNIQUE_CARRIER, prop)) + geom_bar(stat = "identity")


# Strategy 2: Use `position = "fill"`
# ====================
ggplot(air, aes(OP_UNIQUE_CARRIER, fill = ontime)) +
  geom_bar(position = "fill")



# Strategy 3: Use stat_count's `prop` variable
# ====================
# When using `fill=` and `stat(prop)`, make sure to set `group=` to the same
# feature as `fill=`.
#
ggplot(air, aes(OP_UNIQUE_CARRIER, y = stat(prop), fill = ontime,
    group = ontime)) +
  geom_bar(position = "dodge")



# Airline Example 2 --------------------

# Are there more delays on certain days of the week? Are there more flights?
# |-> How would we find out how many flights are very late (beyond the whisker)?

# Fix the DAY_OF_WEEK column (again!).
days = read.csv("data/airline/L_WEEKDAYS.csv_")

# Match the data again.
row_num = match(air$DAY_OF_WEEK, days$Code)
air$DAY_OF_WEEK = days$Description[row_num]

# Save the result.
#
# This way we don't have to correct the data again.
saveRDS(air, "data/airline/airlines.rds")

# Now, where should we cut off for flights beyond the whisker?
ggplot(air, aes(DAY_OF_WEEK, ARR_DELAY)) + geom_boxplot() +
  ylim(-100, 100)

# Estimate that whisker ends around 40 minutes.
tbl = table(air$ARR_DELAY > 40, air$DAY_OF_WEEK)

# Proportions by column (that is, by day).
prop.table(tbl, 2)



# Airline Example 3 --------------------

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


# Installing R Packages from GitHub --------------------
#
# Many R packages are developed using a website called GitHub, which provides
# storage for the package code and a bug tracker.
#
# Often it's a good idea to check out the GitHub page for a package before
# installing. The GitHub page will usually have a README with details about the
# package.
#
# For instance, for ggmap:
#
#   https://github.com/dkahle/ggmap
#
# The ggmap README warns that the CRAN version of ggmap (the one we can get
# with install.packages()) is outdated.
#
# They recommend a workaround:

# First, install the devtools package, which will help us install packages from
# GitHub.
install.packages("devtools")

# Next, install the development version of ggmap:
devtools::install_github("dkahle/ggmap", ref = "tidyup")


# Most of the time install.packages() is a better choice because packages on
# CRAN tend to be more stable.
#
# Once in a while (like with ggmap) you may need to use
# devtools::install_github() to install a package's development version from
# GitHub.


# Spatial Data --------------------

# To get a bounding box:
#
#   http://boundingbox.klokantech.com/
#
