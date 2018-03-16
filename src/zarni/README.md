## Overview

This README will work through the code and data files this project generates authored primarily by Zarni Htet. For each code file, there will be a short description of how this fits into the larger project. Under each code file section, there will be an explanation of what each chunk within the code file does so the reader/user may easily navigate to the particular code section. 

### Data

We have two raw data set collected by the Bellvue Hospital's Belle Lab. 
**BMI data** - 


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





