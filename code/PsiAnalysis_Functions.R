# PsiAnalysis_Functions.R
#
# This file contains R functions for Psi-analysis and signal processing.
# For detailed descriptions of each function, refer to the README on the front page of this GitHub repository.
#
# Usage:
# - save this file in your machine: "myLocalPath/PsiAnalysis_Functions.R"
# - load this file into RStudio and press the [Source] button
# - or source this file from your own R scripts: source("myLocalPath/PsiAnalysis_Functions.R")
# - Use the functions as described in the README.
#
# Author: Javier Diaz Cisternas
# Date: 2025-04-02
# License: MIT


do.alpha.pulse <- function(tau, fs, t.max){
  time <- seq(from=0, by=1/fs, length.out = fs*t.max)
  pmax(time/tau*exp(1-time/tau), 0)
}


do.dual.exp.pulse <- function(tau1, tau2, fs, t.max){
  if(tau1 >= tau2) stop("tau1 < tau2 required!")
  time <- seq(from=0, by=1/fs, length.out = fs*t.max)
  pmax(tau1*tau2/(tau1 + tau2)*(exp(-time/tau2) - exp(-time/tau1)), 0)
}


unitE <- function(signal, outputE = 1){
  inputE <- sum(signal^2)
  signal*sqrt(outputE/inputE)
}


var.delay <- function(signal, max.delay){
  var.d <- numeric(max.delay)
  for(i in 1:max.delay) var.d[i] <- var(diff(signal, i))
  c(0, var.d)
}


neg.diff.ACF <- function(signal, max.delay){
  -diff(c(acf(signal, max.delay, type= "covariance", plot=F)$acf))
}


epoch.feature <- function(signal, epoch.length, epoch.overlap, fs, func){
  n <- trunc(length(signal)/fs/epoch.length)
  feature <- list()
  rng.1 <- (-epoch.overlap*fs + 1):(epoch.length*fs + epoch.overlap*fs)
  pb <- txtProgressBar(style=3,width=20)
  for(i in 1:n){
    rng <- specular.ext(rng.1 + (i - 1)*epoch.length*fs, length(signal))
    sub.signal <- signal[rng]
    feature[[i]] <- func(sub.signal)
    setTxtProgressBar(pb, i/n)
  }
  close(pb)
  len.feat <- length(feature[[1]])
  feature <- unlist(feature)
  if(len.feat > 1) feature <- matrix(feature, nrow=n, byrow=T)
  feature
}


specular.ext <- function(K, lim.sup){
  N <- length(K)
  L <- sum(K < 1)
  if(L != 0) K[1:L] <- (L + 1):2
  L <- sum(K > lim.sup)
  if(L != 0) K[(N - L + 1):N] <- (lim.sup - 1):(lim.sup - L)
  K
}

psi.extract <- function(psi.matrix, n){
  apply(psi.matrix, 1, function(psi.pattern) sum(psi.pattern[1:n]))
}

plot.Psi.matrix <- function(psi.matrix,
                            win.width = NULL, win.offset=0,
                            col.grad1 = c(rgb(0.5,0,0), rgb(0,0,0)), 
                            col.grad2 = c(rgb(0,0,0), rgb(0,0,1), rgb(0.5,0.5,1), rgb(0,1,1)),
                            numcol = 512, 
                            grad.ratio = 3,
                            x.d = 4/3600, xl = "time (hours)",
                            y.d = 1/5, yl = "delay (ms)",
                            col.limits = NULL,
                            auto.col.lim = 0.98,
                            plot.mar = c(4,4,2,1)){
  n.levels.2 <- round(numcol*grad.ratio/(grad.ratio + 1))
  n.levels.1 <- numcol - n.levels.2
  color.scheme <- c(colorRampPalette(col.grad1)(n.levels.1), colorRampPalette(col.grad2)(n.levels.2))
  if(is.null(col.limits)){
    q <- quantile(psi.matrix, auto.col.lim, na.rm = T)
    col.limits <- c(-q/grad.ratio, q)
    names(col.limits) <- NULL
  }
  if(is.null(win.width)){
    win.width <- nrow(psi.matrix)
    win.offset <- 0
  }
  tx <- seq(from=0, by=x.d, length.out = win.width)
  ty <- seq(from=0, by=y.d, length.out = ncol(psi.matrix))
  par(mar = plot.mar)
  image(tx, ty,
        pmax(pmin(psi.matrix[1:win.width + win.offset,], col.limits[2]), col.limits[1]),
        col=color.scheme,
        xlab = xl,
        ylab = yl)
  invisible(col.limits)
}

map.vector <- function(v, new.length){
  l <- length(v)
  v[ceiling(1:new.length*l/new.length)]
}
