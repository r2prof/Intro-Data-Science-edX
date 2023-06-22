#===============Chapter-04 The tidyverse======================

library(tidyverse)

## Tidy data

## We say that a data table is in tidy format if each row represents one 
## observation and columns represent the different variables available for 
## each of these observations. The murders dataset is an example of a tidy data 
## frame.

library(dslabs)
data(murders)
View(murders)
head(murders)

data("CO2")
View(CO2)

data("ChickWeight")
View(ChickWeight)

data("BOD")
View(BOD)

## Manipulating data frames

## Adding a column with mutate
## The function mutate takes the data frame as a first argument and the name and
## values of the variable as a second argument using the convention name = values. 
## So, to add murder rates, we use:


murders <- mutate(murders, rate = total / population * 100000)
murders


## Notice that here we used total and population inside the function, which are 
## objects that are not defined in our workspace. But why don't we get an error?

## This is one of dplyr's main features. Functions in this package, such as 
## mutate, know to look for variables in the data frame provided in the first 
## argument. 

## In the call to mutate above, total will have the values in murders$total. 
## This approach makes the code much more readable.


## Subsetting with filter
## Now suppose that we want to filter the data table to only show the entries for 
## which the murder rate is lower than 0.71. To do this we use the filter function, 
## which takes the data table as the first argument and then the conditional 
## statement as the second.

filter(murders, rate <= 0.71)
a= filter(murders, rate <= 0.71)
a


## electing columns with select
## Although our data table only has six columns, some data tables include 
## hundreds. If we want to view just a few, we can use the dplyr select function. 
## In the code below we select three columns, assign this to a new object and 
## then filter the new object:

new_table <- select(murders, state, region, rate)
new_table
filter(new_table, rate <= 0.71)

## In the call to select, the first argument murders is an object, but state, 
## region, and rate are variable names.

## 4.4 Exercises

select(murders, state, population) %>% head()

## The dplyr function filter is used to choose specific rows of the data frame 
## to keep. Unlike select which is for columns, filter is for rows. 
## For example, you can show just the New York row like this:
  
x = filter(murders, state == "New York")
x

## We can remove rows using the != operator. For example, to remove Florida, 
## we would do this:


no_florida <- filter(murders, state != "Florida")
no_florida

filter(murders, state %in% c("New York", "Texas"))

filter(murders, population < 5000000 & region == "Northeast")

## The pipe: %>%

## With dplyr we can perform a series of operations, for example select and then 
## filter, by sending the results of one function to another using what is called 
## the pipe operator: %>%

murders %>% select(state, region, rate) %>% filter(rate <= 0.71)


## In general, the pipe sends the result of the left side of the pipe to be the 
## first argument of the function on the right side of the pipe. Here is a very 
## simple example:
  
16 %>% sqrt()

## We can continue to pipe values along:
  
16 %>% sqrt() %>% log2()

## The above statement is equivalent to log2(sqrt(16))

log2(sqrt(16))

## Therefore, when using the pipe with data frames and dplyr, we no longer need 
## to specify the required first argument since the dplyr functions we have 
## described all take the data as the first argument. In the code we wrote:

murders %>% select(state, region, rate) %>% filter(rate <= 0.71)

## murders is the first argument of the select function, and the new data frame 
## (formerly new_table) is the first argument of the filter function.

## Note that the pipe works well with functions where the first argument is the 
## input data. Functions in tidyverse packages like dplyr have this format and 
## can be used easily with the pipe.

murders <- mutate(murders, rate =  total / population * 100000, 
                  rank = rank(-rate))
murders

my_states <- filter(murders, region %in% c("Northeast", "West") & 
                      rate < 1)
my_states

select(my_states, state, rate, rank)

## The pipe %>% permits us to perform both operations sequentially without 
## having to define an intermediate variable my_states. We therefore could have 
## mutated and selected in the same line like this:


mutate(murders, rate =  total / population * 100000, 
       rank = rank(-rate)) %>% select(state, rate, rank)

## Notice that select no longer has a data frame as the first argument. The first
## argument is assumed to be the result of the operation conducted right before the %>%.

## Reset murders to the original table by using data(murders). Use a pipe to 
## create a new data frame called my_states that considers only states in the 
## Northeast or West which have a murder rate lower than 1, and contains only the state, rate and rank columns. The pipe should also have four components separated by three %>%. The code should look something like this:

## my_states <- murders %>%
##  mutate SOMETHING %>% 
##  filter SOMETHING %>% 
##  select SOMETHING

## summarize

## The summarize function in dplyr provides a way to compute summary statistics 
## with intuitive and readable code. We start with a simple example based on heights. 
## The heights dataset includes heights and sex reported by students in an in-class survey.

library(dplyr)
library(dslabs)
data(heights)
heights

s <- heights %>% 
  filter(sex == "Female") %>%
  summarize(average = mean(height), standard_deviation = sd(height))
s

## This takes our original data table as input, filters it to keep only females, 
## and then produces a new summarized table with just the average and the 
## standard deviation of heights. We get to choose the names of the columns of 
## the resulting table. For example, above we decided to use average and 
## standard_deviation, but we could have used other names just the same.

## Because the resulting table stored in s is a data frame, we can access the 
## components with the accessor $:

s$average

s$standard_deviation

## As with most other dplyr functions, summarize is aware of the variable names 
## and we can use them directly. So when inside the call to the summarize function 
## we write mean(height), the function is accessing the column with the 
## name "height" and then computing the average of the resulting numeric vector. 
## We can compute any other summary that operates on vectors and returns a single 
## value. For example, we can add the median, minimum, and maximum heights like this:

heights %>% 
  filter(sex == "Female") %>%
  summarize(median = median(height), minimum = min(height), 
            maximum = max(height))

## We can obtain these three values with just one line using the quantile function: 
## for example, quantile(x, c(0,0.5,1)) returns the min (0th percentile), 
## median (50th percentile), and max (100th percentile) of the vector x. 
## However, if we attempt to use a function like this that returns two or more 
## values inside summarize:

heights %>% 
  filter(sex == "Female") %>%
  summarize(range = quantile(height, c(0, 0.5, 1)))


us_murder_rate <- murders %>%
  summarize(rate = sum(total) / sum(population) * 100000)

us_murder_rate

## pull
## The us_murder_rate object defined above represents just one number. Yet we 
## are storing it in a data frame:
  
class(us_murder_rate)


## Since, as most dplyr functions, summarize always returns a data frame.

## This might be problematic if we want to use this result with functions that 
## require a numeric value. Here we show a useful trick for accessing values 
## stored in data when using pipes: when a data object is piped that object and 
## its columns can be accessed using the pull function. To understand what we 
## mean take a look at this line of code:
  
us_murder_rate %>% pull(rate)

class(us_murder_rate)

## This returns the value in the rate column of us_murder_rate making it 
## equivalent to us_murder_rate$rate.

## To get a number from the original data table with one line of code we can type:

us_murder_rate <- murders %>% 
summarize(rate = sum(total) / sum(population) * 100000) %>% pull(rate)

us_murder_rate

## which is now a numeric:

class(us_murder_rate)


## Group then summarize with group_by
## A common operation in data exploration is to first split data into groups 
## and then compute summaries for each group. For example, we may want to compute 
## the average and standard deviation for men's and women's heights separately. 
## The group_by function helps us do this. If we type this:
  
heights %>% group_by(sex)


## The result does not look very different from heights, except we see 
## Groups: sex [2] when we print the object. Although not immediately obvious 
## from its appearance, this is now a special data frame called a grouped data 
## frame, and dplyr functions, in particular summarize, will behave differently 
## when acting on this object. Conceptually, you can think of this table as many 
## tables, with the same columns but not necessarily the same number of rows, 
## stacked together in one object. When we summarize the data after grouping, 
## this is what happens:


heights %>% 
  group_by(sex) %>%
  summarize(average = mean(height), standard_deviation = sd(height))

## The summarize function applies the summarization to each group separately.

## For another example, let's compute the median murder rate in the four regions
## of the country:
  
murders
murders %>% group_by(region) %>%
  summarize(median_rate = median(rate))

## Sorting data frames
## When examining a dataset, it is often convenient to sort the table by the 
## different columns. We know about the order and sort function, but for ordering 
## entire tables, the dplyr function arrange is useful. For example, here we order 
## the states by population size:

  
murders %>% arrange(population) %>%
head()

## With arrange we get to decide which column to sort by. To see the states by 
## murder rate, from lowest to highest, we arrange by rate instead:

murders %>% arrange(rate) %>%
head()

## Note that the default behavior is to order in ascending order. In dplyr, the function desc transforms a vector so that it is in descending order. To sort the table in descending order, we can type:

murders %>% 
  arrange(desc(rate)) 

## Nested sorting
## If we are ordering by a column with ties, we can use a second column to break
## the tie. Similarly, a third column can be used to break ties between first and
## second and so on. Here we order by region, then within region we order by 
## murder rate:
  
murders %>% arrange(region, rate) %>% head()

## The top n

## In the code above, we have used the function head to avoid having the page 
## fill up with the entire dataset. If we want to see a larger proportion, we 
## can use the top_n function. This function takes a data frame as it's first 
## argument, the number of rows to show in the second, and the variable to filter 
## by in the third. Here is an example of how to see the top 5 rows:

murders %>% top_n(10, rate)

library(NHANES)
data(NHANES)
View(NHANES)
head(NHANES)

##  Tibbles

## Tidy data must be stored in data frames. We introduced the data frame in 
## Section 2.4.1 and have been using the murders data frame throughout the book.
## In Section 4.7.3 we introduced the group_by function, which permits 
## stratifying data before computing summary statistics. But where is the group 
## information stored in the data frame?

murders %>% group_by(region)

## Notice that there are no columns with this information. But, if you look 
## closely at the output above, you see the line A tibble followed by dimensions. 
## We can learn the class of the returned object using:


murders %>% group_by(region) %>% class()


## The tbl, pronounced tibble, is a special kind of data frame. The functions 
## group_by and summarize always return this type of data frame. The group_by 
## function returns a special kind of tbl, the grouped_df. We will say more 
## about these later. For consistency, the dplyr manipulation verbs 
## (select, filter, mutate, and arrange) preserve the class of the input: 
## if they receive a regular data frame they return a regular data frame, 
## while if they receive a tibble they return a tibble. But tibbles are the 
## preferred format in the tidyverse and as a result tidyverse functions that 
## produce a data frame from scratch return a tibble. For example, in Chapter 5 
# we will see that tidyverse functions used to import data create tibbles.

## Tibbles are very similar to data frames. In fact, you can think of them as a 
## modern version of data frames. Nonetheless there are three important 
## differences which we describe next.


## Tibbles display better
## The print method for tibbles is more readable than that of a data frame. 
## To see this, compare the outputs of typing murders and the output of murders 
## if we convert it to a tibble. We can do this using as_tibble(murders). 
## If using RStudio, output for a tibble adjusts to your window size. To see 
## this, change the width of your R console and notice how more/less columns 
## are shown.


## Subsets of tibbles are tibbles
## If you subset the columns of a data frame, you may get back an object that is 
## not a data frame, such as a vector or scalar. For example:
  
class(murders[,4])

## is not a data frame. 


## With tibbles this does not happen:
  
class(as_tibble(murders)[,4])

## This is useful in the tidyverse since functions require data frames as input.

## With tibbles, if you want to access the vector that defines a column, and 
## not get back a data frame, you need to use the accessor $:
  
class(as_tibble(murders)$population)

## A related feature is that tibbles will give you a warning if you try to 
## access a column that does not exist. If we accidentally write Population 
## instead of population this:
  
murders$Population

## returns a NULL with no warning, which can make it harder to debug. 

## In contrast, if we try this with a tibble we get an informative warning:

as_tibble(murders)$Population

## Tibbles can have complex entries
## While data frame columns need to be vectors of numbers, strings, or 
## logical values, tibbles can have more complex objects, such as lists or 
## functions. Also, we can create tibbles with functions:
  
tibble(id = c(1, 2, 3), func = c(mean, median, sd))

## Tibbles can be grouped
## The function group_by returns a special kind of tibble: a grouped tibble. 
## This class stores information that lets you know which rows are in which 
## groups. The tidyverse functions, in particular the summarize function, 
## are aware of the group information.


## Create a tibble using tibble instead of data.frame
## It is sometimes useful for us to create our own data frames. To create a data 
## frame in the tibble format, you can do this by using the tibble function.

grades <- tibble(names = c("John", "Juan", "Jean", "Yao"), 
                 exam_1 = c(95, 80, 90, 85), 
                 exam_2 = c(90, 85, 85, 90))
grades


## Note that base R (without packages loaded) has a function with a very similar 
## name, data.frame, that can be used to create a regular data frame rather than 
## a tibble. One other important difference is that by default data.frame coerces 
## characters into factors without providing a warning or message:


grades <- data.frame(names = c("John", "Juan", "Jean", "Yao"), 
                     exam_1 = c(95, 80, 90, 85), 
                     exam_2 = c(90, 85, 85, 90))
grades
class(grades)
class(grades$names)
class(grades$exam_1)

## To avoid this, we use the rather cumbersome argument stringsAsFactors:

grades <- data.frame(names = c("John", "Juan", "Jean", "Yao"), 
                     exam_1 = c(95, 80, 90, 85), 
                     exam_2 = c(90, 85, 85, 90),
                     stringsAsFactors = FALSE)
class(grades$names)


## To convert a regular data frame to a tibble, you can use the as_tibble 
## function.

as_tibble(grades) %>% class()


## The dot operator
## One of the advantages of using the pipe %>% is that we do not have to keep 
## naming new objects as we manipulate the data frame. As a quick reminder, 
## if we want to compute the median murder rate for states in the southern 
## states, instead of typing:
  
tab_1 <- filter(murders, region == "South")
tab_1
tab_2 <- mutate(tab_1, rate = total / population * 10^5)
rates <- tab_2$rate
rates
median(rates)


## We can avoid defining any new intermediate objects by instead typing:
filter(murders, region == "South") %>% 
  mutate(rate = total / population * 10^5) %>% 
  summarize(median = median(rate)) %>%
  pull(median)
  
  
## We can do this because each of these functions takes a data frame as the 
## first argument. But what if we want to access a component of the data frame. 
## For example, what if the pull function was not available and we wanted to 
## access tab_2$rate? What data frame name would we use? The answer is the dot operator.

## For example to access the rate vector without the pull function we could use

rates <- filter(murders, region == "South") %>% 
  mutate(rate = total / population * 10^5) %>% 
  .$rate

median(rates)

## In the next section, we will see other instances in which using 
## the . is useful.

## do
## The tidyverse functions know how to interpret grouped tibbles. Furthermore, 
## to facilitate stringing commands through the pipe %>%, tidyverse functions 
## consistently return data frames, since this assures that the output of a 
## function is accepted as the input of another. But most R functions do not 
## recognize grouped tibbles nor do they return data frames. The quantile 
## function is an example we described in Section 4.7.1. The do function serves 
## as a bridge between R functions such as quantile and the tidyverse. The do 
## function understands grouped tibbles and always returns a data frame.

## In Section 4.7.1, we noted that if we attempt to use quantile to obtain the 
## min, median and max in one call, we will receive an error: 
##Error: expecting result of length one, got : 2.


data(heights)
heights %>% 
  filter(sex == "Female") %>%
  summarize(range = quantile(height, c(0, 0.5, 1)))

## We can use the do function to fix this.

## First we have to write a function that fits into the tidyverse approach: 
## that is, it receives a data frame and returns a data frame.

my_summary <- function(dat){
  x <- quantile(dat$height, c(0, 0.5, 1))
  tibble(min = x[1], median = x[2], max = x[3])
}


## We can now apply the function to the heights dataset to obtain the summaries:

heights %>% 
  group_by(sex) %>% 
  my_summary

## But this is not what we want. We want a summary for each sex and the code 
## returned just one summary. This is because my_summary is not part of the 
## tidyverse and does not know how to handled grouped tibbles. do makes this 
## connection:

heights %>% 
  group_by(sex) %>% 
  do(my_summary(.))


## If you do not use the parenthesis, then the function is not executed and 
## instead do tries to return the function. This gives an error because do must 
## always return a data frame. You can see the error by typing:

heights %>% 
  group_by(sex) %>% 
  do(my_summary)

## The purrr package

## In Section 3.5 we learned about the sapply function, which permitted us to 
## apply the same function to each element of a vector. We constructed a function 
## and used sapply to compute the sum of the first n integers for several values 
## of n like this:
  
  
compute_s_n <- function(n){
    x <- 1:n
    sum(x)
  }
n <- 1:25
s_n <- sapply(n, compute_s_n)
s_n

## This type of operation, applying the same function or procedure to elements 
## of an object, is quite common in data analysis. The purrr package includes 
## functions similar to sapply but that better interact with other tidyverse 
## functions. The main advantage is that we can better control the output type 
## of functions. In contrast, sapply can return several different object types; 
## for example, we might expect a numeric result from a line of code, but sapply 
## might convert our result to character under some circumstances. purrr functions 
## will never do this: they will return objects of a specified type or return an 
## error if this is not possible.

## The first purrr function we will learn is map, which works very similar to 
## sapply but always, without exception, returns a list:
  
require(tidyverse)
library(purrr)
s_n <- map(n, compute_s_n)
class(s_n)

## If we want a numeric vector, we can instead use map_dbl which always returns 
## a vector of numeric values.

s_n <- map_dbl(n, compute_s_n)
class(s_n)


## This produces the same results as the sapply call shown above.

## A particularly useful purrr function for interacting with the rest of the 
## tidyverse is map_df, which always returns a tibble data frame. However, the 
## function being called needs to return a vector or a list with names. For this 
## reason, the following code would result in a Argument 1 must have names error:
  
s_n <- map_df(n, compute_s_n)

## We need to change the function to make this work:
  
compute_s_n <- function(n){
  x <- 1:n
  tibble(sum = sum(x))
}
s_n <- map_df(n, compute_s_n)

## The purrr package provides much more functionality not covered here. For more 
## details you can consult this online resource.

## Tidyverse conditionals
## A typical data analysis will often involve one or more conditional operations. 
## In Section 3.1 we described the ifelse function, which we will use extensively 
## in this book. In this section we present two dplyr functions that provide further 
## functionality for performing conditional operations.

## case_when
## The case_when function is useful for vectorizing conditional statements. 
## It is similar to ifelse but can output any number of values, as opposed to 
## just TRUE or FALSE. Here is an example splitting numbers into negative, 
## positive, and 0:
  
  
x <- c(-2, -1, 0, 1, 2)
case_when(x < 0 ~ "Negative", 
          x > 0 ~ "Positive", 
          TRUE  ~ "Zero")


## A common use for this function is to define categorical variables based on 
## existing variables. For example, suppose we want to compare the murder rates 
## in four groups of states: New England, West Coast, South, and other. For each 
## state, we need to ask if it is in New England, if it is not we ask if it is 
## in the West Coast, if not we ask if it is in the South, and if not we assign 
## other. Here is how we use case_when to do this:


murders %>% 
  mutate(group = case_when(
    abb %in% c("ME", "NH", "VT", "MA", "RI", "CT") ~ "New England",
    abb %in% c("WA", "OR", "CA") ~ "West Coast",
    region == "South" ~ "South",
    TRUE ~ "Other")) %>%
  group_by(group) %>%
  summarize(rate = sum(total) / sum(population) * 10^5) 

## between
## A common operation in data analysis is to determine if a value falls inside 
## an interval. We can check this using conditionals. For example, to check if 
## the elements of a vector x are between a and b we can type

x >= a & x <= b

## However, this can become cumbersome, especially within the tidyverse approach. 
## The between function performs the same operation.

between(x, a, b)
















