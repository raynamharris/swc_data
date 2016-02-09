library(ggplot2)
library(tidyr)
library(dplyr)
library(cowplot)
require(cowplot) 

## read in data; split date into year, month, day; add badged instructor column
instructors <- read.csv("instructor-training-stats.csv", header=TRUE, sep=",")
instructors.split <- instructors %>% 
  separate(start, c("year", "month", "day"), sep = "\\-") 
instructors.split <- mutate(instructors.split, badged.instructors = learners - no.badge)

## filter by classroom type, add rows for 2012 & 2013 so plot colors are same 
inperson <- filter(instructors.split, online < 1)
online <- filter(instructors.split, online >= 1)
inperson <- rbind(inperson, c(2012, 1, 1, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ))
inperson <- rbind(inperson, c(2013, 1, 1, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ))

# filter  by year for comparing classroom style
year2015 <- filter(instructors.split, year==2015)
year2014<- filter(instructors.split, year==2014)

##linear model fitting to get R^2 for each plot
fitall.learners <- lm(data = instructors.split, learners ~ completed.this)
summary(fitall.learners)
#Multiple R-squared:  0.7021,	Adjusted R-squared:  0.6953 
fitall.badged <- lm(data = instructors.split, taught.at.least.once ~ badged.instructors)
summary(fitall.badged)
#Multiple R-squared:  0.915,	Adjusted R-squared:  0.9131
fitinperson <- lm(data = inperson, taught.at.least.once ~ badged.instructors + year)
summary(fitinperson)
#Multiple R-squared:  0.9637,	Adjusted R-squared:  0.9546 
fitonline <- lm(data = online, taught.at.least.once ~ badged.instructors + year)
summary(fitonline)
#Multiple R-squared:  0.9692,	Adjusted R-squared:  0.9595 
fit2014 <- lm(data = year2014, taught.at.least.once ~ badged.instructors + online)
summary(fit2014)
#Multiple R-squared:  0.9816,	Adjusted R-squared:  0.9755 
fit2015 <- lm(data = year2015, taught.at.least.once ~ badged.instructors + online)
summary(fit2015)
#Multiple R-squared:  0.9234,	Adjusted R-squared:  0.9144

#plot number learers vs number who have taught at least once. color by classroom style
all<- ggplot(instructors.split, aes(x=learners, y=taught.at.least.once, colour = factor (online))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  scale_colour_discrete(labels=c("in-person", "online")) +
  stat_smooth(method = "lm", col="red") 
#plot number badged instructors (completed.this) vs number who have taught at least once. color by classroom style
all2<- ggplot(instructors.split, aes(x=badged.instructors, y=taught.at.least.once, colour = factor (online))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  scale_colour_discrete(labels=c("in-person", "online")) +
  stat_smooth(method = "lm", col="red") 
#plot number ONLINE trained badged instructors (completed.this) vs number who have taught at least once. color by year
online.year <- ggplot(online, aes(x=badged.instructors, y=taught.at.least.once, colour = factor (year))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm")
#plot number INPERSON trained badged instructors (completed.this) vs number who have taught at least once. color by year
inperson.year<- ggplot(inperson, aes(x=badged.instructors, y=taught.at.least.once, colour = factor (year))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm") 
plotyear2014 <- ggplot(year2014, aes(x=badged.instructors, y=taught.at.least.once, colour = factor (online))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm")+
  scale_colour_discrete(labels=c("in-person", "online"))
plotyear2015 <- ggplot(year2015, aes(x=badged.instructors, y=taught.at.least.once, colour = factor (online))) + 
  geom_point() + background_grid(major = "xy", minor = "none")  +
  theme(axis.text.x = element_text(angle=70, vjust=0.5)) +
  stat_smooth(method = "lm") +
  scale_colour_discrete(labels=c("in-person", "online"))

#using cowplot to make a grid of plots
plot_grid(all, all2, online.year, inperson.year, plotyear2014, plotyear2015, ncol=2, 
          labels = c("    A. all learners", " B. all new instructors", 
                     "C. online new instructors", "D. in-person new instructors",
                     "       E. 2014", "        F. 2015"))
ggsave("instructor-training-stats-1.png")
