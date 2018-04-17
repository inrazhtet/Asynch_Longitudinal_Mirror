## Overview

The overarching goal of the project is to assess whether infant media exposure is associated with weight/bmi trajectories during their infant to early childhood periods. The study will assist in determining possible cause for intervention. 

## People Involved

Researchers from the NYU School of Medicine, the Bellevue Hospital Center are involved. My direct supervisors are [Professor Marc Scott](https://steinhardt.nyu.edu/faculty/Marc_A._Scott) and [Professor Daphna Harel](https://steinhardt.nyu.edu/faculty/Daphna_Harel).

## Our Goals

In order to examine that association, media exposure data and weight/bmi data need to be synchronized (exactly how the response will be modeled as a function of the predictors is to be determined, but a first step is examining aligned data). 

## Data 

The data is from a larger study carried out under the Bellevue Project for Early Language, Literacy and Education Success. It is a longitudinal analysis of interventions related to child development in low income families. The criteria for entry into the program is as below.

#### Mother 

* English or Spanish speaking
* 18 years and above

#### Child

* Full term gestation, normal birth weight
* No significant medical complications
* Planned follow up in the host institution of the study

*The data is under strict confidentiality agreements and thus, not available for public disclosure. Only results are viewable on markdown files as stated below.*

### Finished Tasks

* Successful implementation of linear interpolation on the asynchronous datasets of BMI and Media Exposure  
* Initial modeling on the Linearly interpolated data for statistically significant relationship
* BMI trajectory exploration of different Media Exposure categories over time for both raw and linearly interpolated data to replicate the work done by the research doctors
* Correlation plots of BMI and Media Exposure on random subject draws to explore underlying functional relationship

### Ongoing Tasks

* Deploying Nagin 

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
  









