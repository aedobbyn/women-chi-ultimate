
source("./munge.R")
source("./model.R")

library(ggthemes)


all_no_na <- all[complete.cases(all), ]


library(gganimate)

foo <- ggplot(data = all, filename = "gganim_output.gif",
              aes(x = how_long_play, y = overall, frame = as.numeric(team))) +
  geom_jitter()

gganimate(foo)


# ---------- relabeling -------

# make key-value pairs for our current facet labels and what we want to see in the plot
team_type_names <- list(
  "no_club" = "No Club",
  "mixed" = "Mixed",
  "womens" = "Womens"
)

# function to return the values of facet labels. called inside facet_grid()
relabel_t_t <- function(variable, value){
  return(team_type_names[value])
}

# relabel <- function(variable, value){
#   return(variable[value])
# }
# can't call relabel(team_type_names) as argment to labeller inside facet_grid() unfortunately


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

# overall satisfacion by team type
overall.team_type <- ggplot(data = all) +
  geom_bar(aes(overall, fill = team_type), position = "dodge") 
overall.team_type

overall.box <- ggplot(data = all) +
  geom_boxplot(aes(team, overall), alpha = 0.05, fill = "blue") +
  # geom_boxplot(aes(team, preds.m.big), alpha = 0.05, fill = "red") +
  theme_bw()
overall.box

overall.point <- ggplot(data = all) +
  geom_jitter(aes(team, overall)) +
  geom_jitter(aes(team, preds.m.big), alpha = 0.05, colour = "red")
overall.point

# hist of predictions from m.big
qplot(preds.m.big)


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

# amount faceted rather than colored
# percentage of total on y axis rather than counts
ggplot(na.omit(all)) + 
  geom_bar(aes(x = satis_amount_recode,
               y = (..count..)/sum(..count..),
               position = "dodge")) +
  facet_grid(~ team_type) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

# level faceted
# percentage of total on y axis 
ggplot(na.omit(all)) + 
  geom_bar(aes(x = satis_level_recode,
               y = (..count..)/sum(..count..), 
           position = "dodge")) +
  facet_grid(~ team_type) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))


# ---- satisfaction amount (percentage of subset) among subsets of team_type
# team_type=='womens'
ggplot(na.omit(all[all$team_type=="womens", ])) + 
  geom_bar(aes(x = satis_amount_recode, y = (..count..)/sum(..count..),
               position = "fill")) +
  labs(title = "Satisfaction with Amount of Play: Womens") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_discrete(drop=FALSE) +     # don't drop unused levels
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

# team_type=='mixed'
ggplot(na.omit(all[all$team_type=="mixed", ])) + 
  geom_bar(aes(x = satis_amount_recode, y = (..count..)/sum(..count..),
               position = "fill")) +
  labs(title = "Satisfaction with Amount of Play: Mixed") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_discrete(drop=FALSE) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

# team_type=='no_club'
ggplot(na.omit(all[all$team_type=="no_club", ])) + 
  geom_bar(aes(x = satis_amount_recode, y = (..count..)/sum(..count..),
               position = "fill")) +
  labs(title = "Satisfaction with Amount of Play: Non-Chicago Club Players") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_discrete(drop=FALSE) +
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



# ------------- overall -------------

# overall satisfaction and inclusion histogram
overall.hist <- ggplot(data = all) +
  geom_bar(aes(overall))
overall.hist

# by team type
overall.team_type <- ggplot(data = all) +
  geom_bar(aes(overall)) +
  facet_grid(. ~ team_type)
overall.team_type

# means by team type
ggplot(means.by.team) +
  geom_bar(aes(x = team, y = mean_overall, fill = team_type), stat = "identity") +
  coord_cartesian(ylim = c(30, 50))

# just womens
# careful of the nemesis outlier (only nemesis player with age==4)
ggplot(all[all$team_type == "womens", ],
       aes(x = as.numeric(age), y = overall, colour = team)) + 
  geom_jitter() +
  geom_smooth(method = "lm", se = FALSE)

# barchart of mean overall by team type
# not currently right
# ggplot(all) + 
#   geom_bar(aes(x = team_type, y = mean(overall)), stat = "identity") 




# -------- age --------

# effect of age on satisfaction and inclusion
# jittered age (numeric) vs. overall w/ linear regression line superimposed
qplot(as.numeric(age), overall,
      data = all) +
  geom_jitter() +
  geom_smooth(method = "lm", se = FALSE)

# same including team type
# so mixed and no club women are driving the age effect on satisfaction and inclusion
qplot(as.numeric(age), overall, colour = team_type,
      data = all) +
  geom_jitter() +
  geom_smooth(method = "lm", se = FALSE)

# jittered age (ordinal) vs. overall w/ boxplot superimposed
qplot(age, overall, data = all) +
  geom_jitter() +
  geom_boxplot(alpha = 0.3)


# team demographics (need a better way to represent this)
# age_play_time <- ggplot(aes(team, age), data = all, na.rm = TRUE, stat=count) +
#   geom_point(aes(size = count)) # aes(colour = where_live, size = count)
# age_play_time




# ---- inclusion ----

incl_women_plot <- ggplot(aes(inclus_women), data = na.omit(all)) +
  geom_bar()
incl_women_plot

incl_mixed_plot <- ggplot(aes(inclus_mixed), data = na.omit(all)) +
  geom_bar()
incl_mixed_plot

incl_UC_plot <- ggplot(aes(inclus_UC), data = na.omit(all)) +
  geom_bar()
incl_UC_plot

incl_college_plot <- ggplot(aes(inclus_college), data = na.omit(all)) +
  geom_bar()
incl_college_plot


inc_blot <- ggplot(data = na.omit(all)) +
  geom_bar(aes(inclus_women), fill = "red")
  geom_bar(aes(inclus_mixed), fill = "blue")
inc_blot



incl_plot <- ggplot(aes(college), data = inclusion, na.rm=TRUE) +
  geom_bar(fill = "red", position="dodge") +
  geom_bar(aes(women), fill = "blue", position="dodge")
incl_plot


inclus_club.women <- ggplot(data = na.omit(all[all$team_type == "womens", ])) +
  geom_bar(aes(x = conn_club, fill = team))
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
  geom_bar(aes(team, fill = how_long_play), position = "fill") + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
womens_teams.how_long_play




# data jumble
ggplot(data = all_no_na) +
  geom_jitter(aes(how_long_play, satis_combined, colour = team_type)) +
  ggtitle("Combined Satisfaction by How Long People have Played") +
  labs(x = "How Long Played", y = "Combined Satisfaction") +
  theme_minimal()


ggplot(data = all_no_na) +
  geom_jitter(aes(how_long_play, satis_combined, colour = team_type)) +
  ggtitle("Combined Satisfaction by How Long People have Played") +
  labs(x = "How Long Played", y = "Combined Satisfaction") +
  theme_minimal()




# density plots

ggplot(data = all_no_na) +
  geom_density(aes(satis_combined, colour = team_type)) +
  theme_minimal()


# overall by start playing
ggplot(data = all_no_na) +
  geom_density(aes(overall, colour = start_playing)) +
  ggtitle("Overall Happiness by where Started Playing") +
  labs(x = "Overall Happiness", y = "Density") +
  theme_minimal()




