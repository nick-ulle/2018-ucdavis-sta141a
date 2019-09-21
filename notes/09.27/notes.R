# R comments start with `#`.

# STA 141A Lecture 1 (Sep 27)
#
# Instructor: Nick Ulle
# 
# See Piazza for additional resources.

# Links:
#   * John Snow: https://en.wikipedia.org/wiki/John_Snow
#
#   * ProPublica Workflow: https://www.propublica.org/article/minority-neighborhoods-higher-car-insurance-premiums-methodology
#
#   * ProPublica Article: https://www.propublica.org/article/minority-neighborhoods-higher-car-insurance-premiums-white-areas-same-risk
#
#   * Jon Snow (Game of Thrones): https://thenextweb.com/contributors/2017/10/06/data-analysis-reveals-main-character-along-game-thrones/
#
#   * Dogs Ranking: https://informationisbeautiful.net/visualizations/best-in-show-whats-the-top-data-dog/


# --------------------
# Send commands to R by typing your command and pressing <Enter>.
5

# You can use R to do arithmetic.
4 + 6

4 - 6

4 * 6

4 / 6

4 ^ 6 

# You can also create "variables" to save values or results from computations.
myvariable1 = 5

myvariable1

# You can use either `=` or `<-` to create variables. They are equivalent.
myvariable1 <- 5

# You can use variables like any other value.
myvariable1 + 6

# Vectors are a major feature of R. You can combine values into a vector with
# `c()`.
c(4, 5, 6)

c(4, 5)

# Many operations on vectors are element-by-element.
c(4, 5) + c(6, 7)

# The name `c` is the name of a function (some saved code that does a task). If
# you write `c` you can see the code. This is in contrast to `c()`, which runs
# the code.
c

# You can run, or "call", multiple functions in one line.
mean(c(4, 5, 6))

# You can get help with any function by putting a `?` before the function name.
?c


# --------------------
# Plotting the dogs data. I'll talk about this code more next week.
setwd("~/university/teach/sta141a/notes")

dogs = readRDS("dogs_full.rds")
head(dogs)

# Note that you need to `install.packages("ggplot")` before you can load the
# ggplot2 package with `library(ggplot2)`.
library(ggplot2)

ggplot(dogs, aes(x = datadog, y = popularity, color = group)) + geom_point()
