# STA 141A
# Lecture 4 (Oct 9)
#
# See Piazza for office hours!

# References:
#   * TARP ch 1.4 "Preview of Some Important R Data Structures"
#   * R4DS ch 7 "Data Visualization" (book ch 5)
#   * "Visualizing Data" by Cleveland

# R Data Types ----------------------------------------

typeof("hi")
typeof(5)
typeof(5.1)
typeof(1+3i)
typeof(4L)
typeof(mean)

"5.1" # Looks like a number, but R sees a character

mean("5.1")
mean("a")

mean(5.1)

# Functions to convert between types usually start with `as.`
typeof(as.numeric("5.1"))

as.numeric("hi")

as.character(5)

# Vectors have the same type as their elements.
typeof(c(5, 3, 2.1))

# When you make a vector, R converts to the highest type (see below)
typeof(c(5, "hello", 4.1))

# Type Hierarchy
# --------------
# lists -- list()
# character -- "hello"
# complex -- 1+4i, ...
# double -- 3.1, 5.222, ...
# integers -- 1L, 2L, ...
# logical -- TRUE, FALSE
# ------------
# Outside the hierarchy:
# functions -- mean, median, typeof, ...

typeof(c(TRUE, 3L))

c(TRUE, 5.1, "hello")

typeof(mean)

# A list is a collection of elements that may have different types.
#
# The c() function creates a list if there's no way to convert all elements to
# the same type.
x = c(1, TRUE, mean, 5.1)

typeof(x)

# Lists and vectors are one-dimensional and have length
length(x)

# Similar to how data frames are two-dimensional and have dimensions
dogs = readRDS("data/dogs/dogs_full.rds")
dim(dogs)

# One-dimensional objects usually have `NULL` as their dimensions
dim(x)

# [ ] gets another list
x[4] 
sin(x[4])
typeof(x[4])

# [[ ]] gets elements inside the list
x[[4]]
typeof(x[[4]])
sin(x[[4]])

# Pepper shaker: https://twitter.com/hadleywickham/status/643381054758363136

# For vectors, [ ] and [[ ]] both return the element inside
x = c(1, 2, 3)
typeof(x)
x[1]
x[[1]]


# Q: What does "Subscript out of bounds" mean?
#
# A: This error means you tried to get an element that isn't in the list.
#
# For example, our list has length 3. So there's no element 10:
x
x[[10]]

# The [ ] operator returns NA for invalid indexes instead of causing an error.
#
# BE CAREFUL! Assuming [ ] will return a non-missing value is a common source
# of errors.
x[10]

# How are [[, ]] and [, ] different for data frames?
#
# Both return a scalar.
dogs[[4, 3]]
dogs[4, 3]

# But data frames are actually a kind of list.
typeof(dogs)

# And the elements of the list are the columns of the data frame.
all(dogs[[4]] == dogs$popularity_all)

all(dogs[[3]] == dogs$datadog) # NA because column contains NA

all.equal(dogs[[3]], dogs$datadog) # Check equality of everything

dogs[[3]] # this gets column 3 of data frame / element 3 of list

# Get column 4, element 3.
dogs[[4]][[3]] # same as dogs[[3, 4]]

typeof(dogs)

# In addition to a type, every object has one or more classes.
#
# TYPE says "What is it?" The type is how R stores the object in memory.
#
# CLASS says "What can it do?" The class says how R presents the object to
# you and how functions use the object.

# You can see the class(es) of an object with class():
class(dogs)

# You can remove the class(es) of an object with unclass().
#
# unclass() lets you see how the object looks "under the hood".
#
# So if we unclass() a data frame, we can see that it looks like a named list.
unclass(dogs)

# A named list, for comparison:
list(x = 1, y = 2)

# There are two important differences between [ ] and [[ ]]:
#
# 1. [[ ]] gets elements from inside lists (as we saw above)
# 2. [[ ]] always returns a single element.

# So the second difference means...
#


# [ ] can get many elements
#
# THIS WORKS
dogs[4, ]


# [[ ]] always returns a single element
#
# SO THIS DOESN'T WORK
dogs[[4, ]]


# More About Lists --------------------

# A list (or vector) can be an element of another list.
inner = list("hello", "hi")
x = list(1, inner, 3)
x

# Lists in lists are another case where you might use [[ ]] twice.
#
x[[2]][[1]] # get element 1 of element 2


# Apply Functions ----------------------------------------

# Let's say we want to get the class of every column in the dogs data.
#
# We could write:
class(dogs$breed)
class(dogs$group)
# ...
#
# But we're lazy, and R is supposed to make our life easy! So don't repeat
# code.

# Instead we can use sapply (pronounced S-apply).
#
#      |-- DATA (with many elements -- a vector/list/data frame)
#      v       v---- FUNCTION (to apply to each element)
sapply(dogs, class)


# The "s" in sapply() stands for "simplify". The sapply() function tries to
# return a vector that's the same length as the input data, following the same
# rules for types as c().

sapply(dogs, mean)

mean(dogs$height, na.rm = TRUE)

# You can pass additional arguments to the applied function by adding them at
# the end of sapply():
sapply(dogs, mean, na.rm = TRUE)


# Exploratory Data Analysis ----------------------------------------

# What does it mean to "explore" data?
#
# * Look for patterns (examine variation in the data)
# * Look for errors in the data
# * Look for relationships between variables
# * Look at data to get an overview (what data are present?)
# * Check assumptions (model, conclusions, etc)
#
# What are the techniques to "explore" data?
#
# * Make plots
# * Compute summary statistics
# * Fit models (including hypothesis tests, machine learning)

# Exploratory data analysis (EDA) is part science, part art. We're going to
# look at different ways to do EDA, organized by statistical data type.
#
# However, these are just baselines or suggestions for where to start.
#
# When you explore data, think of yourself as a detective or an investigative
# journalist. You need to figure out:
#
# * What questions should I ask?
# * What assumptions can I make?
#
# 

# Univariate Data --------------------

# The "group" feature is categorical.

class(dogs$group) # class "factor" is R's class for categorical data

# Factors are stored in memory as integers to save memory. 1 means first
# category, 2 means second category, etc.
typeof(dogs$group)


# How can we explore univariate categorical data?
#
# Frequency counts!

table(dogs$group) # count() dplyr
summary(dogs$group)

# Use sort() if you want to sort the table.
sort(table(dogs$group))

# Bar plots are another option.
library(ggplot2)
ggplot(dogs, aes(x = group)) + geom_bar()

# PIE CHARTS ARE EVIL!
#
# Most people have a hard time comparing arc lengths.
#
# On the other hand, most people are good at comparing linear lengths (as in a
# bar plots).
#
# So use bar or dot plots rather than pie plots.
#
# For more about human perception, including experiment-based research, see
# "The Elements of Graphing Data" by Cleveland.


# We can convert our bar plot to a dot plot by changing the geom.
#
# We also need to change the stat layer. The stat layer controls how the data
# is transformed before being displayed.
#
# Usually geoms and stats come in pairs. Every geom has a default stat.
#
# The default stat for points is "identity", which doesn't transform the data
# at all.
#
# In this case we want to count up the groups, so instead of "identity", we use
# the default stat from geom_bar, which is "count".
ggplot(dogs, aes(x = group)) + geom_point(stat = "count")


# We can adjust the axes with xlim(), ylim()
#
# But these will hide any points/lines that touch the edge of the plot.
ggplot(dogs, aes(x = group)) + geom_point(stat = "count") +
  ylim(0, 30)

# If you want to keep points/lines that touch the edge of the plot, there's
# another way to change x/y limits:
ggplot(dogs, aes(x = group)) + geom_point(stat = "count") +
  coord_cartesian(ylim = c(0, 30))

# Missing Data ----------------------------------------
#
# When you first encounter a data set, it's a good idea to explore the missing
# data.
#
# How can you explore something that's missing?
#
# The key to exploring missing data is to look for patterns in where the data
# is missing.
#
# For example, in the dogs data set, some heights are missing. But which ones?
# Is it just the terriers? Is it just the hound dogs? Or are they missing at
# random?
#
# We can check by creating a categorical feature that shows which heights are
# missing:
dogs$height_na = is.na(dogs$height)

# Now we can analyze dogs$height_na as if it were any other categorical
# variable.

table(dogs$height_na)
