

library(tidyverse)
library(readxl)
library(plyr)

sorted <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 1, skip = 1)
raw <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 2, skip = 0)
quant <- read_excel("women_ultimate_quant_data.xlsx")

# last row is NA, get rid of it
sorted <- sorted[1:(nrow(sorted) - 1), ]

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
demographics$where_live <- factor(demographics$where_live)
demographics$can_quote <- factor(demographics$can_quote)
demographics$team <- factor(demographics$team)
# demographics$currently_playing <- factor(demographics$currently_playing) # this is free response, needs hand coding or could do some NLP stuff though
# demographics$played_this_year <- factor(demographics$played_this_year) # same


# set age levels ordinally
age_levels <- c("Under 18", "18-22", "23-26",
                "27-30", "31-36", "37+")

demographics$age <- factor(demographics$age, levels = age_levels, ordered = TRUE)

levels(demographics$age)


# rename team levels for non-Chicago club teams to make shorter
demographics$team <- 
  plyr::revalue(demographics$team, 
                c(`I play on a non-Chicago-based club team.` = "Non-Chicago",
                  `I don't play on a Chicago-based club team.` = "No-Club"))



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


# relevel 
name_levels <- c("Disagree", "Somewhat disagree",
                 "Neutral - I don't have an opinion here.",
                 "Somewhat Agree", "Agree")


# set datatypes
dev_inclusion$UC <- factor(dev_inclusion$UC, levels = name_levels, ordered = TRUE)
dev_inclusion$college <- factor(dev_inclusion$college, levels = num_levels, labels = name_levels, ordered = TRUE)
dev_inclusion$women <- factor(dev_inclusion$women, levels = num_levels, labels = name_levels, ordered = TRUE)
dev_inclusion$mixed <- factor(dev_inclusion$mixed, levels = num_levels, labels = name_levels, ordered = TRUE)



# check levels
levels(dev_inclusion$UC)




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
                demogr_inclus$team_type <- "other"))

# from team_type, make club_or_not column
demogr_inclus$club_or_not <- 
  ifelse(demogr_inclus$team_type == "other",
         demogr_inclus$club_or_not <- "not_club",
         demogr_inclus$club_or_not <- "club")

# make these new variables factors
demogr_inclus$team_type <- factor(demogr_inclus$team_type)
demogr_inclus$club_or_not <- factor(demogr_inclus$club_or_not)
















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
# 
# 

# demogr_inclus$team_type2 <- "x"
#   
# sort_teams <- function(v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       demogr_inclus$team_type2[t] <- "womens"
#       print(demogr_inclus$team_type2[t])
#     } else {
#       demogr_inclus$team_type2[t] <- "not"
#     }
#   }
# }
# 
# sort_teams(complete.cases(demogr_inclus$team))
# 
# 
# u1 <- rnorm(30)
# 
# usq <- 0
# 
# for(i in 1:10) {
#   usq[i] <- u1[i]*u1[i]
#   print(usq[i])
# }
# 
# 
# 
# usq[i] <- u1[i]*u1[i]
# print(usq[i])
# 
# demogr_inclus$team_type2 <- sort_teams(demogr_inclus$team)



