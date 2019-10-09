# Package v0.1.2
## Major Updates
  - Each of the major functions now produce S4 objects with similar slots
    - This results in a more standardized and predictable set of outputs for each function
  - With the S4 classes, I've added a print method that summarizes the results of the functions
  - The `multistage_test` function can now perform two kinds of number correct scoring, instead of the original one, and records which scoring logic was used
  - A plot function was introduced to aid in creating publication-ready diagrams showing the multistage test design (including the mixed adaptive tests)
    - This function also works with the two relevant S4 objects created in this release
