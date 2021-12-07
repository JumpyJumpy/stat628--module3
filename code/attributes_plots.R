## By T Luo ##
library(tidytext)
library(tidyr)
library(dplyr)
library(stringr)
library(tidyverse)
library(magrittr)
library(MASS)
library(car)

getwd()
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


# model_lm <- lm(stars ~ . - (business_id), data = anova_factor)
## anova model ##
model <- aov(stars ~ . - business_id, data = anova_factor)
summary(model)


library(xtable)
print(xtable(anova(model)))


# Plotting_unify the star ratings
anova$stars[which(anova$stars == 1.5)] <- floor(anova$stars[which(anova$stars == 1.5)])
anova$stars[which(anova$stars == 2.5)] <- floor(anova$stars[which(anova$stars == 2.5)])
anova$stars[which(anova$stars == 3.5)] <- floor(anova$stars[which(anova$stars == 3.5)])
anova$stars[which(anova$stars == 4.5)] <- floor(anova$stars[which(anova$stars == 4.5)])

library(ggplot2)
library(wesanderson)

## Restaurant Delivery

#Plot Restaurant Delivery proportion by stars#
result <- anova %>% count(RestaurantsDelivery, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- result[c(11:15), 3] / sum

stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 0.6), xlab = "Stars", ylab = "Proportion", main = "Restaurants Delivery", legend.text = c("FALSE", "TRUE"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))

# Plot Average Rating by Restaurant Delivery
RD_false_index <- which(anova$RestaurantsDelivery == "False")
RD_true_index <- which(anova$RestaurantsDelivery == "True")
avg_rating_RD <- c(mean(anova$stars[RD_false_index]), mean(anova$stars[RD_true_index]))
rd <- c("False", "True")
avg_rating_RD_dat <- as.data.frame(cbind(avg_rating_RD, rd))
avg_rating_RD_dat$avg_rating_RD <- as.numeric(as.character(avg_rating_RD_dat$avg_rating_RD))
colnames(avg_rating_RD_dat)[1] <- "AverageRating"; colnames(avg_rating_RD_dat)[2] <- "RestaurantsDelivery"
as.numeric(avg_rating_RD_dat$AverageRating)
plot_avg_rating_RD <- ggplot(avg_rating_RD_dat, aes(x = RestaurantsDelivery, y = AverageRating, fill = RestaurantsDelivery)) + geom_bar(stat = "identity")
plot_avg_rating_RD +
        theme(text = element_text(size = 18), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants Delivery") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# # variance equal test#
# p = 0.007478 
leveneTest(anova$stars ~ anova$RestaurantsDelivery)

# two-sample t-test
# p-value = 0.00646
# not equal
t.test(anova$stars[RD_false_index], anova$stars[RD_true_index], paired = FALSE, var.equal = FALSE)

## Restaurant reservation

#Plot Restaurant reservation proportion by stars#

result <- anova %>% count(RestaurantsReservations, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum

true <- c(0, 28 / 162, 198 / 948, 308 / 1731, 14 / 147)

stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 1), xlab = "Stars", ylab = "Proportion", main = "Restaurants Reservation", legend.text = c("FALSE", "TRUE"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))

# Plot Average Rating by Restaurant reservation
RR_false_index <- which(anova$RestaurantsReservations == "False")
RR_true_index <- which(anova$RestaurantsReservations == "True")
avg_rating_RR <- c(mean(anova$stars[RR_false_index]), mean(anova$stars[RR_true_index]))
RR <- c("False", "True")
avg_rating_RR_dat <- as.data.frame(cbind(avg_rating_RR, RR))
avg_rating_RR_dat$avg_rating_RR <- as.numeric(as.character(avg_rating_RR_dat$avg_rating_RR))
colnames(avg_rating_RR_dat)[1] <- "AverageRating"; colnames(avg_rating_RR_dat)[2] <- "RestaurantsReservations"
as.numeric(avg_rating_RR_dat$AverageRating)
plot_avg_rating_RR <- ggplot(avg_rating_RR_dat, aes(x = RestaurantsReservations, y = AverageRating, fill = RestaurantsReservations)) + geom_bar(stat = "identity")
plot_avg_rating_RR +
        theme(text = element_text(size = 18), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants Reservation") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# variance equal test#
# p = 0.8733
leveneTest(anova$stars ~ anova$RestaurantsReservations)

# two-sample t-test
# p-value = 0.3921

t.test(anova$stars[RR_false_index], anova$stars[RR_true_index], paired = FALSE, var.equal = TRUE)


## Parking Garage


result <- anova %>% count(garage, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- result[c(11:15), 3] / sum
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 1), xlab = "Stars", ylab = "Proportion", main = "Garage", legend.text = c("FALSE", "TRUE"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by Garage Parking
GP_false_index <- which(anova$garage == "False")
GP_true_index <- which(anova$garage == "True")

avg_rating_GP <- c(mean(anova$stars[GP_false_index]), mean(anova$stars[GP_true_index]))
GP <- c("False", "True")
avg_rating_GP_dat <- as.data.frame(cbind(avg_rating_GP, GP))
avg_rating_GP_dat$avg_rating_GP <- as.numeric(as.character(avg_rating_GP_dat$avg_rating_GP))
colnames(avg_rating_GP_dat)[1] <- "AverageRating"; colnames(avg_rating_GP_dat)[2] <- "BusinessParking"
plot_avg_rating_GP <- ggplot(avg_rating_GP_dat, aes(x = BusinessParking, y = AverageRating, fill = BusinessParking)) + geom_bar(stat = "identity")
plot_avg_rating_GP +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Business Parking") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p = 2.199e-06
leveneTest(anova$stars ~ anova$garage)


# p-value = 0.1597
t.test(anova$stars[GP_false_index], anova$stars[GP_true_index], paired = FALSE, var.equal = FALSE)


## Outdoor Seating


result <- anova %>% count(OutdoorSeating, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- result[c(11:15), 3] / sum
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 0.8), xlab = "Stars", ylab = "Proportion", main = "Outdoor Seating", legend.text = c("FALSE", "TRUE"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by Outdoor Seating
OS_false_index <- which(anova$OutdoorSeating == "False")
OS_true_index <- which(anova$OutdoorSeating == "True")
avg_rating_OS <- c(mean(anova$stars[OS_false_index]), mean(anova$stars[OS_true_index]))
OS <- c("False", "True")
avg_rating_OS_dat <- as.data.frame(cbind(avg_rating_OS, OS))
avg_rating_OS_dat$avg_rating_OS <- as.numeric(as.character(avg_rating_OS_dat$avg_rating_OS))
colnames(avg_rating_OS_dat)[1] <- "AverageRating"; colnames(avg_rating_OS_dat)[2] <- "OutdoorSeating"
plot_avg_rating_OS <- ggplot(avg_rating_OS_dat, aes(x = OutdoorSeating, y = AverageRating, fill = OutdoorSeating)) + geom_bar(stat = "identity")
plot_avg_rating_OS +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Outdoor Seating") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p 1.803e-06
leveneTest(anova$stars ~ anova$OutdoorSeating)
# p-value = 1.342e-07
t.test(anova$stars[OS_false_index], anova$stars[OS_true_index],
       paired = FALSE, var.equal = FALSE)


### Has TV

result <- anova %>% count(HasTV, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- result[c(11:15), 3] / sum
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 0.6), xlab = "Stars", ylab = "Proportion", main = "HasTV", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))

# Plot Average Rating by HasTV
TV_false_index <- which(anova$HasTV == "False")
TV_true_index <- which(anova$HasTV == "True")
avg_rating_TV <- c(mean(anova$stars[TV_false_index]), mean(anova$stars[TV_true_index]))
TV <- c("False", "True")
avg_rating_TV_dat <- as.data.frame(cbind(avg_rating_TV, TV))
avg_rating_TV_dat$avg_rating_TV <- as.numeric(as.character(avg_rating_TV_dat$avg_rating_TV))
colnames(avg_rating_TV_dat)[1] <- "AverageRating"; colnames(avg_rating_TV_dat)[2] <- "HasTV"
plot_avg_rating_TV <- ggplot(avg_rating_TV_dat, aes(x = HasTV, y = AverageRating, fill = HasTV)) + geom_bar(stat = "identity")
plot_avg_rating_TV +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("HasTV") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p = 1.486e-11
leveneTest(anova$stars ~ anova$HasTV)
# p-value = 5.314e-16
t.test(anova$stars[TV_false_index], anova$stars[TV_true_index],
       paired = FALSE, var.equal = FALSE)


## PriceRange

result <- anova %>% count(anova$RestaurantsPriceRange2, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
first <- result[c(1:5), 3] / sum
second <- result[c(6:10), 3] / sum
third <- result[c(11:15), 3] / sum
fourth <- c(0, 4 / 162, 4 / 948, 2 / 1731, 0)
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, first, second, third, fourth)
matrix <- t(datause[, c(2:5)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 4, name = "Darjeeling1"), ylim = c(0, 0.6), xlab = "Stars", ylab = "Proportion", main = "Price Range", legend.text = c("$", "$$", "$$$", "$$$$"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average rating by Price Range
PR_1_index <- which(anova$RestaurantsPriceRange2 == 1)
PR_2_index <- which(anova$RestaurantsPriceRange2 == 2)
PR_3_index <- which(anova$RestaurantsPriceRange2 == 3)
PR_4_index <- which(anova$RestaurantsPriceRange2 == 4)
avg_rating_PR <- c(mean(anova$stars[PR_1_index]), mean(anova$stars[PR_2_index]), mean(anova$stars[PR_3_index]), mean(anova$stars[PR_4_index]))
PR <- c("1", "2", "3", "4")
avg_rating_PR_dat <- as.data.frame(cbind(avg_rating_PR, PR))
avg_rating_PR_dat$avg_rating_PR <- as.numeric(as.character(avg_rating_PR_dat$avg_rating_PR))
colnames(avg_rating_PR_dat)[1] <- "AverageRating"; colnames(avg_rating_PR_dat)[2] <- "PriceRange"
plot_avg_rating_PR <- ggplot(avg_rating_PR_dat, aes(x = PriceRange, y = AverageRating, fill = PriceRange)) + geom_bar(stat = "identity")
plot_avg_rating_PR +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Price Range") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 5, name = "Darjeeling1"))


# Tukey HSD #
price_range_new <- anova[which(anova$RestaurantsPriceRange2 != "NA"),]
fit_PR <- aov(price_range_new$stars ~ price_range_new$RestaurantsPriceRange2)
summary(fit_PR)
# only 4-3 is not significant #
TukeyHSD(fit_PR)

## Street

result <- anova %>% count(anova$street, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- result[c(11:15), 3] / sum
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 0.8), xlab = "Stars", ylab = "Proportion", main = "Street", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by street
street_false_index <- which(anova$street == "False")
street_true_index <- which(anova$street == "True")
avg_rating_street <- c(mean(anova$stars[street_false_index]), mean(anova$stars[street_true_index]))
street <- c("False", "True")
avg_rating_street_dat <- as.data.frame(cbind(avg_rating_street, street))
avg_rating_street_dat$avg_rating_street <- as.numeric(as.character(avg_rating_street_dat$avg_rating_street))
colnames(avg_rating_street_dat)[1] <- "AverageRating"; colnames(avg_rating_street_dat)[2] <- "street"
plot_avg_rating_street <- ggplot(avg_rating_street_dat, aes(x = street, y = AverageRating, fill = street)) + geom_bar(stat = "identity")
plot_avg_rating_street +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Street") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p < 2.2e-16
leveneTest(anova$stars ~ anova$street)
# p-value < 2.2e-16
t.test(anova$stars[street_false_index], anova$stars[street_true_index],
       paired = FALSE, var.equal = FALSE)


## Lots


result <- anova %>% count(lot, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- result[c(11:15), 3] / sum
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 0.8), xlab = "Stars", ylab = "Proportion", main = "Lot", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by Lots
lot_false_index <- which(anova$lot == "False")
lot_true_index <- which(anova$lot == "True")
avg_rating_lot <- c(mean(anova$stars[lot_false_index]), mean(anova$stars[lot_true_index]))
lot <- c("False", "True")
avg_rating_lot_dat <- as.data.frame(cbind(avg_rating_lot, lot))
avg_rating_lot_dat$avg_rating_lot <- as.numeric(as.character(avg_rating_lot_dat$avg_rating_lot))
colnames(avg_rating_lot_dat)[1] <- "AverageRating"; colnames(avg_rating_lot_dat)[2] <- "GoodForlot"
plot_avg_rating_lot <- ggplot(avg_rating_lot_dat, aes(x = GoodForlot, y = AverageRating, fill = GoodForlot)) + geom_bar(stat = "identity")
plot_avg_rating_lot +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants Good For lot") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p = 2.349e-09
leveneTest(anova$stars ~ anova$lot)
# p-value = 0.06255
t.test(anova$stars[lot_false_index], anova$stars[lot_true_index],
       paired = FALSE, var.equal = FALSE)


# valet

result <- anova %>% count(valet, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- c(0, 3 / 162, 16 / 948, 23 / 1731, 2 / 147)
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 1.1), xlab = "Stars", ylab = "Proportion", main = "Valet", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by Valet
valet_false_index <- which(anova$valet == "False")
valet_true_index <- which(anova$valet == "True")
avg_rating_valet <- c(mean(anova$stars[valet_false_index]), mean(anova$stars[valet_true_index]))
valet <- c("False", "True")
avg_rating_valet_dat <- as.data.frame(cbind(avg_rating_valet, valet))
avg_rating_valet_dat$avg_rating_valet <- as.numeric(as.character(avg_rating_valet_dat$avg_rating_valet))
colnames(avg_rating_valet_dat)[1] <- "AverageRating"; colnames(avg_rating_valet_dat)[2] <- "GoodForvalet"
plot_avg_rating_valet <- ggplot(avg_rating_valet_dat, aes(x = GoodForvalet, y = AverageRating, fill = GoodForvalet)) + geom_bar(stat = "identity")
plot_avg_rating_valet +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants Good For valet") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p = 3.006e-09
leveneTest(anova$stars ~ anova$valet)
# p-value = 0.4359
t.test(anova$stars[valet_false_index], anova$stars[valet_true_index],
       paired = FALSE, var.equal = FALSE)


# intimate

result <- anova %>% count(intimate, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- c(0, 3 / 162, 16 / 948, 23 / 1731, 2 / 147)
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 1), xlab = "Stars", ylab = "Proportion", main = "Intimate", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by Intimates
intimate_false_index <- which(anova$intimate == "False")
intimate_true_index <- which(anova$intimate == "True")
avg_rating_intimate <- c(mean(anova$stars[intimate_false_index]), mean(anova$stars[intimate_true_index]))
intimate <- c("False", "True")
avg_rating_intimate_dat <- as.data.frame(cbind(avg_rating_intimate, intimate))
avg_rating_intimate_dat$avg_rating_intimate <- as.numeric(as.character(avg_rating_intimate_dat$avg_rating_intimate))
colnames(avg_rating_intimate_dat)[1] <- "AverageRating"; colnames(avg_rating_intimate_dat)[2] <- "GoodForintimate"
plot_avg_rating_intimate <- ggplot(avg_rating_intimate_dat, aes(x = GoodForintimate, y = AverageRating, fill = GoodForintimate)) + geom_bar(stat = "identity")
plot_avg_rating_intimate +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants Good For intimate") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p = 0.00537
leveneTest(anova$stars ~ anova$intimate)
# p-value = 0.03744
t.test(anova$stars[intimate_false_index], anova$stars[intimate_true_index],
       paired = FALSE, var.equal = FALSE)


# touristy

result <- anova %>% count(touristy, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- c(0, 1 / 162, 9 / 948, 4 / 1731, 0)
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 0.8), xlab = "Stars", ylab = "Proportion", main = "touristy", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by touristys
touristy_false_index <- which(anova$touristy == "False")
touristy_true_index <- which(anova$touristy == "True")
avg_rating_touristy <- c(mean(anova$stars[touristy_false_index]), mean(anova$stars[touristy_true_index]))
touristy <- c("False", "True")
avg_rating_touristy_dat <- as.data.frame(cbind(avg_rating_touristy, touristy))
avg_rating_touristy_dat$avg_rating_touristy <- as.numeric(as.character(avg_rating_touristy_dat$avg_rating_touristy))
colnames(avg_rating_touristy_dat)[1] <- "AverageRating"; colnames(avg_rating_touristy_dat)[2] <- "GoodFortouristy"
plot_avg_rating_touristy <- ggplot(avg_rating_touristy_dat, aes(x = GoodFortouristy, y = AverageRating, fill = GoodFortouristy)) + geom_bar(stat = "identity")
plot_avg_rating_touristy +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants Good For touristy") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p = 0.0007864
leveneTest(anova$stars ~ anova$touristy)
# p-value = 0.02825
t.test(anova$stars[touristy_false_index], anova$stars[touristy_true_index],
       paired = FALSE, var.equal = FALSE)


# # classy


result <- anova %>% count(classy, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- result[c(1:5), 3] / sum
true <- c(0, 6 / 162, 108 / 948, 262 / 1731, 8 / 147)
stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 0.8), xlab = "Stars", ylab = "Proportion", main = "classy", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.2, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by classys
classy_false_index <- which(anova$classy == "False")
classy_true_index <- which(anova$classy == "True")
avg_rating_classy <- c(mean(anova$stars[classy_false_index]), mean(anova$stars[classy_true_index]))
classy <- c("False", "True")
avg_rating_classy_dat <- as.data.frame(cbind(avg_rating_classy, classy))
avg_rating_classy_dat$avg_rating_classy <- as.numeric(as.character(avg_rating_classy_dat$avg_rating_classy))
colnames(avg_rating_classy_dat)[1] <- "AverageRating"; colnames(avg_rating_classy_dat)[2] <- "GoodForclassy"
plot_avg_rating_classy <- ggplot(avg_rating_classy_dat, aes(x = GoodForclassy, y = AverageRating, fill = GoodForclassy)) + geom_bar(stat = "identity")
plot_avg_rating_classy +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants Good For classy") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))

# p = 8.762e-08
leveneTest(anova$stars ~ anova$classy)
# p-value = 1.05e-05
t.test(anova$stars[classy_false_index], anova$stars[classy_true_index],
       paired = FALSE, var.equal = FALSE)


######################################################################


# Plot Restaurant Takeout by Stars 

result <- anova %>% count(anova$RestaurantsTakeOut, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
false <- c(0, 14 / 162, 44 / 948, 74 / 1731, 17 / 147)
true <- result[c(10:14), 3] / sum

stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, false, true)
matrix <- t(datause[, c(2:3)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 2, name = "Darjeeling1"), ylim = c(0, 1.1), xlab = "Stars", ylab = "Proportion", main = "Restaurants Takeout", legend.text = c("False", "True"), args.legend = c(13, 0.5, x.intersp = 0.1, y.intersp = 0.7, text.width = 2, cex = 0.6))


# Plot Average Rating by Restaurant Takeout
RT_false_index <- which(anova$RestaurantsTakeOut == "False")
RT_true_index <- which(anova$RestaurantsTakeOut == "True")
avg_rating_RT <- c(mean(anova$stars[RT_false_index]), mean(anova$stars[RT_true_index]))
rt <- c("False", "True")
avg_rating_RT_dat <- as.data.frame(cbind(avg_rating_RT, rt))
avg_rating_RT_dat$avg_rating_RT <- as.numeric(as.character(avg_rating_RT_dat$avg_rating_RT))
colnames(avg_rating_RT_dat)[1] <- "AverageRating"; colnames(avg_rating_RT_dat)[2] <- "RestaurantsTakeout"
as.numeric(avg_rating_RT_dat$AverageRating)

plot_avg_rating_RT <- ggplot(avg_rating_RT_dat, aes(x = RestaurantsTakeout, y = AverageRating, fill = RestaurantsTakeout)) + geom_bar(stat = "identity")
plot_avg_rating_RT +
        theme(text = element_text(size = 20), legend.position = "none", plot.title = element_text(hjust = 0.5)) +
        scale_y_continuous(limits = c(0, 5)) +
        xlab("Restaurants reservation") +
        ylab("Average Rating") +
        geom_text(stat = "identity", aes(label = round(AverageRating, digits = 4)), size = 8) +
        scale_fill_manual(values = wes_palette(n = 2, name = "Darjeeling1"))


# p-value = 0.03954
leveneTest(anova$stars ~ anova$RestaurantsTakeOut)
# two-sample t-test
# p-value = 0.7016
t.test(anova$stars[RT_false_index], anova$stars[RT_true_index], paired = FALSE, var.equal = FALSE)


# Plot WIFI by Stars 


result <- anova %>% count(WiFi, stars)
sum <- aggregate(result$n, by = list(type = result$stars), sum)$x
free <- result[c(1:5), 3] / sum
no <- c(1 / 13, 6 / 162, 28 / 948, 59 / 1731, 0)
paid <- c(0, 1 / 162, 8 / 948, 6 / 1731, 0)

stars <- c(1, 2, 3, 4, 5)
datause <- cbind(stars, no, free, paid)
matrix <- t(datause[, c(2:4)])
barplot(matrix, names.arg = stars, beside = TRUE, col = wes_palette(n = 3, name = "Darjeeling1"), ylim = c(0, 1), xlab = "Stars", ylab = "Proportion", main = "Wifi", legend.text = c("no", "free", "paid"), args.legend = c(13, 0.8, x.intersp = 0.2, y.intersp = 0.65, text.width = 2, cex = 0.6))

wifi_new <- anova[which(anova$WiFi != "NA"),]
wifi_aov <- aov(wifi_new$stars ~ wifi_new$WiFi)
summary(wifi_aov)
TukeyHSD(wifi_aov)



