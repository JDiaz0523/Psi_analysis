#--------------------------------------------------
# Demo Script #4
# Psi-Patterns of Spontaneous Mouse EEG
# Author  : Javier Diaz
# Purpose : Demonstrate Psi-pattern analysis on mouse EEG
#--------------------------------------------------

# Requirements:
# - Input data: 'mouse_eeg_1h_5kHz.rds' (1-hour EEG vector, sampled at 5 kHz)
#
# The script generates two plot panels:
# 1) Psi-matrix (x-axis: time, one column per EEG epoch; y-axis: delay)
# 2) Three Psi-patterns representative of WAKE (gray), NREM sleep (blue), and REM sleep (red).
#    EEG times are indicated by dashed lines in panel 1.
#--------------------------------------------------

# Replace myLocalPath with the actual path to PsiAnalysis_Functions.R and uncomment the next line
# source("myLocalPath/PsiAnalysis_Functions.R")

#----------------- Path and file name ------------------
eeg.data.path <- "paste-the-path-to-EEG-file-here"
eeg.data.fileName <- "mouse_eeg_1h_5kHz.rds"

# Load EEG data
eeg <- readRDS(file.path(eeg.data.path, eeg.data.fileName))

#----------------- Analysis Parameters ------------------
epoch.length <- 4       # Length of each epoch in seconds
fs <- 5000              # Sampling frequency (Hz)
max.delay <- 1250       # Maximum delay for Psi calculation (in samples)

# Generate Psi matrix
cat("Generating Psi-matrix...\n")
EEG_Psi_matrix <- epoch.feature(eeg, epoch.length, epoch.length / 2, fs, 
                                function(epoch) neg.diff.ACF(epoch, max.delay))

#----------------- Representative Epochs ------------------
# Indices pointing to representative state-dependent Psi-patterns
WAKE.epoch <- 126
NREM.epoch <- 485
REM.epoch <- 767

# Plot scaling factor
plot.window.scale <- 0.65

#----------------- Plot Psi Matrix ------------------
x11(width = 15 * plot.window.scale, height = 9 * plot.window.scale)
plot.Psi.matrix(EEG_Psi_matrix)
title("Psi-Matrix")

# Add annotations for highlighted epochs
abline(v = WAKE.epoch * epoch.length / 3600, col = "lightgray", lwd = 2, lty = 3)
abline(v = NREM.epoch * epoch.length / 3600, col = "lightblue", lwd = 2, lty = 3)
abline(v = REM.epoch * epoch.length / 3600, col = "pink", lwd = 2, lty = 3)

text(WAKE.epoch * epoch.length / 3600, 240, "WAKE", col = "lightgray")
text(NREM.epoch * epoch.length / 3600, 240, "NREM", col = "lightblue")
text(REM.epoch * epoch.length / 3600, 240, "REM", col = "pink")

#----------------- Plots: Psi-patterns from Highlighted Epochs ------------------
x11(width = 5 * plot.window.scale, height = 9 * plot.window.scale)
par(mfrow = c(3, 1), mar = c(4, 4, 1, 1))  # Multi-panel layout

# Time vector for delays
x.time <- seq(from = 0, by = 1000 / fs, length.out = ncol(EEG_Psi_matrix))
y.lim <- c(-50, 150)  # y-axis scale

# Plot for WAKE
plot(x.time, EEG_Psi_matrix[WAKE.epoch, ], type = "l", lwd = 2, col = "darkgray", 
     ylim = y.lim, xlab = "Delay (ms)", ylab = "Power density (WAKE)")
abline(h = 0, lty = 2)

# Plot for NREM
plot(x.time, EEG_Psi_matrix[NREM.epoch, ], type = "l", lwd = 2, col = "blue", 
     ylim = y.lim, xlab = "Delay (ms)", ylab = "Power density (NREM)")
abline(h = 0, lty = 2)

# Plot for REM
plot(x.time, EEG_Psi_matrix[REM.epoch, ], type = "l", lwd = 2, col = "red", 
     ylim = y.lim, xlab = "Delay (ms)", ylab = "Power density (REM)")
abline(h = 0, lty = 2)
