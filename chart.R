
source("./munge.R")

# make histogram of age distribution
age_hist <- ggplot(aes(age), data = demographics) +
  geom_bar()
age_hist


# make histogram of team distribution
team_hist <- ggplot(aes(team), data = demographics) +
  geom_bar()
team_hist

# team demographics (need a better way to represent this)
age_play_time <- ggplot(aes(team, age), data = demographics, na.rm = TRUE, stat=count) +
  geom_point() # aes(colour = where_live, size = count)
age_play_time






dev_incl_plot <- ggplot(aes(women), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(mixed), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(UC), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(college), data = na.omit(dev_inclusion)) +
  geom_bar()
dev_incl_plot

dev_incl_plot <- ggplot(aes(college), data = dev_inclusion, na.rm=TRUE) +
  geom_bar(fill = "red", position="dodge") +
  geom_bar(aes(women), fill = "blue", position="dodge")
dev_incl_plot



# club or not barchart
club.or.not <- ggplot(aes(team_type), data = na.omit(demogr_inclus)) +
  geom_bar(position = "dodge")
club.or.not
