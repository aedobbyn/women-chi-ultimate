

library(tidyverse)
library(readxl)

sorted <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 1, skip = 1)
raw <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 2, skip = 0)


# make demographics tbl
demographics <- raw[, 2:7]

# give better var names
demographics <- demographics %>% 
  rename(
  age = `Age:`,
  where_live = `Please choose the option that best describes where you currently live.`,
  can_quote = `May we anonymously quote your answers from this survey?`,
  how_long_play = `How long have you been playing ultimate?`,
  start_playing = `At what point in your life did you start playing ultimate?`,
  first_experience = `What best describes your first ultimate experience?`
)

# set datatypes
demographics$age <- factor(demographics$age)
demographics$where_live <- factor(demographics$where_live)
demographics$can_quote <- factor(demographics$can_quote)
demographics$how_long_play <- factor(demographics$how_long_play)
demographics$start_playing <- factor(demographics$start_playing)
demographics$first_experience <- factor(demographics$first_experience)




age_hist <- ggplot(aes(age), data = demographics) +
  geom_bar()
age_hist

age_play_time <- ggplot(aes(age, how_long_play), data = demographics) +
  geom_density()
age_play_time





