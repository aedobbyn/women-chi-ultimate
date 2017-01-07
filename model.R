
# in ordered logit models, t value is ratio of coefficient:std.error
# variable.L is the linear effect of the predictor variable on the response variable. 
# variable.Q is the quadratic.

# library(MASS)


# - - - - omnibus - - - - 
# what is the effect of all non-ordinal predictors on overall 
m.big <- lm(overall ~ 
              age + team + 
              currently_playing + how_long_play, 
            # start_playing,
            data = all)
summary(m.big)



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




