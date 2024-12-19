# Psi-patterns of Mouse EEG: Demo Scripts and Functions
**Author**: Javier Diaz  

## Overview
This repository contains scripts and functions for analyzing mouse EEG data using the Psi-analysis framework.  
For details on the methodology, refer to [our paper](https://doi.org/xyz).  

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
3. [Functions list](#functions-list)
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
## Functions list
## Function Descriptions Table

| Function           | Description                                                 |
|--------------------|-------------------------------------------------------------|
| do.alpha.pulse     | Generates an alpha function vector given the tau parameter. |
| do.dual.exp.pulse  | Generates a dual-exponential function vector given tau1 and tau2 parameters. |
| unitE              | Rescales a vector to unit energy (default), or to any other arbitrary value. |
| var.delay          | Computes the variance of a signal after subtracting delayed copies of itself. |
| neg.diff.ACF       | Computes the negative derivative of the autocovariance function. |
| epoch.feature      | Divides a signal into epochs and evaluates a feature according to a given function. |
| specular.ext       | Extends a vector by mirroring its ends.                     |
| plot.Psi.matrix    | Displays the Psi matrix using a parameterizable pseudocolor scale. |
| map.vector         | Rescales a vector to a specified length using proportional mapping. |

---
do.alpha.pulse
---
Description
Usage
Arguments
Value
