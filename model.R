

# ---- models -----

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


# regular lm doesn't work
m.UC.team_type.2 <- lm(UC ~ team_type,
                       data = demogr_inclus)