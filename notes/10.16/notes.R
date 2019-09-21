# STA 141A
# Lecture 6 (Oct 16)
#
# See Piazza for office hours!

# References:
#   * "Visualizing Data" by Cleveland
#   * R4DS ch 28 "Graphics for Communication" (book ch ??)
#   * "The Elements of Graphing Data" by Cleveland


# Multivariate EDA --------------------

# Let's again consider numerical vs categorical.
#
# For instance:
#   How does height vary for different groups of dogs?
#
# What can we do to display these?
#   * side-by-side box plots
#   * side-by-side violin plots
#   * overlapping density plots

dogs = readRDS("data/dogs/dogs_full.rds")

library(ggplot2)
ggplot(dogs, aes(group, height)) + geom_boxplot()

# One way we can see more detail is by adding violin plots, which show the
# density sideways along the box plot.
ggplot(dogs, aes(group, height)) + geom_boxplot() + geom_violin()

# Side note: stat = "identity" is useful for bar plots, but not useful for
# density plots.

# If we use a density plot, how can we display the groups?
ggplot(dogs, aes(color = group, height)) + geom_density()

# Too many lines! We can use a ridge plot instead to show many densities at
# once.
install.packages("ggridges")
library(ggridges)

ggplot(dogs, aes(x = height, y = group)) + geom_density_ridges()


# Facets
#
# Can we make the same plot (group vs height) with side-by-side plots?
#
# Two functions to make side-by-side plots:
#   * facet_wrap()
#   * facet_grid()

ggplot(dogs, aes(height, color = size)) + geom_density() +
  facet_wrap(~ group)

# Set scales = "free" to allow scales to vary. But usually you want the scales
# to be the same, since it makes comparisons easier.

ggplot(dogs, aes(height, color = size)) + geom_density() +
  facet_wrap(~ group, scales = "free")

# Facets also work with ridge plots.
ggplot(dogs, aes(height, size)) + geom_density_ridges() +
  facet_wrap(~ group)

# Side note: use the `bw` parameter to change density smoothness. See notes for
# the previous lecture for an example.

# The facet_grid() function gives you more control over how the facets are laid
# out.
#
# ROWS ~ COLUMNS
#
ggplot(dogs, aes(height)) + geom_density() +
  facet_grid(size ~ .)

ggplot(dogs, aes(height)) + geom_density() +
  facet_grid(. ~ size)

ggplot(dogs, aes(height)) + geom_density() +
  facet_grid(grooming ~ size)

# When should we use facets versus aesthetics?
#   * FACETS: Use when aesthetics would put too much information on the plot
#   (too many lines, too many points, etc).
#
#   * AESTHETICS: Use aesthetics when there is less information to show; facets
#   tend to use space less efficiently than aesthetics.
#
# But overall, think about the reader! There is no rule that always holds when
# deciding whether to use facets or aesthetics (or both).


# For example, this is a case where it's silly to use facets:
ggplot(dogs, aes(size)) + geom_bar() + facet_wrap(~ grooming)


# Q: What to do with three continuous variables?

# First let's consider a simpler problem.
# -> What to do with two continuous variables?
#
#     * Scatterplot
#     * Statistical test or model (check assumptions)
#     * Correlation

ggplot(dogs, aes(height, weight)) + geom_point()

# Now let's add lifetime cost to the plot. How can we do that?
#
# Since lifetime_cost is continuous, we can't use facets. Instead we can use
# aesthetics that work with continuous variables.

ggplot(dogs, aes(height, weight, color = lifetime_cost)) + geom_point()

# Small differences in color are hard to judge, just like small differences in
# arc length (think pie charts).
#
# We can add a redundant aesthetic to make the plot easier to read. Let's use
# size.

ggplot(dogs, aes(height, weight, color = lifetime_cost, size = lifetime_cost)) +
  geom_point()

# Now the points overlap -- there is overplotting. One way to fix overplotting
# is to make the points transparent.
#
# The `alpha` aesthetic controls transparency.

ggplot(dogs, aes(height, weight, color = lifetime_cost, size = lifetime_cost)) +
  geom_point(alpha = 0.5)


# Sometimes it's also possible to make a plot clearer by changing which
# aesthetic maps to each variable.
#
# For instance, we can swap weight and lifetime_cost:

ggplot(dogs, aes(height, lifetime_cost, color = weight, size = weight)) +
  geom_point(alpha = 0.5)

# The drawback is that now the plot emphasizes the (weak) relationship between
# height and lifetime_cost, rather than the relationship between height and
# weight.
#
# So when you make your plot you need to think about what you're trying to
# show, and also about what the reader will see.


# A plot is worth 1000 words. Just like writing, you make have to go through
# several revisions of a plot to find the best version.


# Discretization --------------------
#
# Discretization is another way to deal with 3+ continuous features.
#
# The idea is to turn the continuous feature into a discrete/categorical one.
#
# We've already seen this idea with histograms:

ggplot(dogs, aes(lifetime_cost)) + geom_histogram()

# The histogram splits the range of the data into "bins" and counts how many
# observations are in each bin.

# If we want to make our own bins:
#   * cut() -- built-in
#   * cut_interval(), cut_number(), cut_width() -- in ggplot2
#
# The cut_ functions are more specific than cut(), and usually the ones you'll
# want to use.

cost_d = cut_number(dogs$lifetime_cost, 5)
cost_d
class(cost_d)
table(cost_d)

summary(dogs$lifetime_cost)
cost_d2 = cut_width(dogs$lifetime_cost, 5000)
table(cost_d2)

?cut_interval

# DANGER!! The drawback to discretization is that you lose information. The
# worst case is having only 1 bin, in which case you have no information at
# all, because every observation is in the same bin.


# After discretizing a feature, you can use it like a categorical feature.
#
# Usually it is easier to make plots with 3+ features if most of them are
# categorical.

ggplot(dogs, aes(height, weight, color = cost_d, shape = cost_d)) +
  geom_point(alpha = 0.5)


# Sorting --------------------

x = c(1, 3, 4, 2)

# The sort() function is great for sorting vectors.
sort(x)

# ...but sort() doesn't work well for data frames.
head(dogs)

# Instead:
#   1. Use the order() function to find out how the rows should be ordered.
#   2. Sort the rows by subsetting.

ord = order(dogs$popularity)
dogs[ord, ]

# Also works for vectors:
ord = order(x)
x[ord]


# Graphic Design --------------------
#
# Think about the reader when you design your plots.
#
# If you put color on a plot:
#   * Will colorblind people be able to read the plot?
#   * Will the plot be legibile in black and white?
#
# There are ways to use color while still making your plots accessible.
#
# You can check how your plot would look to a colorblind person with Color
# Oracle: http://www.colororacle.org/
#
# There are also several palettes that are colorblind or print safe:
#   * ColorBrewer
#   * Viridis

# ColorBrewer -- see http://colorbrewer2.org/
#   * In ggplot2, see scale_color_brewer(), scale_fill_brewer()
#   * For other plot packages, see the "RColorBrewer" package

# Viridis -- see https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
#   * In ggplot2, see scale_color_viridis_ and scale_fill_viridis_
#   * For other plot packages, see the "viridis" package
