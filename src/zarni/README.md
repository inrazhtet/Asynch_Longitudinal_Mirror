## Overview

* What this is project about? 
* Who are involved? 
* What are we trying to achieve?

I can synthesize the couple of slides of the Bellvue Tomopoulos_Suzy power point deck.

### Data 

* Where is the data from?

We have two raw data set collected by the Bellvue Hospital's Belle Lab. <br />
**BMI data** - <br />
**Media Exposure data** - <br />

### Current Work Status

* What we have finished so far?

### Future Works

* Description of the immediate next tasks for the week

### Directory Structure

* Where the files are?
* What does each file do? How are they linked?

### References

* Bellvue's Powerpoint Deck?


###### Below text to be edited.
1. **01_Linear_Interpolation**: This code file contains start to end process of converting Raw Media Exposure and BMI data to *linearly interpolated data* by linking the two data sets by SubjectID and filling in the missing corresponding time stamps at each data set.

2. **02_InitialModels**: The initial modeling file contains fitting models for the Linear interpolated data set with simple linear regression and a multi-level model.

3. **03_Loess_Smoothing**: <FILL IN LATER once you re-run the file>
  


### Overview (Draft)

The overarching goal of the project is to assess whether infant media exposure is associated with weight/bmi trajectories during their infant to early childhood periods. In order to examine that association, media exposure data and weight/bmi data need to be synchronized (exactly how the response will be modeled as a function of the predictors is to be determined, but a first step is examining aligned data).  As can be seen below in our short data snippet, media exposure and weight/bmi are collected at **asynchronous** time points. Our goal is to impute these missing data at missing time points via **linear interpolation**. For more on **linear interpolation**, please see the *Appendix* section.











