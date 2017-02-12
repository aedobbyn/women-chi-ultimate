
# in ordered logit models, t value is ratio of coefficient:std.error
# variable.L is the linear effect of the predictor variable on the response variable. 
# variable.Q is the quadratic.

# library(MASS)

source("./munge.R")


# - - - - omnibus - - - - 
# what is the effect of all predictors on overall?
# team_type and where_live are not ordered, the rest are
m.big <- lm(overall ~ 
            age + team_type + 
            currently_playing + 
            how_long_play + 
            start_playing +
            where_live,
            data = all)
summary(m.big)

# effect of just team on overall
m.team <- lm(overall ~ 
              team,
            data = all)
summary(m.team)

# try single predictor predicting overall
m.x <- lm(overall ~ 
               team,
             data = all)
summary(m.x)


# all predictors on combined satisfaction
m.allpreds.satis <- lm(satis_combined ~ 
                     age + team_type + 
                     currently_playing + 
                     how_long_play + 
                     start_playing +
                     where_live,
                   data = all)
tidy(summary(m.allpreds.satis))

# all predictors on combined connectedness
m.allpreds.conn <- lm(conn_combined ~ 
                         age + team_type + 
                         currently_playing + 
                         how_long_play + 
                         start_playing +
                         where_live,
                       data = all)
summary(m.allpreds.conn)

# all predictors on combined inclusion
m.allpreds.inclus <- lm(inclus_combined ~ 
                         age + team_type + 
                         currently_playing + 
                         how_long_play + 
                         start_playing +
                         where_live,
                       data = all)
summary(m.allpreds.inclus)



# being on a women's or mixed team makes you significantly happier.
# no other big findings from this
# - - - - - - - - - - - - 


# ANOVA
summary(aov(overall ~ 
            age + team_type + currently_playing + how_long_play, 
            data = all))
# age and team type are signif

# linear age model
# make age numeric, no longer an ordinal factor
age.fit <- lm(overall ~ as.numeric(age), data = all)
summary(age.fit)
# so in a linear model older -> less happy




# ----------- ordered logit/probit regressions ---------------

# ------------------ *** example for calculating p values in case need to *** -------------------------------------- 
# does team type predict how included people feel women are
m.inclus_women.team_type <- MASS::polr(inclus_women ~ team_type, 
                                       data = all,
                                       Hess = TRUE)

# if need to calculate p values
# save the model's coefficients and t-values, calculate the p values associated with them, and stitch
# those back onto the 
sum.m.inclus_women.team_type <- coef(summary(m.inclus_women.team_type))
p.m.inclus_women.team_type <- pnorm(abs(sum.m.inclus_women.team_type[, "t value"]), lower.tail = FALSE) * 2
(full.inclus_women.team_type <- cbind(sum.m.inclus_women.team_type, "p value" = p.m.inclus_women.team_type))


# conf int
# if the int is outside 0, reject the null
(conf.m.inclus_women.team_type <- confint(m.inclus_women.team_type))

# ---------------------------------------------------------------------------------------------------------------- 



# ordinal logistic: does age predict team_type?
m.team_type.age <- MASS::polr(team_type ~ age, 
                              data = all, 
                              Hess = TRUE)
summary(m.team_type.age)


# probit: does age predict team_type?
m.club_or_not.age <- glm(club_or_not ~ age,
                         data = all,
                         family=binomial(link="probit"))
summary(m.club_or_not.age)


# ordinal logistic: does team type predict satisfaction with UC?
m.UC.team_type <- MASS::polr(inclus_UC ~ team_type,
                             data = all,
                             Hess = TRUE)
summary(m.UC.team_type)


# ------
# try anova() to see whether team_type is signif
library(ordinal)

# ------- with team_type and age predicting satis_level_recode --------
m.team_t <- clm(satis_level_recode ~ team_type + age,
                link = "probit",
                       data = all)

# take out team type
m.no.team_t <- clm(satis_level_recode ~ age,
                   link = "probit",
                       data = all)

# compare models
anova(m.team_t, m.no.team_t)
# model with team type does't predict satisfaction level better than the one without it
# probit and logit linking functions yield roughly the same chisq


# ------- with team_type and age predicting satis_amount_recode ------- 
m.team_t <- clm(satis_amount_recode ~ team_type + age,
                link = "probit",
                data = all)
m.no.team_t <- clm(satis_amount_recode ~ age,
                   link = "probit",
                   data = all)
anova(m.team_t, m.no.team_t)
# model with team type DOES predict satisfaction level better than the one without it (p = 0.0072)


# ------




# ------------------ by team_type ---------------------
# predict overall satisfaction, inclusion, and both from team type
# no_club is reference level, coded as 1
# mixed coded as 2
# womens coded as 3

# both womens and mixed players have overall higher satisfaction and inclusion than non-club players

# p = 0.0252
m.satis_combined.team_type <- lm(satis_combined ~ team_type,
                       data = all)
summary(m.satis_combined.team_type)

# p = 1.17e-07
m.conn_combined.team_type <- lm(conn_combined ~ team_type,
                                 data = all)
summary(m.conn_combined.team_type)

# p = 0.00245
m.inclus_combined.team_type <- lm(inclus_combined ~ team_type,
                                 data = all)
summary(m.inclus_combined.team_type)

# p = 2.82e-07
m.overall.team_type <- lm(overall ~ team_type,
                                  data = all)
summary(m.overall.team_type)



# is there a signif difference in combined satisfaction and inclusion scores between womens and mixed players?
# no, p = 0.841
womens_and_mixed.m.overall.team_type <- lm(overall ~ team_type,
                                            data = all[all$team_type %in% c("womens", "mixed"), ])
summary(womens_and_mixed.m.overall.team_type)


# ---- by club_or_not

m.overall.club_or_not <- lm(overall ~ club_or_not,
                             # family = "binomial",
                          data = all)
summary(m.overall.club_or_not)


# ------------------ by team ---------------------
# is one team the most satisfied with amount and level of play?
# nope
m.satis_combined.team <- lm(satis_combined ~ team,
                                       data = all)
summary(m.satis_combined.team)


# does one group feel the least/most connected?
# non-club feels significantly less connected 
m.conn_combined.team <- lm(conn_combined ~ team,
                            data = all)
summary(m.conn_combined.team)


# "Other" feels significantly the least happy. Shakedown is marginally happy.
m.inclus_combined.team <- lm(inclus_combined ~ team,
                            data = all)
summary(m.inclus_combined.team)

# non-club is significantly the unhappiest. "Other" is marginally unhappy. 
m.overall.team <- lm(overall ~ team,
                                            data = all)
summary(m.overall.team)




# ---- preds ---

# predict overall values for each row based on the model m.big and save them in the object preds.m.big
preds.m.big <- predict(m.big, na.rm = FALSE)
# add another element to this vector (the mean) so that we end up with the right number of rows 
preds.m.big <- c(preds.m.big, mean(preds.m.big))
# add these predictions as a new column to the df
all <- cbind(all, preds.m.big)



# predict overall from just team_type (much less variation here)
preds_overall.team_type <- predict(m.overall.team_type)
all <- cbind(all, preds_overall.team_type)





# ------ kmeans ------

# Hypothesis: unsupervised clustering into two groups --> group fault line will be the club vs. no_club divide
# into three groups --> clusters will mainly represent the three team_types

# remove the one NA case, who dis?
# keep only predictor vars (not outcome vars) that aren't team and team_type (because that's what we think
# will determine in some part which clusters people fall into)
cluster_dat <- all[complete.cases(all), ] %>% 
  select(
    age, where_live, currently_playing, how_long_play, start_playing, first_experience,
    overall
  )


# scale the data?
# take out outliers?


# from a dataset without NAs, cluster people based on their "overall" ratings in first
# two, then three clusters.
# this returns an objet of class kmeans. do str(clusters_two) to see what's in here.
set.seed(10)
clusters_two <- kmeans(cluster_dat$overall, centers = 2, iter.max = 15, nstart = 20)
clusters_three <- kmeans(cluster_dat$overall, centers = 3, iter.max = 15, nstart = 20)


# look at a table of dat broken into two clusters compared to club or not
table(clusters_two$cluster, all_no_na$club_or_not)
# so club got looped into mostly 2, and not_club is mostly 1

# same but three clusters compared to team_type
table(clusters_three$cluster, all_no_na$team_type)
# based on this,
# no_club = 1 and 3
# mixed = 1
# womens = 1
# so the differentiator is that of 2s, most of them are no_club. 1 is a mixed bag


# cbind the cluster portion of these two the df with no NAs
cluster_dat <- data.frame(cluster_dat, 
                        clusters_two = factor(clusters_two$cluster),
                        clusters_three = factor(clusters_three$cluster))


# plot
ggplot(data = all_no_na, 
       aes(club_or_not, overall, color = clusters_two)) + 
  geom_point() +
  ggtitle("Unsupervised Clustering of Overall Scores into Three Groups") +
  labs(x = "Team Type", y = "Overall Happiness")



# not jittered, two clusters
ggplot(data = all_no_na, 
       aes(x = team_type, y = overall, colour = clusters_three)) + 
  geom_point() +
  ggtitle("Unsupervised Clustering of Overall Scores into Three Groups") +
  labs(x = "Team Type", y = "Overall Happiness")


# jittered
ggplot(data = all_no_na, 
       aes(x = team_type, y = overall, colour = clusters_three)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Three Groups") +
  labs(x = "Team Type", y = "Overall Happiness") +
  theme_minimal()










# try the same with no team indicators

all_no_team_indics <- all[complete.cases(all), ] %>% 
  select(
    -c(team, team_type)
  )


set.seed(11)
clusters_two_x <- kmeans(all_no_team_indics$overall, centers = 2, iter.max = 15, nstart = 20)
clusters_three_x <- kmeans(all_no_team_indics$overall, centers = 3, iter.max = 15, nstart = 20)


all_no_team_indics <- data.frame(all_no_team_indics, 
                        club_or_not = all_no_na$club_or_not,
                        team_type = all_no_na$team_type,
                        clusters_two_x = clusters_two$cluster,
                        clusters_three_x = clusters_three$cluster)


# ------ without team indicators

# try to get an abline / smooth in there

# 
ggplot(data = all_no_team_indics,    
       aes(x = team_type, y = overall, colour = factor(clusters_two))) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups", subtitle = "No Team Indicators") +
  labs(x = "Team Type", y = "Overall Happiness") +
  geom_boxplot(alpha = 0.3) +
  theme_minimal()


ggplot(data = all_no_team_indics, 
       aes(x =  factor(clusters_two), y = overall, colour = team_type)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups -- No Team Indicators") +
  labs(x = "Cluster", y = "Overall Happiness") +
  geom_boxplot(alpha = 0.5) +
  theme_minimal()


ggplot(data = all_no_team_indics, 
       aes(x =  factor(clusters_two), y = overall, colour = team)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups -- No Team Indicators") +
  labs(x = "Cluster", y = "Overall Happiness") +
  # geom_boxplot(data = all_no_team_indics, aes(overall)) +
  theme_minimal()


ggplot(data = all_no_team_indics, 
       aes(x = team_type, y = overall, colour = factor(clusters_three))) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Three Groups -- No Team Indicators") +
  labs(x = "Team Type", y = "Overall Happiness") +
  geom_boxplot(data = all_no_team_indics, aes(overall)) +
  theme_minimal()










# give numeric values that we think correspond to how the algorithm is clustering people
all_no_na_2 <- all_no_na %>% 
  mutate(
    club_or_not_num = ifelse(club_or_not == "not_club", 1, 2),   # not_club = 1, club = 2
    team_type_num = ifelse(team_type == "no_club", 
                           2, ifelse(team_type == "womens", 3, 1))   # mixed = 1, no_club = 2, womens = 3
  )


# compare how well kmeans did compard to actual

# all_no_na_4 <- all_no_na %>% 
#   mutate(
#     good



# same as above for not_club or club, just more programmatically (& verbose :/)
real_cluster <- function(dat) {
  for (i in seq_along(dat[["club_or_not"]])) {
    if (dat[["club_or_not"]][i] == "not_club") {
      dat[["club_or_not_num"]][i] <- 1
    } else if (dat[["club_or_not"]][i] == "club") {
      dat[["club_or_not_num"]][i] <- 2
    }
  }
  as.tbl(data.frame(dat, dat[["club_or_not_num"]]))
}

all_no_na_3 <- real_cluster(all_no_na)






# by team

hc_try <- all %>%
  select(team, overall) %>%
  group_by(team) %>%
  summarise(
    m_overall = mean(overall)
)

rownames(hc_try) <- levels(all$team)



overall_scaled <- scale(hc_try$m_overall)
overall_dist <- dist(overall_scaled)

hc_fit <- hclust(overall_dist, method = "centroid")

plot(hc_fit, hang = -1, cex = 0.8)





hc_try_2 <- all %>%
  group_by(team) %>% 
  summarise(
    # age, where_live, currently_playing, how_long_play, start_playing, first_experience,
    s_amount = mean(as.numeric(satis_amount_recode)), 
    s_level = mean(as.numeric(satis_level_recode))
  )


scale_vars <- function(dat) {
  vars <- dat[, 2:3]
  for (var in vars) {
    print(var[1])
    var_scaled <- scale(var)
    dat <- data.frame(dat, "new" = var_scaled)
  }
  dat
}

hc_2 <- scale_vars(hc_try_2)


# same as:
hc <- apply(hc_try_2[, 2:3], 2, scale)



