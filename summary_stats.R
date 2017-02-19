# summary stats


## variables considered
# predictors
predictor_names <- names(dat[, 2:9])
predictor_vars <- c(names(demographics), names(playing))
predictor_tbl <- as_tibble(predictor_vars, predictor_names)


# outcomes
outcome_names <- names(dat[, 10:ncol(dat)])
outcome_vars <- c(names(satisfaction),
         names(connectedness), names(inclusion))
outcome_tbl <- as_tibble(outcome_vars, outcome_names)



source("./munge.R")

# make sure we're only using dplyr
detach(package:plyr)


# --------------- number of people -------------
get_ns <- function(d, g) {
  tabl <- d %>%
    count_(g);
  print(tabl)
  ggplot(d) + geom_bar(aes_string(g), stat = "count")
}

n_by_age <- get_ns(d = all, g = "age")



# count number of people by team type
n_by_team_type <- all %>% 
  count(team_type)

team_type_plot <- ggplot(n_by_team_type) + geom_bar(aes(team_type, n), stat = "identity")

# by team
n_by_team <- all %>% 
  count(team)

team_plot <- ggplot(n_by_team) + geom_bar(aes(team, n), stat = "identity")




# ------


get_table <- function(summarise_this) {
  all %>%  count_(summarise_this)
}

get_table("team")
get_table("team_type")
get_table("club_or_not")
get_table("age")
get_table("where_live")
get_table("currently_playing")



# capitalize levels for 
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

capitalize_this <- function(var, ...) {
  for (lev in var) {
    if (grepl(pattern = "_", x = lev) == TRUE) {
      lev <- simpleCap(gsub(x = lev, pattern = "_", replacement = " "))
    } else {
      lev <- capitalize(lev)
    }
    lev <- capitalize(lev)
  }
  lev
}

# 
# 
# 
# capitalize_this(levels(all[["club_or_not"]]))
# capitalize_this(all$club_or_not[1])
# 
# get_summaries(capitalize_this(all[["club_or_not"]]))



get_summaries <- function(summarise_this) {
  tabl <- all %>%  count_(summarise_this)
  print(tabl)
  ggplot(data = na.omit(all), aes_string(summarise_this)) + geom_bar(position = "dodge")
}

get_summaries("age")



# get number of participants in each category and plot them
get_summaries <- function(summarise_this) {
  tabl <- all %>%  count_(summarise_this)
  print(tabl)
  ggplot(data = na.omit(all), aes_string(summarise_this)) + geom_bar(position = "dodge")
}

get_summaries("age")


# club or not barchart
club.or.not <- ggplot(aes(club_or_not), data = na.omit(all)) +
  geom_bar(position = "dodge")
club.or.not







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








