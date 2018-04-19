set.seed(1)

#install.packages("AsynchLong")
library(AsynchLong)
library(dplyr)

options(scipen = 999)

setwd("~/Documents/GitHub/Asynch_Longitudinal/data/Intermediate")

bmi = read.csv("bmi_clean_1.csv", header = T)
bmi = bmi[,-c(1,2)]
names(bmi) = c("ID", "Age", "zBMI")

media = read.csv("media_clean_1.csv", header = T)
media = media[,c(3,4,6)]
names(media) = c("ID", "Age", "SqMedia")

fullIDs = intersect(media$ID, bmi$ID)

bmi = subset(bmi, bmi$ID %in% fullIDs)
media = subset(media, media$ID %in% fullIDs)

media$newSqMedia = sqrt(media$SqMedia^2/60)
media$newMedia = media$newSqMedia^2
media$Med2 = media$newMedia^2



x2 = asynchTI(media[,c(1,2,4)], bmi, ncores = 3)
## x data, y data, sq media in hrs, opt bw selected

x3 = asynchTI(media[,c(1,2,4)], bmi, ncores = 3, bw = length(unique(media$ID))^(-0.5))
## x data, y data, sq media in hrs

x4 = asynchTI(media[,c(1,2,4,5)], bmi, ncores = 3, bw = length(unique(media$ID))^(-0.5))
## x data, y data, sqmedia in hrs, media in hrs

x5 = asynchTI(media[,c(1,2,5)], bmi, ncores = 3, bw = length(unique(media$ID))^(-0.5))
## x data, y data, media in hrs

x5 = asynchTI(media[,c(1,2,5,6)], bmi, ncores = 3, bw = length(unique(media$ID))^(-0.5))
## x data, y data, media in hrs, med in hrs sqrd

## stochasticity is in optimal bandwidth selection
## long time to get results is due to bandwidth selection


x3 = asynchTD(media[,c(1,2,5)], bmi, times = c(6, 12, 18, 24), ncores = 3)
## Error