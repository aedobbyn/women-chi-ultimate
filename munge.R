

library(tidyverse)
library(readxl)
library(plyr)
library(googlesheets)
library(hash)

sorted <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 1, skip = 1)
raw <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 2, skip = 0)
# quant <- read_excel("women_ultimate_quant_data.xlsx")

quant_sheet <- gs_title("women ultimate quant data.xlsx")
quant <- quant_sheet %>% 
  gs_read(ws = 1)

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

satisfaction <- satisfaction %>% 
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

# set age levels ordinally
age_levels <- c("Under 18", "18-22", "23-26",
                "27-30", "31-36", "37+")

demographics$age <- factor(demographics$age, levels = age_levels, ordered = TRUE)

levels(demographics$age)



# ------------ playing -------------- 

playing$team <- factor(playing$team)

# rename team levels for non-Chicago club teams to make shorter
playing$team <- 
  plyr::revalue(playing$team, 
                c(`I play on a non-Chicago-based club team.` = "Non-Chicago",
                  `I don't play on a Chicago-based club team.` = "No-Club"))

playing$currently_playing <- factor(playing$currently_playing) # will be replaced below by one from quant dataset
playing$how_long_play <- factor(playing$how_long_play) 
playing$start_playing <- factor(playing$start_playing)
playing$first_experience <- factor(playing$first_experience)


# ---
# pull in currently_playing from quant instead because it was hand coded there
playing$currently_playing <- quant[["Please indicate the ultimate you are playing (or registered for) right now:"]]

# create a hash object to store the levels we want based on hand coding
currently_playing.dict <- hash(c(1:6), c("League Only", "Combination of League, Club, College",
                       "Club Only", "College Only", "None", "Pickup"))

# extract the values
currently_playing.vals <- values(currently_playing.dict)

# set the levels of currently_playing based on 
playing$currently_playing <- factor(playing$currently_playing, labels = currently_playing.vals)


# ----
# pull in start_playing from quant instead because it was hand coded there
playing$start_playing <- quant[["At what point in your life did you start playing ultimate?"]]

# create a hash object to store the levels we want based on hand coding
start_playing.dict <- hash(c(1:3), c("College", "High School", "Post-College"))

# extract the values
start_playing.vals <- values(start_playing.dict)

# set the levels of currently_playing based on 
playing$start_playing <- factor(playing$start_playing, labels = start_playing.vals)


# ---

# pull in first_experience from quant instead because it was hand coded there
playing$first_experience <- quant[["What best describes your first ultimate experience?"]]

# create a hash object to store the levels we want based on hand coding
first_experience.dict <- hash(c(1:4), c("College", "Middle or High School", 
                                        "Pickup", "League"))

# extract the values
first_experience.vals <- values(first_experience.dict)

# set the levels of currently_playing based on 
playing$first_experience <- factor(playing$first_experience, 
                                   levels = first_experience.vals, 
                                   labels = first_experience.vals)



# ------------ satisfaction -------------- 

satisfaction$amount <- factor(satisfaction$amount)
satisfaction$level <- factor(satisfaction$level)
satisfaction$club <- factor(satisfaction$club)
satisfaction$recreational <- factor(satisfaction$recreational)
satisfaction$college <- factor(satisfaction$college)
satisfaction$youth <- factor(satisfaction$youth)


# differentiate variable names in different mini datasets by appending 
# dataset name to beginning of var name
names(satisfaction) <- paste0("satis_", names(satisfaction))


# satis_dict <- hash(factor(c("Not satisfied -- I want to play more.",
#                      "Neutral -- I don't have strong feelings about the amount of ultimate I'm playing.",
#                      "Somewhat satisfied -- I sometimes wish I could play more, but overall I'm happy with the amount that I play.",
#                      "Somewhat satisfied -- I sometimes wish I played less, but overall I'm happy with the amount that I play.",
#                      "Very satisfied -- I'm playing just the right amount")),
#                    factor(c("Not satisfied", "Neutral", 
#                      "Somewhat satisfied: wants more", "Somewhat satisfied: wants less",
#                      "Very satisfied")))

satis_vec <- as.character(c("Not satisfied -- I want to play more.",
  "Neutral -- I don't have strong feelings about the amount of ultimate I'm playing.",
  "Somewhat satisfied -- I sometimes wish I could play more, but overall I'm happy with the amount that I play.",
  "Somewhat satisfied -- I sometimes wish I played less, but overall I'm happy with the amount that I play.",
  "Very satisfied -- I'm playing just the right amount"))


# replace answers other than those in satis_vec with "Other"
satisfaction <- satisfaction %>% 
  mutate(
    satis_amount2 = ifelse(as.character(satis_amount) %in% satis_vec,
           as.character(satis_amount), "Other")
  ) 

satis_vec_plus_other <- c("Not satisfied -- I want to play more.",
                          "Neutral -- I don't have strong feelings about the amount of ultimate I'm playing.",
                          "Other",
                          "Somewhat satisfied -- I sometimes wish I could play more, but overall I'm happy with the amount that I play.",
                          "Somewhat satisfied -- I sometimes wish I played less, but overall I'm happy with the amount that I play.",
                          "Very satisfied -- I'm playing just the right amount")

satisfaction$satis_amount2 <- factor(satisfaction$satis_amount2,
                                     levels = satis_vec_plus_other,
                                     ordered = TRUE)


satis_relabel <- c("Not satisfied",
                   "Neutral", 
                   "Other",
                   "Somewhat satisfied: wants more", 
                   "Somewhat satisfied: wants less",
                   "Very satisfied")

# change labels to 
satisfaction$satis_amount2 <- factor(satisfaction$satis_amount2,
                                     labels = satis_relabel,
                                     ordered = TRUE)




# ------------ inclusion -------------- 

# reorder levels so that Disagree is coded as 1 and Agree is coded as 5
name_levels <- c("Disagree", "Somewhat disagree",
                 "Neutral - I don't have an opinion here", 
                 "Somewhat Agree", "Agree")

# set datatypes. ordered = TRUE because these are ordinal variables.
inclusion$UC <- factor(inclusion$UC, levels = name_levels, ordered = TRUE)
inclusion$college <- factor(inclusion$college, levels = name_levels, ordered = TRUE)
inclusion$women <- factor(inclusion$women, levels = name_levels, ordered = TRUE)


# "Neutral" response is worded differently in mixed
mixed_levels <- c("Disagree", "Somewhat disagree",
                  "Neutral - I don't have an opinion", 
                  "Somewhat Agree", "Agree")

inclusion$mixed <- factor(inclusion$mixed,  levels = mixed_levels, ordered = TRUE)  


# check levels
levels(inclusion$UC)
levels(inclusion$mixed)


# rename levels in 
levels(inclusion$UC)[levels(inclusion$UC) == "Neutral - I don't have an opinion here"] <- "Neutral"
levels(inclusion$college)[levels(inclusion$college) == "Neutral - I don't have an opinion here"] <- "Neutral"
levels(inclusion$women)[levels(inclusion$women) == "Neutral - I don't have an opinion here"] <- "Neutral"

levels(inclusion$mixed)[levels(inclusion$mixed) == "Neutral - I don't have an opinion"] <- "Neutral"



# differentiate variable names in different mini datasets by appending 
# dataset name to beginning of var name
names(satisfaction) <- paste0("satis_", names(satisfaction))
names(inclusion) <- paste0("inclus_", names(inclusion))






# --------------------------- recombine -------------------------------


# combine mini datasets back together in all
all <- as.tbl(cbind(demographics, playing, satisfaction, inclusion))

# make vectors of womens and mixed teams
womens_teams <- c("Dish", "Frenzy", "Nemesis")
mixed_teams <- c("ELevate", "Jabba The Huck", 
                 "Shakedown", "Stack Cats", "UPA")


# --------------- new columns ---------------

# make column for team_type: mixed, womens, no_team
all$team_type <- 
  ifelse(all$team %in% mixed_teams, all$team_type <- "mixed",
         ifelse(all$team %in% womens_teams, all$team_type <- "womens",
                all$team_type <- "no_club"))

# from team_type, make club_or_not column
all$club_or_not <- 
  ifelse(all$team_type == "no_club",
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



