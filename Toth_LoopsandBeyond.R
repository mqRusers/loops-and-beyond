##################  Loops and Beyond  ############################
##############  Efficient iteration in R  ########################
###################  By Anikó Tóth  ##############################
######  Material borrowed from R for Data Science  ###############
#######  By Garrett Grolemund and Hadley Wickham  ################
####################  20 June 2018  ##############################

install.packages("tidyverse")
library("tidyverse")

# Preliminary notes ####
# Tidyverse core packages: ggplot2, tibble, tidyr, readr, purrr, dplyr, stringr, forcats
# Today we will be using mainly tibble and purrr
# Note that James's talk in March covered dplyr
# And Kyle's talk in April covered ggplot2
# Note that tidyverse users like to refer to various bits of syntax using the same "parts of speech" as plain english
  # e.g. a function is usually a verb or an adverb. An object is a noun and a placeholder is a pronoun. 
  # I will occasionally use this terminology because I think it helps to understand the intent and usage of all the bits and pieces.

# Q: Why do we use iteration?
  # A: To reduce duplication and copy-pasting your code. 

# Q: Why is this important?
  # A:    a. It’s easier to see the intent of your code, because your eyes are drawn to what’s different, not what stays the same.
        # b. It’s easier to respond to changes in requirements. As your needs change, you only need to make changes in one place, rather than remembering to change every place that you copied-and-pasted the code.
        # c. You’re likely to have fewer bugs because each line of code is used in more places.

# Part A. Basic iteration with Loops ####

# 1. convert mtcars to a tibble. 
# We will use tibbles for this workshop. Tibbles are like data.frame()s with some small but important differences. 

df <- as.tibble(mtcars)  
df

# 2. Let's get the median of the first column
median(df$mpg)

# 3. How about the medians of the other columns? 
median(df$cyl)
median(df$disp)
median(df$hp) 

#... oops! we have broken our rule of not copy-pasting code more than twice. 

# Let's try using a loop instead. 
# 4. Write a loop that returns the medians of all columns in the input

output <- vector("double", ncol(df))  # 1. output: must be pre-allocated or the loop will be very slow

for (i in seq_along(df)) {            # 2. sequence
  output[[i]] <- median(df[[i]])      # 3. body: this bit does the actual work. Notice the [[ subsetting instead of the [ subsetting
}
output

# What happens when you try to use length() and seq_along() on a zero-length vector?
y <- vector("double", 0)

seq_along(y)
1:length(y)


#  Practice with loops:
# 1. Compute the mean of every column in mtcars.

output <- vector("double", ncol(mtcars))  
for (i in seq_along(mtcars)) {            
  output[[i]] <- mean(mtcars[[i]])     
}
output

# 2. Determine the type of each column in iris

output <- vector("double", ncol(iris))  
for (i in seq_along(iris)) {            
  output[[i]] <- class(iris[[i]])     
}
output

# 3. Compute the number of unique values in each column of iris.
output <- vector("double", ncol(iris))  
for (i in seq_along(iris)) {            
  output[[i]] <- length(unique(iris[[i]]))     
}
output

# (: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :) ####

# Part B: Wrapping loops in functions. ####

#For loops are not as important in R as they are in other languages because R is a 
#functional programming language. This means that it’s possible to wrap up for loops 
#in a function, and call that function instead of using the for loop directly.

df <- tibble( 
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# 1. Write a loop to compute the mean of each column
output <- vector("double", length(df))
for (i in seq_along(df)) {
  output[[i]] <- mean(df[[i]])
}
output

# 2. Put it in a function, so you can call it for any table (note this is often called a "wrapper")

col_mean <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- mean(df[[i]])
  }
  output
}

# 3. Now write functions to compute the median and sd as well. 

col_median <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- median(df[[i]])
  }
  output
}

col_sd <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- sd(df[[i]])
  }
  output
}


#### ... uh-oh. We've broken our copy-paste rule again.  How can we generalise?

# R allows us to pass a function to another function. This is one of the things that makes it so powerful. 

# 4. Write a function that allows you to compute any summary statistic for all the columns in a dataset
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}

# try it out
col_summary(df, median)
col_summary(df, mean)


# Okay, here's where purrr comes in. 
# The goal of using purrr functions instead of for loops is to allow you break common list manipulation challenges into independent pieces:

#How can you solve the problem for a single element of the list? 
#Once you’ve solved that problem, purrr takes care of generalising your solution to every element in the list.

#If you’re solving a complex problem, how can you break it down into bite-sized pieces that allow you to advance one small step towards a solution? 
#With purrr, you get lots of small pieces that you can compose together with the pipe.

#This structure makes it easier to solve new problems. 
#It also makes it easier to understand your solutions to old problems when you re-read your old code.

# Note: the purrr functions are very similar to the apply functions in base R (apply, lapply, sapply, mapply, etc.)
  # The purrr map() functions are basically an upgraded version of the apply functions. 


# (: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :) ####

# Part C. The map functions ####

  # The map functions: specify your output (note that this is more predictable than sapply output, for instance.) 
?map() #makes a list.
?map_lgl() #makes a logical vector.
?map_int() #makes an integer vector.
?map_dbl() #makes a double vector.
?map_chr() #makes a character vector.

  # Input: a vector and a function. 
  # Returns vector of the same length
  # Return type is specified by the function
  # names are preserved (yay!)

# 1. use map_dbl to compute the mean of each column in df
map_dbl(df, mean)  # you should immediately notice how much less typing this requires, and how much more readable it is.

# 2. compute the median of each column
map_dbl(df, median)

# 3. What happens if you use the wrong map function?
map_chr(df, median)
map_int(df, median)

# 4. Compute the mean of each column in df using a pipe. 
  # note: We will be using pipes for the remainder of this workshop. The main purpose of pipes is to avoid nested functions.

df %>% map_dbl(mean)
df %>% map_dbl(median)
df %>% map_dbl(sd)

  # an important difference from our col_summary() function is the ability to pass along additional arguments. 
  # additional arguments can also be passed along in the apply functions

df %>% map_dbl(mean, trim = 0.5)
df %>% map_dbl(mean, na.rm = T)

  # You can also define your own function to put into the map function

# 5. write a function that returns the number of unique values in a vector
num_types <- function(x) {length(unique(x))}  
  # note that curly braces {} are not required for one-line functions. 
  # But keep them if you are not used to it!! This is an easy way to make a bad mistake!

# 6. Apply your function to the iris dataset using map.  Which map function should you use?
iris %>% map_int(num_types)

# We can also use what is called an anonymous function, right inside of map_int
iris %>% map_int(function(x) length(unique(x)))


# Shortcuts (everyone loves shortcuts)

# 7. Fit a model of mpg to weight to each cylinder number in the mtcars dataset using split() and map()
 # Hint: you will need to define an anonymous function. 
models <- mtcars %>% 
  split(.$cyl) %>%   # splits the dataset by number of cylinders. 
  map(function(df) lm(mpg ~ wt, data = df))

# Programmers are profoundly lazy, and they thought that was too much typing, so they made a shortcut. 

models <- mtcars %>% 
  split(.$cyl) %>% 
  map(~lm(mpg ~ wt, data = .))  # ~ replaces 'function(df)' in the anonymous function notation

  # . is a pronoun. map() uses . like the i in a for loop.  
  # note there are two different usages of . here (the pipe usage and the map usage)
  # It references the current list element that your function is to be run on. 

# 8. Use the anonymous function shorthand to extract the r squared of each model
models %>% 
  map(summary) %>% 
  map_dbl(~.$r.squared)

## but that was also too much typing... and it's a little symbol-heavy...plus this is a common operation

# 9.Use "r.squared" in quotes to extract the r squared of each model
models %>% 
  map(summary) %>% 
  map_dbl("r.squared")

  # You can also use an integer to select elements by position:

# 10. Extract the second element of each component the following list.
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))

x %>% map_dbl(2)
#OR
map_dbl(x, 2)

# (: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :) ####

# Part D. Mapping over multiple arguments ####

#So far we’ve mapped along a single input. 
#But often you have multiple related inputs that you need iterate along in parallel.
#That’s the job of the map2() and pmap() functions. 

# 1. Simulate some random normals with 5 components and with different means using rnorm(). 
    #Means: 5, 10, -3
  # Hint: You know how to do that with map()
mu <- list(5, 10, -3) # list of means
mu %>% 
  map(rnorm, n = 5) %>% 
  str()

# 2. What if you also want to vary the standard deviation? 
  # standard deviations: 1, 5, 10
  # One way to do that would be to iterate over the indices and index into vectors of means and sds.
  
sigma <- list(1, 5, 10) # standard deviations
seq_along(mu) %>% 
  map(~rnorm(5, mu[[.]], sigma[[.]])) %>% 
  str()

  # Find a better way is using the help page for map2()
?map2
map2(mu, sigma, rnorm, n = 5) %>% str()
  # Arguments that vary over the iterations should come before the function (.f), and constants should come after.

## How does map2 work under the hood?  Simple: it's just a wrapped for loop!

map2 <- function(x, y, f, ...) {
  out <- vector("list", length(x))
  for (i in seq_along(x)) {
    out[[i]] <- f(x[[i]], y[[i]], ...)
  }
  out
}

  # note that ... (dot dot dot) is a placeholder for additional arguments taken by the function f. 
  # This allows common paramenters to be passed down into the layers of abstraction without extra fuss.

# 3. More than 2 variables? Use pmap(). Vary the number of elements n in the random normals as well. 
  # numbers = 1, 3, and 5
n <- list(1, 3, 5)
# Hint: you have to put the arguments in their own list! That way you can vary as many arguments as you want. 
args1 <- list(n, mu, sigma)

args1 %>%
  pmap(rnorm) %>% 
  str()

# 4. Naming your arguments really helps. In the absence of names, R uses positional matching.

args2 <- list(mean = mu, sd = sigma, n = n)
args2 %>% 
  pmap(rnorm) %>% 
  str()


# 5. You can store all your arguments in a data frame 

params <- tribble(
  ~mean, ~sd, ~n,
  5,     1,  1,
  10,     5,  3,
  -3,    10,  5
)

params %>% 
  pmap(rnorm)

#or

pmap(params, rnorm)


# 6. Finally: you can map different functions as well using invoke_map()

f <- c("runif", "rnorm", "rpois")

param <- list(
  list(min = -1, max = 1), 
  list(sd = 5), 
  list(lambda = 10)
)

invoke_map(f, param, n = 5) %>% str()




