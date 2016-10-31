

library(tidyverse)
library(readxl)

sorted <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 1, skip = 1)
raw <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 2, skip = 0)


# make demographics tbl
demographics <- sorted[, 2:7]

# give better var names
demographics <- demographics %>% 
  rename(
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

levels(demographics$team)

# rename team levels
demographics$team <- 
  plyr::revalue(demographics$team, 
                c(
                  `I don't play on a Chicago-based club team.` = `No Club`,
                  `I play on a non-Chicago-based club team.` = "Non-Chicago"))



age_hist <- ggplot(aes(age), data = demographics) +
  geom_bar()
age_hist




team_hist <- ggplot(aes(team), data = demographics) +
  geom_bar()
team_hist

age_play_time <- ggplot(aes(how_long_play), data = demographics) +
  geom_point(fill=age)
age_play_time





