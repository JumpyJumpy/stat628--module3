library("tidyverse")
library("car")
library("MASS")

business <- read_csv("business_flattened.csv")
review <- read_csv("filtered_reviews.csv")
review$business_id <- factor(review$business_id)

star_avg <- tapply(review$stars, review$business_id, mean)
star_avg <- data.frame(stars = star_avg, business_id = names(star_avg))

dataset <- merge(business, star_avg, by = "business_id")
write.csv(dataset, "dataset.csv")
