library(ggplot2)
library(tidyr)
library(cowplot)

#read in data; split date into year, month, day; add rows for 2012 & 2013 so plot colors are same 
instructors <- read.csv("instructor-training-stats.csv", header=TRUE, sep=",")
instructors.split <- instructors %>% 
  separate(start, c("year", "month", "day"), sep = "\\-") 
inperson <- filter(instructors.split, online < 1)
online <- filter(instructors.split, online >= 1)
inperson <- rbind(inperson, c(2012, 1, 1, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ))
inperson <- rbind(inperson, c(2013, 1, 1, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ))

#linear model fitting for number of people teaching as function of number people completed and year
fitinperson <- lm(data = inperson, taught.at.least.once ~ completed.this + year)
fitonline <- lm(data = online, taught.at.least.once ~ completed.this + year)
summary(fitinperson)
summary(fitonline)

#plots to compare number completed vs taught with year as color code. 
#o1 and i1 first plots so abline for each year while o2 and i2 do not
require(cowplot)  
o1 <- ggplot(online, aes(x=completed.this, y=taught.at.least.once, colour = factor (year))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm")
o2 <- ggplot(online, aes(x=completed.this, y=taught.at.least.once, colour = factor (year))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm", col="Red")
i1 <- ggplot(inperson, aes(x=completed.this, y=taught.at.least.once, colour = factor (year))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm")
i2 <- ggplot(inperson, aes(x=completed.this, y=taught.at.least.once, colour = factor (year))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm", col="Red")
plot_grid(o1, i1, o2, i2, labels = c("      online", "      in-person", "      online", "      in-person"))
