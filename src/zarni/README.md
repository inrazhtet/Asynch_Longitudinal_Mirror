## Overview

This README will work through the code and data files this project generates authored primarily by *Zarni Htet, zh938@nyu.edu*. For each code file, there will be a short description of how this fits into the larger project. Under each code file section, there will be an explanation of what each chunk within the code file does so the reader/user may easily navigate to the particular code section. 

### Data

We have two raw data set collected by the Bellvue Hospital's Belle Lab. <br />
**BMI data** - <br />
**Media Exposure data** - <br />


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

### 01_Linear_Interpolation

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
The **data output** saved is the **clean** data with **NAs** to the final data folder.

8. **Extracting the Singleton Cases from the data set to be handled separately** <br />

To be applied to the Linear Interpolation, Approx function, the single rows of time stamped data with 1 value of either BMI or Media would not do. More details on the requirement of the Approx function are in the Appendix section. Step 8 and Step 9 handles this.

9. **Handling Singleton Data**  *[1 Data Output & 1 Custom Function]* <br />

This section goes through bullet point **1** to bullet point **3** in the Singleton data scenario.
The Singleton data will be combined back once the Singular NAs has been replaced appropriately with LOCF & LOCB which can then supplied into our approxfun as described in details in the Appendix. <br />
The custom function here takes care of LOCF and LOBF cases for subjectIDs with only one filled in Media or BMI value at that time stamp. <br />
The data output saved is the LOCF and LOBF applied data set to an intermediate data folder.

10. **Recombine the Singleton and Non-Singleton Data Sets** <br />

11. **Split the combined data set by the SubjectID** <br />

We split the data set by subjectID so that we can apply the interpolation function to each of the Subject ID

12. **Build Custom Function to Handle Interpolation** *[2 Custom Functions]* <br />

There are two custom functions in this section that allow us to use the approx function (details of the function are in the Appendix) for interpolation for our data set.
A couple of steps are involved to prepare to apply the approx function.
- Figuring out the Vectors and its corresponding indexes to interpolate
- Defining the minimum and maximum values in existing data set to apply LOCF/LOCB to tail missing NAs
- Using a secondary custom function to merge the outputs of Approxfunction from multiple vectors to a single data frame

13. **Applies the Custom Interpolation Function to the Split data set** <br />

This section applies the **split** dataframe into the custom linear interpolation function from above. By split data, it means here that we are handling each subjectID spearately using lapply functions.

14. **Collapse the Split Data Into a Single Data Frame** *[1 Data Output]* <br />

The split data is recomposed into a Single Data Frame. A final cleaned and filled data set is outputted for further use.

**Appendix** <br />
The Appendix has **two** primary sections. The first section went over a conceptual overview of **Lineaer Interpolation**. The second section deals with the *approx linear interpolation function* using two simulated data sets.















