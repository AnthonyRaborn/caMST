
# caMST

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/caMST)](http://cran.r-project.org/package=caMST)
[![Travis-CI Build
Status](http://travis-ci.org/AnthonyRaborn/caMST.svg?branch=master)](http://travis-ci.org/AnthonyRaborn/caMST)
[![CRAN Downloads Per
Month](https://cranlogs.r-pkg.org/badges/caMST)](https://cran.r-project.org/package=caMST)
[![CRAN Downloads
Total](https://cranlogs.r-pkg.org/badges/grand-total/caMST?color=orange)](https://cran.r-project.org/package=caMST)
[![Zenodo
DOI](https://zenodo.org/badge/127388900.svg)](https://zenodo.org/badge/latestdoi/127388900)

## Installation

``` r
install.packages("caMST")  # CRAN-tastic
# install.packages('devtools')
devtools::install_github("AnthonyRaborn/caMST")  # the stable developmental version; add the argument `ref = 'devel'` for the developmental version with no stability guarantee
```

## Usage

Here are some examples demonstrating how to use this package for various
adaptive test frameworks.

### Computer Adaptive Multistage Testing (CMT)

``` r
# load the package
library(caMST)
## 
##              ___  ___ _____  _____
##              |  \/  |/  ___||_   _|
##   ___   __ _ | .  . |\ `--.   | |
##  / __| / _` || |\/| | `--. \  | |
## | (__ | (_| || |  | |/\__/ /  | |
##  \___| \__,_|\_|  |_/\____/   \_/
##      
##  Version 0.1.1
##  \   /\ 
##   ) ( ')  >^)
##  ( /  )   /\\ 
##  \(__)|  _\_V
## Package 'caMST' version 0.1.1

# using simulated test data
data(example_thetas)  # 5 simulated abilities
data(example_responses)  # 5 simulated responsesdata
data(example_transition_matrix)  # the transition matrix for an 18 item 1-3-3 balanced design
data(mst_only_items)  # the CMT item bank
data(mst_only_matrix)  # the matrix specifying how the item data frame relates to the modules

# run the CMT model
results <- multistage_test(mst_item_bank = mst_only_items, modules = mst_only_matrix, 
    transition_matrix = example_transition_matrix, method = "BM", response_matrix = example_responses, 
    initial_theta = 0, model = NULL, n_stages = 3, test_length = 18)
## Time difference of 2.703971 secs
results  # print a summary of the results
## Test Format: Multistage Adaptive Test
## multistage_test(mst_item_bank = mst_only_items, modules = mst_only_matrix, transition_matrix = example_transition_matrix, method = "BM", response_matrix = example_responses, initial_theta = 0, model = NULL, n_stages = 3, test_length = 18)
## Total Run Time: 2.704 secs
## Average Theta Estimate: -0.058
## Average SEM: 0.315
## Most Common Path(s) Taken: 1-3-7 taken by 3 subjects

# how good were the estimates?
data.frame(`True Theta` = example_thetas, `Estimated Theta` = results@final.theta.estimate, 
    `CI95 Lower Bound` = results@final.theta.estimate - 1.96 * results@final.theta.SEM, 
    `CI95 Upper Bound` = results@final.theta.estimate + 1.96 * results@final.theta.SEM)
##    True.Theta Estimated.Theta CI95.Lower.Bound CI95.Upper.Bound
## 1 -0.82791686      -0.9946015      -1.64878277       -0.3404202
## 2  0.61463323       0.6755088       0.01509754        1.3359200
## 3  0.03785365       0.1451625      -0.43083359        0.7211587
## 4 -0.51095175       0.2134472      -0.38381274        0.8107072
## 5 -0.08529469      -0.3284433      -0.92679548        0.2699088
```

The theta estimates under CMT are close except for person 4, whose
estimate falls outisde of the 95% confidence interval.

### Mixed Computerized Adaptive Multistage Testing (Mca-MST)

This is a method that follows the traditional multistage testing
framework with one exception: the routing stage utilizes item-level
adaptation to try to better estimate individual examinees’ abilities
before administering the additional stages. The current implementation
allows for any three-stage design with a single routing module (e.g.,
1-2-3, 1-5-3, etc.), though this will be extended for any arbitrary
number of stages in future updates.

Here is an example with a 1-3-3 design that has 18 items, where each
stage has the same number of items, maximum Fisher information is used
for all item- and module-level adaptations, and the expected a
posteriori estimator is used for the provisional and final ability
estimates.

``` r
# using simulated test data
data(example_thetas)  # 5 simulated abilities
data(example_responses)  # 5 simulated responsesdata
data(example_transition_matrix)  # the transition matrix for an 18 item 1-3-3 balanced design
data(cat_items)  # the items designated for use in the routing module with item-level adaptation
data(mst_items)  # the items designated for use in the second and third modules with module-level adaptation
data(example_module_items)  # the matrix specifying how the item data frame relates to the modules

# what does the data look like?
example_thetas
## [1] -0.82791686  0.61463323  0.03785365 -0.51095175 -0.08529469
example_responses[, 1:5]  # first 5 items
##   Item1 Item2 Item3 Item4 Item5
## 1     1     1     0     0     1
## 2     1     1     1     1     1
## 3     0     1     0     1     1
## 4     1     0     0     0     1
## 5     0     1     0     1     1
example_transition_matrix
##      [,1] [,2] [,3] [,4] [,5] [,6] [,7]
## [1,]    0    1    1    1    0    0    0
## [2,]    0    0    0    0    1    1    0
## [3,]    0    0    0    0    1    1    1
## [4,]    0    0    0    0    0    1    1
## [5,]    0    0    0    0    0    0    0
## [6,]    0    0    0    0    0    0    0
## [7,]    0    0    0    0    0    0    0
head(cat_items)  # 564 items to choose from for the first module
##               a          b         c u content_ID stage
## Item1 0.9690068 -0.8095104 0.2058130 1          1     1
## Item2 0.9977061  0.4988206 0.2478967 1          1     1
## Item3 1.2480486  0.7921580 0.2175363 1          1     1
## Item5 0.8100657 -0.1651131 0.1880910 1          1     1
## Item6 1.8063305 -2.5886409 0.2050464 1          1     1
## Item7 1.5339729  0.2158261 0.1627754 1          1     1
head(mst_items)  # 18 items in the three 2nd stage modules and another 18 in the three 3rd stage modules
##                a          b           c u content_ID stage
## Item16  1.942336 -1.1636251  0.16242780 1          1     2
## Item163 1.291475 -0.8679133  0.08023656 1          2     2
## Item307 1.365496 -0.6952439  0.10618155 1          3     2
## Item338 1.596254 -1.7547242 -0.03506398 1          3     2
## Item455 1.200316 -0.9559227  0.05452028 1          4     2
## Item463 1.198535 -0.9626176  0.06583896 1          4     2
head(example_module_items, 10)  # notice that there are only 6 items in the first module!
##       [,1] [,2] [,3] [,4] [,5] [,6] [,7]
##  [1,]    1    0    0    0    0    0    0
##  [2,]    1    0    0    0    0    0    0
##  [3,]    1    0    0    0    0    0    0
##  [4,]    1    0    0    0    0    0    0
##  [5,]    1    0    0    0    0    0    0
##  [6,]    1    0    0    0    0    0    0
##  [7,]    0    1    0    0    0    0    0
##  [8,]    0    1    0    0    0    0    0
##  [9,]    0    1    0    0    0    0    0
## [10,]    0    1    0    0    0    0    0


# run the Mca-MST model
results <- mixed_adaptive_test(response_matrix = example_responses, cat_item_bank = cat_items, 
    initial_theta = 0, method = "EAP", item_method = "MFI", cat_length = 6, 
    cbControl = NULL, cbGroup = NULL, randomesque = 1, mst_item_bank = mst_items, 
    modules = example_module_items, transition_matrix = example_transition_matrix, 
    n_stages = 3)
## Time difference of 7.812991 secs

results  # prints a summary of the results
## Test Format: Mixed Adaptive Test
## mixed_adaptive_test(response_matrix = example_responses, cat_item_bank = cat_items, initial_theta = 0, method = "EAP", item_method = "MFI", cat_length = 6, cbControl = NULL, cbGroup = NULL, randomesque = 1, mst_item_bank = mst_items, modules = example_module_items, transition_matrix = example_transition_matrix, n_stages = 3)
## Total Run Time: 7.813 secs
## Average Theta Estimate: 0.023
## Average SEM: 0.312
## Most Common Path(s) Taken: 1-3-6 taken by 5 subjects

# How good was our estimate of the individual's abilities?
data.frame(`True Theta` = example_thetas, `Estimated Theta` = results@final.theta.estimate, 
    `CI95 Lower Bound` = results@final.theta.estimate - 1.96 * results@final.theta.SEM, 
    `CI95 Upper Bound` = results@final.theta.estimate + 1.96 * results@final.theta.SEM)
##    True.Theta Estimated.Theta CI95.Lower.Bound CI95.Upper.Bound
## 1 -0.82791686      -0.4591914      -1.00213769       0.08375492
## 2  0.61463323       0.9233826       0.05974935       1.78701580
## 3  0.03785365       0.2025004      -0.35358200       0.75858276
## 4 -0.51095175      -0.1281526      -0.69074442       0.43443930
## 5 -0.08529469      -0.4259613      -0.95708895       0.10516628
```

For these five individuals, the estimated ability level appears fairly
close at worst and almost precisely correct at best. In all cases, the
95% confidence interval includes the simulated ability level, indicating
that the Mca-MST method works well for these individuals.

### Number-Correct (NC) Scoring with CMT

In some cases, applied testing demand the use of NC scoring (even if
it’s not psychometrically valid). To facilitate NC tests, the
`multistage_test()` function accepts a list with the cutoff score for
each route specified. Otherwise, the rest of the inputs are the same.

``` r
data(mst_only_items)
data(example_thetas)
data(example_module_items)
data(example_transition_matrix)
data(example_responses)
# these are the same as in the previous example however, for NC scoring, the
# lsit of cutoff values needs to be specified create nc_list as explained in
# 'details'
nc_list = list(module1 = c(4, 5, 7), module2 = c(8, 14, Inf), module3 = c(8, 
    14, 20), module4 = c(-Inf, 14, 20))
# this is the ONLY difference currently! Everything else remains the same
# run the example
nc.results <- multistage_test(mst_item_bank = mst_only_items, modules = example_module_items, 
    transition_matrix = example_transition_matrix, method = "BM", response_matrix = example_responses, 
    initial_theta = 0, model = NULL, n_stages = 3, test_length = 18, nc_list = nc_list)
## Time difference of 0.123668 secs

# printing a MST using NC scoring also shows the NC scoring method used
nc.results
## Test Format: Multistage Adaptive Test with Cumulative Summation Scoring
## multistage_test(mst_item_bank = mst_only_items, modules = example_module_items, transition_matrix = example_transition_matrix, method = "BM", response_matrix = example_responses, initial_theta = 0, model = NULL, n_stages = 3, test_length = 18, nc_list = nc_list)
## Total Run Time: 0.124 secs
## Average Theta Estimate: 0.036
## Average SEM: 0.336
## Most Common Path(s) Taken: 1-2-5 taken by 2 subjects
## Most Common Path(s) Taken: 1-4-6 taken by 2 subjects

# How well does NC scoring estimate the individual's abilities?  Using the
# estimation procedure from Baker for theta
data.frame(`True Theta` = example_thetas, `Estimated Theta` = nc.results@final.theta.estimate, 
    `CI95 Lower Bound` = nc.results@final.theta.estimate - 1.96 * results@final.theta.SEM, 
    `CI95 Upper Bound` = nc.results@final.theta.estimate + 1.96 * results@final.theta.SEM)
##    True.Theta Estimated.Theta CI95.Lower.Bound CI95.Upper.Bound
## 1 -0.82791686     -0.51226623       -1.0552125       0.03068008
## 2  0.61463323      0.61424430       -0.2493889       1.47787753
## 3  0.03785365      0.27442866       -0.2816537       0.83051104
## 4 -0.51095175     -0.14799784       -0.7105897       0.41459402
## 5 -0.08529469     -0.04877327       -0.5799009       0.48235434
```

With this example data, the NC scoring does about as well as the
previous methods in recovering the ability levels of these individuals.

### Computer Adaptive Testing (CAT)

Using the same individuals, we can administer a computerized adaptive
test with item-level adaptation. Generally, CAT performs better than the
other methods at the cost of algorithm complexity and potential
difficulties maintaining item security and content balance. However, it
is the golden standard for computer-based test and serves as a great
test for ‘best-case scenarios’.

``` r
set.seed(12345)  # to keep randomesque selecting the same items
# using simulated test data
data(example_thetas)  # 5 simulated abilities
data(example_responses)  # 5 simulated responsesdata
data(cat_items)  # using just the CAT-only routing items for the entire CAT test

catResults <- computerized_adaptive_test(cat_item_bank = cat_items, response_matrix = example_responses, 
    randomesque = 5, maxItems = 18, nextItemControl = list(criterion = "MFI", 
        priorDist = "norm", priorPar = c(0, 1), D = 1, range = c(-4, 4), parInt = c(-4, 
            4, 33), infoType = "Fisher", random.seed = NULL, rule = "precision", 
        thr = 0.3, nAvailable = NULL, cbControl = NULL, cbGroup = NULL))
## Time difference of 4.479837 secs

catResults
## Test Format: Computerized Adaptive Test
## computerized_adaptive_test(cat_item_bank = cat_items, response_matrix = example_responses, randomesque = 5, maxItems = 18, nextItemControl = list(criterion = "MFI", priorDist = "norm", priorPar = c(0, 1), D = 1, range = c(-4, 4), parInt = c(-4, 4, 33), infoType = "Fisher", random.seed = NULL, rule = "precision", thr = 0.3, nAvailable = NULL, cbControl = NULL, cbGroup = NULL))
## Total Run Time: 4.48 secs
## Average Theta Estimate: -0.021
## Average SEM: 0.344
## Average Number of Items Seen: 17.8

data.frame(`True Theta` = example_thetas, `Estimated Theta` = catResults@final.theta.estimate, 
    `CI95 Lower Bound` = catResults@final.theta.estimate - 1.96 * results@final.theta.SEM, 
    `CI95 Upper Bound` = catResults@final.theta.estimate + 1.96 * results@final.theta.SEM)
##    True.Theta Estimated.Theta CI95.Lower.Bound CI95.Upper.Bound
## 1 -0.82791686      -0.7050163       -1.2479626       -0.1620700
## 2  0.61463323       1.0595223        0.1958891        1.9231555
## 3  0.03785365       0.2860727       -0.2700096        0.8421551
## 4 -0.51095175      -0.8458816       -1.4084734       -0.2832897
## 5 -0.08529469       0.1003384       -0.4307892        0.6314660
```

The CAT method, using the precision rule with a value of .3 (i.e.,
stopping when the SEM is less than .3) and a maximum test length of 18,
produces theta confidence intervals that encompass the true theta in
each case. It is important to note, however, that only one individual
saw less than 18 items (and he only saw 17), and this individual is the
only one with an SEM of less than .3, so in reality we would probably
want to increase the maxItems each individual can see in order to get a
better estimate of their abilities. However, the theta estimates are
accurate and all fall within the 95% CIs.
