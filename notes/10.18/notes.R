# STA 141A
# Lecture 7 (Oct 18)
#
# See Piazza for office hours!

# References:
#   * R4DS ch 28 "Graphics for Communication" (book ch ??)
#   * "The Elements of Graphing Data" by Cleveland


# Designing Graphics --------------------

dogs = readRDS("data/dogs/dogs_full.rds")

# Labeling -- When you add labels to a plot, the labels can be hard to read if
# they overlap a lot.
#
# Ways to fix:
#   * make the labels smaller (set size=)
#   * reposition the labels (set hjust=, vjust=, nudge_x=, or nudge_y=)
#   * use ggrepel

library(ggplot2)
ggplot(dogs, aes(datadog, popularity)) + geom_point() +
  geom_text(aes(label = breed))

# install.packages("ggrepel")
library(ggrepel)
ggplot(dogs, aes(datadog, popularity)) + geom_point() +
  geom_text_repel(aes(label = breed))


# Overplotting -- When there are lots of points on a plot, it can be hard to
# see the details.
#
# Ways to fix:
#   * make the point smaller (set size=)
#   * make the points transparent (set alpha=)
#   * split the points into several groups (make a new categorical feature)
#   * add contour lines / 2-d density with geom_density_2d()

mystery = readRDS("data/mystery/mystery.rds")
head(mystery)

# The points look like a cloud with no strong trends:
ggplot(mystery, aes(x, y))

# But there's hidden detail in the cloud of points:
ggplot(mystery, aes(x, y)) + geom_point(alpha = 0.25, size = 10)

ggplot(mystery, aes(x, y)) + geom_point() + geom_density2d()

# If you use contours, it's usually a good idea to keep the original points as
# well. Then you can see fine details in places where there aren't lots of
# points.


# Aspect Ratios -- The ratio between the x-axis and y-axis can change how you
# interpret the plot.

head(mystery)

# Looks like the data has a trend with slope 1.
ggplot(mystery, aes(narrow, wide)) + geom_point()

# But if we put the axes on the same scale, we can see the slope is much
# steeper than 1.
ggplot(mystery, aes(narrow, wide)) + geom_point() +
  coord_fixed(ratio = 1)

# Setting the correct aspect ratio is especially important when both axes have
# similar measurements (for example, height1 vs height2).

# Some examples of bad plots:
#   http://viz.wtf/
#
# Some examples of better plots (with R code!):
#   https://www.r-graph-gallery.com/


# Statistics Pitfalls --------------------

# Anscombe's Quartet
head(anscombe)

# Four (x, y) pairs that all look the same in terms of simple statistics:
cor(anscombe$x1, anscombe$y1)
cor(anscombe$x2, anscombe$y2)
cor(anscombe$x3, anscombe$y3)
cor(anscombe$x4, anscombe$y4)

lm(y1 ~ x1, anscombe)
lm(y2 ~ x2, anscombe)
lm(y3 ~ x3, anscombe)
lm(y4 ~ x4, anscombe)

# But when we make plots, we see they are very different:
g1 = ggplot(anscombe, aes(x1, y1)) + geom_point()
g2 = ggplot(anscombe, aes(x2, y2)) + geom_point()
g3 = ggplot(anscombe, aes(x3, y3)) + geom_point()
g4 = ggplot(anscombe, aes(x4, y4)) + geom_point()

# Putting ggplots side-by-side:
library(gridExtra)
grid.arrange(g1, g2, g3, g4, ncol = 2, nrow = 2)


# Moral: Always look at your data from multiple perspectives. Point statistics
# like the correlation or the regression slope only give you part of the
# picture. Visualizing data is usually the best way to understand what's going
# on.


# Spurious Correlations
#   See http://www.tylervigen.com/spurious-correlations
#
# Moral: Correlation (and most other statistics) require common sense
# interpretation. In fact, that's your main value as a statistician or data
# scientist!
#
# A computer can plug numbers into the formula and do the arithmetic far more
# efficiently than you can. At least so far, only a human can make a judgement
# call about how interpret that number.


# Simpson's Paradox
simpson = readRDS("data/simpson/simpson_c.rds")
head(simpson)

# Strong negative correlation between weight and height:
cor(simpson$weight, simpson$height)

# But if we split the data into groups...
by_group = split(simpson, simpson$group)

class(by_group)
length(by_group)
class(by_group[[1]])

head(by_group[[2]])
names(by_group)

# ...each group has a strong positive correlation!
cor(by_group$A$weight, by_group$A$height)
cor(by_group$B$weight, by_group$B$height)

# To understand what's going on, look at the plot:
ggplot(simpson, aes(weight, height, color = group)) + geom_point()

# The real danger is if we didn't have the `group` feature in the data set.
# Then we might not even think to check, and assume the data are negatively
# correlated.
ggplot(simpson, aes(weight, height)) + geom_point()

# Moral: When you explore a feature (or several features), always be on the
# lookout for other features that might interact with your result. In the
# example, the group feature is a "confounding variable" that changes the
# result. We had the confounding variable in the data set, but that won't
# always be the case... the confounding variable might not even be recorded for
# you!
#
# Simpson's paradox comes up a lot in real data. If we generate data randomly,
# the odds of getting a Simpson's paradox are about 1/60.
#
# Also see https://en.wikipedia.org/wiki/Simpson's_paradox


# The Split-apply Pattern --------------------

# aggregate() takes two steps:
#
#   1. Split the data into groups
#   2. Apply/sapply to compute on each group
#
# aggregate() is convenient but sometimes we need more flexibility.
#
# The split() function only does step 1 above.

by_group = split(simpson$height, simpson$group)

# Output is a list with 1 element per group.
head(by_group[[1]])
names(by_group)

# The sapply() function only does step 2 above.
sapply(by_group, mean)


# In addition to aggregate(), the tapply() function also combines the split and
# apply steps.
#
# t stands for table, and tapply() returns a table like the table() function.
tapply(simpson$height, simpson$group, mean)

# When should you use split-sapply instead of aggregate()?
#
#   * When you're only interested in a few groups.
#   * When you need to treat some groups specially (e.g., do a statistical
#     transformation or standardization for some groups).
#   * When you want to do something different to each group.

# For instance, we can remove groups we aren't interested in:
by_group = split(simpson$height, simpson$group)
names(by_group)
index = match(c("A", "D"), names(by_group))
index
by_group = by_group[-index]
names(by_group)

by_group[[1]]

x = c(6, 7, 8)
x[-2]

# Or we can use split() as an alternative to taking many subsets:
groupA = simpson[simpson$group == "A", ]
groupB = simpson[simpson$group == "B", ]

by_group = split(simpson, simpson$group)
by_group$A
by_group$B


# So how can we use split-apply to compute the correlations in Simpson's
# paradox?

# Doesn't work:
sapply(by_group, cor)

by_group[[1]]

# The cor() function expects 2 numerical vectors, but by_group[[1]] is a data
# frame (and so are the other elements of by_group).

# We can write our own function with the `function` keyword.
#
# Curly braces { } mark where the code starts and ends.

my_cor = function(x) {
  # Here `x` is a parameter or dummy variable. We can choose any variable name
  # we want.
  
  # We'll use this function in sapply(by_group, _____)
  #
  # So x will look like an element of by_group (for example,  by_group[[1]])
  # That is, x is a data frame with columns weight, height, group.
  
  # The output of the function is whatever's on the last line.
  cor(x$weight, x$height)
}

# The code in the function doesn't actually run until we call the function,
# either directly as in:
#   
#   my_cor(by_group[[1]])
#
# Or indirectly with sapply()


# Seems to work:
sapply(by_group, my_cor)

head(by_group[[1]])


# Airline Data --------------------

# For the next lecture we'll look at airline data from:
#
#   https://www.transtats.bts.gov/DL_SelectFields.asp
#
