# Vendored functions from the mstR package (v1.2, archived on CRAN)
#
# Original authors: David Magis (U Liege, Belgium), Duanli Yan (ETS, USA),
#                   Alina von Davier (ACTNext, USA)
# Original license: GPL (>= 2)
# Reference: Magis, Yan and von Davier (2017, ISBN:978-3-319-69218-0)
#
# These functions were vendored into caMST because mstR is archived on CRAN
# and cannot be listed as a dependency for CRAN submission. Only the subset
# of functions required by caMST is included here. The catR equivalents of
# thetaEst, eapEst, and semTheta are used directly from catR instead.
#
# caMST is licensed GPL (>= 3); mstR's GPL (>= 2) permits redistribution
# under any later GPL version, so this inclusion is license-compatible.

#' @importFrom stats dnorm dunif rmultinom


# ---------------------------------------------------------------------------
# Internal helpers (not exported)
# ---------------------------------------------------------------------------

.mstR_Pi <- function(th, it, model = NULL, D = 1) {
  it <- rbind(it)
  if (is.null(model)) {
    a <- it[, 1]
    b <- it[, 2]
    c <- it[, 3]
    d <- it[, 4]
    e <- exp(D * a * (th - b))
    Pi <- c + (d - c) * e / (1 + e)
    Pi[Pi == 0] <- 1e-10
    Pi[Pi == 1] <- 1 - 1e-10
    dPi <- D * a * e * (d - c) / (1 + e)^2
    d2Pi <- D^2 * a^2 * e * (1 - e) * (d - c) / (1 + e)^3
    d3Pi <- D^3 * a^3 * e * (d - c) * (e^2 - 4 * e + 1) / (1 + e)^4
    res <- list(Pi = Pi, dPi = dPi, d2Pi = d2Pi, d3Pi = d3Pi)
  } else {
    if (sum(model == c("GRM", "MGRM", "PCM", "GPCM", "RSM", "NRM")) == 0)
      stop("invalid 'model' name'", call. = FALSE)
    if (model == "GRM" | model == "MGRM") {
      if (model == "GRM")
        prov <- prov1 <- prov2 <- prov3 <- matrix(NA, nrow(it), ncol(it))
      else
        prov <- prov1 <- prov2 <- prov3 <- matrix(NA, nrow(it), ncol(it) - 1)
      for (i in 1:nrow(it)) {
        aj <- it[i, 1]
        if (model == "GRM")
          bj <- it[i, 2:ncol(it)]
        else
          bj <- it[i, 2] - it[i, 3:ncol(it)]
        bj <- bj[!is.na(bj)]
        ej <- exp(D * aj * (th - bj))
        Pjs <- ej / (1 + ej)
        Pjs <- c(1, Pjs, 0)
        dPjs <- D * aj * Pjs * (1 - Pjs)
        d2Pjs <- D * aj * (dPjs - 2 * Pjs * dPjs)
        d3Pjs <- D * aj * (d2Pjs - 2 * dPjs^2 - 2 * Pjs * d2Pjs)
        n <- length(Pjs)
        prov[i, 1:(n - 1)] <- Pjs[1:(n - 1)] - Pjs[2:n]
        prov1[i, 1:(n - 1)] <- dPjs[1:(n - 1)] - dPjs[2:n]
        prov2[i, 1:(n - 1)] <- d2Pjs[1:(n - 1)] - d2Pjs[2:n]
        prov3[i, 1:(n - 1)] <- d3Pjs[1:(n - 1)] - d3Pjs[2:n]
      }
    } else {
      nc <- switch(model, PCM = ncol(it) + 1, GPCM = ncol(it),
                   RSM = ncol(it), NRM = ncol(it) / 2 + 1)
      prov <- prov1 <- prov2 <- prov3 <- matrix(NA, nrow(it), nc)
      for (i in 1:nrow(it)) {
        dj <- v <- 0
        if (model == "PCM") {
          for (t in 1:ncol(it)) {
            dj <- c(dj, dj[t] + D * (th - it[i, t]))
            v <- c(v, t)
          }
        }
        if (model == "GPCM") {
          for (t in 1:(ncol(it) - 1)) {
            dj <- c(dj, dj[t] + it[i, 1] * D * (th - it[i, t + 1]))
            v <- c(v, it[i, 1] * t)
          }
        }
        if (model == "RSM") {
          for (t in 1:(ncol(it) - 1)) {
            dj <- c(dj, dj[t] + D * (th - (it[i, 1] + it[i, t + 1])))
            v <- c(v, t)
          }
        }
        if (model == "NRM") {
          for (t in 1:(ncol(it) / 2)) {
            dj <- c(dj, it[i, (2 * (t - 1) + 1)] * th + it[i, (2 * t)])
            v <- c(v, it[i, (2 * (t - 1) + 1)])
          }
        }
        v <- v[!is.na(dj)]
        dj <- dj[!is.na(dj)]
        Gammaj <- exp(dj)
        dGammaj <- Gammaj * v
        d2Gammaj <- Gammaj * v^2
        d3Gammaj <- Gammaj * v^3
        Sg <- sum(Gammaj)
        Sdg <- sum(dGammaj)
        Sd2g <- sum(d2Gammaj)
        Sd3g <- sum(d3Gammaj)
        n <- length(Gammaj)
        prov[i, 1:n] <- Gammaj / Sg
        prov1[i, 1:n] <- dGammaj / Sg - Gammaj * Sdg / Sg^2
        prov2[i, 1:n] <- d2Gammaj / Sg - 2 * dGammaj * Sdg / Sg^2 -
          Gammaj * Sd2g / Sg^2 + 2 * Gammaj * Sdg^2 / Sg^3
        prov3[i, 1:n] <- d3Gammaj / Sg -
          (Gammaj * Sd3g + 3 * dGammaj * Sd2g + 3 * d2Gammaj * Sdg) / Sg^2 +
          (6 * Gammaj * Sdg * Sd2g + 6 * dGammaj * Sdg^2) / Sg^3 -
          6 * Gammaj * Sdg^3 / Sg^4
      }
    }
    cn <- "cat0"
    for (i in 1:(ncol(prov) - 1)) cn <- c(cn, paste("cat", i, sep = ""))
    colnames(prov) <- colnames(prov1) <- colnames(prov2) <- colnames(prov3) <- cn
    rn <- "Item1"
    if (nrow(it) > 1) {
      for (i in 2:nrow(prov)) rn <- c(rn, paste("Item", i, sep = ""))
    }
    rownames(prov) <- rownames(prov1) <- rownames(prov2) <- rownames(prov3) <- rn
    res <- list(Pi = prov, dPi = prov1, d2Pi = prov2, d3Pi = prov3)
  }
  return(res)
}


.mstR_Ii <- function(th, it, model = NULL, D = 1) {
  pr <- .mstR_Pi(th, it, model = model, D = D)
  P <- pr$Pi
  dP <- pr$dPi
  d2P <- pr$d2Pi
  d3P <- pr$d3Pi
  if (is.null(model)) {
    Q <- 1 - P
    Ii <- dP^2 / (P * Q)
    dIi <- dP * (2 * P * Q * d2P - dP^2 * (Q - P)) / (P^2 * Q^2)
    d2Ii <- (2 * P * Q * (d2P^2 + dP * d3P) - 2 * dP^2 * d2P * (Q - P)) /
      (P^2 * Q^2) -
      (3 * P^2 * Q * dP^2 * d2P - P * dP^4 * (2 * Q - P)) / (P^4 * Q^2) +
      (3 * P * Q^2 * dP^2 * d2P - Q * dP^4 * (Q - 2 * P)) / (P^2 * Q^4)
  } else {
    pr0 <- dP^2 / P
    pr1 <- 2 * dP * d2P / P - dP^3 / P^2
    pr2 <- (2 * d2P^2 + 2 * dP * d3P) / P - 2 * dP^2 * d2P / -3 * dP *
      d2P / P^2 + 2 * dP^4 / P^3
    Ii <- as.numeric(rowSums(pr0, na.rm = TRUE))
    dIi <- as.numeric(rowSums(pr1, na.rm = TRUE))
    d2Ii <- as.numeric(rowSums(pr2, na.rm = TRUE))
  }
  res <- list(Ii = Ii, dIi = dIi, d2Ii = d2Ii)
  return(res)
}


.mstR_integrate <- function(x, y) {
  hauteur <- x[2:length(x)] - x[1:(length(x) - 1)]
  base <- apply(cbind(y[1:(length(y) - 1)], y[2:length(y)]), 1, mean)
  res <- sum(base * hauteur)
  return(res)
}


.mstR_MWMI <- function(itemBank, modules, target.mod, it.given, x,
                        model = NULL, lower = -4, upper = 4, nqp = 33,
                        type = "MLWMI", priorDist = "norm",
                        priorPar = c(0, 1), D = 1) {
  if (type != "MLWMI" & type != "MPWMI")
    stop("'type' must be either 'MLWMI' or 'MPWMI'", call. = FALSE)
  if (is.null(model)) {
    L <- function(th, x, par) prod(.mstR_Pi(th, par, D = D)$Pi^x *
      (1 - .mstR_Pi(th, par, D = D)$Pi)^(1 - x))
    X <- seq(from = lower, to = upper, length = nqp)
    lik <- sapply(X, L, x, itemBank[it.given, ])
    items <- which(modules[, target.mod] == 1)
    Iprov <- function(t) sum(.mstR_Ii(t, itemBank, D = D)$Ii[items])
    info <- sapply(X, Iprov)
    crit.value <- lik * info
    if (type == "MPWMI") {
      pd <- NULL
      for (k in 1:length(X)) pd[k] <- switch(priorDist,
        norm = dnorm(X[k], priorPar[1], priorPar[2]),
        unif = dunif(X[k], priorPar[1], priorPar[2]))
      crit.value <- crit.value * pd
    }
  } else {
    LL <- function(th, it.given, x, model, D = 1) {
      if (dim(it.given)[1] == 0)
        res <- 1
      else {
        prob <- .mstR_Pi(th, it.given, model = model, D = D)$Pi
        res <- 1
        for (i in 1:length(x)) res <- res * prob[i, x[i] + 1]
      }
      return(res)
    }
    X <- seq(from = lower, to = upper, length = nqp)
    lik <- sapply(X, LL, itemBank[it.given, ], x, model, D = D)
    items <- which(modules[, target.mod] == 1)
    Iprov <- function(t) sum(.mstR_Ii(t, itemBank[items, ], model = model,
      D = D)$Ii)
    info <- sapply(X, Iprov)
    crit.value <- lik * info
    if (type == "MPWMI") {
      pd <- NULL
      for (k in 1:length(X)) pd[k] <- switch(priorDist,
        norm = dnorm(X[k], priorPar[1], priorPar[2]),
        unif = dunif(X[k], priorPar[1], priorPar[2]))
      crit.value <- crit.value * pd
    }
  }
  RES <- .mstR_integrate(X, crit.value)
  return(RES)
}


.mstR_MKL <- function(itemBank, modules, target.mod, theta = NULL, it.given,
                       x, model = NULL, lower = -4, upper = 4, nqp = 33,
                       type = "MKL", priorDist = "norm",
                       priorPar = c(0, 1), D = 1) {
  if (type != "MKL" & type != "MKLP")
    stop("'type' must be either 'MKL' or 'MKLP'", call. = FALSE)
  if (is.null(theta))
    theta <- catR::thetaEst(itemBank[it.given, ], x, D = D, model = model,
                            method = "ML")
  KLF <- NULL
  par <- rbind(itemBank[modules[, target.mod] == 1, ])
  X <- seq(from = lower, to = upper, length = nqp)
  par.given <- itemBank[it.given, ]
  if (is.null(model)) {
    L <- function(th, r, param) prod(.mstR_Pi(th, param, D = D)$Pi^r *
      (1 - .mstR_Pi(th, param, D = D)$Pi)^(1 - r))
    lik <- sapply(X, L, x, par.given)
    for (t in 1:nqp) KLF[t] <- sum(
      .mstR_Pi(theta, par, D = D)$Pi *
        log(.mstR_Pi(theta, par, D = D)$Pi / .mstR_Pi(X[t], par, D = D)$Pi) +
        (1 - .mstR_Pi(theta, par, D = D)$Pi) *
        log((1 - .mstR_Pi(theta, par, D = D)$Pi) /
              (1 - .mstR_Pi(X[t], par, D = D)$Pi)))
    crit.value <- lik * KLF
    if (type == "MKLP") {
      pd <- switch(priorDist,
        norm = dnorm(X, priorPar[1], priorPar[2]),
        unif = dunif(X, priorPar[1], priorPar[2]))
      crit.value <- crit.value * pd
    }
  } else {
    LL <- function(th, param, r, model, D = 1) {
      prob <- .mstR_Pi(th, param, model = model, D = D)$Pi
      res <- 1
      for (i in 1:length(r)) res <- res * prob[i, r[i] + 1]
      return(res)
    }
    lik <- sapply(X, LL, par.given, x, model = model, D = D)
    pi <- .mstR_Pi(theta, par, model = model, D = D)$Pi
    for (i in 1:length(X)) {
      pri <- .mstR_Pi(X[i], par, model = model, D = D)$Pi
      KLF[i] <- sum(pi * log(pi / pri), na.rm = TRUE)
    }
    crit.value <- lik * KLF
    if (type == "MKLP") {
      pd <- switch(priorDist,
        norm = dnorm(X, priorPar[1], priorPar[2]),
        unif = dunif(X, priorPar[1], priorPar[2]))
      crit.value <- crit.value * pd
    }
  }
  RES <- .mstR_integrate(X, crit.value)
  return(RES)
}


# ---------------------------------------------------------------------------
# Module selection functions used by caMST (not exported)
# ---------------------------------------------------------------------------

startModule <- function(itemBank, modules, transMatrix, model = NULL,
                        fixModule = NULL, seed = NULL, theta = 0, D = 1) {
  if (!is.null(fixModule)) {
    if (sum(transMatrix[, fixModule]) > 0)
      stop("Selected module is not from stage 1!", call. = FALSE)
    items <- which(modules[, fixModule] == 1)
    par <- itemBank[items, ]
    thStart <- NA
    res <- list(module = fixModule, items = items, par = par,
                thStart = thStart)
  } else {
    if (!is.null(seed)) {
      if (!is.na(seed)) set.seed(seed)
      mod <- sample(which(colSums(transMatrix) == 0), 1)
      items <- which(modules[, mod] == 1)
      par <- itemBank[items, ]
      thStart <- NA
      module <- mod
      set.seed(NULL)
    } else {
      mods <- which(colSums(transMatrix) == 0)
      info <- NULL
      for (i in 1:length(mods)) {
        items <- which(modules[, mods[i]] == 1)
        info[i] <- sum(.mstR_Ii(theta, itemBank[items, ], model = model,
                                D = D)$Ii)
      }
      keep <- min(which(info == max(info)))
      items <- which(modules[, mods[keep]] == 1)
      par <- itemBank[items, ]
      thStart <- theta
      module <- mods[keep]
    }
    res <- list(module = module, items = items, par = par, thStart = thStart)
  }
  return(res)
}


nextModule <- function(itemBank, modules, transMatrix, model = NULL,
                       current.module, out, x = NULL, cutoff = NULL,
                       theta = 0, criterion = "MFI", priorDist = "norm",
                       priorPar = c(0, 1), D = 1, range = c(-4, 4),
                       parInt = c(-4, 4, 33), randomesque = 1,
                       random.seed = NULL) {
  crit <- switch(criterion, MFI = "MFI", MLWMI = "MLWMI", MPWMI = "MPWMI",
                 MKL = "MKL", MKLP = "MKLP", random = "random")
  if (is.null(cutoff) & is.null(crit))
    stop("invalid 'criterion' name", call. = FALSE)
  if (is.null(cutoff) & !is.null(model)) {
    mod <- switch(model, GRM = 1, MGRM = 2, PCM = 3, GPCM = 4,
                  RSM = 5, NRM = 6)
    if (is.null(mod))
      stop("invalid 'model' type!", call. = FALSE)
  }
  pot.mods <- which(transMatrix[current.module, ] == 1)
  sel.stage <- NULL
  for (i in 1:length(pot.mods)) {
    items <- which(modules[, pot.mods[i]] == 1)
    if (length(out) + length(items) == length(unique(c(out, items))))
      sel.stage <- c(sel.stage, pot.mods[i])
  }
  if (is.null(sel.stage))
    stop("No available module without overlap with administered items",
         call. = FALSE)
  if (!is.null(cutoff)) {
    thr <- NULL
    for (i in 1:(length(sel.stage) - 1))
      thr <- c(thr, cutoff[cutoff[, 1] == sel.stage[i] &
                              cutoff[, 2] == sel.stage[i + 1], 3])
    thr <- c(-Inf, thr, Inf)
    if (sum(thr == theta) == 1) {
      ind <- which(thr == theta)
    } else {
      n <- length(thr)
      ind <- which(thr[1:(n - 1)] < theta & thr[2:n] > theta)
    }
    if (length(sel.stage) > 1) {
      probs <- rep((1 - randomesque) / (length(sel.stage) - 1),
                   length(sel.stage))
      probs[ind] <- randomesque
      if (!is.null(random.seed)) set.seed(random.seed)
      ind.pr <- which(c(rmultinom(1, 1, probs)) == 1)
    }
    final.module <- sel.stage[ind.pr]
    select <- which(modules[, final.module] == 1)
    bm <- ifelse(ind == ind.pr, TRUE, FALSE)
    res <- list(module = final.module, items = select,
                par = itemBank[select, ], info = theta,
                criterion = "cutoff", best.module = bm)
  } else {
    if (criterion == "MFI") {
      infos <- NULL
      for (i in 1:length(sel.stage)) {
        items <- which(modules[, sel.stage[i]] == 1)
        infos[i] <- sum(.mstR_Ii(theta, itemBank[items, ], model = model,
                                  D = D)$Ii)
      }
      maxinfo <- which(infos == max(infos))
      if (length(maxinfo) > 1) maxinfo <- sample(maxinfo, 1)
      if (length(sel.stage) > 1) {
        probs <- rep((1 - randomesque) / (length(sel.stage) - 1),
                     length(sel.stage))
        probs[maxinfo] <- randomesque
        if (!is.null(random.seed)) set.seed(random.seed)
        maxinfo.pr <- which(c(rmultinom(1, 1, probs)) == 1)
      }
      final.module <- sel.stage[maxinfo.pr]
      select <- which(modules[, final.module] == 1)
      bm <- ifelse(maxinfo == maxinfo.pr, TRUE, FALSE)
      res <- list(module = final.module, items = select,
                  par = itemBank[select, ], info = max(infos),
                  criterion = "MFI", best.module = bm)
    }
    if (criterion == "MLWMI" | criterion == "MPWMI") {
      infos <- NULL
      for (i in 1:length(sel.stage)) {
        infos[i] <- .mstR_MWMI(itemBank, modules, target.mod = sel.stage[i],
          it.given = out, x = x, lower = parInt[1], upper = parInt[2],
          nqp = parInt[3], type = criterion, priorDist = priorDist,
          priorPar = priorPar, D = D)
      }
      maxinfo <- which(infos == max(infos))
      if (length(maxinfo) > 1) maxinfo <- sample(maxinfo, 1)
      if (length(sel.stage) > 1) {
        probs <- rep((1 - randomesque) / (length(sel.stage) - 1),
                     length(sel.stage))
        probs[maxinfo] <- randomesque
        if (!is.null(random.seed)) set.seed(random.seed)
        maxinfo.pr <- which(c(rmultinom(1, 1, probs)) == 1)
      }
      final.module <- sel.stage[maxinfo.pr]
      select <- which(modules[, final.module] == 1)
      bm <- ifelse(maxinfo == maxinfo.pr, TRUE, FALSE)
      res <- list(module = final.module, items = select,
                  par = itemBank[select, ], info = max(infos),
                  criterion = criterion, best.module = bm)
    }
    if (criterion == "MKL" | criterion == "MKLP") {
      infos <- NULL
      for (i in 1:length(sel.stage)) {
        infos[i] <- .mstR_MKL(itemBank, modules, target.mod = sel.stage[i],
          it.given = out, x = x, theta = theta, lower = parInt[1],
          upper = parInt[2], nqp = parInt[3], type = criterion,
          priorDist = priorDist, priorPar = priorPar, D = D)
      }
      maxinfo <- which(infos == max(infos))
      if (length(maxinfo) > 1) maxinfo <- sample(maxinfo, 1)
      if (length(sel.stage) > 1) {
        probs <- rep((1 - randomesque) / (length(sel.stage) - 1),
                     length(sel.stage))
        probs[maxinfo] <- randomesque
        if (!is.null(random.seed)) set.seed(random.seed)
        maxinfo.pr <- which(c(rmultinom(1, 1, probs)) == 1)
      }
      final.module <- sel.stage[maxinfo.pr]
      select <- which(modules[, final.module] == 1)
      bm <- ifelse(maxinfo == maxinfo.pr, TRUE, FALSE)
      res <- list(module = final.module, items = select,
                  par = itemBank[select, ], info = max(infos),
                  criterion = criterion, best.module = bm)
    }
    if (criterion == "random") {
      final.module <- sample(sel.stage, 1)
      select <- which(modules[, final.module] == 1)
      res <- list(module = final.module, items = select,
                  par = itemBank[select, ], info = NA,
                  criterion = "random", best.module = TRUE)
    }
  }
  set.seed(NULL)
  return(res)
}
