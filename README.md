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
| var.delay          | Computes the variance of a signal after subtracting delayed copies of itself. |
| neg.diff.ACF       | Computes the negative derivative of the autocovariance function. |
| epoch.feature      | Divides a signal into epochs and evaluates a feature according to a given function. |
| specular.ext       | Extends a vector by mirroring its ends.                     |
| plot.Psi.matrix    | Displays the Psi matrix using a parameterizable pseudocolor scale. |
| map.vector         | Rescales a vector to a specified length using proportional mapping. |

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
Calculates the variance of a given signal after subtracting progressively delayed copies of itself.

#### **Usage**
```r
var.delay(signal, max.delay)
```

#### **Arguments**
| Argument | Description |  
|----------|-------------|
| `signal`    | A numeric vector representing the input signal. |
| `max.delay`   | Maximum delay to evaluate the variance. |

#### **Value**
A numeric vector with length `max.delay` + 1 (a zero value is added as the fist element, corresponding to the expected zero variance at zero delay).

#### **Example**
```r
# Following eq. 11 (ref), Psi can be numerically calculated as 
Psi <- diff(var.delay(signal, max.delay))/2
```
