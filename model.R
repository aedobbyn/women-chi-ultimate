
# in ordered logit models, t value is ratio of coefficient:std.error
# variable.L is the linear effect of the predictor variable on the response variable. 
# variable.Q is the quadratic.



# ----------------- 
# omnibus 
m.big <- lm(overall ~ 
              age + team_type + currently_playing + how_long_play, data = all)
summary(m.big)
# being on a women's or mixed team makes you significantly happier.



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






# ordinal logistic: does age predict team_type?
m.team_type.age <- MASS::polr(team_type ~ age,
                              data = demogr_inclus)
summary(m.team_type.age)


# probit: does age predict team_type?
m.club_or_not.age <- glm(club_or_not ~ age,
                         data = demogr_inclus,
                         family=binomial(link="probit"))
summary(m.club_or_not.age)


# ordinal logistic: does team type predict satisfaction with UC?
m.UC.team_type <- MASS::polr(UC ~ team_type,
                             data = demogr_inclus)
summary(m.UC.team)






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





