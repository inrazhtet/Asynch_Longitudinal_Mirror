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

my.rowmerge <- function(x) ifelse(!all(is.na(x)),mean(x, na.rm = T), NA)

## *Arguments*:
### x - Takes in Rows of data with the Same SubjectID and Time Stamp

## *Function Design*
### ifelse                - picks between two outcomes: output of TRUE condition or NA
### !all()                - if NOT everything
### is.na(x)              - connected with above. if NOT everything is.na (i.e, 2 or more rows of data have values   other than NA)
### max(x, na.rm = TRUE)  - pick the maximum value (i.e the value that is NOT NA after removing all the NAs)

## *Expected Output*
### The function will go through each Same SubjectID and Time Stamp pairing and output a Single merged row! 


#############################################################################
## Last Value Carried Forward/ Last Value Carried Backward Custom Function ##
#############################################################################

fill_NA <- function(df){
  
  ## *Brief Description*
  ### Apply LOCF to fill NAs   
  
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



