# summary stats

# make sure we're only using dplyr
detach(package:plyr)


# --------------- number of people -------------

# count number of people by team type
n_by_team_type <- all %>% 
  count(team_type)

n_by_team <- all %>% 
  count(team)

ggplot(n_by_team_type) + geom_bar(aes(team_type, n), stat = "identity")




# -------- calculate overall happiness --------
all <- all %>% 
  mutate(
    satis_combined = (as.numeric(satis_amount_recode) + as.numeric(satis_level_recode)),
    conn_combined = (as.numeric(conn_club) + as.numeric(conn_recreational) +
                       as.numeric(conn_college) + as.numeric(conn_youth)),
    inclus_combined = (as.numeric(inclus_UC) + as.numeric(inclus_college) + as.numeric(inclus_women) +
                         as.numeric(inclus_mixed)),
    overall = (satis_combined + conn_combined + inclus_combined)
  )

summary(all$overall)



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
    mean_satis = mean(satis_combined), 
    mean_conn = mean(conn_combined),
    mean_inclus = mean(inclus_combined),
    mean_overall = mean(overall)
  )
means.by.team



# get means for all aggregated variables
means_overall <- means.by.team %>% 
  ungroup() %>% 
  select(
    3:ncol(.)
  ) %>% 
  map_dbl(mean)








