library(tidytext)
library(tidyr)
library(dplyr)
library(stringr)
library(tidyverse)
library(magrittr)
library(MASS)
library(car)

business <- read_csv("business_flattened.csv")
review <- read_csv("filtered_reviews.csv")
review$business_id <- factor(review$business_id)


star_avg <- tapply(review$stars, review$business_id, mean)
star_avg <- data.frame(stars = star_avg, business_id = names(star_avg))

dataset <- merge(business, star_avg, by = "business_id")
write.csv(dataset, "dataset.csv")


## get data ##
## mark NA as one level ##
anova <- read.csv("business_flattened.csv", na.strings = NULL)[, c(2, 10, 16, 24, 31, 20, 30, 23, 25, 51:64)]
summary(anova)


anova$RestaurantsPriceRange2[is.na(anova$RestaurantsPriceRange2)] <- 0
anova$RestaurantsPriceRange2 <- factor(anova$RestaurantsPriceRange2)

## data processing ##
anova$WiFi <- gsub("u'free'", "FREE", anova$WiFi)
anova$WiFi <- gsub("'free'", "FREE", anova$WiFi)
anova$WiFi <- gsub("'no'", "NO", anova$WiFi)
anova$WiFi <- gsub("u'no'", "NO", anova$WiFi)
anova$WiFi <- gsub("u'paid'", "PAID", anova$WiFi)
anova$WiFi <- gsub("uNO", "", anova$WiFi)
anova$WiFi <- gsub("'paid'", "PAID", anova$WiFi)
anova$RestaurantsTakeOut <- gsub("None", "", anova$RestaurantsTakeOut)
anova$RestaurantsDelivery <- gsub("None", "", anova$RestaurantsDelivery)
anova$OutdoorSeating <- gsub("None", "", anova$OutdoorSeating)
anova$HasTV <- gsub("None", "", anova$HasTV)
anova$RestaurantsReservations <- gsub("None", "", anova$RestaurantsReservations)
anova$RestaurantsPriceRange2 <- gsub("0", "", anova$RestaurantsPriceRange2)
anova[which(anova == "", arr.ind = T)] <- "NA"

anova_factor <- cbind(anova[, c(1, 2)], as.data.frame(lapply(anova[, -c(1, 2)], factor)))
colnames(anova_factor)[1] <- "business_id"


model <- lm(stars ~ . - (business_id), data = anova_factor)
summary(model)
## anova model ##
model <- aov(stars ~ . - business_id, data = anova_factor)
summary(model)

