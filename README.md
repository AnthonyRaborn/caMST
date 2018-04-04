
# caMST

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/caMST)](http://cran.r-project.org/package=caMST)
[![Travis-CI Build
Status](http://travis-ci.org/AnthonyRaborn/caMST.svg?branch=master)](http://travis-ci.org/AnthonyRaborn/caMST)

## Installation

``` r
# install.packages("devtools")
devtools::install_github("AnthonyRaborn/caMST") # the developmental version; no CRAN version yet
```

## Usage

Here are some examples demonstrating how to use this package for various
adaptive test frameworks.

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
load("data/example_thetas.rda") # 5 simulated abilities
load("data/example_responses.rda") # 5 simulated responses
load("data/example_transition_matrix.rda") # the transition matrix for an 18 item 1-3-3 balanced design
load("data/cat_items.rda") # the items designated for use in the routing module with item-level adaptation
load("data/mst_items.rda") # the items designated for use in the second and third modules with module-level adaptation
load("data/example_module_items.rda") # the matrix specifying how the item data frame relates to the modules

# what does the data look like?
example_thetas
##  [1] -0.82791686  0.61463323  0.03785365 -0.51095175 -0.08529469
example_responses[,1:5] # first 5 items
##    Item3 Item4 Item5 Item6 Item7
##  1     0     0     1     1     0
##  2     1     1     1     1     1
##  3     0     1     1     1     1
##  4     0     0     1     1     1
##  5     0     1     1     1     0
example_transition_matrix
##       [,1] [,2] [,3] [,4] [,5] [,6] [,7]
##  [1,]    0    1    1    1    0    0    0
##  [2,]    0    0    0    0    1    1    0
##  [3,]    0    0    0    0    1    1    1
##  [4,]    0    0    0    0    0    1    1
##  [5,]    0    0    0    0    0    0    0
##  [6,]    0    0    0    0    0    0    0
##  [7,]    0    0    0    0    0    0    0
head(cat_items) # 564 items to choose from for the first module
##                a          b         c u content_ID stage
##  Item1 0.9690068 -0.8095104 0.2058130 1          1     1
##  Item2 0.9977061  0.4988206 0.2478967 1          1     1
##  Item3 1.2480486  0.7921580 0.2175363 1          1     1
##  Item5 0.8100657 -0.1651131 0.1880910 1          1     1
##  Item6 1.8063305 -2.5886409 0.2050464 1          1     1
##  Item7 1.5339729  0.2158261 0.1627754 1          1     1
head(mst_items) # 18 items in the three 2nd stage modules and another 18 in the three 3rd stage modules
##                 a          b           c u content_ID stage
##  Item16  1.942336 -1.1636251  0.16242780 1          1     2
##  Item163 1.291475 -0.8679133  0.08023656 1          2     2
##  Item307 1.365496 -0.6952439  0.10618155 1          3     2
##  Item338 1.596254 -1.7547242 -0.03506398 1          3     2
##  Item455 1.200316 -0.9559227  0.05452028 1          4     2
##  Item463 1.198535 -0.9626176  0.06583896 1          4     2
head(example_module_items, 10) # notice that there are only 6 items in the first module!
##        [,1] [,2] [,3] [,4] [,5] [,6] [,7]
##   [1,]    1    0    0    0    0    0    0
##   [2,]    1    0    0    0    0    0    0
##   [3,]    1    0    0    0    0    0    0
##   [4,]    1    0    0    0    0    0    0
##   [5,]    1    0    0    0    0    0    0
##   [6,]    1    0    0    0    0    0    0
##   [7,]    0    1    0    0    0    0    0
##   [8,]    0    1    0    0    0    0    0
##   [9,]    0    1    0    0    0    0    0
##  [10,]    0    1    0    0    0    0    0


# run the Mca-MST model
results <- mixed_adaptive_test(response_matrix = example_responses, 
                               cat_item_bank = cat_items, initial_theta = 0,
                               method = "EAP", item_method = "MFI", 
                               cat_length = 6, cbControl = NULL, cbGroup = NULL,
                               randomesque = 1, mst_item_bank = mst_items, 
                               modules = example_module_items, 
                               transition_matrix = example_transition_matrix)
##  Time difference of 5.920149 secs

# The function outputs a list with named elements; 
# each individual is his or her own element in the list.
# the first person's results:
results[[1]]
##  $final.theta.estimate.mstR
##  [1] -0.4591914
##  
##  $eap.theta
##  [1] -0.4591914
##  
##  $final.theta.iterative
##  final.theta.estimates 
##             -0.4667809 
##  
##  $sem.iterative
##  final.theta.SEM 
##        0.2770134 
##  
##  $final.item.bank
##                 a           b            c u
##  Item218 1.965859 -0.14896078  0.093636182 1
##  Item233 2.062836 -0.62296659  0.183517489 1
##  Item255 1.878777 -0.62845092  0.108941349 1
##  Item113 1.873268 -0.78761796  0.127308819 1
##  Item436 1.845554 -0.70759536  0.138748432 1
##  Item592 1.841591  0.01429615  0.061182887 1
##  Item16  1.942336 -1.16362512  0.162427797 1
##  Item163 1.291475 -0.86791331  0.080236564 1
##  Item307 1.365496 -0.69524391  0.106181552 1
##  Item338 1.596254 -1.75472419 -0.035063979 1
##  Item455 1.200316 -0.95592274  0.054520279 1
##  Item463 1.198535 -0.96261759  0.065838958 1
##  Item24  1.457714 -0.13649086  0.070461056 1
##  Item187 1.735446 -0.02408069  0.096825087 1
##  Item303 1.409571  0.24277169  0.068452610 1
##  Item323 1.577189 -0.03436954  0.096662564 1
##  Item475 1.754482 -0.07231393  0.232554853 1
##  Item515 1.353925 -0.32042542  0.176799965 1
##  Item4   1.523265  0.47756078  0.182158317 1
##  Item210 1.361568  0.63500846  0.053184254 1
##  Item320 1.707442  0.59352903  0.259429826 1
##  Item360 1.439101  1.34016671  0.198780718 1
##  Item453 1.463229  1.64556723 -0.002269462 1
##  Item469 1.604599  0.47257021  0.228727061 1
##  Item26  1.577682 -1.29291163  0.164442133 1
##  Item178 1.704296 -0.65642080  0.062392125 1
##  Item356 1.457852 -0.58485427  0.121895635 1
##  Item358 1.392341 -1.43879752  0.276613693 1
##  Item467 1.669552 -0.75538706  0.140674467 1
##  Item468 1.252312 -0.97014412 -0.010202359 1
##  Item25  1.765608 -0.26227232  0.047067211 1
##  Item200 2.374551 -0.26604121  0.243866356 1
##  Item342 1.465245 -0.15055771  0.189351931 1
##  Item352 1.676479 -0.20880138 -0.017662196 1
##  Item523 1.591088 -0.01293736  0.236757364 1
##  Item529 1.492281 -0.30719160  0.059637357 1
##  Item98  1.517569  0.55773427  0.239810532 1
##  Item258 1.734635  1.30553497  0.255535744 1
##  Item364 1.615977  0.97482181  0.284621021 1
##  Item369 1.186457  0.35378389 -0.007758204 1
##  Item470 1.574611  0.70167241  0.242930804 1
##  Item473 2.372814  0.73038359  0.330609525 1
##  
##  $final.items.seen
##   [1] "Item218" "Item233" "Item255" "Item113" "Item436" "Item592" "Item24" 
##   [8] "Item187" "Item303" "Item323" "Item475" "Item515" "Item25"  "Item200"
##  [15] "Item342" "Item352" "Item523" "Item529"
##  
##  $modules.seen
##  [1] 3 6
##  
##  $final.responses
##   [1] 0 1 0 1 1 1 1 0 1 0 1 0 0 0 0 0 1 1

# How good was our estimate of the individual's abilities?
data.frame("True Theta" = example_thetas,
           "Estimated Theta" = unlist(lapply(results, '[[', 1)),
           "CI95 Lower Bound" = unlist(lapply(results, '[[', 1)) -
             1.96*unlist(lapply(results, '[[', 4)),
           "CI95 Upper Bound" = unlist(lapply(results, '[[', 1)) +
             1.96*unlist(lapply(results, '[[', 4)))
##     True.Theta Estimated.Theta CI95.Lower.Bound CI95.Upper.Bound
##  1 -0.82791686      -0.4591914     -1.002137692       0.08375492
##  2  0.61463323       0.6266054      0.004088176       1.24912266
##  3  0.03785365       0.2025004     -0.353582000       0.75858276
##  4 -0.51095175      -0.1281526     -0.690744424       0.43443930
##  5 -0.08529469      -0.4259613     -0.957088953       0.10516628
```

For these five individuals, the estimated ability level appears fairly
close at worst and almost precisely correct at best. In all cases, the
95% confidence interval includes the simulated ability level, indicating
that the Mca-MST method works well for these individuals.
