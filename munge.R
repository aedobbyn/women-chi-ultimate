
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
demographics <- dat[, c(2, 4)]   # taking where_live (column 3) this from hand-coded quant

# give better var names
demographics <- demographics %>% 
  dplyr::rename(
  age = `Age:`,
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
satisfaction <- dat[, 10:11]

# satisfaction also encompasses all the connectedness questions

satisfaction <- satisfaction %>% 
  dplyr::rename(
    satis_amount = `How satisfied are you with the AMOUNT of ultimate you are currently playing?`, 
    satis_level = `How satisfied are you with the LEVEL of ultimate you are currently playing?`
)


# connectedness
connectedness <- dat[, 12:15]

connectedness <- connectedness %>% 
  dplyr::rename(
    conn_club = `How connected do you feel to the CLUB ultimate community in Chicago?`,
    conn_recreational = `How connected do you feel to the RECREATIONAL ultimate community in Chicago? (e.g. UC leagues, pickup)`,
    conn_college = `How connected do you feel to the COLLEGE ultimate community in Chicago?`,
    conn_youth = `How connected do you feel to the YOUTH ultimate community in Chicago? (e.g. CUJO, YCC, high school, middle school, etc.)`
  )



# make development and inclusion tbl
inclusion <- dat[, 16:19]

inclusion <- inclusion %>% 
  dplyr::rename(
    inclus_UC = `Ultimate Chicago supports the development and inclusion of women in ultimate.`,
    inclus_college = `College ultimate teams support the development and inclusion of women in ultimate.`,
    inclus_women = `Women's club teams support the development and inclusion of women in ultimate.`,
    inclus_mixed = `Mixed club teams support the development and inclusion of women in ultimate.`
)





# ------------------- set datatypes ---------------------------------------------------------------

# ------------ demographics -----------
# getting where_live from quant
demographics$where_live <- factor(quant[["Please choose the option that best describes where you currently live."]])

where_live.dict <- hash(c(1:3), c("Chicago Suburbs", "Chicago", "Other"))

# extract the values
where_live.vals <- values(where_live.dict)

# set the levels
demographics$where_live <- factor(demographics$where_live, 
                                labels = where_live.vals,
                                ordered = FALSE)

# set Chicago as reference level of 1
new.where_live.dict <- hash(c(2, 1, 3), c("Chicago Suburbs", "Chicago", "Other"))

demographics$where_live <- factor(demographics$where_live,
                                  levels = values(new.where_live.dict),
                                  ordered = FALSE)




demographics$can_quote <- factor(demographics$can_quote,
                                 labels = c("More info", "No", "Yes"))

# set age levels ordinally
age_levels <- c("Under 18", "18-22", "23-26",
                "27-30", "31-36", "37+")

demographics$age <- factor(demographics$age, 
                           levels = age_levels,
                           ordered = TRUE)

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

how_long_play.dict <- hash(c(1:5), c("<1 year", "1-3 years",
                                     "3-5 years", "5-10 years",
                                     "10+ years"))

# extract the values
how_long_play.vals <- values(how_long_play.dict)

# set the levels of currently_playing based on 
playing$how_long_play <- factor(playing$how_long_play, 
                                levels = how_long_play.vals,
                                ordered = TRUE)


# ---
# pull in currently_playing from quant instead because it was hand coded there
playing$currently_playing <- quant[["Please indicate the ultimate you are playing (or registered for) right now:"]]

# create a hash object to store the levels we want based on hand coding
currently_playing.dict <- hash(c(1:6), c("League Only", "Combination of League, Club, College",
                       "Club Only", "College Only", "None", "Pickup"))

# extract the values
currently_playing.vals <- values(currently_playing.dict)

# set the levels of currently_playing based on 
playing$currently_playing <- factor(playing$currently_playing, 
                                    labels = currently_playing.vals,
                                    ordered = TRUE)


# ----
# pull in start_playing from quant instead because it was hand coded there
playing$start_playing <- quant[["At what point in your life did you start playing ultimate?"]]

# create a hash object to store the levels we want based on hand coding
start_playing.dict <- hash(c(1:3), c("College", "High School", "Post-College"))

# extract the values
start_playing.vals <- values(start_playing.dict)

# set the levels of currently_playing based on 
playing$start_playing <- factor(playing$start_playing, 
                                labels = start_playing.vals) 


# reorder and relevel because high school is coded as a 2 in between college and post-college, 
# so ordering as it is in quant dataset wouldn't make temporal sense
start_playing_new_vals <- c(1:3)
start_playing_new_labs <- c("High School", "College", "Post-College")

# relevel and relabel
playing$start_playing <- factor(playing$start_playing,
                                          levels = start_playing_new_labs,
                                          ordered = TRUE)




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
                                   # levels = first_experience.vals,
                                   labels = first_experience.vals)  # same here -- ordering doesn't make sense



# ------------ satisfaction -------------- 

# satisfaction$satis_amount <- factor(satisfaction$amount)
# satisfaction$satis_level <- factor(satisfaction$level)
# satisfaction$conn_club <- factor(satisfaction$club)
# satisfaction$conn_recreational <- factor(satisfaction$recreational)
# satisfaction$conn_college <- factor(satisfaction$college)
# satisfaction$conn_youth <- factor(satisfaction$youth)


# # differentiate variable names in different mini datasets by appending 
# # dataset name to beginning of var name
# names(satisfaction) <- paste0("satis_", names(satisfaction))

# make a vector of all the standardized non-Other answers
satis_amount_vec <- as.character(c("Not satisfied -- I want to play more.",
                                   "Not satisfied -- I want to play less.",
  "Neutral -- I don't have strong feelings about the amount of ultimate I'm playing.",
  "Somewhat satisfied -- I sometimes wish I could play more, but overall I'm happy with the amount that I play.",
  "Somewhat satisfied -- I sometimes wish I played less, but overall I'm happy with the amount that I play.",
  "Very satisfied -- I'm playing just the right amount"))

# make a vector of the levels with "Other" after Neutral. might want to revisit the placement of this
# b/c if we take it outthere will be a bigger ordinal gap between neutral and somewhat satisfied than 
# there should be.
satis_amount_vec_plus_other <- c("Not satisfied -- I want to play more.",
                                 "Not satisfied -- I want to play less.",
                          "Neutral -- I don't have strong feelings about the amount of ultimate I'm playing.",
                          "Other",
                          "Somewhat satisfied -- I sometimes wish I could play more, but overall I'm happy with the amount that I play.",
                          "Somewhat satisfied -- I sometimes wish I played less, but overall I'm happy with the amount that I play.",
                          "Very satisfied -- I'm playing just the right amount")

satis_relabel <- c("Not satisfied: wants more",
                   "Not satisfied: wants less",
                   "Neutral", 
                   "Other",
                   "Somewhat satisfied: wants more", 
                   "Somewhat satisfied: wants less",
                   "Very satisfied")


# replace answers other than those in satis_vec with "Other"
satisfaction <- satisfaction %>% 
  mutate(
    satis_amount_recode = ifelse(as.character(satis_amount) %in% satis_amount_vec,
           as.character(satis_amount), "Other")
  )

# relevel and relabel
satisfaction$satis_amount_recode <- factor(satisfaction$satis_amount_recode,
                                     levels = satis_amount_vec_plus_other,
                                     labels = satis_relabel,
                                     ordered = TRUE)



# --

# do same for satisfaction level


# make a vector of all the standardized non-Other answers
satis_level_vec <- as.character(c("Not satisfied -- I want to play more competitively",
                            "Not satisfied -- I want to play less competitively.",
                            "Neutral -- I don't have strong feelings about the level of ultimate I'm playing.",
                            "Somewhat satisfied -- I sometimes wish I could play more competitively, but overall I'm satisfied with the level that I play.",
                            "Somewhat satisfied -- I sometimes wish I played less competitively, but overall I'm satisfied with the level that I play.", 
                            "Very satisfied -- I have the opportunity to play at the right level of competitiveness for me."))

# make a vector of the levels with "Other" after Neutral. might want to revisit the placement of this
# b/c if we take it out there will be a bigger ordinal gap between neutral and somewhat satisfied than 
# there should be.
satis_level_vec_plus_other  <- c("Not satisfied -- I want to play more competitively",
                            "Not satisfied -- I want to play less competitively.",
                            "Neutral -- I don't have strong feelings about the level of ultimate I'm playing.",
                            "Other",
                            "Somewhat satisfied -- I sometimes wish I could play more competitively, but overall I'm satisfied with the level that I play.",
                            "Somewhat satisfied -- I sometimes wish I played less competitively, but overall I'm satisfied with the level that I play.", 
                            "Very satisfied -- I have the opportunity to play at the right level of competitiveness for me.")

satis_level_relabel <- c("Not satisfied: wants more competitive",
                         "Not satisfied: wants less competitive",
                         "Neutral",
                         "Other",
                         "Somewhat satisfied: wants more competitive",
                         "Somewhat satisfied: wants less competitive",
                         "Very satisfied")


# replace answers other than those in satis_vec with "Other"
satisfaction <- satisfaction %>% 
  mutate(
    satis_level_recode = ifelse(as.character(satis_level) %in% satis_level_vec,
                                 as.character(satis_level), "Other")
  )


# relevel and relabel
satisfaction$satis_level_recode <- factor(satisfaction$satis_level_recode,
                                          levels = satis_level_vec_plus_other,
                                          labels = satis_level_relabel,
                                           ordered = TRUE)


# drop columns from before recode
satisfaction <- satisfaction %>% 
  dplyr::select(
    -c(satis_amount, satis_level)
  )


# -------------------- connectedness --------------------

conn.dict <- hash(c(1:6), c("Disconnected",
                             "Somewhat disconnected",
                             "Neutral",
                             "Somewhat connected",
                             "Connected",
                             "Very connected"))

# extract the values
conn.vals <- values(conn.dict)

# set the levels of currently_playing based on 
connectedness$conn_club <- factor(connectedness$conn_club, 
                                  levels = conn.vals,
                                  ordered = TRUE)
connectedness$conn_recreational <- factor(connectedness$conn_recreational, 
                                  levels = conn.vals,
                                  ordered = TRUE)
connectedness$conn_college <- factor(connectedness$conn_college, 
                                    levels = conn.vals,
                                    ordered = TRUE)
connectedness$conn_youth <- factor(connectedness$conn_youth, 
                                    levels = conn.vals,
                                   ordered = TRUE)




# ------------ inclusion -------------- 

# reorder levels so that Disagree is coded as 1 and Agree is coded as 5
name_levels <- c("Disagree", "Somewhat disagree",
                 "Neutral - I don't have an opinion here.", 
                 "Somewhat Agree", "Agree")

# "Neutral" response is worded differently in mixed
mixed_levels <- c("Disagree", "Somewhat disagree",
                  "Neutral - I don't have an opinion", 
                  "Somewhat Agree", "Agree")


# set datatypes. ordered = TRUE because these are ordinal variables.
inclusion$inclus_UC <- factor(inclusion$inclus_UC, levels = name_levels, ordered = TRUE)
inclusion$inclus_college <- factor(inclusion$inclus_college, levels = name_levels, ordered = TRUE)
inclusion$inclus_women <- factor(inclusion$inclus_women, levels = name_levels, ordered = TRUE)


inclusion$inclus_mixed <- factor(inclusion$inclus_mixed,  levels = mixed_levels, ordered = TRUE)  


# check levels
levels(inclusion$inclus_UC)
levels(inclusion$inclus_mixed)


# rename levels in 
levels(inclusion$inclus_UC)[levels(inclusion$inclus_UC) == "Neutral - I don't have an opinion here."] <- "Neutral"
levels(inclusion$inclus_college)[levels(inclusion$inclus_college) == "Neutral - I don't have an opinion here."] <- "Neutral"
levels(inclusion$inclus_women)[levels(inclusion$inclus_women) == "Neutral - I don't have an opinion here."] <- "Neutral"

levels(inclusion$inclus_mixed)[levels(inclusion$inclus_mixed) == "Neutral - I don't have an opinion"] <- "Neutral"






# --------------------------- recombine -------------------------------


# combine mini datasets back together in all
all <- as.tbl(cbind(demographics, playing, satisfaction, connectedness, inclusion))

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

# rearrange levels so 1 = no_club, the reference group
team_type.dict <- hash(c(1:3), c("no_club", "mixed", "womens"))
team_type.vals <- values(team_type.dict)
all$team_type <- factor(all$team_type, 
                        levels = team_type.vals,
                        ordered = FALSE)


# from team_type, make club_or_not column
all$club_or_not <- 
  ifelse(all$team_type == "no_club",
         all$club_or_not <- "not_club",
         all$club_or_not <- "club")

# make these new variables factors
all$team_type <- factor(all$team_type)
all$club_or_not <- factor(all$club_or_not)






# -------- calculate overall happiness --------
all <- all %>% 
  mutate(
    satis_combined = (as.numeric(satis_amount_recode) + as.numeric(satis_level_recode)),
    conn_combined = (as.numeric(conn_club) + as.numeric(conn_recreational) +
                       as.numeric(conn_college) + as.numeric(conn_youth)),
    inclus_combined = (as.numeric(inclus_UC) + as.numeric(inclus_college) + as.numeric(inclus_women) +
      as.numeric(inclus_mixed)),
    overall = (satis_combined + conn_combined + inclus_combined)
  )

summary(all$overall)



# ---- what were the *observed* max and min for these combined measures? ----

# satisfaction
max(all$satis_combined)   # 14
min(all$satis_combined)   # 3

# connectedness
max(all$conn_combined)   # 18
min(all$conn_combined)   # 4

# inclusion
max(all$inclus_combined)  # 20
min(all$inclus_combined)  # 10

# both
max(all$overall)  # 50
min(all$overall)  # 20



# ---- what were the *theoretical* max and min for these combined measures? ----

# (theoretical minimum is assigned a 1 in all cases, so least satisfied/included sum will equal
# the number of variables in satisfaction and inclusion datasets)

# connectedness
max_conn <- max(as.numeric(all$conn_club)) + max(as.numeric(all$conn_recreational)) +
  max(as.numeric(all$conn_college)) + max(as.numeric(all$conn_youth))
max_conn   # 22
sum(ncol(connectedness))  # 4

# satisfaction
max_satis <- max(as.numeric(all$conn_club)) + max(as.numeric(all$conn_recreational)) +
  max(as.numeric(all$conn_college)) + max(as.numeric(all$conn_youth)) + max(as.numeric(all$satis_amount_recode)) +
  max(as.numeric(all$satis_level_recode))
max_satis   # 36
sum(ncol(satisfaction))  # 2


# inclusion
max_inclus <- max(as.numeric(all$inclus_UC)) + max(as.numeric(all$inclus_college)) + max(as.numeric(all$inclus_women)) +
                 max(as.numeric(all$inclus_mixed))
max_inclus   # 20
sum(ncol(inclusion))   # 4


# overall
max_satis + max_conn + max_inclus # 78
sum(ncol(satisfaction)) + sum(ncol(connectedness)) + sum(ncol(inclusion))   # 10


# get means by team_type
means.by.team <- all %>% 
  group_by(team_type, team) %>% 
  dplyr::summarise(                        # make sure to include dplyr:: here. not sure which package is masking summarise()
    mean_satis = mean(satis_combined), 
    mean_conn = mean(conn_combined),
    mean_inclus = mean(inclus_combined),
    mean_overall = mean(overall)
  )
means.by.team



# get means for all aggregated variables
means_overall <- means.by.team %>% 
  ungroup() %>% 
  select(
    3:ncol(.)
  ) %>% 
  map_dbl(mean)

# 
# 1:10 %>%
#   map(rnorm, mean = 10) %>%
#   map_dbl(mean)
# 
# 1:10 %>%
#   map(~ rnorm(10, .x))
# 
# 
# mtcars %>% map_dbl(sum)
# mtcars %>% map(sum)
# 
# bar <- mtcars %>%
#   group_by(cyl)
# 
# 
# 
# a <- matrix(1:30, 5, 6)
# ta <- t(a)
# 
# mtcars %>%
#   split(.$cyl) %>%
#   map(~ lm(mpg ~ wt, data = .x))




# you have the total number of sets and the increment. how many burpees?
tally <- function (lim, increment) {
  count <- 0
  for (set in 1:lim) {
    count <- count + increment*set
  }
  return(count)
}

tally(7, 3)


# you have the number of reps for the first two sets.
# the increment is always the same. how many burpees?
how_sore <- function(max, second) {
  counter <- max
  this_set <- max
  increment <- max - second
  while (this_set > 0) {
    this_set <- this_set - increment
    counter <- counter + this_set
  }
  print(paste0("You're doing ", counter, " burpees! o_O"))
}

how_sore(21, 18)







