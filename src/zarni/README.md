## Overview

The overarching goal of the project is to assess whether infant media exposure is associated with weight/bmi trajectories during their infant to early childhood periods. The study will assist in determining a possible cause for intervention. 

## People Involved

Researchers from the NYU School of Medicine, the Bellevue Hospital Center are involved. My direct supervisors are [Professor Marc Scott](https://steinhardt.nyu.edu/faculty/Marc_A._Scott) and [Professor Daphna Harel](https://steinhardt.nyu.edu/faculty/Daphna_Harel).

## Our Goals

To examine the association between media exposure and bmi, media exposure data and weight/bmi data need to be synchronized (exactly how the response will be modeled as a function of the predictors is to be determined, but a first step is examining aligned data). 

## Data 

The data is from a larger study carried out under the Bellevue Project for Early Language, Literacy and Education Success. It is a longitudinal analysis of interventions related to child development in low-income families. The criteria for entry into the program is as below.

#### Mother 

* English or Spanish speaking
* 18 years and above

#### Child

* Full-term gestation, normal birth weight
* No significant medical complications
* Planned to follow up in the host institution of the study

*The data is under strict confidentiality agreements and thus, not available for public disclosure. Only results are viewable in markdown files as stated below.*

## Finished Tasks

* Successful implementation of linear interpolation on the asynchronous datasets of BMI and Media Exposure  
* Initial modeling on the Linearly interpolated data for determining any statistically significant relationship
* BMI trajectory exploration of different Media Exposure categories over time for both raw and linearly interpolated data to replicate the work done by the research doctors
* Correlation plots of BMI and Media Exposure on random subject draws to explore underlying functional relationships

## Ongoing Tasks

* Deploying Nagin Clustering on raw BIM and Media exposure data to discover underlying different subject groups

## Directory Structure

* **data** *unavailable for public viewing*
* **src** *code files*
  * **daphna** - Professor Daphna Harel's code files
  * **marc** - Professor Marc Scott's code files
  * **zarni** - my code files
      * **01a_Linear_Interpolation.md** : This code file includes a start to end process of converting Raw Media Exposure and BMI data to   *linearly interpolated data* by linking the two data sets by SubjectID and filling in the missing corresponding timestamps at each data set.
      * **01b_Function_Linterpolation.R** : This code file contains helper functions and wrapper written for 01a_Linear_interpolation.Rmd.
      * **02_InitialModels.md** : This code file contains initial linear regression and multi-level models.
      * **03_BMI_Trajectories.md** : This code file contains BMI trajectories over time across different Media Exposure categories for both raw and interpolated data.
      * **04_CorrelationPlots.md** : This code file contains correlation plots between BMI and Media Exposure of randomly drawn subjects.
      * **05_a_Nagin_Clusters_BMI.md** : This code file contains initial nagin clustering of the raw BMI data.
      * **05_a_Nagin_Clusters_Media.md** : This code file contains initial nagin clustering of the raw Media Exposure data.


## How to best review and access the material

The **markdown** files contain both the most important code snippets as well as outputs of those results. For more details, looking the RMarkdown files would be the option. As the data is not accessible to the public, one would not be able to run the file. If there are any points for clarification, please feel free to create a GitHub issue or contact me at zh938@nyu.edu.

## References

* Infant Media Exposure and Longitudinal Weight Status Trajectories in Low Income Young Children by Tomopoulous S, Weisleder A, Cates CB, Scott MA, Dreyer BP, Messito M, Kim A & Mendelsohn AL

  









