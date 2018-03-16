## Overview

This README will work through the code and data files this project generates authored primarily by Zarni Htet. For each code file, there will be a short description of how this fits into the larger project. Under each code file section, there will be an explanation of what each chunk within the code file does so the reader/user may easily navigate to the particular code section. 

### Data

We have two raw data set collected by the Bellvue Hospital's Belle Lab. <br />
**BMI data** - 
**Media Exposure data** -


### Data Files Overview

- `data/raw` contains the raw data file.
- `data/processing` contains the data files in working stage.
- `data/intermediate` contains the data files that are used for intermediate analysis such as missing data exploration, unmatched/matched variables dataframes etc.
- `data/final` contains the final output data sets to be used in other analysis code files.

### Code Files Overview
1. **01_Linear_Interpolation**: This code file contains start to end process of converting Raw Media Exposure and BMI data to *linearly interpolated data* by linking the two data sets by SubjectID and filling in the missing corresponding time stamps at each data set.

2. **02_InitialModels**: The initial modeling file contains fitting models for the Linear interpolated data set with simple linear regression and a multi-level model.

3. **03_Loess_Smoothing**: <FILL IN LATER once you re-run the file>
  
### Code File Details

#### 01_Linear_Interpolation

**I. Uploading Raw Data** <br />

This segment uploads raw .dta files and convert to .csv for processing.

**II. Data Exploration** <br />

This segment checks if there are any recorded missing values, distribution of count of time intervals across subject IDs on both data sets etc.

**III. Data Cleaning** <br />

Informed by the data exploration, this segment attempts to handle cases in BMI and Media Exposure data where there is only one time stamp. The reason is that the Linear Interpolation function can only take in data sets with at least 2 time points.

**IV. Creating Linearly Interpolated Data** <br />

This section outlines 13 steps that are needed to create a complete **Linearly Interpolated Data set**. The bullet points 2 to 4 mentioned in the Data Cleaning section are handled here.

1. **Finding the Subject IDs that match** <br />

2. **Extracting matched BMI and Media data from shared ID** <br />

3. **Generating NAs for each of the data set** <br /> 
We are generating NA columns for each of the data set so that when we joined later, they can fill in for the missing timepoints for
Media value for **BMI** data set and BMI value for **Media** data set.

4. **Merging the two data sets** <br />
This section merges the two data sets and orders it by SubjectID so we can start to see gaps in BMI and Media data across multiple timepoints

5. **Arrange the data set of each SubjectID by time** <br />
On top of the ordering by subjectID, we further ordered the data set by time within **each** subjectID

6. **Checking # of duplicated values for each time value within each subject** <br />
This section checks if BMI and Media data has been recorded at the same time. The goal is to merge the two rows so that we will not be interpolating either BMI or Media data for the time stamps where original data already exists. 

7. **Merging duplicated row into 1 row** *[1 Data Output & 1 Custom Function]* <br />
This section has a custom function applied to a dplyr summarize_each function to merge the duplicated time stamps data of BMI and Media.
It also saved the **clean** data with **NAs** to the final data folder.

8. **Extracting the Singleton Cases from the data set to be handled separately** <br />
To be applied to the Linear Interpolation, Approx function, the single rows of time stamped data with 1 value of either BMI or Media would not do. More details on the requirement of the Approx function are in the Appendix section. Step 8 and Step 9 handles this.

9. **Handling Singleton Data**  *[1 Data Output & 1 Custom Function]* <br />
This section goes through bullet point **1** to bullet point **3** in the Singleton data scenario.
The Singleton data will be combined back once the Singular NAs has been replaced appropriately with LOCF & LOCB which can then supplied into our approxfun as described in details in the Appendix.
The **custom function** here takes care of LOCF and LOBF cases for subjectIDs with only one filled in Media or BMI value at that time stamp.










