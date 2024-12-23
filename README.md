# Psi-patterns of Mouse EEG: R Functions and Demo Scripts.
**Author**: Javier Diaz  

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
| specular.ext       | Extends a vector by mirroring its ends. |
| plot.Psi.matrix    | Displays the Psi matrix using a custom pseudocolor scale. |
| [map.vector](#mapvector)         | Rescales a vector to a specified length using proportional mapping. |

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
### **map.vector**
---
#### **Description**
Resamples a vector to a specified length by mapping original indices proportionally.

#### **Usage**
```r
map.vector(v, new.length)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `v`    | A numerical vector. |
| `new.length`   | xxxx. |

#### **Value**
A numeric vector of length `new.length`.
#### **Example**
```r
# comments
score.4s.24h <- map.vector(score.10s.24h, 21600)
```
