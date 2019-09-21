# STA 141A
# Lecture 16 (Nov 27)
#
# See Piazza for office hours!

# Admin:
#   * Extra OH:
#       + Patrick: Rescheduled due to car problems
#       + Nick: TODAY 4-7pm (max 8pm) in MSB 1139
#       + Ken: Wed 2-5pm in Carlson 110
#   * Assignment 5 due Dec 1
#   * Assignment 6 (final project) coming Nov 29 (due Dec 11)
#   * Reminder: no in class final

# References:
#   * stringr Cheatsheet:
#     https://github.com/rstudio/cheatsheets/raw/master/strings.pdf
#   * R for Data Science, Ch 14 "Strings"
#   * The Art of R Programming, Ch 13

# Topics Today:
#   * String/date processing and regular expressions Q & A
#   * Debugging

# NEW Data & Packages:

# Debugging
# =========
# On Canvas: data/messy_cl_vehicles.zip

# Key idea: work backwards from the problem or thing that went
# wrong

x = "1,000"
x = as.numeric(x)
result = sqrt(x + 1)
result

# Harder to debug, can't run individual lines as easily:
result = sqrt(as.numeric("1,000") + 1)

# Write short lines and use variables

# From 11/15
data_dir = "data/craigslist/messy_vehicles"
dirs = list.files(data_dir, full.names = TRUE)

library(stringr)

load_posts = function(directory) {
  files = list.files(directory, full.names = TRUE)

  posts = sapply(files, function(file) {
    
    #stop("Error!") # <--- causes an error
    post = readLines(file, encoding = "UTF-8")
    post_string = str_c(post, collapse = "\n")
  })
  
  # Make a data frame, and include the region name.
  data.frame(text = posts, region = basename(directory))
}

posts = lapply(dirs, load_posts)
str(posts)

# 1. One way to debug a function is to remove the body of the
# function and test each line.
# Code from load_posts():
# load_posts() has a directory parameter
directory = dirs[[1]]
files = list.files(directory, full.names = TRUE)

posts = sapply(files, function(file) {
  stop("Error!") # <--- causes an error
  post = readLines(file, encoding = "UTF-8")
  post_string = str_c(post, collapse = "\n")
})

# Make a data frame, and include the region name.
data.frame(text = posts, region = basename(directory))
# -----

# 2. Another way to debug a function is to use debug()
debug(load_posts)

posts = lapply(dirs, load_posts)
undebug(load_posts)

# 3. Another way to debug is with browser()

load_posts = function(directory) {
  files = list.files(directory, full.names = TRUE)
  
  posts = sapply(files, function(file) {
    browser()
    stop("Error!") # <--- causes an error
    post = readLines(file, encoding = "UTF-8")
    post_string = str_c(post, collapse = "\n")
  })
  
  # Make a data frame, and include the region name.
  data.frame(text = posts, region = basename(directory))
}

posts = lapply(dirs, load_posts)


# 4. Another way to debug is with the traceback:

load_posts = function(directory) {
  files = list.files(directory, full.names = TRUE)
  
  posts = sapply(files, function(file) {
    stop("Error!") # <--- causes an error
    post = readLines(file, encoding = "UTF-8")
    post_string = str_c(post, collapse = "\n")
  })
  
  # Make a data frame, and include the region name.
  data.frame(text = posts, region = basename(directory))
}

posts = lapply(dirs, load_posts)

# The options() function changes global options in R.
?options

# We can change the `error` option to have R call a function when an error
# occurs.
#
# The recover() function prints out the stack trace and asks where you would
# like to debug.
options(error = recover)

# To turn off error recovery, set `error` to NULL.
options(error = NULL)


# Q & A
# =====
library(stringr)

# Q: How to grab characters before and after a pattern in a string?
x = c("The blue cat was fluffy.", "The red dog liked to bark.")

# Let's try to extract adjectives like "blue" and "red",
# whenever they appear in front of "dog" or "cat".
#
# We'd also like our code to work with other adjectives

pattern = "dog|cat"
str_extract(x, pattern)

"\n" # <-- newline in R
message("hi")
#message("\")
message("\\")

pattern = "\\w+ (dog|cat)"
?regex

pattern = "([A-Za-z]{3}) (dog|cat)"
str_extract(x, pattern)

str_match(x, pattern)

# Q: How does {} work in regex?
pattern = " (a{3})b"

str_extract("aaaaaaaab", pattern)
str_match("aaaaaaaab", pattern)

# {1,5} repeats 1 to 5 times
# Note no space after , in {}

# Q: Can we ignore case using some kind of regex command?

# [A-Za-z]

# To turn off case sensitivity, use fixed() or regex() around the
# pattern
str_detect("A", "a")

str_detect("A", regex("a", ignore_case = TRUE))

# Q: Lookahead and lookbehind
x = c("blue cat", "blue dog", "red dog")

# We'd like to match any word that comes after "blue", and
# just extract that word
str_match(x, "blue (\\w+)")

# We could also do this using lookaheads and lookbehinds
str_extract(x, "(?<=blue )\\w+") # lookbehind

# The idea of a lookahead is the same, but matches something
# after the string.

# Note that lookaheads and lookbehinds are not captured:
str_match(x, "(?<=blue )\\w+")

# Most of the time, there are simpler ways to extract parts of the string than
# to use a lookahead/lookbehind.
#
# Lookaheads and lookbehinds tend to be slow to compute, so avoid them if
# possible.


# Q: What does the word() function do?
x = c("The cat was blue.")
word(x, 2)

str_split(x, " ")
word(x, 4)

word

# Q: How do date processing and date format strings work?

x = "27 November 11:38am 2018"

# We want R to know that x is a date and not a string

?strptime
# also see lubridate package

result = strptime(x, "%d %B %H:%M%p %Y")

# You can set the timezone with tz=

class(result)
# POSIXlt or POSIXct (POSIXt)

x = "Nov 27 2018"
strptime(x, "%b %d %Y")

# Note: The date format codes that mention 'locale' are talking about your
# computer's default language.
#
# For example, "%B" matches month names in your computer's default language.
#
# If you want to match month names in English, you can override the default
# language for times in R by running:
Sys.setlocale("LC_TIME", "English")

# Thanks to an anonymous student for pointing Sys.setlocale() out to me!
