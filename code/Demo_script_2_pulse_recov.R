#------------------------------------------------------
# Demo Script #2
# Pulse Recovery from FPP Using the Psi Operator
#------------------------------------------------------

# Replace myLocalPath with the path to PsiAnalysis_Functions.R and uncomment the next line
# source("myLocalPath/PsiAnalysis_Functions.R")

#------------------------------------------------------
# Select Phi Operator Definition (see paper main text and methods)
#------------------------------------------------------
Phi.definition <- list(
  Eq.11 = function(v) diff(var.delay(v, max.delay)) / 2,  # Implementation of Eq. 11
  Eq.12 = function(v) neg.diff.ACF(v, max.delay)          # Implementation of Eq. 12
)

# Select the method ("Eq.11" or "Eq.12")
selected.method <- "Eq.12"

#------------------------------------------------------
# Signal Parameters
#------------------------------------------------------
fs <- 5000         # Sampling rate (samples per second)
lambda_g <- 5000   # Pulse density of Poisson process (pulses per second)
lambda <- lambda_g / fs  # Pulse density at the sample-interval timing

# Define pulse (convolution kernel) as an alpha function with tau = 0.0015
tau <- 0.0015

# Total duration of the simulated signal (in seconds)
total.time <- 64
n.samples <- fs * total.time

#------------------------------------------------------
# Generate Poisson Process and Pulse
#------------------------------------------------------
PP <- rpois(n.samples, lambda)  # Poisson process
pulse <- do.alpha.pulse(tau, fs, total.time)  # Generate alpha-function pulse

# Normalize pulse energy to 1
pulse <- unitE(pulse)

# Simulated signal is the convolution of PP and an arbitrary pulse
X <- convolve(pulse, rev(PP), type = "circular")

# Ensure the signal has zero mean (simulate an AC signal)
X <- X - mean(X)

#------------------------------------------------------
# Pulse Recovery and Visualization
#------------------------------------------------------
max.delay <- 150
x.time <- seq(from = 0, by = 1000 / fs, length.out = max.delay)  # Time axis (milliseconds)
k <- lambda_g / fs / sum(pulse)  # Scaling factor (see Eq. 6 in the paper)

# Plot true pulse waveform (black trace)
plot(
  x.time, k * pulse[1:max.delay], type = "l", col = "red",
  xlab = "Time (ms)", ylab = "Pulse Amplitude", lwd = 3
)
title("Pulse waveform (red trace). Recovered pulse (black trace)")

# Compute Psi operator and overlay recovered pulse (red trace)
Psi.X <- Phi.definition[[selected.method]](X)
lines(x.time, Psi.X, lwd = 4, col = rgb(0, 0, 0, 0.75))
