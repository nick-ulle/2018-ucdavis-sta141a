# STA 141A
# Lecture 2 (Oct 2)
#
# See Piazza for office hours!

# The reference I originally listed was about ggplot2 (which I didn't have time
# to discuss). So here are updated references.
#
# For this lecture:
#   * R4DS ch 6 "Workflow: scripts" (book ch 4)
#   * R4DS ch 8 "Workflow: projects" (book ch 6)
#
# For the next lecture:
#   * R4DS ch 3 "Data Visualization" (book ch 1)

# Dogs example:
setwd("~/university/teach/sta141a/notes")

dogs = readRDS("dogs_full.rds")
head(dogs)

library(ggplot2)
ggplot(dogs, aes(x = datadog, y = popularity, color = group)) +
  geom_point()


# Setting Up A Data Analysis --------------------

# 1. Create a project folder.
# 2. Download the data (and move it to the project folder).
# 3. Load the data.

# Files & Paths --------------------

# In order to load the data, you need to tell R where the data is.

# Get the path to the working directory.
getwd()

# Set the working directory.
setwd("/home")

# When you write a script, try to plan so that other users can run your code.
#
# One way to do that is to avoid using setwd() in scripts. Other users probably
# don't have the same file system as you!
#
# If you put data in the same folder as your script (or a 'data/' subfolder),
# then you can use relative paths to load data and avoid setwd().
#
# It's fine to use setwd() in the R console at the beginning of a project.

# An absolute path starts from the top of the hard drive ("/" or "C:\").
setwd("/home/nick")

# A relative path starts from the working directory.
setwd("nick") # This path is relative to '/home'.

# "~" is a shortcut to your personal directory (on my machine: '/home/nick')
setwd("~")

# List files in working directory.
list.files()

list.files("/")

setwd("~/sta141a")
list.files()

dogs_top = readRDS("dogs_top.rds")

# Checking Structure --------------------
# Once you've loaded the data, the natural first step is to check how the data
# is structured.

# Get number of columns/rows.
ncol(dogs_top)
nrow(dogs_top)

dim(dogs_top)

dogs = readRDS("dogs_full.rds")

dim(dogs)

# What are the column names?
colnames(dogs)

rownames(dogs)

names(dogs)

# What is the overall STRucture of the data?
str(dogs)

# Summarizing Data --------------------
# R also has functions to help you summarize the content of the data.

# Get top 6 rows.
head(dogs)

head(dogs, 10)

# Get bottom 6 rows.
tail(dogs)

# Get statistical summaries.
summary(dogs)

# Other summary statistics.
?mean
?median
?sd
?var
??"variance"
?IQR

# Can't compute summary statistic on entire data frame.
sd(dogs)

# These functions expect vectors of numbers instead.
sd(c(1, 3, 4, 7, 8, 2))

# Subsets --------------------

# So we need to extract a single column. We can use $ to get a column by name.
sd(dogs$height)

# NA stands for "not available", a missing value. When the data set was
# created, the author didn't include a value for that measurement.
#
# Many functions have an na.rm parameter, which you can use to tell R to ignore
# missing values.
sd(dogs$height, na.rm = TRUE)

# Since the value of NA is unknown, the default value of any arithmetic or
# statistic that involves NA is also unknown.
5 + NA

# So while you can use == to check numbers for equality...
c(4, 5, 6) == 6

# ...it won't work for NA, because one NA might not equal another NA.
c(4, NA, 6) == NA

# Instead, you can check for NAs with:
is.na(NA)

is.na(5)

is.na(dogs$height)

# You can get frequency counts for a categorical variable with table().
table(dogs$group)

# TRUE/FALSE values are categories, so you can also use table() to count the
# number of NAs in a vector or column.
table(is.na(dogs$height))


# There's another way to subset that's more general than $.
#
# With [, ] you can get specific rows and columns.
dogs[1, 1]
#    ^  ^----- column
#    |-------- row


dogs[1, 4]

# A blank entry in [, ] means all rows or all columns.
dogs[1, ] # row 1, all columns

is.na(dogs[, 1])

# Q: How can we get just the rows where the height feature is not NA?

# A: We saw the condition
is.na(dogs$height)

# We can use conditions to subset with [, ]. 
#
# Since we want rows where height is NOT NA, we also need to negate the
# condition. The negation operator is !.
not_na = !is.na(dogs$height)

dogs[not_na, ]

# Q: How can we find out the row numbers for rows with NAs?
#
# A: Use which() to find positions of TRUEs in a logical vector.
which(is.na(dogs$height))


# Finally, you can also use names in [, ].
dogs[, "breed"]

# So there are three ways to use [, ]:
#
#   * With numerical indexes, like dogs[1, ]
#
#   * With logical vectors, like dogs[not_na, ]
#
#   * With names, like dogs[, "breed"]


# Packages --------------------
# Listed at:
#
#   https://cran.r-project.org/
#

# Install package on machine (do one time)
install.packages("ggplot2")

# Load a package (do every time you restart R)
library("ggplot2")
