# STA 141A
# Lecture 15 (Nov 15)
#
# See Piazza for office hours!

# Admin:

# References:
#   * stringr Cheatsheet:
#     https://github.com/rstudio/cheatsheets/raw/master/strings.pdf
#   * R for Data Science Chapter 14 "Strings"

# Topics Today:
#   * Regular expressions example
#   * Lubridate

# NEW Data & Packages:
#   * messy_cl_vehicles.zip (on Canvas)

# Regex Example
# =============
# Data: messy_cl_vehicles.zip
#
# This data set is similar to the messy Craigslist apartments data set,
# messy_cl.zip. The main difference is that these posts are about vehicles for
# sale rather than apartments for rent.
#
# We're going to look at some examples of how to extract features about the
# vehicles being sold in these posts.
#
# Before we can do that, we need to actually load the posts.
#
# Let's start with the North Bay posts.

data_dir = "data/craigslist/messy_vehicles"
nby_dir = file.path(data_dir, "sfbay_nby")

files = list.files(nby_dir, full.names = TRUE)
nby = lapply(files, readLines, encoding = "UTF-8")

# This works for North Bay; there are 2995 posts.
#
# We need to do the same thing for the other regions, so let's turn this code
# into a function we can use with lapply().
#
# The only part that will be different for each region is the directory, so we
# can make that the parameter for our function.

load_posts = function(directory) {
  files = list.files(directory, full.names = TRUE)

  # Return the result instead of saving it in a variable.
  lapply(files, readLines, encoding = "UTF-8")
}

# Now let's test our function on North Bay again.
nby2 = load_posts(nby_dir)

# This seems to work, so let's try this for all posts.
dirs = list.files(data_dir, full.names = TRUE)
posts = lapply(dirs, load_posts)

# The posts variable is a list with 5 elements. Each element is a list of posts
# for one of the five regions.
#
# We'd really like to have a data frame where each post is 1 row, and the text
# is in a column. Then we can use all the functions we've learned for working
# with data frames.
# 
# To figure out how to make a data frame, let's look at the format of just one
# post.

post = posts[[1]][[1]]
str(post)

# The post is a character vector with 103 elements. Each element is one line of
# text. There's a title, followed by the text of the post, followed by some
# attributes. So the format looks like:
#
# >  Title
# >
# >  Text...
# >  ...
# >  ...
# >
# >  Date Posted:
# >  ...
#
# We can make a data frame with the data.frame() function. By trying this
# function out on some vectors, or by reading the help file, we can see that it
# takes a vector argument and turns each element into one row. For example:

data.frame(1:3) # 3 rows

# So if we want each post to be a single row, we need to turn each post into a
# single string. Based on the stringr cheatsheet, the str_c() function can
# combine lines into a single string.

library(stringr)
post_string = str_c(post, collapse = "\n")

# The \n is a newline character, an invisible character that marks the end of a
# line in a text document. You can read more about special characters like
# newline at ?Quotes
#
# Now that we know how to collapse a post, we need to do this to every post.
#
# Since we already have to read every post, let's change the lapply() in load
# posts. It's more efficient to reuse the loop rather than writing another. Our
# load_posts() function becomes:

load_posts = function(directory) {
  files = list.files(directory, full.names = TRUE)

  # Use sapply() now since str_c() returns a single string.
  sapply(files, function(file) {
    post = readLines(file, encoding = "UTF-8")
    str_c(post, collapse = "\n")
  })
}

# So now we can use load_posts() to get a single vector:
nby3 = load_posts(nby_dir)
str(nby3)

# We can use the vector to make a data frame. In fact, since we know we want a
# data frame for each region, let's include this step in load_posts(). Our
# final version of the function is:

load_posts = function(directory) {
  files = list.files(directory, full.names = TRUE)

  posts = sapply(files, function(file) {
    post = readLines(file, encoding = "UTF-8")
    post_string = str_c(post, collapse = "\n")
  })
  
  # Make a data frame, and include the region name.
  data.frame(text = posts, region = basename(directory))
}

# Again we can use this in lapply():

posts = lapply(dirs, load_posts)
str(posts)

# Now we have a list of 5 data frames, 1 for each region. How can we combine
# these?
#
# You may already know the rbind() function to bind data frame rows,
# essentially stacking the data frames on top of each other. We could write
#   
#   rbind(posts[[1]], posts[[2]], posts[[3]], posts[[4]], posts[[5]])
#
# but this is really tedious.
#
# We want to call rbind(), but use a list (posts) as the arguments. We can do
# this with do.call(), which calls a given function with a given list of
# arguments. So:

posts_df = do.call(rbind, posts)
str(posts_df)

# Now we've finally got a data frame with all of the posts.
#
# This is great because the stringr functions are all vectorized. We can use
# them on the entire text column when we extract features.
#
# Let's start with something easy. We'll get the title of each post.
#
# As usual, we'll simplify the problem by first looking at just 1-2 cases.

test = posts_df$text[[1]]
message(test)

# The title is on the first line. How can we tell where the first line is?
#
# Remember that when we combined all the lines in the post, we put a newline \n
# between each line. So there's a newline at the end of the first line!
#
# We can use our old friend str_split_fixed() to get the title:
result = str_split_fixed(test, "\n", 2)
result[, 1]

# This seems to work, so let's try it on the entire data frame.
result = str_split_fixed(posts_df$text, "\n", 2)

head(result[, 1])

# Looks good, so let's save the title into a new column, and replace the text
# column to exclude the title.
posts_df$title = result[, 1]
posts_df$text = result[, 2]

# Next, let's get the attributes at the end of each post. We know these start
# with a newline \n followed by "Date Posted", so:
test = posts_df$text[[1]]

result = str_split_fixed(test, "\nDate Posted:", 2)
result[, 2]

# Again, this seems to work. So let's do this for all the posts.

result = str_split_fixed(posts_df$text, "\nDate Posted:", 2)
posts_df$text = result[, 1]
posts_df$attribs = result[, 2]

# Now let's separate out the attributes. Each is on a separate line, so we can
# just split on newlines.
#
# As usual, we try for just one post first.

test = posts_df$attribs[[1]]
str_split(test, "\n")

# We could reuse our str_split_fixed() strategy from before, where we split off
# just one attribute, make a new data frame column, and then move on to the
# next. It works, but it's tedious and basically repeats the same step for each
# attribute.
#
# We can do it more elegantly by writing a loop, or by taking advantage of the
# fact that we know there are exactly 7 attributes. Let's do the latter.

result = str_split_fixed(test, "\n", 7)

# This is good, but we'd really like the name of the attribute and the value of
# the attribute separately.
#
# First let's just get the names of the attributes from this result.
# Eventually, we'll use these a column names in our data frame. We have to add
# "Date_Posted" manually since we removed it earlier:

result2 = str_split_fixed(result[1, -1], ": ", 2)
names = c("Date_Posted", result2[, 1])
names = tolower(names) # lowercase column names are easier to type

# Now let's try to get the values for all the attributes.

result = str_split_fixed(posts_df$attribs, "\n", 7)

result[2, ] # peek at second row

# Let's make this into a data frame and name the columns appropriately.

result_df = as.data.frame(result)
names(result_df) = names

# The values in each row still contain the attribute names. Let's try removing
# these for one column. We can do this with str_remove() and a regex that
# matches all letters and spaces up to the first ":".

price = str_remove(result_df$price, "^[A-z ]+: ")
result_df$price = price

# We can repeat this for the rest of the columns with an lapply():
cols = names(result_df)[-c(1, 2)]
result_df[cols] = lapply(result_df[cols], str_remove, "^[A-z ]+: ")

# Finally, let's bind this data frame to our posts data frame.

result = cbind(posts_df, result_df)
str(result)

# Looks good, so save this as the new posts_df and remove the attribs column:
posts_df = result

posts_df = posts_df[-match("attribs", names(posts_df))]

# We're done breaking down the parts of the post. The next step is to convert
# the columns of our data frame to appropriate types.
#
# Let's just do one here as an example; you can try the others for practice.
#

# Dates & Lubridate
# =================

# We'll convert the date_posted column into actual dates.
#
# To do this, we'll use the strptime() function, which converts a string into a
# date (the POSIXct and POSIXlt classes).
#
# The strptime() function's second argument is a string that describes the date
# format. You can learn more about the date format language by reading the
# ?strptime help file. The date format language is good to know because it's
# used in many programming languages, not just R.
#
# For our dates, the format we need is
#   
#   MONTH DAY, YEAR at HOUR:MINUTE
#
# which is
#
#   %B %d %Y at %H:%M
#
# in the date format language. So:
test = posts_df$date_posted[[1]]

strptime(test, "%B %d, %Y at %H:%M")

# For some reason this doesn't work. Did we get our format wrong? Let's check:
strptime("November 14, 2018 at 12:48", "%B %d, %Y at %H:%M")

# It looks like the pattern works. So is something wrong with test?
str(test)

# Ah, it's a factor. So the whole date_posted column must be a factor. Let's
# fix that.

posts_df$date_posted = as.character(posts_df$date_posted)

# In fact, this could be a problem for all the columns, since data.frame()
# automatically converts character columns to factors. So it's a good idea to
# check:
str(posts_df)

# We could fix the columns that are factors; that's left as an exercise.
#
# Let's convert the dates now.
test = posts_df$date_posted[[1]]

strptime(test, "%B %d, %Y at %H:%M")

# Again this doesn't work. Notice that the date starts with an extra space " ".
# In fact, all of our date_posted strings do. So we need to match this in our
# date format string.

strptime(test, " %B %d, %Y at %H:%M")

# Now it works, so let's do the whole column.

result = strptime(posts_df$date_posted, " %B %d, %Y at %H:%M")

# Finally, note that the lubridate package provides many functions to make it
# easier to work with dates that are in standard formats.
#
# Using lubridate, we could just write:

library(lubridate)

result = mdy_hm(posts_df$date_posted)

# However, I've shown you strptime() because learning the date format language
# is essential if you ever have to deal with a date that's not in a standard
# format.
#
# Let's save the result of our work:

posts_df$date_posted = result

# Now that the data frame is in good shape, let's also save a copy in case we
# want to restart R or make a mistake later.
saveRDS(posts_df, "vehicle_posts.rds")


# Extracting Features
# ===================
# As our last example, let's try extracting a more difficult feature.
#
# When buying a vehicle, the odometer reading of the vehicle is an important
# detail to consider. The odometer reading is the number of miles the vehicle
# has driven since being made, and is a good indicator of how long the vehicle
# will continue to work.
#
# First let's see if many posts include the word odometer.
table(str_detect(posts_df$text, "odometer"))

# The number of posts that match is very low. This could be because of the case
# of the word, so let's ignore case:
is_odo = str_detect(posts_df$text, regex("odometer", ignore_case = TRUE))
table(is_odo)

# That doesn't help much, so let's try looking for the word "miles" as well.
is_odo = str_detect(posts_df$text, regex("odometer|miles", ignore_case = TRUE))
table(is_odo)

# Now we get more than half the posts. What's going on with the other half?
# Let's take a look at some:

head(posts_df$text[!is_odo])

# Some of these don't have any odometer reading, but others use the word
# "mileage". So let's include that in our search.
pattern = regex("odometer|miles|mileage", ignore_case = TRUE)
is_odo = str_detect(posts_df$text, pattern)
table(is_odo)

# That helps a lot. If we wanted to improve our result, we could keep examining
# posts that don't match. This is similar to examining residuals in a
# statistical model in order to find out how to improve the model.
#
# Let's go ahead and move on now that we have more than 3/4 of the posts.
# 
# We need to actually extract the odometer reading, so let's see what the it
# looks like in some of these posts:

message(posts_df$text[is_odo][[1]]) # 139,144 Miles

message(posts_df$text[is_odo][[2]]) # Mileage:16,404

# Based on these two samples:
#   * The actual reading will be a number, possibly with commas.
#   * Related words may appear before or after the number, separated by spaces
#     or punctuation.
#
# So let's try this regex:
#
#                          --------- match the number
#   (odometer|mileage)[: ]*([0-9,]+)
#   ----------------------- match the word before
#
# We also need to match cases where the word appears after, so we can also try
# the regex:
#
#   --------- match the number
#   ([0-9,]+) ?(miles?|odometer|mileage)
#               ------------------------- match the word after
#
# Let's try both of these on all the posts. We want the number in a group so
# that we can get it easily using str_match().

re1 = regex("(odometer|mileage)[: ]*([0-9,]+)", ignore_case = TRUE)
re2 = regex("([0-9,]+) ?(miles?|odometer|mileage)", ignore_case = TRUE)

m1 = str_match(posts_df$text, re1)
m2 = str_match(posts_df$text, re2)

# Let's combine the number columns from each:

result = cbind(m1[, 3], m2[, 2])

# Are there any rows where we got a match for both patterns?

num_na = rowSums(is.na(result))
table(num_na)

head(result[num_na == 0, ])

# Clearly there are. So what's going on with these posts? Let's check the
# texts:

posts_df$text[num_na == 0][[3]]

# It's subtle, but the problem is that the post contains "00Mileage: 167,403".
#
# Let's require that the number of miles starts with a nonzero number.

re1 = regex("(odometer|mileage)[: ]*([1-9][0-9,]*)", ignore_case = TRUE)
re2 = regex("([1-9][0-9,]*) ?(miles?|odometer|mileage)", ignore_case = TRUE)

m1 = str_match(posts_df$text, re1)
m2 = str_match(posts_df$text, re2)

# Now we can check the result again.
result = cbind(m1[, 3], m2[, 2])
num_na = rowSums(is.na(result))
table(num_na)

# How many rows still have a match for both patterns and different values?
table(num_na, result[, 1] != result[, 2])

# There's still a lot, so let's look at another post:

is_bad = which(result[, 1] != result[, 2])
bad_posts = posts_df$text[is_bad]
bad_posts[[30]]

result[is_bad, ][30, ]

result[num_na == 0, ][30, ]

# This post says "Mileage: 93k miles", and also guarantees a "3000 MILES"
# warranty. So we need to include "k" as an option for our number, and we need
# to do something to elimnate warranties.
#
# First let's add "k":

re1 = regex("(odometer|mileage)[: ]*([1-9][0-9,]*k?)", ignore_case = TRUE)
re2 = regex("([1-9][0-9,]*k?) ?(miles?|odometer|mileage)", ignore_case = TRUE)

m1 = str_match(posts_df$text, re1)
m2 = str_match(posts_df$text, re2)

# Now we check our result again:
result = cbind(m1[, 3], m2[, 2])
num_na = rowSums(is.na(result))
table(num_na)

is_bad = which(result[, 1] != result[, 2])
length(is_bad)

# Now we get about 9k of the 11k posts that mention an odometer reading, but we
# still have 1k posts with two different matches.

head(result[is_bad, ])

# Are these posts just getting two matches because of the the 1000 mile
# guarantees? Let's check how often "1000" appears:
is_1k = str_detect(result[is_bad, ], "1,?000")
sum(is_1k) / length(result[is_bad, ])

# Only about 2%, so what's wrong with the rest? Let's check the text again:

posts_df$text[is_bad][[50]]
result[is_bad, ][50, ]

# Looks like "99896Mileage: 61,565" is causing the problem.
#
# One way to deal with this is to prioritize the re1 pattern over the re2
# pattern. This might not always be correct, but it's a reasonable choice. We
# could randomly sample some two-match posts to check if this strategy holds
# up.
#
# Let's get our odometer readings using this strategy.

odo = result[, 1] # default to re1 match

is_na = is.na(odo)
odo[is_na] = result[is_na, 2] # get re2 match where re1 did not match

table(is.na(odo))

# Now we have odometer readings for 9k posts.
#
# We could study the posts where we re1 and re2 both DID NOT match to improve
# our accuracy. The process is similar to what we just did to improve accuracy
# where both matched.
#
# So let's skip straight to converting the odometer readings to numbers.
#
# The as.numeric() function doesn't understand commas:
as.numeric("1,000")

# So first let's just remove commas from our odometer readings:

odo = str_remove_all(odo, ",")

# Next, we need to check for readings that end with "k". We want to remember
# these so we can multiply by 1000 later.

is_k = str_which(odo, "[Kk]") # 2531 readings end with "k"

# Now let's remove the "k" and convert to numbers:

odo = str_remove_all(odo, "[Kk]")
odo_num = as.numeric(odo)

# Finally, let's multiply by 1000 where the "k"s were:

odo_num[is_k] = odo_num[is_k] * 1000

# Now we've got odometer readings, so we can add these to our data frame:

posts_df$odometer = odo_num

# Remeber that if we wanted better accuracy, we would just need to further
# refine our regular expressions by examining the text of the posts.
