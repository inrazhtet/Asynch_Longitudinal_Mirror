02\_InitialModels
================
Zarni Htet
March 7, 2018

### Introduction

The goal of this code file is to explore whether infant media exposure is associated with weight/bmi trajectories during their infant to early childhood periods. We explore a simple linear regression model and a multilevel regression model in the code file.

### Datasets Involved

The linearly interpolated final data set generated from *01a\_Linear\_Interpolation* is used here.

### Admnistration

Professor Marc Scott and Professor Daphna Harel are the supervisors of this project. The data is from the Belle Lab at the Bellevue Hospital. Additional background on the project is in the *README* at the root directory of the Github repository associated with the project.

#### R Libraries

This block has all the *required* libraries for this code file.

``` r
library(lme4) # For lmer function
library(lmerTest)
library(rio) # For importing data frames
```

#### Importing the data frames to be used

``` r
bmi_media <- import("../../data/final/final_interp_data.csv")
```

### Functional Form

#### Simple Linear Regression

We are regressing BMI on Media and Time.

*Y*(*B**M**I*)∼*X*(*M**e**d**i**a*)+*t*(*M**o**n**t**h**s*)+*ϵ*

``` r
fit <- lm(zBMI ~ Media + Months, data = bmi_media)
print(summary(fit))
```

    ## 
    ## Call:
    ## lm(formula = zBMI ~ Media + Months, data = bmi_media)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -5.6007 -0.7349 -0.0215  0.7390  4.4395 
    ## 
    ## Coefficients:
    ##              Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.0416871  0.0224304   1.859   0.0631 .  
    ## Media       0.0004144  0.0001059   3.912 9.22e-05 ***
    ## Months      0.0163335  0.0005890  27.731  < 2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.126 on 10167 degrees of freedom
    ## Multiple R-squared:  0.07078,    Adjusted R-squared:  0.0706 
    ## F-statistic: 387.2 on 2 and 10167 DF,  p-value: < 2.2e-16

#### Simple Linear Regression Interpretation

On average, a unit increase in media is associated with a 0.02868 increase in BMI.

#### Multi Level Regression

##### Varying Intercept Model with individual predictor

*B**M**I*<sub>*t**i*</sub> = *b*<sub>0</sub> + *b*<sub>1</sub>*M**e**d**i**a*<sub>*t**i*</sub> + *b*<sub>2</sub>*M**o**n**t**h**s*<sub>*t**i*</sub> + *ζ*<sub>*i*</sub> + *ϵ*<sub>*t**i*</sub>

``` r
#lmer code
M1 = lmer(zBMI~Media + Months + (1|ID), data = bmi_media)
print(summary(M1))
```

    ## Linear mixed model fit by REML t-tests use Satterthwaite approximations
    ##   to degrees of freedom [lmerMod]
    ## Formula: zBMI ~ Media + Months + (1 | ID)
    ##    Data: bmi_media
    ## 
    ## REML criterion at convergence: 25912.1
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -7.1848 -0.5325  0.0346  0.5870  4.6660 
    ## 
    ## Random effects:
    ##  Groups   Name        Variance Std.Dev.
    ##  ID       (Intercept) 0.5950   0.7714  
    ##  Residual             0.6422   0.8014  
    ## Number of obs: 10170, groups:  ID, 537
    ## 
    ## Fixed effects:
    ##              Estimate Std. Error        df t value Pr(>|t|)    
    ## (Intercept) 8.080e-02  4.073e-02 9.440e+02   1.984   0.0476 *  
    ## Media       1.434e-04  1.401e-04 8.363e+03   1.024   0.3061    
    ## Months      1.530e-02  4.445e-04 9.790e+03  34.410   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##        (Intr) Media 
    ## Media  -0.493       
    ## Months -0.241  0.075

#### Model Interpretation

Controlling for differences between subjects, the effect of one unit change in Media is 0.0161 to BMI and it is not statistically significant assuming our model assumptions are correct. With the likelihood ratio test below, the random effects are warranted.

#### Likelihood ratio test

``` r
print(rand(M1))
```

    ## Analysis of Random effects Table:
    ##    Chi.sq Chi.DF p.value    
    ## ID   5389      1  <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
