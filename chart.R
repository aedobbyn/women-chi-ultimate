
source("./munge.R")

# make histogram of age distribution
age_hist <- ggplot(aes(age), data = demographics) +
  geom_bar()
age_hist

# make histogram of team distribution
team_hist <- ggplot(aes(team), data = demographics) +
  geom_bar()
team_hist


# first_experience histogram
qplot(first_experience, data = all)



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



# inclusion types

incl.types <- ggplot(data = all) +
  geom_bar(aes(inclus_mixed), fill = "blue", alpha = 0.5) +
  geom_bar(aes(inclus_women), fill = "red", alpha = 0.5)
incl.types



# age histogram by team type
age.team_type <-  ggplot(data = all) +
  facet_grid( ~ team_type) +
  geom_bar(aes(age))
age.team_type



# how well are women included by team type
inclus_women.team_type <- ggplot(data = all) +
  facet_grid( ~ team_type) +
  geom_bar(aes(inclus_women)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
inclus_women.team_type


# 
inclus_women.team_type <- ggplot(data = all) +
  facet_grid( ~ team_type) +
  geom_bar(aes(inclus_women)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
inclus_women.team_type




# team demographics (need a better way to represent this)
age_play_time <- ggplot(aes(team, age), data = demographics, na.rm = TRUE, stat=count) +
  geom_point() # aes(colour = where_live, size = count)
age_play_time






incl_plot <- ggplot(aes(women), data = na.omit(inclusion)) +
  geom_bar()
incl_plot

incl_plot <- ggplot(aes(mixed), data = na.omit(inclusion)) +
  geom_bar()
incl_plot

incl_plot <- ggplot(aes(UC), data = na.omit(inclusion)) +
  geom_bar()
incl_plot

incl_plot <- ggplot(aes(college), data = na.omit(inclusion)) +
  geom_bar()
incl_plot

incl_plot <- ggplot(aes(college), data = inclusion, na.rm=TRUE) +
  geom_bar(fill = "red", position="dodge") +
  geom_bar(aes(women), fill = "blue", position="dodge")
incl_plot



# club or not barchart
club.or.not <- ggplot(aes(team_type), data = na.omit(demogr_inclus)) +
  geom_bar(position = "dodge")
club.or.not





