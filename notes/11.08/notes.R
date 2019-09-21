# STA 141A
# Lecture 13 (Nov 8)
#
# See Piazza for office hours!

# Admin:
#   * New office hour: Thursdays 4-5pm MSB 1117

# References:
#   * Apply Functions: https://stackoverflow.com/a/7141669
#   * Loops: The Art of R Programming 7, 13
#   * stringr Cheatsheet:
#     https://github.com/rstudio/cheatsheets/raw/master/strings.pdf

# Topics Today:
#   * Loops
#   * Package 'stringr'
#   * Regular expressions

# NEW Data & Packages:
#   * catalog.zip (on Canvas)
#   * Package 'stringr'

# Loops
# =====
# A loop is a programming tool or function or command that lets you
# do something over and over.
#
# Four ways to write loops in R:
# 1. Apply functions: lapply(), sapply(), apply(), tapply()
sapply(c(1, 2, 3), sin) # BAD

dogs = readRDS("data/dogs/dogs_full.rds")

class(dogs) # class() is not vectorized
sapply(dogs, class) # ...so reasonable to use class() with sapply()


# 2. Vectorization
# Vectorization is much faster than any other kind of loop.
#
# Most common vectorized functions: sin(), sqrt(), cos(), abs(), ..

sin(c(1, 2, 3)) # GOOD

# 3. For-loops and While-loops

message("1") 
message("Warning you have caused the computer to catch on fire!!!!")
print("1")
print("Warning you have caused the computer to catch on fire!!!!")
"hi"

for (i in c(7, 5, 1, 3)) {
  message(i)
}
sapply(c(7, 5, 1, 3), message)



sapply(c(1, 2, 3), sin)

sin(c(1, 2, 3))



# In this example, we ask for more memory at every iteration
# Very inefficient!
x = c()
for (i in c(7, 5, 1, 3)) {
  x = c(x, sin(i))
}

# Instead we want to ask for all the memory we need at beginning
# This is called "preallocating"
x = numeric(4) # integer(), character(), logical()
to_compute = c(7, 5, 1, 3)
for (i in c(1, 2, 3, 4)) {
  x[i] = sin(to_compute[i])
}
x

# x[1] = sin(to_compute[1]) # to_compute[1] is 7
# x[2] = sin(to_compute[2]) # to_compute[2] is 5
# ...

x = numeric(4) # integer(), character(), logical()
to_compute = c(7, 5, 1, 3)
for (i in seq_along(to_compute)) {
  x[i] = sin(to_compute[i])
}
x

1:length(to_compute)
seq(1, length(to_compute))

x = c()
to_compute = c()
seq_along(to_compute)
for (i in seq_along(to_compute)) {
  message(to_compute[i])
}
1:length(to_compute)
for (i in 1:length(to_compute)) {
  message("Hi", to_compute[i])
}

0:length(to_compute)
0:5

x

# Drawbacks for loops:
#   1. We have to explicitly save the result somehow
#   2. We have to remember to preallocate
#   3. We have to get the iteration number with seq_along()

# When should you use a for loop?
# --> When one iteration depends on a previous iteration.

to_compute = c(7, 5, 2, 3)
x = 0
for (i in seq_along(to_compute)) {
  x = x + to_compute[i]
  if (x > 12) {
    x = 0 
  }
}
# x = 0 + 7
# x = 7 + 5
# x = 12 + 2

x = 0
i = 1

# When should you use a while-loop?
# --> When you don't know how many times you need to iterate.
while (x < 10) {
  x = x + rnorm(1)
  i = i + 1
}


# To identify where you need a loop in code you already have, look for lines or
# groups of lines that are mostly the same.
#
# For instance:
message("Hello from STA 141A")
message("Hello from STA 141B")
message("Hello from STA 141C")
message("Hello from STA 13")
# ...only the course number changes.

# So...
num = c("141A", "141B", "141C", "13")

message(num[[1]])
message(num[[2]])
# ...

sapply(num, message)

# We have to write a custom function for sapply() since it passes each element
# as the first argument to the function.
sapply(num, function(msg) {
  message("Hello from STA ", msg)
})

# You can write the custom function outside of sapply() if you prefer.
sta_message = function(msg) {
  message("Hello from STA ", msg)
}
sta_message("108") # test that it works
sapply(num, sta_message)


# 4. Recursion
num
f = function(x) {
  message(x[1])
  if (length(x) > 1)
    f(x[-1])
}

f(num)

# In R, recursion is usually the slowest way to write a loop.
# But some problems are naturally recursive, so for those problems
# it may make sense to use recursion.
# 
# Fibonacci numbers
#
# 1 1 2 3 5 8 13
#
# Fibonacci numbers are naturally recursive, but even this can
# be computed faster using other kinds of loops.

summary(dogs)
summary(list(1:3, 5:6))
1:3 + 4:6


# Loop-writing Strategy
# =====================
# When thinking about writing a loop, try (in order):
# 
# 1. vectorization
# 2. apply functions
# 3. for/while-loops
#     * Try a for-loop first if one iteration depends on another.
#     * Try a while-loop first if the number of iterations is unknown.
# 4. recursion
#     * May be useful for naturally recursive problems (like Fibonacci), but 
#       often there's a faster solution with other kinds of loops.
#
#
# Before you write the loop, try writing the code for just 1 iteration.
#
# Make sure that code works; it's easy to test code for 1 iteration.
#
# When you have 1 iteration working, then try using the code in a loop (you
# will have to make some small changes).
#
# If your loop doesn't work, try to figure out which iteration is causing the
# problem. One way to do this is to use message() to print out information.
#
# Then try to write the code for the broken iteration, get that iteration
# working, and repeat this whole process.


# String Processing
# =================
sta = readLines("data/ucd_catalog/catalog/STA.txt")

# How do we load all of the course descriptions?
files = list.files("data/ucd_catalog/catalog", full.names = TRUE)
readLines(files[[1]])
readLines(files[[2]])
length(files)
desc = lapply(files, readLines)

# We can use a loop to load all the files
# We can use a loop to process all the files
#
# But let's focus on one iteration and make sure we get it right
#
# What do we actually want to do to this file?
# * Three letter code e.g., 'STA'
# * Course number
# * Course title
# * Number of credits
# * Number of hours
# * Prerequisites
# * Description
sta
length(sta)

# We want to use a loop to process each description.
desc = sta[[1]]

library(stringr)

str_sub(desc, 1, 3)

# Stringr is vectorized
str_sub(sta, 1, 3)
?str_sub

desc

str_split("dogs & cats", "&")

# Regular expressions (or "regex") is a language for describing patterns.
#
# Regular expressions are used in many different programming languages, so what
# you learn about them here applies to more than just R.
#
# | matches the string on the left or the right
str_split("dogs & cats / parrot", "/|&") # split at / or &

# [ ] matches any one character inside the brackets
str_split("dogs & cats / parrot", "[/&]") # split at / or &

# You can use more than one character as the splitter:
str_split("dogs &/ cats // parrot", "[/&]/") # split at // or &/

# So | and [ ] have special meanings in regular expressions. You can turn off
# the special meanings with the fixed() function.
str_split("dogs [ cats [ parrot", fixed("[")) # split at [

# The str_split() function is vectorized, and returns a list with one element
# for each string to split. Inside each list element is the vector of pieces.
x = c("dogs & cats & parrot", "iguanas & fishes")
result = str_split(x, "&")

result[[1]] # pieces for x[1]
result[[2]] # pieces for x[2]

# Often we want to split a lot of strings the same number of times each. The
# str_split_fixed() function can do this.

str_split_fixed(x, "&", 2) # split into 2 pieces

str_split_fixed(x, "&", 3) # split into 3 pieces

# Now it's easy to get the first piece for each string:
result2 = str_split_fixed(x, "&", 2)
result2[, 1]

# NOTE: str_split_fixed() does not turn off regular expressions, and has
# nothing to do with fixed()!
