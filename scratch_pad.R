
# sort_teams <- function(d, v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       d$team_type <- "womens"
#     } else if (t %in% mixed_teams) {
#       d$team_type <- "mixed"
#     } else {
#       d$team_type <- "no_team"
#     }
#   }
# }
# all$team_type <- sort_teams(all, all$team)
# 

# sort_teams <- function(v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       all$team_type <- "womens"
#     } else if (t %in% mixed_teams) {
#       all$team_type <- "mixed"
#     } else {
#       all$team_type <- "no_team"
#     }
#   }
# }
# all$team_type <- sort_teams(all$team)
# 
# 

# all$team_type2 <- "x"
#   
# sort_teams <- function(v) {
#   for (t in v) {
#     if (t %in% womens_teams) {
#       all$team_type2[t] <- "womens"
#       print(all$team_type2[t])
#     } else {
#       all$team_type2[t] <- "not"
#     }
#   }
# }
# 
# sort_teams(complete.cases(all$team))
# 
# 
# u1 <- rnorm(30)
# 
# usq <- 0
# 
# for(i in 1:10) {
#   usq[i] <- u1[i]*u1[i]
#   print(usq[i])
# }
# 
# 
# 
# usq[i] <- u1[i]*u1[i]
# print(usq[i])
# 
# all$team_type2 <- sort_teams(all$team)


