# STA 141A
# Lecture 3 (Oct 4)
#
# See Piazza for office hours!

# Reference:
#   * R4DS ch 3 "Data Visualization" (book ch 1)
#   * TARP ch 1.4 "Preview of Some Important R Data Structures"

# Dogs example:
setwd("~/university/teach/sta141a/notes")

dogs = readRDS("dogs_full.rds")
head(dogs)

library(ggplot2)
ggplot(dogs, aes(x = datadog, y = popularity, color = group)) +
  geom_point()


# Grammar of Graphics --------------------
# Documentation:
#
#   https://ggplot2.tidyverse.org/
#

# Layer 1: Data
dogs = readRDS("data/dogs/dogs_full.rds")

library("ggplot2")
ggplot(dogs)

# Layer 2: GEOMetry -- shapes to represent data
ggplot(dogs) + geom_point()

# Layer 3: AESthetic -- "wires" between geometry and data
ggplot(dogs) + geom_point(aes(x = datadog, y = popularity))

ggplot(dogs, aes(x = datadog, y = popularity)) + geom_point()


# -----
# Add another geom to add breed names to the plot
ggplot(dogs, aes(x = datadog, y = popularity)) + geom_point() +
  geom_text(aes(label = breed))


# What else should we do to make this more like the plot at
#
#   https://informationisbeautiful.net/visualizations/best-in-show-whats-the-top-data-dog/
#
# 1. Reverse the y-axis

# Layer 4: SCALE -- controls how data numbers are transformed to screen
ggplot(dogs, aes(x = datadog, y = popularity)) + geom_point() +
  geom_text(aes(label = breed)) +
  scale_y_reverse()

# We could also just make popularity negative.
#
# But if popularity is negative, it could be confusing to readers.
#
# In general, if ggplot provides a simple command to do exactly what you want
# (as with scale_y_reverse() here), that command is the best option.
#
# If you need to do something more complicated, you may want to transform that
# data before you make the plot.
#
ggplot(dogs, aes(x = datadog, y = -popularity)) + geom_point() +
  geom_text(aes(label = breed))

# Now...
#
# 2. Adjust the text, so it's not on top of points
#
# See ?geom_text and vignette("ggplot2-specs") for details
#
ggplot(dogs, aes(x = datadog, y = popularity)) + geom_point() +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse()

# Add colors for each group
ggplot(dogs, aes(x = datadog, y = popularity, color = group)) +
  geom_point() +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse()

# Depending on where we set the color aesthetic, color gets added to the
# points, the text, or both.
ggplot(dogs, aes(x = datadog, y = popularity)) +
  geom_point(aes(color = group)) +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse()

ggplot(dogs, aes(x = datadog, y = popularity)) +
  geom_point() +
  geom_text(aes(label = breed, color = group),
            hjust = "left", vjust = "top") +
  scale_y_reverse()

ggplot(dogs, aes(x = datadog, y = popularity)) +
  geom_point(aes(color = "blue")) +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse()


# Layer 5: THEME -- overall style of the plot
#
# Use themes when you want to change default colors, shapes, etc. throughout
# the plot.

ggplot(dogs, aes(x = datadog, y = popularity)) +
  geom_point() +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse() +
  theme_classic()

# But...if you want to change the default color palette for an aesthetic,
# instead of themes you need to use scales.
my_colors = c("red", "blue", "green", "orange", "purple", "yellow", "cyan")

ggplot(dogs, aes(x = datadog, y = popularity, color = group)) +
  geom_point() +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse() +
  scale_color_manual(values = my_colors) # set new color palette


# Layer 6: LABELS
ggplot(dogs, aes(x = datadog, y = popularity, color = group)) +
  geom_point() +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse() +
  labs(title = "Best in Show", x = "Computed DataDog Score",
       y = "AKC Popularity Ranking") +

# Other label functions:
#
# ggtitle() -- title
# xlab() -- x label
# ylab() -- y label

# Layer 7: GUIDES -- legends

ggplot(dogs, aes(x = datadog, y = popularity, color = group)) +
  geom_point() +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse() +
  labs(title = "Best in Show", x = "Computed DataDog Score",
       y = "AKC Popularity Ranking") +
  guides(color = guide_legend(title = "Dog Type"))


# You can save the last plot you created to your working directory with:
ggsave("dogs_plot.png")


# Layer 8: Annotations -- additional geoms that are not mapped to data
#
ggplot(dogs, aes(x = datadog, y = popularity, color = group)) +
  geom_point() +
  geom_text(aes(label = breed), hjust = "left", vjust = "top") +
  scale_y_reverse() +
  labs(title = "Best in Show", x = "Computed DataDog Score",
       y = "AKC Popularity Ranking") +
  guides(color = guide_legend(title = "Dog Type")) +
  annotate("text", x = 1, y = 1, label = "Inexplicably Overrated", hjust = "left")
#          ^-- name of a geom    ^--- aesthetic for the geom



# Layer       | Description
# ----------  | -----------
# data        | A data frame to visualize
# geometry    | Geometry to represent the data visually
# statistics  | An alternative to geometry
# aesthetics  | The map or "wires" between data and geometry
# scales      | How numbers in data are converted to numbers on screen
# labels      | Titles and axis labels
# guides      | Legend settings
# annotations | Additional geoms that are not mapped to data
# coordinates | Coordinate systems (Cartesian, logarithmic, polar)
# facets      | Side-by-side panels


# --------------------
# Q:How can we display the 'group' variable graphically?
#
# A: Show counts in a bar plot.

ggplot(dogs, aes(x = group, fill = size)) +
  geom_bar(position = "dodge")


# geom_bar() counts up the categories automatically. But we can also count
# categories with:
table(dogs$group)


# Statistical Data Types --------------------

# Categorical
#   * Nominal -- colors
#   * Ordinal -- size categories
#
# Numerical
#   * Discrete -- years, people, etc
#   * Continuous -- years, height, weight
#
# Images
# Spatial
# Text
# ...


# R's Data Types --------------------

# Use the typeof() function to see how R stores a value in memory.
#
typeof("hello")

# Note that R data types do not match one-to-one with statistical data types.
#
# For instance, "5.111" seems like continuous data, but because of the quotes,
# R sees it as a character.
typeof("5.1111")

# Without the quotes, it is a number.
typeof(5.1111)

# Here "double" stands for double-precision floating point number, which is a
# format computers use to represent real numbers.

# Other types:

typeof(1+3i)

typeof(mean) # A "closure" is a kind of function

# To make an R integer, add L after the number.
#
# R can convert between real numbers and integers automatically, so you'll
# almost never need to write L after numbers.
typeof(5L)


# For messier data sets than what we've seen so far, you will have to convert
# between R data types.
# 
# For instance:
x = c("5.1", "3.2", "7")

mean(x) # doesn't work

x = as.numeric(x) # convert to numeric (type "double")

mean(x) # now we can get the mean


