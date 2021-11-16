library(tidytext)
library(tidyr)
library(dplyr)
library(stringr)

## get data ##
## let NA as one level ##
anova=read.csv("business_flattened.csv", na.strings = NULL)[,c(10,16,24,31,20,30,23,25,51:64)]


anova$RestaurantsPriceRange2[is.na(anova$RestaurantsPriceRange2)]=0
anova$RestaurantsPriceRange2=as.factor(anova$RestaurantsPriceRange2)

## data processing ##
anova$WiFi=gsub("u'free'","FREE",anova$WiFi)
anova$WiFi=gsub("'free'","FREE",anova$WiFi)
anova$WiFi=gsub("'no'","NO",anova$WiFi)
anova$WiFi=gsub("u'no'","NO",anova$WiFi)
anova$WiFi=gsub("u'paid'","PAID",anova$WiFi)
anova$WiFi=gsub("'paid'","PAID",anova$WiFi)
anova$RestaurantsTakeOut=gsub("None","",anova$RestaurantsTakeOut)
anova$RestaurantsDelivery=gsub("None","",anova$RestaurantsDelivery)
anova$OutdoorSeating=gsub("None","",anova$OutdoorSeating)
anova$HasTV=gsub("None","",anova$HasTV)
anova$RestaurantsReservations=gsub("None","",anova$RestaurantsReservations)
anova$RestaurantsPriceRange2=gsub("0","",anova$RestaurantsPriceRange2)

## anova model ##
model=aov(stars~.,data=anova)
summary(model)
