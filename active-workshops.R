library(ggplot2)
library(tidyr)
library(cowplot)

active <- read.csv("active-workshops.csv", header=FALSE, sep=",")
names(active)[1] <- "date"
names(active)[2] <- "number_workshops"

p <- ggplot(active, aes(date, number_workshops))
p + geom_point(alpha = 1/4)

active.split <- active %>% 
  separate(date, c("year", "month", "day"), sep = "\\-") 
active.sum.month <- active.split %>% 
  group_by(year, month) %>%
  summarize(workshops.per.month = sum(number_workshops)) 
active.sum.month$date <- paste(active.sum.month$year, active.sum.month$month, sep="-")

require(cowplot)  
q <- ggplot(active.sum.month, aes(x=date, y=workshops.per.month, colour = factor (year))) + 
  geom_point() + background_grid(major = "y", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5))
q            