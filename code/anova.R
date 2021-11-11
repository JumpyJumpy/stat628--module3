library("tidyverse")
library("car")
library("MASS")

business <- read_csv("business_flattened.csv")
review <- read_csv("filtered_reviews.csv")
review$business_id <- factor(review$business_id)

star_avg <- tapply()
