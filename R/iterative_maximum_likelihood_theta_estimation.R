iterative.theta.estimate = function (initial_theta = 0, item.params, response.pattern){
  # This function is used to estimate person thetas based on their response patterns, meaning that
  # novel response patterns can produce a (hopefully unbiased) theta estimate.

  # split item param data frame into vectors
  item.discriminations = item.params[,1]
  item.difficulty = item.params[,2]
  item.guessing = item.params[,3]

  ########### To estimate the person parameter based on pre-specified item discriminations, dificulties, a
  ###### given response pattern, and some initial theta value, the following code sets up a WHILE statement
  ###### to continuously update the theta up to the stopping point, defined as changes in theta estimate
  ###### being less than 0.001. Based on Baker (2001) Chapter 5. http://echo.edres.org:8080/irt/baker/final.pdf
  final.theta.estimates = c() # this is where the point estimates are saved
  final.theta.SEM = c() # this is where the standard error of measurement values are saved
  for (i in 1:nrow(response.pattern)){ # for each individual,
    person.response.pattern = as.numeric(unlist(response.pattern[i,])) # take their response pattern
    current.theta = initial_theta
    new.theta = 0
    probability.correct = item.guessing + (1 - item.guessing)/(1+exp(-1*item.discriminations*(current.theta-item.difficulty)))
    numerator = sum(item.discriminations * (person.response.pattern - probability.correct))
    denominator = sum(item.discriminations^2 * probability.correct * (1-probability.correct))
    j = 0
    while (abs(numerator/denominator) > 0.001 && abs(new.theta) < 4 && j < 100) {
      j = j+1
      numerator = sum(item.discriminations * (person.response.pattern - probability.correct))
      denominator = sum(item.discriminations^2 * probability.correct * (1-probability.correct))

      new.theta = current.theta + (numerator/denominator)
      current.theta = new.theta
      probability.correct = item.guessing + (1 - item.guessing)/(1+exp(-1*item.discriminations*(current.theta-item.difficulty)))
    }
    final.theta.estimates[i] = new.theta
    final.theta.SEM[i] = 1/sqrt(denominator)
  }
  return(cbind(final.theta.estimates, final.theta.SEM))
}
