#------------------------------------------------------
# Demo Script #3
# Pulse mixture generation and recovery of the corresponding Psi-pattern
#------------------------------------------------------

# Replace myLocalPath with the path to PsiAnalysis_Functions.R and uncomment the next line
# source("myLocalPath/PsiAnalysis_Functions.R")

#------------------------------------------------------
# Experimental Settings
#------------------------------------------------------
cat("---------------------------------------------------\n")
cat("Experimental Settings:\n")
cat("---------------------------------------------------\n")

# Sampling rate (samples per second)
fs <- 5000
cat(paste0("Sampling rate (fs)       : ", fs, " samples per second\n"))

# Total simulation time (seconds)
total.time <- 128
cat(paste0("Total time (total.time)  : ", total.time, " seconds\n"))

# Pulse density (pulses per second)
lambda_g <- 7500
cat(paste0("Pulse density (lambda_g) : ", lambda_g, " pulses per second\n"))

# Compute pulse density at the sample-interval timing
lambda <- lambda_g / fs

# Total number of samples
n.samples <- fs * total.time

# Initialize signal
X <- numeric(n.samples)

#------------------------------------------------------
# Generate Pulse Mixture
#------------------------------------------------------

#----------- Slow Pulse ------------------------------
tau1 <- 0.015
E.pulse1 <- 0.9  # Energy contribution (must be in range ]0, 1[)

# Validate energy contribution
if (E.pulse1 >= 1 | E.pulse1 <= 0) stop("E.pulse1 must be in the range ]0, 1[")

cat(paste0("Pulse 1 (slow), tau = ", tau1, " seconds\n"))
cat(paste0("Energy of pulse 1 (E.pulse1) : ", round(E.pulse1, 2), "\n"))

# Generate Poisson process and pulse
PP1 <- rpois(n.samples, lambda)
pulse1 <- do.alpha.pulse(tau1, fs, total.time)
pulse1 <- unitE(pulse1, E.pulse1)

# Convolve with Poisson process
X1 <- convolve(pulse1, rev(PP1), type = "circular")
X <- X + X1

#----------- Fast Pulse ------------------------------
tau2 <- 0.001
E.pulse2 <- 1 - E.pulse1

cat(paste0("Pulse 2 (fast), tau = ", tau2, " seconds\n"))
cat(paste0("Energy of pulse 2 (E.pulse2) : ", round(E.pulse2, 2), "\n"))

# Generate Poisson process and pulse
PP2 <- rpois(n.samples, lambda)
pulse2 <- do.alpha.pulse(tau2, fs, total.time)
pulse2 <- unitE(pulse2, E.pulse2)

# Convolve with Poisson process
X2 <- convolve(pulse2, rev(PP2), type = "circular")
X <- X + X2

# Ensure zero-mean AC signal
X <- X - mean(X)

#------------------------------------------------------
# Visualization
#------------------------------------------------------
par(mfrow = c(2, 1))  # Two-panel layout
par(mar = c(4, 4, 3, 1))

#-------------------------- Upper Panel ----------------------------------------
y.scale <- 3.5 * sd(X)  # Symmetric y-axis scaling
t.secs <- 1000  # Visualization time in milliseconds

# Time axis for upper panel
x.time.upper <- seq(from = 0, by = 1000 / fs, length.out = fs * t.secs / 1000)

plot(
  x.time.upper, X[1:(fs * t.secs / 1000)], type = "l",
  ylim = c(-y.scale, y.scale), xlab = "Time (ms)", ylab = "FPP Amplitude"
)
title("Filtered Poisson Process")
abline(h = 0, lty = 2)

#-------------------------- Lower Panel ----------------------------------------
max.delay <- 150  # Max delay for recovered pulses (in milliseconds)
plot.samps <- fs * max.delay / 1000  # Number of samples for lower panel

# Time axis for lower panel
x.time.lower <- seq(from = 0, by = 1000 / fs, length.out = plot.samps)

# Compute Psi-pattern
Psi.X <- neg.diff.ACF(X, plot.samps)

# Scaling factors for pulse recovery
k1 <- E.pulse1 * lambda_g / fs / sum(pulse1)
k2 <- E.pulse2 * lambda_g / fs / sum(pulse2)

# Plot individual pulses and Psi-pattern
plot(
  x.time.lower, (k1 * pulse1 + k2 * pulse2)[1:plot.samps], type = "l", lwd = 3,
  xlab = "Time (ms)", ylab = "Power Density", col = "red"
)
title("Individual Pulses (dashed) & Psi-pattern (black)")

# Overlay individual pulses
lines(x.time.lower, k1 * pulse1[1:plot.samps], lty = 2)
lines(x.time.lower, k2 * pulse2[1:plot.samps], lty = 2)
lines(x.time.lower, Psi.X, lwd = 4, col = rgb(0, 0, 0, 0.75))
