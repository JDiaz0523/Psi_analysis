# Psi-patterns of Mouse EEG: R Functions and Demo Scripts.
**Author**: Javier Diaz Cisternas  

## Overview
This repository contains scripts and functions for analyzing mouse EEG data using the Psi-analysis framework.  
For details on the methodology, refer to [link to DOI](https://doi.org/xyz).  

---

## Quick Start
If you're new to this project, you can simply:
1. Copy and paste the functions provided in `psi_analysis_functions.R` into your RStudio environment.
2. Download the test data file [mouse_eeg_1h_5kHz.rds](data/mouse_eeg_1h_5kHz.rds) and place it in your working directory.
3. Follow the examples provided in the demo scripts to generate Psi-matrices and visualizations.  

This approach ensures you can quickly test the framework without complex setup steps.

---

## Table of Contents
1. [About Psi-analysis](#about-psi-analysis)
2. [Installation](#installation)
3. [Functions list](#Function-Descriptions-Table)
4. [Usage](#usage)
5. [Examples](#examples)
6. [Quick Start](#quick-start)
7. [Contributing](#contributing)

---

## About Psi-analysis
Psi-analysis is a novel framework designed to analyze state-dependent EEG patterns at high temporal resolution.  
It is particularly effective for identifying characteristic Psi-matrix patterns across sleep states (WAKE, NREM, REM).

## About filtered Poisson process
Filtered Poisson Process (FPP)

A Poisson process models the random occurrence of discrete, independent events in time, typically represented as instantaneous points. The filtered Poisson process extends this concept by replacing each instantaneous event with a non-instantaneous function, often referred to as a kernel. This transformation generates a continuous signal, where overlapping contributions occur naturally when events are temporally close, resulting in the superposition of the kernels.

The FPP efficiently captures the intrinsic interference arising from the randomness of event timing. This is achieved by generating a Poisson process and convolving it with an arbitrary kernel. The resulting signal retains the randomness of the underlying process while incorporating the effects of the chosen kernel's temporal profile.

The R code provided in this repository demonstrates the basic steps to generate and visualize filtered Poisson processes, showcasing their utility in modeling stochastic signals. Below is a simple example illustrating how to generate an FPP in R:

```r
#----------------------------------------------------
# Generating a Filtered Poisson Process (FPP)
#----------------------------------------------------

# Step 1: Set parameters
fs <- 2000               # Sampling frequency (Hz)
total.time <- 1          # Total duration (seconds)
n.samples <- fs*total.time  # Number of samples
lambda_g <- 500          # Event rate (events/second)
lambda <- lambda_g/fs  # Event rate (events/sample)
E_g <- 1 # The energy carried by the pulse

# Step 2: Generate Poisson process
PP <- rpois(n.samples, lambda)

# Step 3: Define kernel (pulse)
tau <- 0.01              # Kernel time constant (seconds)
pulse <- do.alpha.pulse(tau, fs, total.time)  # Custom kernel function
pulse <- unitE(pulse, E_g)    # Normalize kernel energy to 1

# Step 4: Convolve Poisson process with kernel
FPP <- convolve(pulse, rev(PP), type = "circular")
FPP <- FPP - mean(FPP)   # Center the signal (e.g., for EEG simulations)

# Step 5: Plot the resulting FPP
plot(FPP, type = "l", 
     main = "Filtered Poisson Process (FPP)", 
     xlab = "Time (samples)", 
     ylab = "Amplitude")
```

Details

The function `rpois` generates a vector of length `n.samples` filled with random deviates following the Poisson distribution parameterized by `lambda`. Each value in the vector is an integer representing the number of events that occurred randomly in a specific time bin, based on the sampling frequency (`fs`).

* A time bin corresponds to a single sample, determined by fs (e.g., if `fs = 2000`, each time bin is 1/2000 seconds).
* The expected number of events per bin is `lambda = lambda_g/fs`, where `lambda_g` is the event rate in events per second.

The kernel (or pulse) can be defined using any arbitrary function, provided that its total energy is finite (i.e., it forms a discrete energy packet). An [alpha function](#doalphapulse) is used in the example. Regardless of the specific pulse shape, it is important to control the pulse's energy fully, as key properties of the FPP depend on it. For example, the FPP variance is `lambda_g*E_g/fs`, while the FPP power is `lambda_g*E_g` (see xxx for additional information).

In the convolution operation, the option "circular" confines the signal to a cylindrical space, ensuring no energy leakage occurs at the borders. This approach mimics the properties of an infinite signal by wrapping contributions from the edges back into the signal, preserving the integrity of the convolution and avoiding artifacts that may arise in finite-length signals.

## Installation
Clone this repository and install the required R packages.  
```bash
git clone https://github.com/your_username/psi-analysis.git
```
## Function Descriptions Table

| Function           | Description                                                 |
|--------------------|-------------------------------------------------------------|
| [do.alpha.pulse](#doalphapulse)     | Generates an alpha function vector given the $\tau$ parameter. |
| [do.dual.exp.pulse](#dodualexppulse)  | Generates a dual-exponential function vector given $\tau_1$ and $\tau_2$ parameters. |
| [unitE](#unite)              | Rescales a vector to unit energy (default), or to any other arbitrary value. |
| [var.delay](#vardelay)          | Computes the variance of a signal after subtracting delayed copies of itself. |
| [neg.diff.ACF](#negdiffACF)       | Computes the negative derivative of the autocovariance function. |
| [epoch.feature](#epochfeature)      | Divides a signal into epochs and evaluates a feature according to a given function. |
| [specular.ext](#specularext)       | Extends a vector by mirroring its ends. |
| [plot.Psi.matrix](#plotPsimatrix)    | Displays the Psi matrix using a custom pseudocolor scale. |
| [map.vector](#mapvector)         | Rescales a vector to a specified length using proportional mapping. |

The complete implementation of these functions is available in the file [`PsiAnalysis_Functions.R`](link-to-the-file).    
Users can download or explore the file directly from the repository.
---------------------------------------------------------------------------------------
### **do.alpha.pulse**
---
#### **Description**
Generates an alpha function vector defined by the equation:
```math
\frac{t}{\tau} \, e^{1 - \frac{t}{\tau}}
```
This function is widely used for modeling neuronal activation waveforms, including simulations of synaptic conductances and other time-dependent neural processes.

#### **Usage**
```r
do.alpha.pulse(tau, fs, t.max)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `tau`    | Time constant $\tau$ in seconds. |
| `fs`     | Sampling rate (samples per second). |
| `t.max`  | Time length in seconds. |

#### **Value**
A floating-point vector of length `t.max`$\times$`fs`

#### **Example**
```r
plot(do.alpha.pulse(0.1, 1000, 1), type="l")
```

---------------------------------------------------------------------------------------
### **do.dual.exp.pulse**
---
#### **Description**
Generates a dual-exponential function vector defined by the equation:
```math
\frac{\tau_1\tau_2}{\tau_1 + \tau_2} \, (e^{-\frac{t}{\tau_2}} - e^{-\frac{t}{\tau_1}})
```
This function is widely used for modeling neuronal activation waveforms, including simulations of synaptic conductances and other time-dependent neural processes.

#### **Usage**
```r
do.dual.exp.pulse(tau1, tau2, fs, t.max)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `tau1`    | Time constant controlling the rising phase (seconds). |
| `tau2`    | Time constant controlling the falling phase (seconds). |
| `fs`     | Sampling rate (samples per second). |
| `t.max`  | Time length in seconds. |

Important: The condition tau1 < tau2 must be satisfied.

#### **Value**
A floating-point vector of length `t.max`$\times$`fs`

#### **Example**
```r
plot(do.dual.exp.pulse(0.01, 0.1, 1000, 1), type="l")
```

---------------------------------------------------------------------------------------
### **unitE**
---
#### **Description**
Scales an input vector to achieve unit energy (by default) or any other energy value specified by `outputE`.

#### **Usage**
```r
unitE(signal, outputE = 1)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `signal`    | A numeric vector representing the input signal. |
| `outputE`   | The desired energy of the output vector (default is 1). |

#### **Value**
A numeric vector with the same length as the input vector, scaled to the specified energy.

#### **Example**
```r
# Scale an alpha pulse to unit energy
pulse <- unitE(do.alpha.pulse(0.1, 1000, 1))

# Scale another instance of the alpha pulse to achieve an energy of 2.
pulse2 <- unitE(do.alpha.pulse(0.1, 1000, 1), outputE = 2)
```

---------------------------------------------------------------------------------------
### **var.delay**
---
#### **Description**
Calculates the variance of a given signal after subtracting progressively delayed copies of itself. This function, corresponding to the variance of $\hat{X}$ (ref, Eq. 4), is primarily intended for demonstrating mathematical concepts through numerical methods (see Notes below).

#### **Usage**
```r
var.delay(signal, max.delay)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `signal`    | A numeric vector representing the input signal. |
| `max.delay`   | The maximum delay to evaluate the variance. |

#### **Value**
A numeric vector of length max.delay + 1. The first element is zero, corresponding to the expected zero variance at zero delay.

#### **Example**
```r
# Following Equation 11 (ref), Psi can be numerically calculated as:
Psi <- diff(var.delay(signal, max.delay))/2
```

Notes

- This function operates slowly in R (an interpreted language) and is intended only for demonstrations, such as numerically illustrating the equivalence of Equations 11 and 12 (ref), supported by Equation 9 (see demo script 2).

- For improved performance, use the neg.diff.ACF function, which calculates Psi efficiently by leveraging the optimized `acf` function.

---------------------------------------------------------------------------------------
### **neg.diff.ACF**
---
#### **Description**
Computes the negative derivative of the autocovariance function using the built-in R function `acf`.

#### **Usage**
```r
neg.diff.ACF(signal, max.delay)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `signal`    | A numeric vector representing the input signal. |
| `max.delay`   | The maximum delay (lag) for which the negative derivative is computed. |

#### **Value**
A numeric vector of length `max.delay`, representing the negative derivative values of the autocovariance function at each delay.

#### **Example**
```r
# Following Equation 12 (ref), Psi can be numerically calculated as:
Psi <- neg.diff.ACF(signal, max.delay)
```

---------------------------------------------------------------------------------------
### **epoch.feature**
---
#### **Description**
Divides a signal into overlapping epochs and computes features for each epoch using a user-specified function. This method is highly versatile, supporting both scalar and vector-based feature extraction, making it suitable for various time-series analysis applications.

#### **Usage**
```r
epoch.feature(signal, epoch.length, epoch.overlap, fs, func)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `signal`    | A numeric vector representing the input signal. |
| `epoch.length`   | The duration of each epoch (in seconds). |
| `epoch.overlap`   | The overlap between consecutive epochs (in seconds). |
| `fs`   | The input signal's sampling rate (samples per second). |
| `func`   | A user-defined function applied to each epoch. This function can return either a scalar or a vector. |

Details

1. The signal is divided into overlapping epochs based on epoch.length and epoch.overlap.
2. For each epoch:
* The indices of the epoch are computed, accounting for overlap.
* Out-of-bound indices are handled gracefully using specular.ext to reflect signal boundaries.
* The specified function (func) is applied to the sub-signal corresponding to the epoch.
3. Progress is displayed via a progress bar (txtProgressBar).
4. The output adapts to the dimensionality of the features:
* If func returns a scalar, the output is a vector.
* If func returns a vector (e.g., neg.diff.ACF), the output is a matrix where rows correspond to epochs.

#### **Value**
- A numeric vector if the feature function returns a scalar.
- A numeric matrix if the feature function returns a vector, with each row corresponding to an epoch.

#### **Example**
```r
# Compute the mean for overlapping epochs (a moving average).
# The function `mean` returns a scalar value for each epoch.
# Signal (5kHz) is divided into 4-second epochs with 2-second overlap.
moving.average <- epoch.feature(
  signal = EEG, 
  epoch.length = 4, 
  epoch.overlap = 2, 
  fs = 5000, 
  func = mean
)

# Compute a Psi-matrix for EEG data using `neg.diff.ACF` as the feature function.
# Each epoch spans 4 seconds with 50% overlap (2 seconds).
# As `neg.diff.ACF` requires an additional argument (`max.delay`), 
# wrapping it in an anonymous function is one effective way to pass it to `func`.
# The result `Psi.matrix` is a matrix where each row corresponds to an epoch.
Psi.matrix <- epoch.feature(
  signal = EEG, 
  epoch.length = 4, 
  epoch.overlap = 2, 
  fs = 5000, 
  func = function(epoch) neg.diff.ACF(epoch, max.delay = 1250)
)

```
---------------------------------------------------------------------------------------
### **specular.ext**
---
#### **Description**
Mirrors the boundaries of a signal to handle out-of-bound indices gracefully. This function adjusts indices outside the valid range (1 to `lim.sup`) by reflecting them back into the range, ensuring continuity at the boundaries. When called by the function `epoch.feature`, `lim.sup` corresponds to the length of the signal under analysis.

#### **Usage**
```r
specular.ext(K, lim.sup)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `K`    | A numeric vector of indices to be adjusted. |
| `lim.sup`   | The upper limit of the valid range of indices (typically the signal length). |

#### **Value**
A numeric vector of the same length as `K`, with out-of-bound indices replaced by their mirrored equivalents.

Details
- For indices less than 1, the function mirrors them around 1.
- For indices greater than `lim.sup`, the function mirrors them around `lim.sup`.
- This ensures all returned indices are within the valid range [1,`lim.sup`].

#### **Example**
```r
# If we divide a ramp signal with 100 elements (e.g., 1:100) into 10 epochs, 
# and extend each epoch by 50%, the following indices might arise for the first and last epochs:
# - The first epoch: -4:10
# - The last epoch: 91:105

# Adjust the first epoch's indices using specular.ext
adjusted.first.epoch <- specular.ext(-4:10, lim.sup = 100)
print(adjusted.first.epoch)
# Output: c(6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

# Adjust the last epoch's indices using specular.ext
adjusted.last.epoch <- specular.ext(91:105, lim.sup = 100)
print(adjusted.last.epoch)
# Output: c(91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 99, 98, 97, 96, 95)
```

---------------------------------------------------------------------------------------
### **plot.Psi.matrix**
---
#### **Description**
The `plot.Psi.matrix` function visualizes a Psi-matrix using a dual pseudocolor scale designed to emphasize the significance of zero in the Psi-scale (ref). The function applies two separate color gradients—one for negative values and another for positive values—that meet seamlessly at zero with a shared black color. This ensures clear visual differentiation of positive and negative regions in the matrix.

To accommodate the expected distribution of Psi-values (mostly positive), the positive color gradient spans a broader range and includes more levels of colors, as defined by the grad.ratio parameter (typically at least three times the span of the negative range).

Key features include:

- Customizable Color Gradients: User-specified color scales for negative and positive values, with seamless blending at zero.
- Windowing: Flexible options to plot a subsection of the Psi-matrix using adjustable window width and offsets.
- Dynamic or Manual Scaling: Automatically adjusts color limits based on data quantiles or uses user-defined limits for consistent scaling across plots.
- Axis Configuration: Customizable x and y-axis labels, units, and scaling tailored to Psi-matrix data.

This function is particularly suited for the visualization of EEG Psi-pattern dynamics.


#### **Usage**
```r
plot.Psi.matrix(psi.matrix, win.width = NULL, win.offset = 0,
                col.grad1 = c(rgb(0.5,0,0), rgb(0,0,0)), 
                col.grad2 = c(rgb(0,0,0), rgb(0,0,1), rgb(0.5,0.5,1), rgb(0,1,1)),
                grad.ratio = 3, x.d = 4/3600, xl = "time (hours)", y.d = 1/5, yl = "time (ms)",
                col.limits = NULL, auto.col.lim = 0.98, plot.mar = c(4,4,2,1), num.col = 512)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `psi.matrix`    | A Psi-matrix, where each row corresponds to a Psi-pattern. |
| `win.width`   | The number of rows (epochs) to be visualized in the plot. If set to `NULL` (default), the entire matrix is plotted.|
| `win.offset`   | Time offset (number of epochs) used alongside `win.width` to visualize a specific submatrix of `psi.matrix`.|
| `col.grad1`   | Color gradient representing the negative range of the Psi-scale. Default: [dark-red → black].|
| `col.grad2`   | Color gradient representing the positive range of the Psi-scale. Default: [black → blue → light-blue → cyan]. |
| `num.col`   | Total number of color levels across `col.grad1` and `col.grad2`. Default: `num.col = 512`. |
| `grad.ratio`   | Ratio of positive (`col.grad2`) to negative (`col.grad1`) color levels. Default: `grad.ratio = 3`, empirically adjusted for the Psi-scale distribution. |
| `x.d`   | Scaling factor for the temporal axis. Default: adjusted to 4-second epochs expressed in hours. |
| `xl`   | Label for the temporal axis. Default: `time (hours)`. |
| `y.d`   | Scaling factor for the delay (lag) axis. Default: adjusted to a 5 kHz sampling rate and expressed in milliseconds. |
| `yl`   | Label for the delay axis. Default: `delay (ms)`. |
| `col.limits`   | A two-element vector specifying the range of the Psi-scale to map onto the pseudocolor scale. If `NULL` (default), autoscaling is applied. |
| `auto.col.lim`   | Quantile of psi.matrix used to determine the upper limit of the pseudocolor scale during autoscaling. Values exceeding this limit are clipped. Default: `auto.col.lim = 0.98`. |
| `plot.mar`   |A four-element vector specifying the plot area margins. Default: `[4, 4, 2, 1]` (bottom, left, upper, right). |

Details
- **Customizable Color Scales**. The function allows users to modify the color scales for visualization. Internally, colorRampPalette is used to generate the color gradients, with `col.grad1` and `col.grad2` passed as arguments to this function.
- **Autoscaling Behavior**: When autoscaling is enabled (default), the upper limit of the Psi range is determined using quantile evaluation:
  ```r
  q <- quantile(psi.matrix, auto.col.lim, na.rm = TRUE)
  ```
  The lower limit is calculated as -q/grad.ratio, ensuring the positive and negative ranges are scaled proportionally.
- **Custom Visualization**. For enhanced contrast or specific visualization needs, users can analyze the histogram of `psi.matrix` and manually define the color scale limits. For example:
  ```r
  plot.Psi.matrix(EEG_Psi_matrix, col.limits = c(val1, val2))
  ```

#### **Value**
The primary output of the function is the Psi-matrix visualization as a pseudocolor plot.
In addition, the function invisibly returns `col.limits`, a two-element numeric vector representing the minimum and maximum values of the Psi-scale mapped onto the pseudocolor scale. This can be reused to ensure consistent scaling across multiple plots.

#### **Example**
```r
# Provided EEG_Psi_matrix as a Psi-matrix:

# Example 1: Visualization of the entire Psi-matrix using autoscaling
plot.Psi.matrix(EEG_Psi_matrix)

# Example 2: Visualization of specific time intervals (e.g., first and second hours)
# Visualizing the first hour of the Psi-matrix (4-second epochs = 900 epochs/hour)
plot.Psi.matrix(EEG_Psi_matrix, win.width = 900)

# Visualizing the second hour of the Psi-matrix
plot.Psi.matrix(EEG_Psi_matrix, win.width = 900, win.offset = 900)

# Example 3: Consistent scaling across baseline and experimental datasets
# Visualize the baseline Psi-matrix and capture its pseudocolor mapping range
ref.limits <- plot.Psi.matrix(EEG_Psi_matrix.baseline)

# Use the same pseudocolor scaling to visualize the experimental Psi-matrix
plot.Psi.matrix(EEG_Psi_matrix.exp, col.limits = ref.limits)

# Example 4: Visualization without margins for raster export
# Visualizing only the colored Psi-matrix (e.g., for export to Inkscape or Illustrator)
plot.Psi.matrix(EEG_Psi_matrix, plot.mar = c(0, 0, 0, 0))

```

---------------------------------------------------------------------------------------
### **map.vector**
---
#### **Description**
Resamples a categorized numeric vector (e.g., hypnograms) to a specified length by proportionally mapping its original indices. This ensures the resampled vector retains the original categories and their relative distribution.

#### **Usage**
```r
map.vector(v, new.length)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `v`    | A numeric or categorical vector representing the input data (e.g., hypnogram stages). |
| `new.length`   | The desired length of the resampled vector. |

#### **Value**
A vector of length new.length containing resampled elements from v, preserving the unique categories and their relative order.

#### **Example**
```r
# Example: Resampling a wake-sleep stages vector
# If `score.10s.24h` is a categorized vector of wake-sleep stages for 10-second epochs covering 24 hours,
# you can map it to 4-second epochs (21600 epochs in 24 hours) as follows:
score.4s.24h <- map.vector(score.10s.24h, 21600)
```
