

library(tidyverse)
library(readxl)

sorted <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 1, skip = 1)
raw <- read_excel("women_chicago_ultimate_raw.xlsx", sheet = 2, skip = 0)


demographics <- raw[, 2:7]

demographics <- demographics %>% 
  rename(
  age = `Age:`,
  where_live = `Please choose the option that best describes where you currently live.`,
  
)


