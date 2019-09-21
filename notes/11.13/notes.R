# STA 141A
# Lecture 14 (Nov 13)
#
# See Piazza for office hours!

# Admin:
#   * New office hour: Thursdays 4-5pm MSB 1117

# References:
#   * stringr Cheatsheet:
#     https://github.com/rstudio/cheatsheets/raw/master/strings.pdf
#   * R for Data Science Chapter 14 "Strings"

# Topics Today:
#   * Package 'stringr'
#   * Regular expressions

# NEW Data & Packages:
#

# String Processing
# =================
# Data: catalog.zip on Canvas

# We can use a loop to load all the files.
files = list.files("data/ucd_catalog/catalog", full.names = TRUE)

all_files = lapply(files, readLines)

# We also want to extract course descriptions and features related to course
# descrptions from each file.
#
# We could write another loop to do that, but then we're looping over the files
# twice, which is not very efficient.
#
# Instead, let's extract each course descriptions in the same loop as the one
# where we load each file. We're using lapply() to loop, so we need a function
# that reads a file and then extracts the course descriptions.
#
# There are no built-in functions to extract course descriptions, so we'll have
# to write our own.
#
# The input from lapply() is one file name, since we're looping over the
# variable `files`. For example:
files[[1]]

get_desc = function(file) {
  # Load the file.
  text = readLines(file)

  # Each description is on one line. There are blank lines between the
  # descriptions.
  #
  # Get rid of the blank lines:
  desc = text[text != ""]

  # Return the descriptions.
  #
  # R functions automatically return whatever's on the last line.
  desc
}

# Now let's test the function.
#
# We need to try a few different files in case some are different.
get_desc(files[[1]])

get_desc(files[[48]])

get_desc(files[[103]])

# It looks like get_desc() works, so now what?
#
# Let's try using the function in our loop, lapply(). Remember: always test one
# iteration, like we did above, before trying the loop.
#
#
descriptions = lapply(files, get_desc)

# There are 211 files, so we get a list with 211 elements.
class(descriptions)
length(descriptions)

# Each element is the descriptions for one file.
class(descriptions[[1]])
length(descriptions[[1]]) # 122 descriptions in first file

# Now what? The descriptions are not very useful for doing statistics when
# they're just one long string. We need to extract some features.
#
# For each description, let's try to get:
#   * Three letter code, like 'STA'
#   * Course number
#   * Course title
#   * Number of credits
#   * Number of hours
#   * Prerequisites
#   * Description
#
# Notice that I said 'for each description'. Does that mean we need to write
# another loop, or change get_desc()? Usually the answer would be yes, but
# recall that stringr's string manipulation functions are vectorized.
#
# Vectorization is almost always faster than lapply(). Since we want to extract
# the same thing from every description, it's better to use vectorization than
# to change get_desc().
#
# To use vectorization, we need a vector. But we have a list of vectors:
class(descriptions)
class(descriptions[[1]])
class(descriptions[[3]])

# How can we combine all of the descriptions into one vector?
#
# The unlist() function simplifies a list into a single vector:
desc = unlist(descriptions)

class(desc)
length(desc) # now 24106 descriptions

# Now let's try to extract the three letter code for each description.
library(stringr)

# Start with just one post, and then generalize the code to others.
test = desc[[1]]

# Recall the str_split_fixed() function, which splits a string into a fixed
# number of pieces.
#
# Split test at " ", into 2 pieces:
str_split_fixed(test, " ", 2)

# The first piece is the 3-letter department code. So now let's do this for all
# the descriptions:
code = str_split_fixed(desc, " ", 2)

code[1, ]
class(code)

# Now we have a matrix where each row is a description. The first column is the
# course code and the second column is the remaining text.
#
# Let's turn this into a data frame:
desc = data.frame(code)
names(desc) = c("code", "remain")

nrow(desc) # sanity check: still 24106 descriptions

# Already we can see how many courses are offered by each department.
table(desc$code)

# Next, let's get the course numbers.
#
# We can split again, this time at "—"
result = str_split_fixed(desc$remain, "—", 2)

result[1, ]

result[20, ]

# The result looks okay, so let's save it into the data frame.
#
# The first column is the course number.
desc$number = result[, 1]

# Second column is the remaining text.
desc$remain = result[, 2]

# Now we can try to use the same process to get the title.
#
# This time we split on " ("
#
# But this code gives us an error:
result = str_split_fixed(desc$remain, " (", 2)

#> Error in stri_split_regex(string, pattern, n = n, simplify = simplify,  :
#>   Incorrectly nested parentheses in regexp pattern. (U_REGEX_MISMATCHED_PAREN)
#
# The error says our "regexp pattern" was incorrect.
#
# So what's a "regexp pattern"?
#
# The error is talking about regular expressions, a language used to describe
# patterns in strings. Regular expressions are sometimes called "regex" or
# "regexp".
#
# All of the stringr functions with a `pattern` parameter expect a regular
# expression. 
#
# So now we need to learn another languge: regular expressions! The good news
# is that this language is not specific to R. Many different programming
# languages have support for regular expressions, so your skills here will
# transfer to other languages.


# Regular Expressions
# ===================
# A regular expression can describe a complicated pattern in just a few
# characters, because some characters are "metacharacters" with a special
# meaning.
#
# Letters and numbers are NEVER metacharacters. They are always literal.
#
# Metacharacters:
# .     any character
# ^     beginning of string
# $     end of string
#
# [ab]  'a' or 'b'
# [^a]  any character except 'a'
#
# ()      make a group
# (ab|c)  match 'ab' or 'c'
#
# \\    escape (make the next character a non-metacharacter)
# \\N   back reference (match contents of Nth group)
#
# *     previous character appears 0 or more times
# +     previous character appears 1 or more times
# ?     previous character appears 0 or 1 times
# {N}   previous character appears exactly N times
# {N, } previous character appears at least N times
#
# *?    non-greedy *
# +?    non-greedy +
# ??    non-greedy ?
#
# Even more:
?regex

# The function
#     str_extract(string, pattern)
# returns the part of STRING that matches PATTERN. This function is great for
# testing regular expressions, since you can see what matches.
#
# Let's use it here to try out some metacharacters.

strings = c("The cake is a lie", "The pie is a lie")

# The metacharacter '.' matches any one character.
#
# In our test strings, '.' matches 'T' at the beginning of each:
str_extract(strings, ".")

# A few things to notices from this example:
#
#   * The pattern is matched from left to right.
#   * If the string is longer than the pattern, but contains a match for the
#     pattern, that counts as a match overall.
#   * Matching stops as soon as the entire pattern is matched.

# We can force pattern to match at the beginning of a string or end of a string
# with '^' and '$', respectively.
#
# So:
str_extract(strings, ".ie")

# matches 'pie' in the first string, but with '$' we can say we mean the end
# of the string:
str_extract(strings, ".ie$")

# If we want the pattern to match the whole string, we can put '^' at the
# beginning and '$' at the end:
str_extract(strings, "The pie") # matches second

str_extract(strings, "^The pie$") # no match
str_extract("The pie", "^The pie$") # matches


# Alternations --------------------
#
# The '[ ]' metacharacter, called an alternation, matches any one character
# inside the square brackets.
#
# So if we want to match 'pie' or 'lie', but nothing else, we can write:
str_extract(strings, "[pl]ie")

# The '[^ ]' metacharacter matches any one character EXCEPT the ones inside the
# square brackets. So if we want to match any 'ie' word except 'pie':
str_extract(strings, "[^p]ie")

# You can include ranges with '-' in alternations to cut down on typing:
str_extract(strings, "[a-oq-z]ie") # doesn't match 'pie'

# The '-' only marks a range when it's between two characters. Otherwise, it's
# just a '-':
#                        v--- a range
str_extract("-3", "[a-][0-9]")
#                    ^--- just a '-', not a range

# Groups --------------------
#
# The '( )' metacharacter is called a group. Groups are mostly useful for
# organizing your regex.
#
# The function
#   str_match(string, pattern)
# returns the part of STRING that matches PATTERN, as well as all sub-matches
# for groups.
#
# So for example:
str_match(strings, "The (.)")

# The first column is the same as the result from str_extract()
#
# The second column is the match for '(.)'

# You can use '|' inside groups to allow one pattern or another:
str_match(strings, "The (pie|cake|cookie)") # matches pie, cake, or cookie


# Escape Characters --------------------
#
# We can make a metacharacter into a literal character by adding a backslash
# '\' in front. The backslash is called an escape character, because it escapes
# the usual rules of regular expressions.
#
# So a literal '.' is written as '\.' in regular expressions.
#
# However, backslash '\' is also an escape character for R, so we need to put
# two backslashes '\\' in an R string to get one actual backslash. You can see
# this with:
message("\\")

# Thus our regex becomes:
str_extract(strings, "\\.") # only matches literal '.'

str_extract("Hi there.", "\\.")

# As a diagram:
# 
#    R sees        Regex sees        Regex matches
#    '\\.'  ---->  '\.'       ---->  '.'
#

# Same idea, but for literal '[':
str_extract("Hi[Bye", "\\[")

# This is related to the error message we got when trying to extract titles
# from the course descriptions.
#
# We wanted a literal parenthesis '(', but '(' is a metacharacter in regular
# expressions. Our original code was:
#
#    result = str_split_fixed(desc$remain, " (", 2)
#
# Let's change it so that '(' is literal:
result = str_split_fixed(desc$remain, " \\(", 2)

# Now we get a correct result.
result[1, ]

desc$title = result[, 1]
desc$remain = result[, 2]

# The course descriptions are well-organized, so we could keep using our
# splitting strategy to get more features.
#
# But what if we only wanted one feature, say the title? What if we had text
# that was more disorganized?
#
# Regular expressions can still help, but we need to learn about quantifiers.

# Quantifiers --------------------
#
# Quantifiers are metacharacters that let you repeat characters or even whole
# groups.
#
# The '?' metacharacter repeats something 0 or 1 time.
strings = c("The cat", "The fat cats", "The fat orange cat")

str_extract(strings, "The (fat )?cat") # 'fat ' is optional

str_extract(strings, "cats?") # 's' is optional

# The '*' metacharacter repeats something 0 or more times.
# The '+' metacharacter repeats something 1 or more times.
#
# The '{M,N}' metacharacer repeats something M to N times. So '{2,4}' repeats
# at least twice and at most four times.

strings = c("la YAY", "la la YAY", "la la la YAY", "la la la la YAY")
str_extract(strings, "^(la ){2,3}YAY")

# Notice that this can give counterintuitive results if you don't anchor the
# regular expression with a literal character or beginning/end of string:
str_extract(strings, "(la ){2,3}YAY") # now matches fourth string


# Backreferences --------------------
#
# A backreference refers to the match for an earlier group.
#
# Backreferences are written '\N' where N is replaced by the group number.
#
# So in R, '\\1' refers to the first group.
#
# For example:
strings = c("The cat is a cat", "The cat is a dog", "The dog is a dog")

str_extract(strings, "The ([a-zA-Z]+) is a \\1")

# Backreferences are slow to compute, so try other strategies first.


# String Processing (continued) 
# =============================
#
# Now let's get back to extracting features from the course descriptions.
head(desc)

# What if we want the prerequisites for each course?
#
# By skimming some of the descriptions, the format seems to be:
#
#   Prerequisite(s): LONG SENTENCE WITH WORDS.
#
# So our regular expression will be:
#                                  vvv--- literal '.'
#   Prerequisite\\(s\\): [a-zA-Z ]+\\.
#                        ^^^^^^^^^^--- letters or spaces, repeat 1+ times
#
# We can add a group around the words in order to capture the actual
# prerequisites:
#
#   Prerequisite\\(s\\): ([a-zA-Z ]+)\\.
#
# Now let's try this:
result = str_match(desc$remain, "Prerequisite\\(s\\): ([a-zA-Z ]+)\\.")

result[1, ]

# The first result is NA, so our regex might be wrong. How can we tell?
#
# Let's try a simpler regex to find out how many courses mention prerequisites
# at all:
has_pq = str_detect(desc$remain, "Prereq")
table(has_pq) # 18800 have prereqs

desc$prereq = result[, 2]
head(desc[has_pq, ])

# This looks good, except that some prerequisites have ; or other characters
# besides '[a-zA-Z ]'. So let's change our pattern to:
#
#   Prerequisite\\(s\\): ([^.]+)\\.
#
result = str_match(desc$remain, "Prerequisite\\(s\\): ([^.]+)\\.")

desc$prereq = result[, 2]
head(desc[has_pq, ])

# Now it looks like we've extracted all of the prerequsiites. We could double
# check by looking for NAs in our prereq column and comparing to has_pq.
#
# Unlike the earlier features, we didn't use a split strategy here. Instead, we
# used quantifiers to extract an arbitrary number of characters/words.
#
# The benefit of this strategy is that we can easily get text anywhere in the
# description. The drawback is that it's more complicated than the splitting
# strategy. Simpler strategies are not only easier to program, but also tend to
# be more robust against unexpected input.
#
# For instance, the strategy we used here would break if one of the
# descriptions had "Prerequisite:" instead of "Prerequisite(s):". We could make
# a split strategy, perhaps using ":", that's robust against this weakness.
#
# Also note that many other strategies are possible with regular expressions.
#
# In general, try to choose a strategy that is not too complicated and
# reasonably accurate. This is similar to the approach we usually take with
# statistical models. We want something general/robust, but also accurate.
