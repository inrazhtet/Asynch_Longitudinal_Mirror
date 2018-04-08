02\_InitialModels
================
Zarni Htet
March 7, 2018

### Introduction

The goal of this code file is to explore whether infant media exposure is associated with weight/bmi trajectories during their infant to early childhood periods. We explore a simple linear regression model and a multi level regression model in the code file.

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
    ## -5.7036 -0.7318 -0.0229  0.7468  4.4148 
    ## 
    ## Coefficients:
    ##              Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.0238824  0.0235880   1.012 0.311335    
    ## Media       0.0004199  0.0001129   3.720 0.000201 ***
    ## Months      0.0181910  0.0006329  28.741  < 2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.127 on 8880 degrees of freedom
    ##   (1287 observations deleted due to missingness)
    ## Multiple R-squared:  0.08553,    Adjusted R-squared:  0.08532 
    ## F-statistic: 415.3 on 2 and 8880 DF,  p-value: < 2.2e-16

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
    ## REML criterion at convergence: 23152.2
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -7.1154 -0.5394  0.0327  0.5868  4.5009 
    ## 
    ## Random effects:
    ##  Groups   Name        Variance Std.Dev.
    ##  ID       (Intercept) 0.5621   0.7497  
    ##  Residual             0.6758   0.8221  
    ## Number of obs: 8883, groups:  ID, 537
    ## 
    ## Fixed effects:
    ##              Estimate Std. Error        df t value Pr(>|t|)    
    ## (Intercept) 2.975e-02  4.281e-02 1.033e+03   0.695   0.4872    
    ## Media       3.890e-04  1.730e-04 4.732e+03   2.248   0.0246 *  
    ## Months      1.766e-02  4.973e-04 8.574e+03  35.514   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##        (Intr) Media 
    ## Media  -0.580       
    ## Months -0.242  0.079

#### Model Interpretation

Controlling for differences between subjects, the effect of one unit change in Media is 0.0161 to BMI and it is not statistically significant assuming our model assumptions are correct. With the likelihood ratio test below, the random effects are warranted.

#### Likelihood ratio test

``` r
print(rand(M1))
```

    ## Analysis of Random effects Table:
    ##    Chi.sq Chi.DF p.value    
    ## ID   4216      1  <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
