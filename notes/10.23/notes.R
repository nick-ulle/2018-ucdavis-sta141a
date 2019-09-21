# STA 141A
# Lecture 8 (Oct 23)
#
# See Piazza for office hours!

# References:

# Links:
# * https://www.npr.org/sections/health-shots/2018/10/22/656594050/a-new-prescription-for-depression-join-a-team-and-get-sweaty
# * https://www.7-zip.org/


# Airline Data --------------------

# A zip file with the airline data is available on Canvas.
#
# The airline data is originally from:
#
#   https://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236
#

# A zip file is a kind of archive. An archive bundles a bunch of files into one
# file, so they don't get lost, are easier to transfer/download, and so on.
#
# A zip file is also a kind of compression. Compression stores files more
# efficiently (using fewer bytes). There are two kinds of compression:
#
# * Lossy (some info is lost): jpeg (images), mp3 (music), ...
# * Lossless (no info is lost): png (images), flac (music), zip, ...
#
# Zip files are lossless.


# CSV stands for Comma-Separated Values.
#
# CSV files are the primary way tabular data is distributed online.
#
# They are plain text files, and look like:
#
# 1,3,"hello"       <---- rows
# 1.4,6,"hi"        <--/
#
# Commas separate columns, new lines separate rows.


# Since CSV files are plain text files, you can open a CSV file with a text
# editor to take a look at the format.
#
# Suggested Text Editors:
#   * Windows: Notepad++ <https://notepad-plus-plus.org/>
#   * OS X: Atom <https://atom.io/>
#   * OS X: Sublime Text <https://www.sublimetext.com/> -- NOT FREE
#
# Built-in Text Editors (if you don't want to install anything):
#   * Windows: Notepad
#   * OS X: TextEdit
#   * Linux: nano
#
# Extreme Text Editors (if you feel adventurous):
#   * Neovim <https://neovim.io/>
#   * Vim <https://www.vim.org/>
#   * Emacs <https://www.gnu.org/software/emacs/>
#
# It's a good idea to get familiar with at least one text editor, since your
# text editor is your main tool to inspect unfamiliar files.
#
# Microsoft Word is NOT a text editor, it's a word processor, and the
# difference matters.
#
# RStudio is NOT a text editor, it's an integrated development environment
# (IDE), and the difference matters. Usually an IDE is good for 1-2 specific
# languages, whereas a text editor is like Swiss army knife.


# We need to specify whether or not the file has a header.
air = read.csv("data/airline/2018.01_air_delays.csv", header = TRUE)

head(air)
names(air)
dim(air)
summary(air)

# CSV files are a bit messy
#
# Need to check that the R data types are appropriate for the statistical data
# types
#
# Use factor(), as.character(), as.numeric(), etc to change data types.

# For example, DAY_OF_WEEK is really categorical, and should be a factor.
day_of_week = factor(air$DAY_OF_WEEK)

summary(day_of_week)
head(day_of_week)

# Read lookup table for DAY_OF_WEEK numbers (from the data website).
days = read.csv("data/airline/L_WEEKDAYS.csv_")
days

# Now we can rename the levels.
#
# One way to rename the levels is to type them out:
levels(day_of_week) = c("Monday", "Tuesday", "...")

# Another way to rename levels:
#
# This way requires that the order in days$Description is correct.
levels(day_of_week) = days$Description

levels(day_of_week)

# One more way to rename levels:
m = match(day_of_week, days$Code)
day_of_week = days$Description[m]

# This way is the best combination of speed and reliability.


# Check that the result makes sense:
table(day_of_week)
table(air$DAY_OF_WEEK)

# Save the result:
air$DAY_OF_WEEK = day_of_week



# What kinds of questions can we ask (or answer) with this data?
#
#
# * What airports are most likely to have delays? Or least likely?
# * Check for seasonal delays (but we would need data on more months)
# * What area or region is most likely to have delays?
# * What are the main causes of delay?
#     * How often does weather cause a delay?
# * Does a delay on one flight cause later delays (for the same plane)?


# Are there more delays on certain days of the week? Are there more flights?

table(air$DAY_OF_WEEK)

names(air)

# -> First make our question more specific within the context of the data set.
#
# Let's look at arrival delay (numerical) and day of week (categorical)
#
head(air$ARR_DELAY)
summary(air$ARR_DELAY)

library(ggplot2)
gg = ggplot(air, aes(DAY_OF_WEEK, ARR_DELAY)) +
  geom_boxplot()

# Most flights are on time!
# 
# But flights that aren't on time are mostly very late!
#
# Let's zoom in on the part of the plot where most of the observatons are:

gg + ylim(-50, 50) + geom_hline(yintercept = 0)

# In fact, most flights are early!



# THINK ABOUT: How would we find out how many flights are very late (beyond the
# whisker)?


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
ontime = air$ARR_DELAY <= 0
head(ontime)
table(ontime)

air$ontime = ontime
table(air$ontime, air$OP_UNIQUE_CARRIER)
names(air)

# The table is hard to read

head(air$OP_UNIQUE_CARRIER)

ggplot(air, aes(ontime, fill = OP_UNIQUE_CARRIER)) +
  geom_bar(position = "dodge")

# The bar plot is also hard to read, because there are so many carriers.

# Instead, use ontime for the fill color and put carriers on the axis:
ggplot(air, aes(OP_UNIQUE_CARRIER, fill = ontime)) +
  geom_bar(position = "dodge")

# Now we can see what's going on.
