

# ---- models -----

# omnibus 
m.big <- lm(satis_and_inclus_combined ~ 
              age + team_type + currently_playing + how_long_play, data = all)
summary(m.big)
# being on a women's or mixed team makes you significantly happier.


# does team type predict how included people feel women are
m.inclus_women.team_type <- MASS::polr(inclus_women ~ team_type, 
                                       data = all,
                                       Hess = TRUE)

sum.m.inclus_women.team_type <- coef(summary(m.inclus_women.team_type))

p.m.inclus_women.team_type <- pnorm(abs(sum.m.inclus_women.team_type[, "t value"]), lower.tail = FALSE) * 2

## combined table
(full.inclus_women.team_type <- cbind(p.m.inclus_women.team_type, "p value" = p.m.inclus_women.team_type))









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
# both womens and mixed players have overall higher satisfaction and inclusion than non-club players
m.satis_combined.team_type <- lm(satis_combined ~ team_type,
                       data = all)
summary(m.satis_combined.team_type)

# same
m.inclus_combined.team_type <- lm(inclus_combined ~ team_type,
                                 data = all)
summary(m.inclus_combined.team_type)

# same
m.satis_and_inclus_combined.team_type <- lm(satis_and_inclus_combined ~ team_type,
                                  data = all)
summary(m.satis_and_inclus_combined.team_type)


# is there a signif difference in combined satisfaction and inclusion scores between womens and mixed players?
# no, p = 0.841
womens_and_mixed.m.satis_and_inclus_combined.team_type <- lm(satis_and_inclus_combined ~ team_type,
                                            data = all[all$team_type %in% c("womens", "mixed"), ])
summary(womens_and_mixed.m.satis_and_inclus_combined.team_type)



# ------------------ by team ---------------------
# is one team the happiest?
# non-club is significantly the unhappiest. 
m.satis_combined.team <- lm(satis_combined ~ team,
                                       data = all)
summary(m.satis_combined.team)

# "Other" feels significantly the least happy. Shakedown is marginally happy.
m.inclus_combined.team <- lm(inclus_combined ~ team,
                            data = all)
summary(m.inclus_combined.team)

# non-club is significantly the unhappiest. "Other" is marginally unhappy. 
m.satis_and_inclus_combined.team <- lm(satis_and_inclus_combined ~ team,
                                            data = all)
summary(m.satis_and_inclus_combined.team)





