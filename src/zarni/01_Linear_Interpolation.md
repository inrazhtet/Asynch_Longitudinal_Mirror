01\_Linear\_Interpolation
================
Zarni Htet (<zh938@nyu.edu>)
March 15, 2018

### Imputation using Linear Interpolation

This Markdown is filling the missing data for **BMI** and **Media Exposure** data sets at asynchronous time points using linear interpolation. By missing data, we mean to link **subjects** across the **BMI** and **Media Exposure** data sets. For some **subjects** we may find that data has been collected for both BMI and Media Exposure all about at the same time points. On the other hand, some subjects may have BMI time points 1,2,3 but Media time points 3,5,6. We hope to have for the subject all the time points for both data sets at 1,2,3,5,6.

### Admnistration

The project is supervised by Professor Marc Scott and Professor Daphna Harel. The data is from the Belle Lab at the Bellevue Hospital. More details of the project scope is in the README of the primary repository folder.

#### R Libraries

This code block has all the needed R libraries to run this segment of the Markdown.

``` r
#For the dta raw files
library(foreign)
```

    ## Warning: package 'foreign' was built under R version 3.3.2

``` r
#For importing different types of data set without specification
library(rio)
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
library(rmarkdown)
```

    ## Warning: package 'rmarkdown' was built under R version 3.3.2

``` r
#knitr library for rendering
library(knitr)
```

#### I: Uploading Raw data

In this code chunk, we are uploading raw .dta data and converting to it a csv. This will then be saved to a processing data folder to protect the integrity of the raw data.

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

##### Loading the Data back from Processing Folder

This code chunk is loading the working version of the data extra to be used throughout the document.

``` r
#processing bmi data
p_bmi <- import("../../data/processing/bmi.csv")
p_media <- import("../../data/processing/media.csv")
```

#### II: Data Exploration

This code chunks examine the two data sets. In particular, the focus here is on the key variables and the time intervals they are recorded. At the end of each code block for each data set, there is a short summary of what the data consists of.

##### The BMI data set overview

``` r
head(p_bmi)
```

    ##   V1 ID_    AgeMos       zBMI
    ## 1  1   1 0.0000000 -3.5407891
    ## 2  2   1 0.1314168 -3.1878707
    ## 3  3   1 0.5585216 -0.2831618
    ## 4  4   1 1.5441478 -1.2716171
    ## 5  5   1 4.3039017 -1.1837007
    ## 6  6   1 6.3737168 -2.5585830

``` r
tail(p_bmi)
```

    ##          V1   ID_    AgeMos       zBMI
    ## 10321 10321 91008 0.9199179  1.4600797
    ## 10322 10322 91008 1.2813141  1.8749880
    ## 10323 10323 91118 0.0000000 -0.9925033
    ## 10324 10324 91118 0.5913758  1.3112072
    ## 10325 10325 91118 1.5112936  1.9073267
    ## 10326 10326 91118 3.9096510  2.6738663

``` r
dim(p_bmi) #10326, 4
```

    ## [1] 10326     4

``` r
#check the number of unique subjects
length(unique(p_bmi$ID_)) #667 
```

    ## [1] 667

``` r
length(unique(p_bmi$AgeMos)) #1951
```

    ## [1] 1951

``` r
print(sum(is.na(p_bmi$ID_))) #0 no values are missing here
```

    ## [1] 0

``` r
print(sum(is.na(p_bmi$AgeMos))) #0 no values are missing here
```

    ## [1] 0

Each subject has different time points. For subject 1, months may be 0, 0.5, 1.0 while subject 2 has months in 0, 0.7, 1.2 etc.

This is to explore the number of time intervals each subject has.

``` r
#This uses dplyr to group by each subject and count their instances. This effectively counts the number of time points each of them have.
bmi_timed <- p_bmi %>% 
  group_by(ID_) %>%
  summarize(n = n()) 
print(bmi_timed)
```

    ## # A tibble: 667 × 2
    ##      ID_     n
    ##    <int> <int>
    ## 1      1     7
    ## 2      2    18
    ## 3      3     9
    ## 4      4     9
    ## 5      5    11
    ## 6      6     5
    ## 7      7    24
    ## 8      8    14
    ## 9      9    10
    ## 10    10    16
    ## # ... with 657 more rows

``` r
#alternatively, this tells you a lot:
tt <- table(table(p_bmi$ID_))
print(tt)
```

    ## 
    ##  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 
    ##  3  9 31 22 13 16 23 16 28 19 27 29 29 31 28 34 28 34 45 27 31 27 28 22 11 
    ## 26 27 28 29 30 31 32 33 34 35 38 39 
    ## 16  8  3  7  6  4  3  2  3  1  2  1

``` r
#or this:
barplot(tt)
```

![](01_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-5-1.png)

We will do a quick barplot to see the distribution of time points for each subject has

``` r
#Using the table function and barplot to draw the distribution of time. 
barplot(table(bmi$ID_), main = "Time Count Distribution \n for Each Subject for BMI")
```

![](01_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-6-1.png)

Check the Minimum/Maximum number of time intervals. If you have only 1 time interval, we may have to apply **LOCF** and/or **LOCB** to interpolate across other time intervals. By other time

``` r
min(bmi_timed$n) #1
```

    ## [1] 1

``` r
max(bmi_timed$n) #39
```

    ## [1] 39

At least 1 subject has only 1 time interval for BMI. These **singletons** will be applied **LOCF** or **LOCB**.

##### Media exposure data set overview

``` r
head(p_media)
```

    ##   V1 ID_    AgeMos lnmediatimespent sqrtmediatimespent
    ## 1  1   1 15.244353         4.948760          11.832160
    ## 2  2   1  7.786448         5.463832          15.329710
    ## 3  3   2 24.147844         4.795791          10.954452
    ## 4  4   2 42.940453         3.433987           5.477226
    ## 5  5   2  6.735113         4.330733           8.660254
    ## 6  6   2 60.714581         4.795791          10.954452

``` r
tail(p_media)
```

    ##        V1   ID_   AgeMos lnmediatimespent sqrtmediatimespent
    ## 1634 1634 90372 16.09856         5.602119          16.431677
    ## 1635 1635 90406 50.43121         5.198497          13.416408
    ## 1636 1636 90425 23.65503         3.433987           5.477226
    ## 1637 1637 90448 36.66530         4.510859           9.486833
    ## 1638 1638 90448 27.92608         4.110874           7.745967
    ## 1639 1639 90448 59.79466         5.198497          13.416408

``` r
dim(p_media) #1639, 5
```

    ## [1] 1639    5

``` r
#check the number of unique subjects
length(unique(p_media$ID_)) #542 
```

    ## [1] 542

``` r
length(unique(p_media$AgeMos)) #745
```

    ## [1] 745

``` r
print(sum(is.na(p_media$ID_))) #0
```

    ## [1] 0

``` r
print(sum(is.na(p_media$AgeMos))) #0
```

    ## [1] 0

This is to explore the number of time intervals each subject has.

``` r
#This uses dplyr to group by each subject and count their instances. This effectively counts the number of time points each of them have.
media_timed <- p_media %>% 
  group_by(ID_) %>%
  summarize(n = n()) 
print(media_timed)
```

    ## # A tibble: 542 × 2
    ##      ID_     n
    ##    <int> <int>
    ## 1      1     2
    ## 2      2     4
    ## 3      3     1
    ## 4      4     2
    ## 5      5     5
    ## 6      6     3
    ## 7      7     3
    ## 8      8     4
    ## 9      9     2
    ## 10    10     3
    ## # ... with 532 more rows

Like the BMI from before, each subject has different count of time as well as time intervals where the data is collected.

``` r
#Using the table function and barplot to draw the distribution of time. 
barplot(table(bmi$ID_), main = "Time Count Distribution \n for Each Subject for Media Exposure")
```

![](01_Linear_Interpolation_files/figure-markdown_github/unnamed-chunk-10-1.png)

#### III: Data Cleaning

In this section, I will attempt to discover the subjects that only have 1 data point for the BMI data set or the Media exposure data set. The data points with only 1 time stamp cannot immediately be applied to a Linear Interpolation Function which requires 2 time points at the very least. See *Appendix* below for more details of how the function works.

##### Handling the Singletons

The singletons will be handled in 4 different ways.

-   If there is only one timestamp for the ID for BOTH BMI and Media (that is they were both only collected once and at the same time point), then leave it as it is.

*For coding purposes in Linear Interpolation, this data set has to be taken out while the others are being interpolated and then, merged later*

**Results** None of these cases exist. <br />

-   If one variable was collected once, and the other was collected serveral times, the LOCF/LOCB to fill in the blanks

**Solution** A function has been created to handle this below.

-   If both variables were collected once, but at differnent time points, then merge those two values (equivalent to LOCF/LOCB)

**Solution** A function has been created to handle this below.

-   If one variable is collected, and the other is never collected - we have to drop them from the dataset I think.

**Solution** An Inner Join of the data set removes those that need to be dropped.

###### Handling Bullet Point 1 Scenario

The objective of this section is to temporarily remove the data set portion of bullet point 1 above where there is only 1 time each data set and the data set time stamps match.

``` r
#1) Get the Singleton IDs of both Data Sets

#An assumption has been that for each row, there is no missing corresponding time value or bmi value. This assumption holds because of the missingness checks above.

### GET the BMI data set singletons
bmi_exclude <- bmi_timed[bmi_timed$n==1,]
### GET the MEDIA data set singletons
media_exclude <- media_timed[media_timed$n==1,]
### Gather all the Singleton Values in 1 Data Set
all_singletons <- unique(rbind(bmi_exclude, media_exclude))

### Check which Singleton Values between BMI and Media data set matches
print(bmi_exclude$ID_ %in% media_exclude$ID_)
```

    ## [1] FALSE FALSE  TRUE

``` r
### As the third item in the list matches we need to see if the time matches too. If so, we need to remove it.
m_id <- bmi_exclude$ID_[3] #Getting the matched Singleton Subject_ID
### Pulling out a data frame for the subject ID for each data set and Inner-joining
#### Note: bmi_timed data frame only contains IDs of Singletons. We have to use p_bmi to pull the whole data set
bmi_singleton <- p_bmi[p_bmi$ID_ == m_id,]
print(bmi_singleton)
```

    ##        V1 ID_ AgeMos      zBMI
    ## 9334 9334 626      0 -1.546457

``` r
media_singleton <- p_media[p_media$ID_ == m_id,]
print(media_singleton)
```

    ##        V1 ID_   AgeMos lnmediatimespent sqrtmediatimespent
    ## 1536 1536 626 36.79671         5.888878           18.97367

``` r
### Without even innerjoining, a quick scan of the printed data along the AgeMos variable indicate that these two have different time stamps. Therefore, we do not need to remove them from the data set as mentioned in bullet point 1 above.  
```

#### IV: Creating Linearly Interpolated Data

There are **14** steps in this section. At the end, we come out with an entirely interpolated data set. An Appendix section goes through the concept of Linear Interpolation as well as testing the Approx function that has been used extensively in this section. Other tests of the custom functions that are written has been removed. Should it need to be in the Appendix, we can easily provide.

**Step 1: Finding the Common ID**

Finding the subject IDs that match

``` r
common_ID <- intersect(p_bmi$ID_, p_media$ID_) # intersection works like in Set theory
print(length(common_ID)) #537 common subject IDs
```

    ## [1] 537

**Step 2: Extracting BMI and Media Data set based on shared ID**

``` r
#Matched BMI
m_bmi <- p_bmi[(p_bmi$ID_ %in% common_ID), ]
#Matched Media
m_media <- p_media [(p_media$ID_ %in% common_ID),]
```

**Step 3: Generating NAs for each of the data set**

We are generating NA columns for each of the data set so that when we joined later, they can fill in for the missing timepoints.

*This references Professor Harel's code under her src folder*

``` r
#BMI data table first!
#First removing column V1 if it exists
if("V1" %in% colnames(m_bmi)){
  m_bmi <- m_bmi[,2:ncol(m_bmi)]
}
#Adding NAs in the BMI table by expanding the column
m_bmi <- cbind(m_bmi[,c(1,2)], NA, m_bmi[,3])
colnames(m_bmi) <- c("ID_", "AgeMos", "NA", "zBMI")

#MEDIA data table second!
if("V1" %in% colnames(m_media)){
 m_media <- m_media[,2:ncol(m_media)] 
}
#Adding NAs in the MEDIA table by expanding the column
m_media <- cbind(m_media, NA)
#Also need to drop squrt time spent as it can be generated by the linear Time
m_media <- m_media[,-4]
```

**Step 4: Merging the two data sets together**

``` r
#The Column Names have to match for the data set to match together
colnames(m_bmi) <- c("ID", "Months", "Media", "zBMI")
colnames(m_media) <- c("ID", "Months", "Media", "zBMI")
#Combined Data Set
c_data <- rbind(m_bmi, m_media)
#Ordering the data set by subject ID
c_data <- c_data[order(c_data[,1]),]
#Convert all the time variables into numeric for later sorting
c_data$Months <- as.numeric(as.character(c_data$Months))
```

**Step 5: Arrange the data set of each SubjectID by Time**

``` r
#dplyr command that does the arrange by the Group ID then within the groups
#arrange it by Months
c_data_arr<- c_data %>% arrange(ID,Months)
```

**Step 6: Checking \# of duplicated values for each time value within each subject**

This section checks if BMI and Media data has been recorded at the same time. The goal is to merge the two rows so that we will not be interpolating either BMI or Media data for the time stamps where original data already exists.

``` r
dup_count <- c_data_arr %>% group_by(ID, Months) %>% summarise(n=n())
#View a subset of all the duplicate rows
v_dup <- dup_count[dup_count$n >1,]
#print(head(v_dup))
print(dim(v_dup))
```

    ## [1] 365   3

**Step 7: Merging duplicated row into 1 row**

For merging rows, we are essentially saying between two values in both rows, do not pick NA, pick the value. Below is a custom-built function that achieves that. Said function will be applied to the dplyr summarize\_each (which is essentially, apply this function to each row of each column).

Custom Function

``` r
#The ifelse commands literally says, if not all of the x vector is NA, pick the maximum after removing the NA. Otherwise, keep the NA.
my.max <- function(x) ifelse(!all(is.na(x)),max(x, na.rm = T), NA)
```

``` r
#If BMI and Media are recorded at the same time month, there should not be two separate rows for it.
#Combined data that is arranged and merged.
c_data_arr_mer <- c_data_arr %>% group_by(ID,Months) %>% summarise_each(funs(my.max))
#This is merged and cleaned data with the NAs
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