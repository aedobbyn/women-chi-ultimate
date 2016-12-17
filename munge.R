

library(tidyverse)
library(readxl)
library(plyr)

sorted <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 1, skip = 1)
raw <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 2, skip = 0)
quant <- read_excel("women_ultimate_quant_data.xlsx")


# make demographics tbl
demographics <- sorted[, 2:7]

# give better var names
demographics <- demographics %>% 
  dplyr::rename(
  age = `Age:`,
  where_live = `Please choose the option that best describes where you currently live.`,
  can_quote = `May we anonymously quote your answers from this survey?`,
  team = `Do you currently play or practice with a Chicago-based club team?`,
  currently_playing = `Please indicate the ultimate you are playing (or registered for) right now:`,
  played_this_year = `For the 2016 calendar year, please indicate where you have played/are playing/plan to play:`
)
 
# how_long_play = `How long have you been playing ultimate?`,
# start_playing = `At what point in your life did you start playing ultimate?`,
# first_experience = `What best describes your first ultimate experience?`

# set datatypes
demographics$age <- factor(demographics$age)
demographics$where_live <- factor(demographics$where_live)
demographics$can_quote <- factor(demographics$can_quote)
demographics$team <- factor(demographics$team)
demographics$currently_playing <- factor(demographics$currently_playing)
demographics$played_this_year <- factor(demographics$played_this_year)


levels(demographics$age)


# rename team levels
demographics$team <- 
  plyr::revalue(demographics$team, 
                c(
                  
                  `I play on a non-Chicago-based club team.` = "Non-Chicago",
                  `I don't play on a Chicago-based club team.` = "No-Club"))

# check levels
levels(demographics$team)


age_levels <- c("Under 18", "18-22", "23-26",
                "27-30", "31-36", "37+")

levels(demographics$age) <- age_levels

# check levels
levels(demographics$age)
# set contrasts
contrasts(demographics$age) <- c(1:6)
# contr.sum(demographics$age)



# make histogram of age distribution
age_hist <- ggplot(aes(age), data = demographics) +
  geom_bar()
age_hist


# make histogram of team distribution
team_hist <- ggplot(aes(team), data = demographics) +
  geom_bar()
team_hist

# team demographics (need a better way to represent this)
age_play_time <- ggplot(aes(team, age), data = demographics, na.rm = TRUE, stat=count) +
  geom_point() # aes(colour = where_live, size = count)
age_play_time




# ---------------------------------


# make development and inclusion tbl
dev_inclusion <- sorted[, 34:37]

dev_inclusion <- dev_inclusion %>% 
  dplyr::rename(
    UC = `Ultimate Chicago supports the development and inclusion of women in ultimate.`,
    college = `College ultimate teams support the development and inclusion of women in ultimate.`,
    women = `Women's club teams support the development and inclusion of women in ultimate.`,
    mixed = `Mixed club teams support the development and inclusion of women in ultimate.`
  )


# set datatypes
dev_inclusion$UC <- factor(dev_inclusion$UC)
dev_inclusion$college <- factor(dev_inclusion$college)
dev_inclusion$women <- factor(dev_inclusion$women)
dev_inclusion$mixed <- factor(dev_inclusion$mixed)





# relevel 
new_levels <- c("Agree", "Somewhat Agree", "Neutral - I don't have an opinion here.",
                "Somewhat disagree", "Disagree")

levels(dev_inclusion$UC) <- new_levels
levels(dev_inclusion$women) <- new_levels
levels(dev_inclusion$college) <- new_levels
levels(dev_inclusion$mixed) <- new_levels

# check levels
levels(dev_inclusion$UC)


dev_incl_plot <- ggplot(aes(women), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(mixed), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(UC), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(college), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(college), data = dev_inclusion, na.rm=TRUE) +
  geom_bar(fill = "red", position="dodge") +
  geom_bar(aes(women), fill = "blue", position="dodge")
dev_incl_plot





# ---- models -----

# combine demographics and dev_inclusion tbls
demogr_inclus <- as.tbl(cbind(demographics, dev_inclusion))

# make vectors of womens and mixed teams
womens_teams <- c("Dish", "Frenzy", "Nemesis")
mixed_teams <- c("ELevate", "Jabba The Huck", 
                 "Shakedown", "Stack Cats", "UPA")


# make column for team_type: mixed, womens, no_team
demogr_inclus$team_type <- 
  ifelse(demogr_inclus$team %in% mixed_teams, demogr_inclus$team_type <- "mixed",
         ifelse(demogr_inclus$team %in% womens_teams, demogr_inclus$team_type <- "womens",
                demogr_inclus$team_type <- "no_team"))

# from team_type, make club_or_not column
demogr_inclus$club_or_not <- 
  ifelse(demogr_inclus$team_type == "no_team",
         demogr_inclus$club_or_not <- "no_club",
         demogr_inclus$club_or_not <- "club")

# make these new variables factors
demogr_inclus$team_type <- factor(demogr_inclus$team_type)
demogr_inclus$club_or_not <- factor(demogr_inclus$club_or_not)


library(lme4)
m.age <- glm(club_or_not ~ age,
         data = na.omit(demogr_inclus),
         family = binomial())


m.UC.team_type <- aov(UC ~ team_type,
         data = na.omit(demogr_inclus))




# sort_teams <- function(d, v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       d$team_type <- "womens"
#     } else if (t %in% mixed_teams) {
#       d$team_type <- "mixed"
#     } else {
#       d$team_type <- "no_team"
#     }
#   }
# }
# demogr_inclus$team_type <- sort_teams(demogr_inclus, demogr_inclus$team)
# 
# 
# sort_teams <- function(v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       demogr_inclus$team_type <- "womens"
#     } else if (t %in% mixed_teams) {
#       demogr_inclus$team_type <- "mixed"
#     } else {
#       demogr_inclus$team_type <- "no_team"
#     }
#   }
# }
# demogr_inclus$team_type <- sort_teams(demogr_inclus$team)






