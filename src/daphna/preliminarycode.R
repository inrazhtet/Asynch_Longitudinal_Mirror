data = read.csv("final_interp_data.csv")
data = data[,-1]
str(data)

nadata = read.csv("merged_arranged_data.csv")
nadata = nadata[,-1]
str(nadata)

data[9:20,]

library(lme4)
library(lmerTest)

mod = lmer(zBMI~Media + Months + (1|ID), data = data)
summary(mod)