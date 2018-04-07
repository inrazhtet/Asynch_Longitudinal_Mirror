##############################################################################
## Zarni Htet                                                               ##
## 15 March 2018                                                            ##
##                                                                          ##
## A file to store the functions for linear interpolation                   ##
##############################################################################

#For processing long form data
library(dplyr)
#GTools library for ordering numeric variables
library(gtools)
#For filling NA values
library(tidyr)

#######################################
## Merging Data Rows Custom Function ##
#######################################

# This function is used to merge two rows of subject ID that has the same time stamps. 
#   
#   A scenario would be 
#   ID Time  BMI   Media Exposure  
#   A   1:00  3       NA             
#   A   1:00  NA      4            
#   
#   Applying this function, you would only have 1 Row 
#   ID Time  BMI   Media Exposure 
#   A  1:00  3     4              

## *Arguments*:
### x - Takes in Rows of data with the Same SubjectID and Time Stamp

## *Function Design*
### ifelse                - picks between two outcomes: output of TRUE condition or NA
### !all()                - if NOT everything
### is.na(x)              - connected with above. if NOT everything is.na (i.e, 2 or more rows of data have values   other than NA)
### max(x, na.rm = TRUE)  - pick the maximum value (i.e the value that is NOT NA after removing all the NAs)

## *Expected Output*
### The function will go through each Same SubjectID and Time Stamp pairing and output a Single merged row! 


my.rowmerge <- function(x) ifelse(!all(is.na(x)),mean(x, na.rm = T), NA)


#############################################################################
## Last Value Carried Forward/ Last Value Carried Backward Custom Function ##
#############################################################################

fill_NA <- function(vector){
  
  ## *Brief Description*
  ### Apply LOCF to fill NAs   
  
  ## *Arguments*
  ### vector - takes in a vector that needs to be filled 
  
  ## *Function Design*
  ### 1. We determine how many non-NAs are there in each vector
  ### 2. If there is only 1 non-NA, it fits our case. 
  ### 3. Therefore, we replace the non-NA value to all other indexes where there are NAs.
  
  
  #Saving the data frame in a local variable
  x <- vector
  #total length of vector
  total <- length(df)
  #total length of NA values in media
  total_na_vector <- sum(is.na(x))
  
  #Replacing the Media NA values if there is only 1 singular non-NA
  if (total-total_na_vector == 1){
    #Get the replace value which is from non-NA
    replace_value <- x[which(!is.na(x))]
    #Replace it to the rest of the vector
    x[which(is.na(x))] <- replace_value
  }
  return(x)
}


####################################################################
## Wrapper around approx() Linear Interpolation built-in function ##
####################################################################

mdz_interpolate <- function(df,coordinatecolunn, missingcolumn, method, rule){
  
  ## *Brief description* 
  ### The purpose of this wrapper is prepare the data column to 
  ### be interpolated using the built-in approx() function
  ### The required parameters of the built-in functions are
  ### 1) Specific indexes of the missing values
  ### 2) The min value for LOCB
  ### 3) The max value for LOCB
  ### 4) The method for linear interpolation
  ### 5) The rule for tail missing values outside min and max values
  
  ## *Arguments*
  ### df - the data frame with the missing data to be interpolated. The expected data frame is sorted via the coordinate column.
  ### coordinate column - a fixed vector of non-missing values. USE DOUBLE QUOTES TO PASS THE COLUMN.
  ### missing column - a vector with missing values alongside the coordinate column. USE DOUBLE QUOTES TO PASS THE COLUMN.
  ### method - to specify which method to interpolate by : constant or linear. USE DOUBLE QUOTES TO PASS THE VALUE.
  ### rule - 1: fill the values beyond the min() and max() with NAs, 2: apply last value carried backward/forward
  
  ## *Function Design*
  ### 1. We pull out the non missing column and missing column from the data frame
  ### 2. We identify the indexes of missing value
  ### 3. As the vector is already sorted, we determine which ones are the minimum and maximum to apply LOCB/LOCF
  ### 4. We apply the proccessed parameters to the built-in approx function
  ### 5. We use a helper function to transform the return robject of approx function back to a dataframe
  
  
  #Pulling out the columns from the data frame 
  x <- as.numeric(unlist(df[,coordinatecolumn]))
  y <- as.numeric(unlist(df[,missingcolumn]))
  #Specifying indexes where the missing values have to be filled
  x_out <- which(is.na(y))
  #Specifying the minimum and maximum values for last value carried backward/forward
  ##Getting the min index first
  y_min_index <- which(!is.na(y))
  ##Getting the min value
  y_min_value <- y[y_min_index]
  ##Getting the max index first
  y_max_index <- which(!is.na(y))
  ##Getting the max value
  y_max_value <- y[y_max_index]
  #Putting together into the interpolation function
  fillobj <- approx(x, y, xout = xout,  method = metgid, yleft = y_min_value, yright = y_max_value, rule = rule)
  #Using the helper function to put this into a data frame
  df <- df_return(df, fillobj, missingcolumn)
  return(df)
}


###########################################
## Helper Function for the Wrapper Above ##
###########################################

df_return <-function(df, robject, missingcolumn){
  
  ##*Brief Description*
  ### The built-in approx function only returns an robject 
  ### with the indexes of where the missing values are interpolated
  ### This function uses the output to put the missing values back to its original data frame
  
  ##*Arguments*
  ### df - the data frame with the missing data to be interpolated. The expected data frame is sorted via the coordinate column.
  ### robject - the robject returned from the approx function which contains the index values for missing rows and the 
  ### the interpolated mixing values
  ### missingcolumn - the column that has missing values. USE DOUBLE QUOTES TO PASS THE COLUMN.
  
  
  df[robject$x, missingcolumn] <- robject$y
  return(df)
}



