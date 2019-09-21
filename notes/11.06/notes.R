# STA 141A
# Lecture 12 (Nov 6)
#
# See Piazza for office hours!

# Admin:
#   * Participation grade estimates posted
#   * New office hour (Thursday afternoon, exact time/place TBA)
#   * Getting help -- contact me if you want an appointment about your grades.
#   * Go vote!

# References:
#   * Reading Text Files: The Art of R Programming 10.2
#   * Loops: The Art of R Programming 7, 13
#   * Apply Functions: https://stackoverflow.com/a/7141669

# Topics Today:
#   * Weeks 1-5 Recap
#   * Reading Text Files
#   * Loops

# NEW Data & Packages:
#   * catalog.zip (on Canvas)
#   * Package 'stringr'

# Recap
# =====
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


# Recap: the match() function
?match

text = c("y", "x", "zx", "xy", "a", "x")
match(c("x", "y", "q"), text, nomatch = 0)

which("x" == text)

dogs = readRDS("data/dogs/dogs_top.rds")
head(dogs)

dogs$breed
index = match("Beagle", dogs$breed)
dogs[index, ]

index = match(5, dogs$popularity_all)
index
dogs[index, ]

# Recap: geom_jitter()
my_data = data.frame(
  x = c(1, 1, 1, 2),
  y = c(1, 1, 1, 2)
)

head(my_data)
library(ggplot2)

ggplot(my_data, aes(x, y)) + geom_point()

ggplot(my_data, aes(x, y)) + geom_jitter(height = 0.01, width = 0.01)


# Recap: Taking Subsets
# =====================
# Four ways to take subsets:
# 1. Using $ to get columns
dogs$breed
class(dogs$breed)

# 2. Using subset() to get rows (mainly for data frames)
subset(dogs, weight >= 10 & popularity_all > 5)

subset(dogs, weight >= 10 | popularity_all > 5)

# 3. Using [[ ]] to get elements (or for data frame, columns)

dogs[[1]] # with indexes/numbers
dogs[["breed"]] # with names
class(dogs[["breed"]])

# Only gets one object/element.
dogs[[c("breed", "group")]]

# 4. Using [ ] to get elements (rows or cols for data frame)

# Keeps the class of the original object (the one you're subsetting)
dogs["breed"] # with names
class(dogs["breed"])

dogs[2] # with indexes/numbers

# Two-argument version: [rows, columns]
dogs[1, 3] # keeps the class
dogs[[1, 3]] # drops the class

is_heavy = dogs$weight >= 10
is_heavy
length(is_heavy)
nrow(dogs)

dogs[is_heavy, ] # with conditions/logical vectors

which(is_heavy)
dogs[which(is_heavy), ]


# Reading Text Files
# ==================
# Data: catalog.zip on Canvas

?readLines
sta = readLines("data/ucd_catalog/catalog/STA.txt")
class(sta)
length(sta)
head(sta)

?open

# We could also open the file as a connection.
#
# This keeps the file open until we explicitly close it with close().

con = file("data/ucd_catalog/catalog/STA.txt", "rt")
readLines(con)
# We can read again if necessary...
# ...

close(con)

# No need to create a connection unless you need to read from the same file
# multiple times.
#
# So most of the time, just use readLines() without file() and close().


# How do we load all of the course descriptions?
#
# Easier question: How do we find out the names of all of the text files?
files = list.files("data/ucd_catalog/catalog/")
files[[1]]
readLines(files[[1]])

?list.files

files = list.files("data/ucd_catalog/catalog", full.names = TRUE)
files[[1]]
readLines(files[[1]])

# We want to use readLines() with every file path in files.
#
# We can use sapply() or lapply() for this!
desc = lapply(files, readLines)
length(desc)
class(desc)
class(desc[[1]])
head(desc[[1]])

head(desc[[2]])

head(desc[[length(files)]])
files


# Loops
# =====
# A loop is a programming tool or function or command that lets you
# do something over and over.
#
# Four ways to write loops in R:
# 1. apply functions: lapply(), sapply(), apply(), tapply()
sapply(c(1, 2, 3), sin) # 's' stands for simplify
class(sapply(c(1, 2, 3), sin))

lapply(c(1, 2, 3), sin) # 'l' stands for list
class(lapply(c(1, 2, 3), sin))

# lapply() always outputs a list

# Generally a bad idea to use apply functions if the function is vectorized:
sin(c(1, 2, 3)) # GOOD

sapply(c(1, 2, 3), sin) # BAD

# But not all functions are vectorized. For example:
sapply(dogs, class)

# The apply() function applies over rows or columns (or other
# dimensions). Mostly useful to apply over rows of a data frame.
dogs
apply(dogs[c("weight", "height")], 1, mean, na.rm = TRUE)
head(dogs)

# tapply() is similar to:
#   * aggregate()
#   * split() followed by sapply()
#
# Mostly useful with data frames.

tapply(dogs$height, dogs$group, mean, na.rm = TRUE)

# We'll see three more ways to write loops in the next lecture.
