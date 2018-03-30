Linear Interpolation
================
Zarni Htet
March 15, 2018

### Introduction

The goal of this code file is to generate an imputed data set of **BMI** and **Media Exposure** for young children from low income families. The existing raw data set has been linearly interpolated to fill in the missing values for **BMI** and **Media Exposure** at missing time points. A sample of the raw data set along with the existing issue and one proposed method for resolution is demonstrated in the objective section below.

### Admnistration

The project is supervised by Professor Marc Scott and Professor Daphna Harel. The data is from the Belle Lab at the Bellevue Hospital. Additional background on the project is in the *README* at the root directory of the Github repository associated with the project.

#### R Libraries

This block has all the *required* libraries for this code file.

``` r
#For the dta raw files
library(foreign)
#For importing different types of data set without specification
library(rio)
#For processing long form data
library(dplyr)
#GTools library for ordering numeric variables
library(gtools)
#For filling NA values
library(tidyr)
#Loading Rmarkdown library for rendering
library(rmarkdown)
#knitr library for rendering
library(knitr)
#for missing data
library(mi)
#Sourcing the code file
source("../zarni/01b_Function_LInterpolation.R")
```

#### I: Uploading Raw data

In this section, the raw data is processed to a .csv format. The data files will then be saved to a processing data folder to protect the integrity of the raw data.

``` r
#The BMI data extract
bmi <- read.dta("../../data/raw/MASextract1.dta")
#The Media data extract
media <- read.dta("../../data/raw/MASextract2.dta")
#Writing the BMI data to processing file
write.csv(bmi, "../../data/processing/bmi.csv")
#Writing the media data to processing file
write.csv(media, "../../data/processing/media.csv")
```

This code chunk is reloading and doing minor cleaning to the working version of the data to be used throughout the rest of the code file.

**Note to self** Insert a custom function to remove the V1 from the data set.

### Objective

The overarching goal of the project is to assess whether infant media exposure is associated with weight/bmi trajectories during their infant to early childhood periods. In order to examine that association, media exposure data and weight/bmi data must be collected at the **same** time. As can be seen below in our short data snippet, media exposure and weight/bmi are collected at **asynchronous** time points. Our goal is to impute these missing data at missing time points via **linear interpolation**. For more on **linear interpolation**, please see the *Appendix* section.

    ##   ID_    AgeMos     zBMI lnmediatimespent sqrtmediatimespent
    ## 7   1  7.786448       NA         5.463832           15.32971
    ## 8   1 12.813142 1.011972               NA                 NA
    ## 9   1 15.244353       NA         4.948760           11.83216

#### II: Data Exploration

This section examines the two datasets. The focus here is to explore the distribution of BMI and Media Exposure as well as cases of missing data and distribution of time points for each data set.

##### The BMI data set overview

    ##    V1 ID_     AgeMos       zBMI
    ## 1   1   1  0.0000000 -3.5407891
    ## 2   2   1  0.1314168 -3.1878707
    ## 3   3   1  0.5585216 -0.2831618
    ## 4   4   1  1.5441478 -1.2716171
    ## 5   5   1  4.3039017 -1.1837007
    ## 6   6   1  6.3737168 -2.5585830
    ## 7   7   1 12.8131418  1.0119723
    ## 8   8   2  0.0000000  1.2820979
    ## 9   9   2  1.5441478  2.6198270
    ## 10 10   2  2.5297742  1.0224092
    ## 11 11   2  6.7351131  1.0519278
    ## 12 12   2 10.8418894  1.9389179
    ## 13 13   2 11.7289524  0.9665915
    ## 14 14   2 26.4147835  1.7445436
    ## 15 15   2 38.6365509  2.4713204

Each subject has different time points. For subject 1, months may be 0, 0.13 , 0.55 while subject 2 has months in 0, 1.5, 2.5 etc.

###### Missing data exploration

As can be seen from the visuals below, the BMI dataset by itself before joining across subjectID and time with the Media Exposure dataset has no missing values.

``` r
mdf_bmi = missing_data.frame(p_bmi)
```

``` r
image(mdf_bmi)
```

![](01a_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-8-1.png)

###### Distribution of BMI values

The BMI values are more or less normalized as can be seen below.

``` r
plot(density(p_bmi$zBMI), main = "Distrbution of BMI Values")
```

![](01a_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-9-1.png)

###### Distribution of Number of Time Intervals by Subject Count for BMI

The number of time points counted over the number of subject ID within each count of time points can be seen below. The majority of the subjects appear to have between 11 and 23 time points.

![](01a_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-10-1.png)

The count of time points per subject ID is also calculated. As shown below, at least one subject ID has only **1** timepoint and **39** timepoints respectively. This insight is useful in that the built-in linear interpolation cannot impute data with only one timepoint. Therefore, those cases will have to be handled separately.

``` r
bmi_timed <- p_bmi %>% 
  group_by(ID_) %>%
  summarize(n = n()) 
print(max(bmi_timed$n))
```

    ## [1] 39

``` r
print(min(bmi_timed$n))
```

    ## [1] 1

##### Media exposure data set overview

    ##    V1 ID_    AgeMos lnmediatimespent sqrtmediatimespent
    ## 1   2   1  7.786448         5.463832          15.329710
    ## 2   1   1 15.244353         4.948760          11.832160
    ## 3   5   2  6.735113         4.330733           8.660254
    ## 4   3   2 24.147844         4.795791          10.954452
    ## 5   4   2 42.940453         3.433987           5.477226
    ## 6   6   2 60.714581         4.795791          10.954452
    ## 7   7   3  9.494866         5.888878          18.973665
    ## 8   8   4  5.848049         3.433987           5.477226
    ## 9   9   4 31.605749         4.110874           7.745967
    ## 10 14   5  6.965092         4.510859           9.486833
    ## 11 10   5 17.314169         5.198497          13.416408
    ## 12 11   5 24.147844         5.602119          16.431677
    ## 13 13   5 42.381931         5.484797          15.491934
    ## 14 12   5 62.357288         4.510859           9.486833
    ## 15 17   6  6.866530         5.017280          12.247449

Like with the BMI data set before each Media data set subject has different time points. For subject 1, months are 7.786, 15.24 while subject 2 has months such as 6.73, 24.14 etc.

###### Missing data exploration

As can be seen from the visuals below, the Media dataset by itself before joining across subjectID and time with the BMI dataset has no missing values.

``` r
mdf_media = missing_data.frame(p_media)
```

    ## Warning in .local(.Object, ...): lnmediatimespent and sqrtmediatimespent have the same rank ordering.
    ##  Please verify whether they are in fact distinct variables.

``` r
image(mdf_media)
```

![](01a_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-15-1.png)

###### Distribution of the Media Variable

The Media exposure data set has two measures of media time spent for infants. One is log transformed and the other is square root transformed. A plot of both transformations is compared below.

``` r
par(mfrow =c(1,2))
plot(density(p_media$sqrtmediatimespent), main = "Sqrt Media Time Spent")
plot(density(p_media$lnmediatimespent), main = "Log Media Time Spent")
```

![](01a_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-16-1.png)

The square root transformation looks more **normal** than log transformation. Subsequently, it is utilized in the rest of the code file.

###### Distribution of Number of Time Intervals by Subject Count for Media Exposure

``` r
#Using the table function and barplot to draw the distribution of time. 
media_tt = table(table(p_media$ID_))
barplot(media_tt, main = "Number of Time Points Distribution by Subject Count")
```

![](01a_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-17-1.png)

The number of time points counted over the number of subject ID within each count of time points can be seen below. Unlike BMI data set, all the Media data set subjects have time points between **1** and **5** inclusive. It indicates that more time points are missing in Media data set compared to the BMI data set.

#### III: Interpolation Scenarios

This section lays out the different interpolation scenarios as the two data sets are joined to capture missing values in each data set. The goal as stated before is to impute these values using **linear interpolation**.

###### Scenario I:

In this case, there are missing BMI and Media Exposure values at varying time points. The built-in linear interpolation function (as described in the *Appendix*) can be applied to each value column of BMI and Media Exposure. The function will work smoothly for cases like these as there is at least **two** values for the respective missing columns. If there are less than **two** non-missing values in BMI or Media Exposure column, the built-in function will fail. Such cases are handled with a custom function as demonstrated later.

    ##   ID_    AgeMos      zBMI lnmediatimespent sqrtmediatimespent
    ## 6   1  6.373717 -2.558583               NA                 NA
    ## 7   1  7.786448        NA         5.463832           15.32971
    ## 8   1 12.813142  1.011972               NA                 NA
    ## 9   1 15.244353        NA         4.948760           11.83216

###### Scenario II:

In this case, one column value (zBMI) is completely filled across all the time points. The Media Exposure value on the other hand has only **one** value. In that case, we cannot utilize the built-in linear interpolation function. A custom function has been created to execute last value carried forward and backward on these cases. This type of scenario can happen similarly to zBMI where it only has **one** value while the Media Exposure column is filled. Additionally, it could be that one of the columns does not necessarily have to be filled completely. Rather that it has at least **two** values or more. Those cases would fall under this scenario as well.

    ##    ID_    AgeMos       zBMI lnmediatimespent sqrtmediatimespent
    ## 31   3  0.000000 -0.2047709               NA                 NA
    ## 32   3  0.164271 -0.8374662               NA                 NA
    ## 33   3  0.624230  1.2653127               NA                 NA
    ## 34   3  1.577002  1.0108550               NA                 NA
    ## 35   3  2.825462  1.4965336               NA                 NA
    ## 36   3  3.745380  0.9784334               NA                 NA
    ## 37   3  6.275154  0.2728231               NA                 NA
    ## 38   3  9.494866  0.6977530         5.888878           18.97367
    ## 39   3 13.634497  1.8940200               NA                 NA

###### Scenario III:

In this case, the subject ID only exists in one data set and does not exist in the other. The confirmation to that case is that all the Media Exposure values are NAs as shown below. As shown before, the Media data has no missing values by itself. Thus, this is a case of subject ID mismatch. There is no point in constructing a study where the subject altogether does not exist in one data set or the other. These cases will be taken care of through only matching common ids between the two data sets.

    ##     ID_    AgeMos      zBMI lnmediatimespent sqrtmediatimespent
    ## 622  39  0.000000 0.6400806               NA                 NA
    ## 623  39  0.624230 0.2247941               NA                 NA
    ## 624  39  1.314168 0.9656801               NA                 NA
    ## 625  39  1.774127 1.4292920               NA                 NA
    ## 626  39  4.106776 2.3997307               NA                 NA
    ## 627  39 11.203285 2.7849188               NA                 NA

###### Scenario IV:

Scenario IV is where the subject ID from both BMI and Media data sets match. Additionally, they only have 1 time point each and that time point is exactly equal as well. In that case, there is **no** other time point to linearly interpolate. As a result such data rows must be temporarily removed before applying our linear interpolation functions. Fortunately, as can be seen below, there is only one subject ID of one time instance in both data sets that where the subject ID matches. However, the exact time instance does not match. Therefore, this scenario is avoided.

    ##       ID_   AgeMos      zBMI lnmediatimespent sqrtmediatimespent
    ## 10551 626  0.00000 -1.546457               NA                 NA
    ## 10552 626 36.79671        NA         5.888878           18.97367

#### IV: Creating Linearly Interpolated Data Set

In this section, the end goal is to create a linearly interpolated data set while resolving scenario I to scenario III of interpolation from the above section. The section is subdivided into the following themes.

-   Subsetting both data sets via **common** subject IDs betwen the two data sets. This action takes care of scenario III.
-   Creating a combined from the two subsetted data sets above for interpolation.
-   Applying custom last value carried forward and backward function to handle scenario II.
-   Applying the built-in interpolation function to execute imputation for scenario I.

There themes are carried out in a total of **7** steps as demonstrated below.

###### Step 1: Finding the Common ID

Finding the subject IDs that match across both data sets

``` r
common_ID <- intersect(p_bmi$ID_, p_media$ID_) # intersection works like in Set theory
print(length(common_ID)) #537 common subject IDs
```

###### Step 2: Subsetting BMI and Media Data set based on shared ID

``` r
#Matched BMI
m_bmi <- p_bmi[(p_bmi$ID_ %in% common_ID), ]
#Matched Media
m_media <- p_media[(p_media$ID_ %in% common_ID),]
```

###### Step 3: Combining both data sets for create missing time points in each data set

``` r
#Merging both data sets by ID and Months  
c_data <- m_bmi %>% full_join(m_media, by =c("ID_" = "ID_", "AgeMos" = "AgeMos"))
#Extracting needed columns esp sqrtmediatimespent as it is more normal than the log transformation
c_data <- c_data[,c("ID_", "AgeMos","sqrtmediatimespent", "zBMI")]
#Renaming the variables
colnames(c_data) <- c("ID", "Months", "Media", "zBMI")

### Doing minor cleaning

#Converting Months into numeric for sorting later
c_data$Months <- as.numeric(as.character(c_data$Months))
#Converting the square root media value to square media for later linear interpolation
c_data$Media <- c_data$Media^2
#Rearrange the data by GroupID then within groups by Time
c_data_arr <- c_data %>% arrange(ID, Months) 
```

###### Missing Values Creation Confirmation

As shown in the picture below, Media exposure missing values and BMI missing values at various time points are created. As to be expected from the data exploration before, there are more Media exposure missing values than that of BMI.

``` r
image(mdf_combined)
```

![](01a_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-27-1.png)

###### Step 4: Merging Duplicated Rows

This section checks if BMI and Media data has been recorded at the same time for the same subject ID. If those rows exist, the goal is to merge those same rows by the **average** values of both BMI and Media Exposure duplicated columns. A sample of what these duplicated rows looks like is show below.

``` r
#Group by gets the same ID and Month and summarise checks the count
dup_count <- c_data_arr %>% group_by(ID, Months) %>% summarise(n=n())
#Capture the duplicate cases
v_dup <- dup_count[dup_count$n >1,]
#Save an id of a duplicate case
id <- v_dup$ID[1]
#Spit out a duplicate case
print(c_data_arr[c_data_arr$ID == id,][3:6,])
```

    ##      ID   Months Media       zBMI
    ## 1213 70 1.215606    NA -0.2115094
    ## 1214 70 1.215606    NA -0.2115094
    ## 1215 70 1.839836    NA -0.0139306
    ## 1216 70 1.839836    NA -0.0139306

###### Custom Function applied to merge the duplicated rows

``` r
#Combined data that is arranged and merged.
c_data_arr_mer <- c_data_arr %>% group_by(ID,Months) %>% summarise_all(funs(my.rowmerge))
```

``` r
#Saving the arranged and merged data set
write.csv(c_data_arr_mer, "../../data/final/final_na_data.csv")
```

**Step 8: Extracting the Singleton Cases from the Data Set to be handled separately**

To be applied to the Linear Interpolation, Approx function, the single rows of time stamped data with 1 value of either BMI or Media would not do. More details on the requirement of the Approx function are in the Appendix section. Step 8 and Step 9 handles this.

``` r
#Getting all the rows with the Singleton IDs
singleton_data <- c_data_arr_mer [(c_data_arr_mer$ID %in% all_singletons$ID_),]
#Getting all the rows with non Singleton IDs
non_singleton_data <- c_data_arr_mer[!(c_data_arr_mer$ID %in% all_singletons$ID_),]
```

**Step 9: Handling Singleton Data**

This section goes through bullet point **1** to bullet point **3** in the Singleton data scenario. The Singleton data will be combined back once the Singular NAs has been replaced appropriately with LOCF & LOCB which can then supplied into our approxfun as described in details in the Appendix.

``` r
###Case I: Locating rows where there is only 1 time stamp for BMI and Media

#Check if there are cases of row n = 1

singleton_1 <- singleton_data %>% group_by(ID) %>%
                                  summarise(n=n())
nrow(singleton_1[singleton_1$n ==1,]) #0
```

    ## [1] 0

``` r
###Case I issues does not exist.
```

``` r
### Case II: LOCF/LOBF for BMI Singleton Cases

### Below function takes care of LOCF, LOBF for Singleton Cases of 1 unit value
### across multiple time periods

fill_NA <- function(df){
  
  #Saving the data frame in a local variable
  x <- df
  #total length of data frame
  total <- nrow(df)
  #total length of NA values in media
  total_na_media <- sum(is.na(df$Media))
  #total length of NA values in bmi
  total_na_bmi <- sum(is.na(df$zBMI))
  
  #Replacing the Media NA values if there is only 1 singular non-NA
  if (total-total_na_media == 1){
    #Get the replace value which is from non-NA
    replace_value <- df$Media[which(!is.na(df$Media))]
    #Replace it to the rest of the vector
    df$Media[which(is.na(df$Media))] <- replace_value
  }
  #Replacing the zBMI NA values if there is only 1 singular non-NA
  if (total-total_na_bmi == 1){
    #Get the replace value which is from non-NA
    replace_value <- df$zBMI[which(!is.na(df$zBMI))]
    #Replace it to the rest of the vector
    df$zBMI[which(is.na(df$zBMI))] <- replace_value
  }
  return(df)
}

#Split by each groupID
singleton_data_split <- split(singleton_data, singleton_data[,1])
#Apply NA fixes to each of the data splits
singleton_NA_filled <- lapply(singleton_data_split, fill_NA)
#Collapse the Split Data into a single data frame
singleton_NA_filled <- bind_rows(singleton_NA_filled)
write.csv(singleton_NA_filled, "../../data/Intermediate/singleton_NA_filled.csv")
```

**Step 10: Recombine the Singleton and Non-Singleton Data Sets**

``` r
combined_data <- rbind(non_singleton_data, singleton_NA_filled)
View(combined_data)
```

**Step 11: Split the combined data set by the Subject ID**

Here we are spliting the data set by subject ID so that we can apply the interpolation function to each of the Subject ID

``` r
#Split the data by subject ID
combined_data_split <- split(combined_data, combined_data[,1])
```

**Step 12: Build Custom Function to Handle Interpolation**

There are two custom functions in this section that allow us to use the approx function (details of the function are in the Appendix) for interpolation for our data set. A couple of steps are involved to prepare to apply the approx function. - Figuring out the Vectors and its corresponding indexes to interpolate - Defining the minimum and maximum values in existing data set to apply LOCF/LOCB to tail missing NAs - Using a secondary custom function to merge the outputs of Approxfunction from multiple vectors to a single data frame

``` r
#Wrapper! Passes to a function:
#Use ... Need to write it out!
#The function will take in a data frame as well as an input vector that specifies which column indexes of the data frame are of interest for the interpolation. The reason we have the input vector is that it give us a flexible to use single function which can deal with a large data frame where multiple columns may need interpolation.

#df refers to the data frame of interest
#par is a vector that specifies the TWO indexes: 1 being time in this case and the other being the missing column index
mdz_interpolate <- function(df, par){
  #Saving the data frame in a local variable
  x <- df
  #Pulling out the index for X vector (In our case Time)
  x_1 <- par[1]
  #Pulling out the index for Y Vector 1 (In our case BMI)
  y_1 <- par[2]
  #Pulling out the index for Y Vector 2 (In our case Media)
  y_2 <- par[3]
  #Pulling out x and y vectors for the interpolation
  #They are in data frame format.You have to unlist and make it a numeric vector.
  xx <- as.numeric(unlist(x[,x_1])) # X vector
  yy_1 <- as.numeric(unlist(x[,y_1])) # Y vector 1
  yy_2 <- as.numeric(unlist(x[,y_2])) # Y vector 2
  #Specifying indexes where we had to fill with the missing NA for y Vector 1
  xout_1 <- which(is.na(yy_1))
  #specifying indexes where we had to fill with the missing NA for y Vector 2
  xout_2 <- which(is.na(yy_2))
  #Specifying the minimum and maximum values for Last Value Carried Backward/Forward
  #Get the non-missing indexes first
  y_nmis_1 <- which(!is.na(yy_1))
  y_nmis_2 <- which(!is.na(yy_2))
  #Get the value from the furthest left index of Y (LOCB)
  y_min_1 <- yy_1[min(y_nmis_1)]
  y_min_2 <- yy_2[min(y_nmis_2)]
  #Get the value from the furthest right index of Y (LOCF)
  y_max_1 <- yy_1[max(y_nmis_1)]
  y_max_2 <- yy_2[max(y_nmis_2)]
  #Apply this to the interpolation function (Explanations of the function are in Appendix section)
  #The interpolation for the first vector
  out_1 <- approx(xx, yy_1, xout = xout_1,  method = "linear", yleft = y_min_1, yright = y_max_1, rule = 2)
  #The interpolation for the second vector
  out_2 <- approx(xx, yy_2, xout = xout_2, method = "linear", yleft = y_min_2, yright = y_max_2, rule = 2)
  #The missing values replaced data frame 1 of replaced Vector 1
  outframe_1 <- d_replace(x, out_1, 3)
  #The missing values replaced data frame 2 of replaced Vector 2
  outframe_2 <- d_replace(x, out_2, 4)
  outframe_1[,4] <- outframe_2[,4]
  return(outframe_1)
}
```

Helper Function that puts missing values back into the data frame.

``` r
#The function takes in an actual data frame (df), an Robject of the interpolation function which contains the index values that has been replaced under vector x and the values that has been imputed under vector y. Then, we specify the column to which those values are replaced with rcol
d_replace <- function(df, robj, rcol){
  
  #saving the local data frame
  df <- df
  #saving the local robject
  robj <- robj
  #specifying the rows and the columns to replace the R values by
  df[robj$x,rcol] <- robj$y 
  return(df)
}
```

**Step 13: Applies the Custom Interpolation Function to the Split data set**

This section applies the **split** dataframe into the custom linear interpolation function from above. By split data, it means here that we are handling each subjectID spearately using lapply functions.

``` r
#The split data is put in and then, the time column: 2, the BMI column: 3 and the media column 4 are applied the interpolation function
c_data_interp <- lapply(combined_data_split, mdz_interpolate, par=c(2,3,4))
```

**Step 14: Collapse the Split Data Into a Single Data Frame**

``` r
#Use dplyr bind_rows to recompose the split data together
#http://dplyr.tidyverse.org/reference/bind.html
c_data_interp_bind <- bind_rows(c_data_interp)
```

``` r
head(c_data_interp_bind)
```

    ## # A tibble: 6 x 4
    ## # Groups:   ID [1]
    ##      ID Months Media   zBMI
    ##   <int>  <dbl> <dbl>  <dbl>
    ## 1     1  0.     235. -3.54 
    ## 2     1  0.131  235. -3.19 
    ## 3     1  0.559  235. -0.283
    ## 4     1  1.54   235. -1.27 
    ## 5     1  4.30   235. -1.18 
    ## 6     1  6.37   235. -2.56

``` r
#Converting the squared transformation back to to square root transformation 
c_data_interp_bind$Media <- sqrt(c_data_interp_bind$Media)
head(c_data_interp_bind)
```

    ## # A tibble: 6 x 4
    ## # Groups:   ID [1]
    ##      ID Months Media   zBMI
    ##   <int>  <dbl> <dbl>  <dbl>
    ## 1     1  0.     15.3 -3.54 
    ## 2     1  0.131  15.3 -3.19 
    ## 3     1  0.559  15.3 -0.283
    ## 4     1  1.54   15.3 -1.27 
    ## 5     1  4.30   15.3 -1.18 
    ## 6     1  6.37   15.3 -2.56

``` r
write.csv(c_data_interp_bind, "../../data/final/final_interp_data.csv")
```

### APPENDIX:

#### Section I: Theorectical Explanation

##### Base Linear Interpolation Function

The linear interpolation equation to be used in the base function is below. The *y*<sub>0</sub> and *y*<sub>1</sub> would be either BMI or Media exposure variable. The *x*<sub>0</sub> and *x*<sub>1</sub> would be the time variable.

The *y* variable is the missing value we are looking for at time *x*. For BMI variable, the *x* corresponds to time from Media exposure that is missing between the *x*<sub>0</sub> and the *x*<sub>1</sub> intervals. The converse can be said of the Media Exposure variable to BMI as well.

Source: Linear Interpolation, Wikipedia
$$
y = y\_{0} + (x - x\_{0}) \\frac{y\_{1}- y\_{0}}{x\_{1} - x\_{0}}
$$

This section deals with testing out functions and other stuffs

Use ApproxFun: <https://stat.ethz.ch/R-manual/R-devel/library/stats/html/approxfun.html>

#### Section II: Testing the Approx Function

##### START: Testing Out Linear Interpolation approx/approxfun

Both approx and approxfun looks fairly similar. There are a couple of **key parameters** to consider \* x,y =&gt; input vectors \* xout =&gt; we specify which indexes we want to interpolate values for \* yleft =&gt; this is specifying the last value to be carried to the left or backward if x values are less than min(x)

-   yright =&gt; this is specifying the last value to be carried to the right or forward if x values are more than max(x)

-   rule =&gt; Two options. 1 is to get NA for yleft, yright case. 2 is to output yleft, yright cases

###### Test Case 1

This is a simple case of some missing Ys with X values. A manual calculation is done below to verify the answer.

This helper function puts back the output to the actual data frame.

Simulated data 1

``` r
x_1 <- c(1,2,3,4,5,6)
y_1 <- c(3,NA,5,NA,NA,10)
xout_1 <- which(is.na(y_1)) #which returns the indexes where y_1 vector has NA values
```

Specifying y\_left and y\_right

This code chunk will tackle the case of last carried left/backward and last carried right/forward. The goal is to find the furthest left y index that is not NA and save the value. The same goes for the furthest right.

``` r
y_nmis_1 <- which(!is.na(y_1)) #indexes of non-missing y values
y_min_1 <- y_1[min(y_nmis_1)] #get the value from the furtherest left index of y 
y_max_1 <- y_1[max(y_nmis_1)] #get the value from the furthest right index of y
```

Applying the function

This code chunk applies the function

``` r
out_1 <- approx(x_1, y_1, xout = xout_1,  method = "linear", yleft = y_min_1, yright = y_max_1, rule = 2)
```

Interpolated results

``` r
print(out_1$y)
```

    ## [1] 4.000000 6.666667 8.333333

Manual calculation to confirm it.

Notetoself: In the future, helper functions should be in a separate source file. Seek permission from MS/DH.

Base interpolation helper function

``` r
#Note: Come back and write more comments later.

#The function takes in two pairs of point and the point you want to interpolate
lin_interpol <- function(y0,y1,x0,x1,x){
  y <- y0 + (x-x0) * ((y1-y0)/(x1-x0))
  return(y)
}
```

Manually outputting the three NA values from above

``` r
res_1_1 <- lin_interpol(3,5,1,3,2)
print(res_1_1)
```

    ## [1] 4

``` r
res_2_1 <- lin_interpol(5,10,3,6,4)
print(res_2_1)
```

    ## [1] 6.666667

``` r
res_3_1 <- lin_interpol(5,10,3,6,5)
print(res_3_1)
```

    ## [1] 8.333333

All the results matches up. We only have a case of Last Value Carried forward and backward to test

###### Test Case 2

Simulated data 2

We are testing the case of last value carried forward with 1 value missing on the left and 2 values missing on the right

``` r
x_2 <- c(1,2,3,4,5,6)
y_2 <- c(NA,3,5,10,NA,NA)
xout_2 <- which(is.na(y_2)) #which returns the indexes where y_1 vector has NA values
```

Same as above (Comments to merge or fill in later)

``` r
y_nmis_2 <- which(!is.na(y_2)) #indexes of non-missing y values
y_min_2 <- y_2[min(y_nmis_2)] #get the value from the furtherest left index of y 
y_max_2 <- y_2[max(y_nmis_2)] #get the value from the furthest right index of y
```

This code chunk applies the function

``` r
out_2 <- approx(x_2, y_2, xout = xout_2,  method = "linear", yleft = y_min_2, yright = y_max_2, rule = 2)
```

Interpolated results

``` r
print(out_2$y)
```

    ## [1]  3 10 10

Perfect. Left value carried forward and right value carried forward works like a charm.
