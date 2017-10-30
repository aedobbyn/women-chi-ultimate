

# differentiate variable names in different mini datasets by appending 
# dataset name to beginning of var name
# names(satisfaction) <- paste0("satis_", names(satisfaction))
# names(inclusion) <- paste0("inclus_", names(inclusion))



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






# satis_level.prop.team_type <- ggplot(data = na.omit(all)) +
#   geom_bar(aes(x = satis_level_recode, fill = team_type), 
#            position = "dodge", y = ..density..) +
#   theme(axis.text.x = element_text(angle = 60, hjust = 1))
# satis_level.prop.team_types









# capitalize_this_tbl2 <- function(df, vec) {
#   df2 <- as_tibble(df) %>% mutate(bar = vec)
#   out <- vector()
#   for (i in df[[bar]]) {
#     if (grepl(pattern = "_", x = i) == TRUE) {
#       i <- simpleCap(gsub(x = i, pattern = "_", replacement = " "))
#     } else {
#       i <- capitalize(i)
#     }
#     out <- c(out, i)
#   }
#   out
#   # cbind(df2, out)
# }
# 
# foo <- as_tibble(all) %>%
#   select(team_type, team) %>% 
#   mutate(
#     bar = team_type
#   )
# foo
# capitalize_this_tbl2(foo, "team_type")




# foo <- get_table("team_type")
# ggplot(foo) + geom_bar(aes(capitalize_this(team_type), n, label = n), stat = "identity") + theme_minimal() +
#   ggtitle(paste0("Breakdown by Team Type")) +
#   labs(x = "Team Type", y = "Count") +
#   geom_text(aes(team_type, y=n), position=position_dodge(width=0.9), vjust=-0.25)


