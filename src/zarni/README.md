## Overview

**Adapting Yoav Bergner's three famous questions**

* What this is project about? 
* Who are involved? 
* What are we trying to achieve?
* Why does it matter?

**PLACEHOLDER BELOW**

The overarching goal of the project is to assess whether infant media exposure is associated with weight/bmi trajectories during their infant to early childhood periods. In order to examine that association, media exposure data and weight/bmi data need to be synchronized (exactly how the response will be modeled as a function of the predictors is to be determined, but a first step is examining aligned data).  As can be seen below in our short data snippet, media exposure and weight/bmi are collected at **asynchronous** time points. Our goal is to impute these missing data at missing time points via **linear interpolation**. For more on **linear interpolation**, please see the *Appendix* section.

### Data 

* Where is the data from?

### Current Project Status

* What we have finished so far?

### Future Tasks

* Description of the immediate next tasks for the week

### Directory Structure

* Where the files are?
* What does each file do? How are they linked?
* What are the important files?

#### How to best read through the materials

* Ask the reader to open the markdown files for overview
* Can skim RMarkdown code details


### References

* Bellvue's Powerpoint Deck?

#### PLEASE IGNORE TEXT BELOW. Boilerplate to be modified.

1. **01_Linear_Interpolation**: This code file contains start to end process of converting Raw Media Exposure and BMI data to *linearly interpolated data* by linking the two data sets by SubjectID and filling in the missing corresponding time stamps at each data set.

2. **02_InitialModels**: The initial modeling file contains fitting models for the Linear interpolated data set with simple linear regression and a multi-level model.

3. **03_Loess_Smoothing**: <FILL IN LATER once you re-run the file>
  









