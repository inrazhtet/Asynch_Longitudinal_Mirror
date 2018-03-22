02\_InitialModels
================
Zarni Htet
March 7, 2018

### Libraries for the lm and lmer packages

``` r
library(lme4) # For lmer function
```

    ## Loading required package: Matrix

``` r
library(lmerTest)
```

    ## 
    ## Attaching package: 'lmerTest'

    ## The following object is masked from 'package:lme4':
    ## 
    ##     lmer

    ## The following object is masked from 'package:stats':
    ## 
    ##     step

``` r
library(rio) # For importing data frames
```

    ## 
    ## Attaching package: 'rio'

    ## The following object is masked from 'package:lme4':
    ## 
    ##     factorize

### Importing the data frames to be used

``` r
bmi_media <- import("../../data/final/final_interp_data.csv")
bmi_media <- bmi_media[,-1]
```

### Functional Form

#### Simple Linear Regression

We are regressing BMI on Media and Time.

\[
Y(BMI) \sim X (Media)+ t (Months) + \epsilon   
\]

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
    ## -5.6058 -0.7347 -0.0228  0.7402  4.4883 
    ## 
    ## Coefficients:
    ##               Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) -0.0292796  0.0472411  -0.620  0.53541    
    ## Media        0.0286978  0.0097438   2.945  0.00323 ** 
    ## Months       0.0162542  0.0005885  27.620  < 2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.126 on 10167 degrees of freedom
    ## Multiple R-squared:  0.07018,    Adjusted R-squared:   0.07 
    ## F-statistic: 383.7 on 2 and 10167 DF,  p-value: < 2.2e-16

#### Simple Linear Regression Interpretation

On average, a unit increase in media is associated with a 0.02868
increase in BMI.

#### Multi Level Regression

##### Varying Intercept Model with individual predictor

\[
BMI_{ti} = b_{0} + b_{1}Media_{ti} + b_{2}Months_{ti} + \zeta_{i} + \epsilon_{ti}
\]

*Note to self: Need to write the distribution of Zeta and its error
distribution*

Lmer Code

``` r
M1 = lmer(zBMI~Media + Months + (1|ID), data = bmi_media)
print(summary(M1))
```

    ## Linear mixed model fit by REML t-tests use Satterthwaite approximations
    ##   to degrees of freedom [lmerMod]
    ## Formula: zBMI ~ Media + Months + (1 | ID)
    ##    Data: bmi_media
    ## 
    ## REML criterion at convergence: 25902.5
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -7.1896 -0.5338  0.0343  0.5864  4.6810 
    ## 
    ## Random effects:
    ##  Groups   Name        Variance Std.Dev.
    ##  ID       (Intercept) 0.5955   0.7717  
    ##  Residual             0.6421   0.8013  
    ## Number of obs: 10170, groups:  ID, 537
    ## 
    ## Fixed effects:
    ##              Estimate Std. Error        df t value Pr(>|t|)    
    ## (Intercept) 2.825e-02  6.637e-02 3.532e+03   0.426    0.670    
    ## Media       1.610e-02  1.236e-02 9.178e+03   1.303    0.193    
    ## Months      1.528e-02  4.435e-04 9.782e+03  34.457   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##        (Intr) Media 
    ## Media  -0.845       
    ## Months -0.155  0.035

#### Model Interpretation

Controlling for differences between subjects, the effect of one unit
change in Media is 0.0161 to BMI and it is not statistically significant
assuming our model assumptions are correct. With the likelihood ratio
test below, the random effects are warranted.

#### Likelihood ratio test

``` r
rand(M1)
```

    ## Analysis of Random effects Table:
    ##    Chi.sq Chi.DF p.value    
    ## ID   5396      1  <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
