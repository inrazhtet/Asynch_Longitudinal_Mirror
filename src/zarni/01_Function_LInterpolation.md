01\_Function\_LInterpolation
================
Zarni Htet

### Libraries for making the Function works!

``` r
#For processing long form data
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
#GTools library for ordering numeric variables
library(gtools)
#For filling NA values
library(tidyr)
```

    ## Warning: package 'tidyr' was built under R version 3.3.2

``` r
#Loading Rmarkdown library for rendering
```

Custom Functions
----------------

### Merging Custom Function

This function is used to merge two rows of subject ID that has the time stamps. <br />

A scenario would be <br /> ID Time BMI Media Exposure <br /> A 1:00 3 NA <br />
A 1:00 NA 4 <br />

Applying this function, you would only have 1 Row <br /> ID Time BMI Media Exposure <br /> A 1:00 3 4 <br />

``` r
my.max <- function(x) ifelse(!all(is.na(x)),max(x, na.rm = T), NA)
## *Arguments*:
### X - Takes in Rows of data with the Same SubjectID and Time Stamp

## *Function Design*
### ifelse                - picks between two outcomes: output of TRUE condition or NA
### !all()                - if NOT everything
### is.na(x)              - connected with above. if NOT everything is.na (i.e, 2 or more rows of data have values   other than NA)
### max(x, na.rm = TRUE)  - pick the maximum value (i.e the value that is NOT NA after removing all the NAs)

## *Expected Output*
### The function will go through each Same SubjectID and Time Stamp pairing and output a Single merged row! 
```

### LOCF/LOCB Function

This function is used to fill in Media and BMI values for subjects that only have 1 value of Media and/or BMI at one time point.

``` r
fill_NA <- function(df){
  
## *Arguments*
### df - Takes in a data frame of each SubjectID with their corresponding vector of BMI and Media Exposure Values

## *Function Design*
### 1. We determine how many non-NAs are there in each vector of Media and BMI.
### 2. If there is only 1 non-NA, it fits our case. 
### 3. Therefore, we replace the non-NA value to all other indexes where there are NAs.

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
```

Wrappers
--------

### mdz\_interpolate

The purpose of this function is to wrap around the built-in approx function. <br /> Tests of the built-in approx function are in the Appendix Section of the corresponding code file **01\_Linear\_Interpolation.Rmd**

``` r
mdz_interpolate <- function(df, par){
  
  ## *Arguments*
  ### df - Takes in a data frame for each subject ID with their corresponding vector of BMI and Media Exposure values
  ### par - Takes in a vector of parameters that is required by the Approx Function that we are wrapping around.
  ###       These are the Column Indexes of the Time Stamp variable, the BMI variable and the Media exposure variable that we want to work on in the data frame
  
  ##  *Function Design*
  ### 1) Pull out the parameters and input in local variables
  ### 2) Pull out the vectors from the parameters index to be interpolated
  ### 3) Idenitfy the missing indexes to be interpolated in each of the vectors
  ### 4) Identify the smallest and largest values in each index for LOCF/LOCB
  ### 5) Input the Vectors, the Indexes Vectors for replacement and the smallest and largest values to the ApproxFunction for Interpolation
  ### 6) ApproxFun is applied twice there are two vectors, BMI and Media Exposure we are trying to replace
  ### 7) ApproxFun returns a list of points where Linear Interpolation has worked on
  ### 8) A helper function d_replace updates the existing data frame with the interpolated vector output from ApproxFun
  ### 9) d_replace is applied twice for each respective vector and the two data frames are merged as a final step and return!
  
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

Helper Function
---------------

### Data Frame Update Function

The purpose of this function is to take in the output of the approx linear interpolation function and compose it back to dataframe.

``` r
d_replace <- function(df, robj, rcol){
  
  ## *Arguments*
  ### df - Takes in a data frame for each subject ID with their corresponding vector of BMI and Media Exposure values
  ### robject - The return RObject from Approx Linear Interpolation function It has two components: a row index and values. The row index corresponds to missing value indexes that has been linearly interpolated.
  ### rcol - The index of the column to be replaced with the values of the robject vector
  ## *Function Design*
  ### 1. Save the passed arguments in local variables
  ### 2. replace row and column of data frame with the interpolcated y values
  
  #saving the local data frame
  df <- df
  #saving the local robject
  robj <- robj
  #specifying the rows and the columns to replace the R values by
  df[robj$x,rcol] <- robj$y 
  return(df)
}
```