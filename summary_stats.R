# summary stats

source("./munge.R")

# make sure we're only using dplyr
detach(package:plyr)


# function for capitalizing words in vector separated by underscores
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}
capitalize_this <- function(vec, ...) {
  out <- vector()
  for (i in vec) {
    if (grepl(pattern = "_", x = i) == TRUE) {
      i <- simpleCap(gsub(x = i, pattern = "_", replacement = " "))
    } else {
      i <- capitalize(i)
    }
    out <- c(out, i)
  }
  out
}

# for tibbles
capitalize_this_tbl <- function(df, vec) {
  out <- vector()
  for (i in df[[vec]]) {
    if (grepl(pattern = "_", x = i) == TRUE) {
      i <- simpleCap(gsub(x = i, pattern = "_", replacement = " "))
    } else {
      i <- capitalize(i)
    }
    out <- c(out, i)
  }
  out
}


# --- examples
# capitalize_this(head(all$team_type))
# capitalize_this(head(all[, 20]))
# capitalize_this(names(all))
# capitalize_this_tbl(df = get_table("team_type"), vec = "team_type")



## -------- variables considered ----------
# predictors
predictor_names <- names(dat[, 2:9])
predictor_vars <- c(names(demographics), names(playing))
predictor_tbl <- data.frame(Variable = predictor_vars, Name = predictor_names)


# outcomes
outcome_names <- names(dat[, 10:ncol(dat)])
outcome_vars <- c(names(satisfaction),
         names(connectedness), names(inclusion))
outcome_tbl <- data.frame(Variable = outcome_vars, Name = outcome_names)



# ------
# get just a table of counts per group for a certain variable
get_table <- function(summarise_this) {
  all %>%  count_(summarise_this)
}

get_table("age")
get_table("team_type")
get_table("where_live")
get_table("currently_playing")




# --------------- table and a graph -------------

# get number of participants in each category and plot them
get_summaries <- function(d, var) {
  tabl <- d %>%
    count_(var);
  print(tabl)
  # cap_tbl <- capitalize_this_tbl(tabl, "team_type")
  ggplot(d) + geom_bar(aes_string(var), stat = "count") + theme_minimal() +
    ggtitle(paste0("Breakdown by ", capitalize_this(var))) +
    labs(x = capitalize_this(var), y = "Count")
  # ggplot(tabl) + geom_bar(aes_string(capitalize_this(var), n), stat = "identity")
}

get_summaries(d = all, var = "club_or_not")
get_summaries(d = all, var = "where_live")
get_summaries(d = all, var = "how_long_play")
get_summaries(d = all, var = "team")


n_by_age <- get_summaries(d = all, var = "age")
n_by_age




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
    mean_satis = round(mean(satis_combined), digits = 2), 
    mean_conn = round(mean(conn_combined), digits = 2),
    mean_inclus = round(mean(inclus_combined), digits = 2),
    mean_overall = round(mean(overall), digits = 2)
  ) %>% 
  arrange(mean_overall) %>% 
  rename(
    `Team Type` = team_type,
    Team = team,
    `Mean Satisfaction` = mean_satis,
    `Mean Connectedness` = mean_conn,
    `Mean Inclusion` = mean_inclus,
    `Mean Overall` = mean_overall
  )
means.by.team


# get means for all aggregated variables
means_overall <- means.by.team %>% 
  ungroup() %>% 
  select(
    3:ncol(.)
  ) %>% 
  map_dbl(mean)
means_overall








# ----- if need to do by hand --------
# # count number of people by team type
# n_by_team_type <- all %>% 
#   count(team_type)
# 
# team_type_plot <- ggplot(n_by_team_type) + geom_bar(aes(team_type, n), stat = "identity")
# 
# # by team
# n_by_team <- all %>% 
#   count(team)
# 
# team_plot <- ggplot(n_by_team) + geom_bar(aes(team, n), stat = "identity")


# club or not barchart
# club.or.not <- ggplot(aes(club_or_not), data = na.omit(all)) +
#   geom_bar(position = "dodge")
# club.or.not






