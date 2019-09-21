# STA 141A
# Lecture 5 (Oct 11)
#
# See Piazza for office hours!

# References:
#   * R4DS ch 7 "Data Visualization" (book ch 5)
#   * "Visualizing Data" by Cleveland


# Categorical Features --------------------


dogs = readRDS("data/dogs/dogs_full.rds")

str(dogs)
# Get category names with levels():
levels(dogs$size)

# Rename categories:
levels(dogs$size) = c("HUGE", "medium", "small")
levels(dogs$size)
tail(dogs$size)

levels(dogs$size)[1] = "large"
levels(dogs$size)

# DANGER! Wrong way to reorder levels:
levels(dogs$size) = c("small", "medium", "large")

# Right way to reorder levels:
size_fix = factor(dogs$size, c("small", "medium", "large"))

levels(dogs$size)
levels(size_fix)

table(dogs$size)
table(size_fix)

library(ggplot2)
ggplot(dogs, aes(height, weight, color = size_fix)) + geom_point()

# Missing Data
#
# When you get a new data set, start with:
#
# 1. Load the data
# 2. Check structure -- nrow(), str(), head(), summary()
# 3. Explore missing values -- is.na()

table(dogs$size)

nrow(dogs)
sum(table(dogs$size))

summary(dogs)

sum(table(dogs$kids))
nrow(dogs)

?table
# Make table() show NA as a category:
table(dogs$kids, useNA = "always")


# How can you explore something that's missing?
#
# Use is.na() to create "shadow" versions of the features.


is.na(dogs$kids)

shadow = is.na(dogs)
class(shadow)
class(dogs)
shadow = as.data.frame(shadow) # back into a data frame

# Now explore shadow data together with original data.


# Continuous Features --------------------
head(dogs)
fivenum(dogs$datadog)

library(ggplot2)
# A boxplot shows Tukey's five number summary graphically:
ggplot(dogs, aes(y = datadog)) + geom_boxplot()

# A histogram cuts the data into bins, and shows the count for each bin.
ggplot(dogs, aes(x = datadog)) + geom_histogram()

# A density plot is a smoothed histogram.
ggplot(dogs, aes(x = datadog)) + geom_density()

ggplot(dogs, aes(x = datadog)) + geom_density(bw = 0.01)


# What does variance / standard deviation tell us?
# - scaling factor
# - how far observations are from the average, on average
sd(dogs$datadog, na.rm = TRUE)
mu = mean(dogs$datadog, na.rm = TRUE)

min(dogs$datadog, na.rm = TRUE)
max(dogs$datadog, na.rm = TRUE)

m = median(dogs$datadog, na.rm = TRUE)

# We can add lines to the plot to see the skew:
ggplot(dogs, aes(x = datadog)) + geom_density() +
  geom_vline(aes(xintercept = m)) +
  geom_vline(aes(xintercept = mu), color = "red")

# geom_vline() -- vertical
# geom_hline() -- horizontal
# geom_abline() -- any (straight) line

# Quantile plots (useful for checking normality)
# geom_quantile()

# Discrete Features --------------------

head(dogs)
dogs$ailments

# We can treat discrete data like categorical data
table(dogs$ailments)
ggplot(dogs, aes(x = ailments)) + geom_bar()

# We can treat discrete data like continuous data
mean(dogs$ailments, na.rm = TRUE)

# Is there a situation where one way is better than the other?
#
# time series -- discrete, but neither way is best
# rankings -- discrete, but neither way makes sense
# lots of "categories" -- use continuous methods
#     For example: home runs, university population
#
# few "categories" -- use categorical methods
#     For example: TRUE/FALSE, number of children


# Multivariate EDA --------------------

# (categorical, categorical) -> frequencies
#
# Similar to the univariate case!
#
tbl = table(size = dogs$size, group = dogs$group)
tbl
addmargins(tbl)

prop.table(tbl) # total proportions
prop.table(tbl, margin = 1) # proportions row-wise
prop.table(tbl, margin = 2) # proportions column-wise

ggplot(dogs, aes(size, fill = group)) +
  geom_bar(position = "dodge")

props = prop.table(tbl)
props
props = as.data.frame(props)

ggplot(props, aes(size, fill = group, y = Freq)) +
  geom_bar(stat = "identity") + scale_fill_viridis_d()

# Heatmaps:
# geom_tile(), geom_raster()


# (numerical, numerical) -> scatterplot, correlation

ggplot(dogs, aes(height, weight)) + geom_point()


# When there are a lot of points, it can be hard to see the details.
#
# A 2d density plot shows where most of the points are at.
ggplot(dogs, aes(height, weight)) + geom_density2d() + geom_point()

# We can also check for linear relationship with correlation:
cor(dogs$height, dogs$weight)


# (numerical, categorical) -> group by category
#
# After grouping the data, we can use methods for univariate continuous data on
# each category.
#
ggplot(dogs, aes(x = size, y = height)) + geom_boxplot()

ggplot(dogs, aes(height, color = size)) + geom_density()


# Aggregation -- computing statistics on groups

#         |-----------|-- relationship of interest
#         v           v     v---- data
aggregate(height ~ size, dogs, mean, na.rm = TRUE)
#                               ^---- statistic


# You can group by more than one categorical variable:
aggregate(height ~ size + grooming, dogs, mean, na.rm = TRUE)
#                  ^      ^
#                  |------|-------- compute statistic for all combinations


# Alternative syntax:
aggregate(dogs$height, list(dogs$size, dogs$grooming), mean)

aggregate(dogs$height, dogs[c("size", "grooming")], mean)


# x1          | x2          | Plot                      | Statistic
# ----------- | ----------- | ------------------------- | ----------
# Categorical |             | dot, bar                  | frequencies
# Categorical | Categorical | dot, bar, mosaic, heatmap | frequencies
#             |             |                           |
# Numerical   |             | box, density, histogram   | location, scale
# Numerical   | Numerical   | scatter                   | correlation
# Numerical   | Categorical | box, density, histogram   | grouped statistics
#             |             |                           |
# Numerical   | Time        | line                      | autocorrelation
# ...
#
# For more than 2 variables, use aesthetics or facets.
#

# Facets --------------------
#
# "Faceting" means making side-by-side graphs for comparison. Each graph is a
# "facet".
#
# ggplot can create facets for you!

# Dog height distribution, over all dogs:
ggplot(dogs, aes(height)) + geom_histogram()

# Dog height distributions, faceted by size:
ggplot(dogs, aes(height)) + geom_histogram() + facet_wrap(~ size)

# facet_wrap() arranges the faceted plots into a grid automatically.
#
# facet_grid() lets you specify the rows and the columns, so you can use two
# variables to facet.

# Dog height distributions, faceted by grooming needs and size:
ggplot(dogs, aes(height)) + geom_histogram() + facet_grid(grooming ~ size)


# Whether you should use facets or aesthetics is a subjective, and depends on
# your data.
#
# Try both and choose the one that's easier to read.
#
# In some cases you may want to examine 3+ variables, and will have to use a
# combination of facets and aesthetics.
