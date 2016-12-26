
source("./munge.R")


# -------------------- hists ------------

# make histogram of age distribution
age_hist <- ggplot(data = all) +
  geom_bar(aes(x = age))
age_hist

# make histogram of team distribution
team_hist <- ggplot(data = all) +
  geom_bar(aes(x = team))
team_hist

# club or not barchart
club.or.not <- ggplot(aes(team_type), data = na.omit(all)) +
  geom_bar(position = "dodge")
club.or.not

# first_experience histogram
qplot(first_experience, data = all)

# age histogram by team type
age.team_type <-  ggplot(data = all) +
  facet_grid( ~ team_type) +
  geom_bar(aes(age))
age.team_type




# ----------- satisfaction -----------

# satisfaction amount and level by team type
# amount
satis_amount.team_type <- ggplot(data = all) +
  geom_bar(aes(x = satis_amount_recode, fill = team_type), position = "dodge") +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
satis_amount.team_type

# level
satis_level.team_type <- ggplot(data = na.omit(all)) +
  geom_bar(aes(x = satis_level_recode, fill = team_type), position = "dodge") +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
satis_level.team_type


# level faceted rather than colored
ggplot(na.omit(all)) + 
  geom_bar(aes(x = satis_level_recode,
           position = "dodge")) +
  facet_grid(~ team_type) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))





# --------------- inclusion -----------

# inclusion 
# mixed and womens overall
incl.mixed.womens <- ggplot(data = all) +
  geom_bar(aes(inclus_mixed), fill = "blue", alpha = 0.5) +
  geom_bar(aes(inclus_women), fill = "red", alpha = 0.5)
incl.mixed.womens



# how well are women included by team type
inclus_women.team_type <- ggplot(data = all) +
  facet_grid( ~ team_type) +
  geom_bar(aes(inclus_women)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
inclus_women.team_type





# team demographics (need a better way to represent this)
# age_play_time <- ggplot(aes(team, age), data = all, na.rm = TRUE, stat=count) +
#   geom_point(aes(size = count)) # aes(colour = where_live, size = count)
# age_play_time






# incl_plot <- ggplot(aes(women), data = na.omit(inclusion)) +
#   geom_bar()
# incl_plot
# 
# incl_plot <- ggplot(aes(mixed), data = na.omit(inclusion)) +
#   geom_bar()
# incl_plot
# 
# incl_plot <- ggplot(aes(UC), data = na.omit(inclusion)) +
#   geom_bar()
# incl_plot
# 
# incl_plot <- ggplot(aes(college), data = na.omit(inclusion)) +
#   geom_bar()
# incl_plot
# 
# incl_plot <- ggplot(aes(college), data = inclusion, na.rm=TRUE) +
#   geom_bar(fill = "red", position="dodge") +
#   geom_bar(aes(women), fill = "blue", position="dodge")
# incl_plot


inclus_club.women <- ggplot(data = na.omit(all[all$team_type == "womens", ])) +
  geom_bar(aes(x = satis_club, fill = team))
inclus_club.women









# currently_playing distribution
currently_playing.hist <- ggplot(data = na.omit(all)) +
  geom_bar(aes(currently_playing)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
currently_playing.hist

# what people are playing by their team type
# not sure how accurate this was because many people took the survey after their
# seasons had ended so what they play in season != what they said they were
# currently playing
currently_playing.team_type <- ggplot(data = na.omit(all)) +
  geom_bar(aes(currently_playing, fill = team)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
currently_playing.team_type




# among women's players

# women's team distribution
womens_teams.hist <- ggplot(data = na.omit(all[all$team_type == "womens", ])) +
  geom_bar(aes(team)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
womens_teams.hist

mixed_teams.hist <- ggplot(data = na.omit(all[all$team_type == "mixed", ])) +
  geom_bar(aes(team)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
mixed_teams.hist


womens_teams.how_long_play <- 
  ggplot(data = na.omit(all[all$team_type == "womens", ])) +
  geom_bar(aes(team, fill = how_long_play)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
womens_teams.how_long_play





