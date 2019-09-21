# STA 141A
# Lecture 20 (Dec 6)

# Admin:
#   * Nick has OH today 4-5pm (max 6pm) in MSB 1117
#   * Reminder: We will not have an in-class final.

# References:
#   * An Introduction to Statistical Learning, Ch 2, 5.1
#     (get it at https://www-bcf.usc.edu/~gareth/ISL/)
#   * The Art of R Programming, Ch 8, 14

# Today was mostly a blackboard lecture. Topics:
#   * Cross-validation
#   * Implementing cross-validation

# How To Translate Ideas Into Code
# --------------------------------
# A very important skill!!!
#
# Before you do any work, check: is there a built-in function?
#
# 1. Make simple examples and draw pictures to make sure you understand the
#    idea. Work through the simple examples by hand, paying attention to the
#    steps you take and whether the result matches your expectations.
#
# 2. Identify the inputs, outputs, and steps. Write these down somewhere -- on
#    paper or in comments. Thinking through the steps carefully will save you
#    time later. Make sure that each step is specific and concrete. Vague steps
#    are a sign that you don't really understand the idea or algorithm!
#
# 3. Divide-and-conquer: complicated steps or logically related steps can be
#    made into separate helper functions. Then you can test that the code for
#    these steps works correctly, independently of the rest of your code.
#
# 4. Test your code on small or simple examples first, including the examples
#    you worked by hand. Use debugging tools to diagnose and fix any bugs you
#    find.
#
# Functions are the building blocks for more sophisticated programs.


# How to sample()
# ---------------
# Pseudo-random numbers
#
# A pseudo-random number generator is a function where small changes to input
# cause sufficiently large changes to output that the outputs appear to be
# random.
#
# f(1) = 64
# f(2) = -7
# f(3) = -41
#

rnorm(1) # Sample 1 standard normal value

# The sample function samples elements from a vector without replacement (but
# there is a parameter to change this).
sample(c("a", "b"), 2)

n = nrow(iris)
n

sample(1:n, n)

sample(n, n)


# Sometimes we want randomness, but also reproducibility.
#
# Internally, R keeps track of the position in the sequence of inputs (for
# example 1, 2, 3, ...) and passes these to the pseudo-random number generator.
# 
# We can (re)set the position in the sequence of inputs in order to make our
# simulations reproducible; this position is called a "seed". The code for this
# is:
set.seed(141) # sets seed to 141

# Note that different seeds will lead to different random sequences.
#
# Be careful about where you set the seed. Generally, you should only set the
# seed once at very beginning of a script or simulation.

rnorm(1)

# Related Courses to STA 141A
# ---------------------------
# STA 141B - How to collect data (from web, databases), and interactive viz
# STA 141C - How to do statistical programming
# ECS 171 - Machine learning
