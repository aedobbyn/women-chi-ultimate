

library(tidyverse)
library(readxl)
library(plyr)

sorted <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 1, skip = 1)
raw <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 2, skip = 0)
quant <- read_excel("women_ultimate_quant_data.xlsx")

# last row is NA, get rid of it
sorted <- sorted[1:(nrow(sorted) - 1), ]

# fix typo in quant name
quant <- quant %>% 
  dplyr::rename(
    `How connected do you feel to the CLUB ultimate community in Chicago?` = `Howu connected do you feel to the CLUB ultimate community in Chicago?`
  )

# in sorted keep only the columns that were kept in quant
dat <- sorted[, names(quant)]


# ------------------- mini datasets -----------------------

# make demographics tbl
demographics <- dat[, 2:4]

# give better var names
demographics <- demographics %>% 
  dplyr::rename(
  age = `Age:`,
  where_live = `Please choose the option that best describes where you currently live.`,
  can_quote = `May we anonymously quote your answers from this survey?`
)

# playing tbl
playing <- dat[, 5:9]

playing <- playing %>% 
  dplyr::rename(
    team = `Do you currently play or practice with a Chicago-based club team?`,
    currently_playing = `Please indicate the ultimate you are playing (or registered for) right now:`,
    # played_this_year = `For the 2016 calendar year, please indicate where you have played/are playing/plan to play:`,
    how_long_play = `How long have you been playing ultimate?`,
    start_playing = `At what point in your life did you start playing ultimate?`,
    first_experience = `What best describes your first ultimate experience?`
)

# satisfaction
satisfaction <- dat[, 10:15]

satsifaction <- satisfaction %>% 
  dplyr::rename(
    amount = `How satisfied are you with the AMOUNT of ultimate you are currently playing?`, 
    level = `How satisfied are you with the LEVEL of ultimate you are currently playing?`,
    club = `How connected do you feel to the CLUB ultimate community in Chicago?`,
    recreational = `How connected do you feel to the RECREATIONAL ultimate community in Chicago? (e.g. UC leagues, pickup)`,
    college = `How connected do you feel to the COLLEGE ultimate community in Chicago?`,
    youth = `How connected do you feel to the YOUTH ultimate community in Chicago? (e.g. CUJO, YCC, high school, middle school, etc.)`
)


# make development and inclusion tbl
inclusion <- dat[, 16:19]

inclusion <- inclusion %>% 
  dplyr::rename(
    UC = `Ultimate Chicago supports the development and inclusion of women in ultimate.`,
    college = `College ultimate teams support the development and inclusion of women in ultimate.`,
    women = `Women's club teams support the development and inclusion of women in ultimate.`,
    mixed = `Mixed club teams support the development and inclusion of women in ultimate.`
)






# ------------------- set datatypes ---------------------------------------------------------------

# ------------ demographics -----------
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


# ------------ playing -------------- 


# ------------ satisfaction -------------- 



# ------------ inclusion -------------- 

# reorder levels so that Disagree is coded as 1 and Agree is coded as 5
name_levels <- c("Disagree", "Somewhat disagree",
                 "Neutral - I don't have an opinion here.",
                 "Somewhat Agree", "Agree")

# set datatypes. ordered = TRUE because these are ordinal variables.
inclusion$UC <- factor(inclusion$UC, levels = name_levels, ordered = TRUE)
inclusion$college <- factor(inclusion$college, levels = name_levels, ordered = TRUE)
inclusion$women <- factor(inclusion$women, levels = name_levels, ordered = TRUE)
inclusion$mixed <- factor(inclusion$mixed,  levels = name_levels, ordered = TRUE)


# check levels
levels(inclusion$UC)







# --------------------------- recombine -------------------------------

# combine mini datasets back together in all
all <- as.tbl(cbind(demographics, playing, satisfaction, inclusion))

# make vectors of womens and mixed teams
womens_teams <- c("Dish", "Frenzy", "Nemesis")
mixed_teams <- c("ELevate", "Jabba The Huck", 
                 "Shakedown", "Stack Cats", "UPA")


# make column for team_type: mixed, womens, no_team
all$team_type <- 
  ifelse(all$team %in% mixed_teams, all$team_type <- "mixed",
         ifelse(all$team %in% womens_teams, all$team_type <- "womens",
                all$team_type <- "other"))

# from team_type, make club_or_not column
all$club_or_not <- 
  ifelse(all$team_type == "other",
         all$club_or_not <- "not_club",
         all$club_or_not <- "club")

# make these new variables factors
all$team_type <- factor(all$team_type)
all$club_or_not <- factor(all$club_or_not)
















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
# all$team_type <- sort_teams(all, all$team)
# 

# sort_teams <- function(v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       all$team_type <- "womens"
#     } else if (t %in% mixed_teams) {
#       all$team_type <- "mixed"
#     } else {
#       all$team_type <- "no_team"
#     }
#   }
# }
# all$team_type <- sort_teams(all$team)
# 
# 

# all$team_type2 <- "x"
#   
# sort_teams <- function(v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       all$team_type2[t] <- "womens"
#       print(all$team_type2[t])
#     } else {
#       all$team_type2[t] <- "not"
#     }
#   }
# }
# 
# sort_teams(complete.cases(all$team))
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
# all$team_type2 <- sort_teams(all$team)



