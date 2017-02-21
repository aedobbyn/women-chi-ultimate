
source("./munge.R")



# Unsupervised cluster analyses: are there natural clusters in the data? How do they map
# to our hypothesis that the two clusters to be found are based on whether you play club
# or not?


# ------ kmeans ------

# Hypothesis: unsupervised clustering into two groups --> group fault line will be the club vs. no_club divide
# into three groups --> clusters will mainly represent the three team_types
# Dependent variable = overall

# get a dataset with only complete cases
all_no_na <- all[complete.cases(all), ]

# remove the one row with a missing value
# keep only predictor vars (not outcome vars) that aren't team and team_type (because that's what we think
# will determine in some part which clusters people fall into)
dat_for_clustering <- all[complete.cases(all), ] %>% 
  select(
    age, where_live, currently_playing, how_long_play, start_playing, first_experience,
    overall
  )

dat_for_clustering <- as_tibble(dat_for_clustering)

# scale the data
numeric_dat <- as_tibble(sapply(dat_for_clustering, as.numeric))
scaled_dat <- as_tibble(scale(numeric_dat))


# from the pared dataset, cluster people based on their "overall" ratings in first
# two, then three clusters.
# this returns an objet of class kmeans. do str(clusters_two) to see what's in here.
set.seed(10) # for reproducibility
clusters_two <- kmeans(scaled_dat$overall, centers = 2, iter.max = 15, nstart = 20)
clusters_three <- kmeans(scaled_dat$overall, centers = 3, iter.max = 15, nstart = 20)


# look at a table of dat broken into two clusters compared to club or not
table(clusters_two$cluster, all_no_na$club_or_not)
# so club got looped into mostly 2, and not_club is mostly 1

# same but three clusters compared to team_type
table(clusters_three$cluster, all_no_na$team_type)
# based on this,
# no_club = 1 and 3; mixed = 1; womens = 1
# so the differentiator is that of 2s, most of them are no_club. 1 is a mixed bag


# cbind the cluster portion of these two the df with no NAs, plus the variables that had team indicators (i.e.,
# club_or_not, team_type, and team) that we had taken out originally
cluster_dat <- as_tibble(data.frame(scaled_dat, 
                          club_or_not = all_no_na$club_or_not,
                          team_type = all_no_na$team_type,
                          team = all_no_na$team,
                          clusters_two = factor(clusters_two$cluster),
                          clusters_three = factor(clusters_three$cluster)))




# ------- plot
# try to get an abline / smooth in there

# ------- with groups (team, team_type, etc.) as the fill ------

# without jitter, without boxplot
ggplot(data = cluster_dat, 
       aes(x = clusters_two, y = overall, colour = team_type)) + 
  geom_point() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups -- No Team Indicators") +
  labs(x = "Cluster", y = "Overall Happiness") +
  theme_minimal()

# without boxplot
ggplot(data = cluster_dat, 
       aes(x = clusters_two, y = overall, colour = team_type)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups -- No Team Indicators") +
  labs(x = "Cluster", y = "Overall Happiness") +
  theme_minimal()

# with boxplot overlaid
ggplot(data = cluster_dat, 
       aes(x = clusters_two, y = overall, colour = team_type)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups -- No Team Indicators") +
  labs(x = "Cluster", y = "Overall Happiness") +
  geom_boxplot(alpha = 0.3) +
  theme_minimal()

# team as grouper
ggplot(data = cluster_dat, 
       aes(x = clusters_two, y = overall, colour = team)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups -- No Team Indicators") +
  labs(x = "Cluster", y = "Overall Happiness") +
  # geom_boxplot(data = all_no_team_indics, aes(overall)) +
  theme_minimal()


# ------- with clusters as the fill ------

ggplot(data = cluster_dat,    
       aes(x = team_type, y = overall, colour = clusters_two)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Two Groups", subtitle = "No Team Indicators") +
  labs(x = "Team Type", y = "Overall Happiness") +
  # geom_boxplot(alpha = 0.3) +
  theme_minimal()


ggplot(data = cluster_dat, 
       aes(x = team_type, y = overall, colour = clusters_three)) + 
  geom_jitter() +
  ggtitle("Unsupervised Clustering of Overall Scores into Three Groups -- No Team Indicators") +
  labs(x = "Team Type", y = "Overall Happiness") +
  theme_minimal()







# -------- validate: not done yet --------

# give numeric values that we think correspond to how the algorithm is clustering people
all_no_na_2 <- all_no_na %>% 
  mutate(
    club_or_not_num = ifelse(club_or_not == "not_club", 1, 2),   # not_club = 1, club = 2
    team_type_num = ifelse(team_type == "no_club", 
                           2, ifelse(team_type == "womens", 3, 1))   # mixed = 1, no_club = 2, womens = 3
  )


# compare how well kmeans did compared to actual

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
all_no_na_3




# ------------------ Hierarchical Clustering -------------------

# Dependent vars: satisfaction amount and satisfaction level
# Grouping vars: team, team_type, or where_live


do_cluster_satis <- function(grouping_var) {
  hc <- all %>%
    group_by_(grouping_var) %>% 
    summarise(
      s_amount = mean(as.numeric(satis_amount_recode)), 
      s_level = mean(as.numeric(satis_level_recode))
    )
  
  # put team names as rownames and take out the team column
  hc <- data.frame(hc)
  rownames(hc) <- hc[[grouping_var]]
  hc <- as_tibble(hc[, 2:ncol(hc)])
  
  # scale the variables of interest (everything except team, which was included in the group_by)
  scale_vars <- function(dat) {
    vars <- dat[, 1:ncol(dat)]
    for (row in vars) {
      var_scaled <- scale(row)
      dat <- data.frame(dat, var_scaled = var_scaled)
    }
    dat
  }
  hc <- scale_vars(hc)
  
  # change the new names to something meaningful (try to get this in the function)
  names(hc)[3:4] <- c("s_amount_scaled", "s_level_scaled")
  
  hc_dist <- dist(hc[3:4])
  hc_fit <- hclust(hc_dist, method = "centroid")
  
  # plot the cluster
  plot(hc_fit, hang = -1, cex = 0.8, srt = 60,
       main = paste0("Cluster based on Satisfaction Amount and Satisfaction Level Per ", grouping_var),
       xlab = "Groups", 
       ylab = "")
  
  # what's the best number of clusters to divide the data into?
  # only run this if there are enough groups to cluster on (i.e., more than 3)
  library(NbClust)
  if (nrow(hc) > 3) {
    num_clust <- NbClust(hc[3:4], min.nc = 2,
                         max.nc = max(6, (nrow(hc) - 4)),   # set max number of clusters to less than number of groups
                         method = "average")
    # depends on what method used and what the max.nc is set to
  }
}

# cluster based on factor variables we think might predict differences in satisfaction amount and level
do_cluster_satis("where_live")
do_cluster_satis("team")
do_cluster_satis("team_type")




# --------------- if need to do this outside the function with team as the grouper -----------

hc_team <- all %>%
  group_by(team) %>% 
  summarise(
    s_amount = mean(as.numeric(satis_amount_recode)), 
    s_level = mean(as.numeric(satis_level_recode))
  )

# put team names as rownames and take out the team column so that rows in plot will have team names
hc_team <- data.frame(hc_team)
rownames(hc_team) <- hc_team[["team"]]
hc_team <- as_tibble(hc_team[, 2:ncol(hc_team)])

# scale the variables of interest (everything except team, which was included in the group_by)
scale_vars <- function(dat) {
  vars <- dat[, 1:ncol(dat)]
  for (row in vars) {
    var_scaled <- scale(row)
    dat <- data.frame(dat, var_scaled = var_scaled)
  }
  dat
}
hc_team <- scale_vars(hc_team)

# change the new names to something meaningful (try to get this in the function)
names(hc_team)[3:4] <- c("s_amount_scaled", "s_level_scaled")

hc_team_dist <- dist(hc_team[3:4])
hc_team_fit <- hclust(hc_team_dist, method = "centroid")

# plot the cluster
plot(hc_team_fit, hang = -1, cex = 0.8, srt = 60,
     main = paste0("Cluster based on Satisfaction Amount and Satisfaction Level Per Team"),
     xlab = "Groups", 
     ylab = "")

# get optimal number of clusters
num_clust <- NbClust(hc_team[3:4], min.nc = 2,
                     max.nc = 8,   # set max number of clusters to less than number of groups
                     method = "centroid")





# cluster based on mean inclusion and connectedness
do_cluster_inclus_conn <- function(grouping_var) {
  hc <- all %>%
    na.omit(.) %>% 
    group_by_(grouping_var) %>% 
    summarise(
      inclus_mean = mean(as.numeric(inclus_combined)), 
      conn_mean = mean(as.numeric(conn_combined))
    )
  
  # put grouping var names as rownames and take out the grouping var column
  hc <- data.frame(hc)
  rownames(hc) <- hc[[grouping_var]]
  hc <- as_tibble(hc[, 2:ncol(hc)])
  
  # scale the variables of interest (everything except team, which was included in the group_by)
  scale_vars <- function(dat) {
    vars <- dat[, 1:ncol(dat)]
    for (row in vars) {
      var_scaled <- scale(row)
      dat <- data.frame(dat, var_scaled = var_scaled)
    }
    dat
  }
  hc <- scale_vars(hc)
  
  # change the new names to something meaningful (try to get this in the function)
  names(hc)[3:4] <- c("inclus_mean", "conn_mean")
  
  hc_dist <- dist(hc[3:4])
  hc_fit <- hclust(hc_dist, method = "centroid")
  
  # plot the cluster
  plot(hc_fit, hang = -1, cex = 0.8, srt = 60,
       main = paste0("Hierarchical Cluster based on \n Inclusion and Connectedness Per ", capitalize_this(grouping_var)),
       xlab = "Groups", 
       ylab = "")
}

do_cluster_inclus_conn("age")
do_cluster_inclus_conn("team_type")
do_cluster_inclus_conn("start_playing")
do_cluster_inclus_conn("currently_playing")









# -- cluster w/ more 

scaled_dat


# dat_cluster <- function(grouping_var, dat) {
#   hc <- dat %>%
#     na.omit(.)
#     # group_by_(grouping_var) %>% 
#     # summarise(
#     #   inclus_mean = mean(as.numeric(inclus_combined)), 
#     #   conn_mean = mean(as.numeric(conn_combined))
#     # )
#   
#   # put grouping var names as rownames and take out the grouping var column
#   hc <- data.frame(hc)
#   rownames(hc) <- hc[[grouping_var]]
#   hc <- as_tibble(hc[, 2:ncol(hc)])
#   
#   # scale the variables of interest (everything except team, which was included in the group_by)
#   scale_vars <- function(dat) {
#     vars <- dat[, 1:ncol(dat)]
#     for (row in vars) {
#       var_scaled <- scale(row)
#       dat <- data.frame(dat, var_scaled = var_scaled)
#     }
#     dat
#   }
#   hc <- scale_vars(hc)
#   
#   # change the new names to something meaningful (try to get this in the function)
#   names(hc)[3:4] <- c("inclus_mean", "conn_mean")
#   
#   hc_dist <- dist(hc[3:4])
#   hc_fit <- hclust(hc_dist, method = "centroid")
#   
#   # plot the cluster
#   plot(hc_fit, hang = -1, cex = 0.8, srt = 60,
#        main = paste0("Hierarchical Cluster based on \n Inclusion and Connectedness Per ", capitalize_this(grouping_var)),
#        xlab = "Groups", 
#        ylab = "")
# }
# 
# 
# 
# dat_cluster()











hc_team <- scaled_dat %>%
  na.omit(.)

# put team names as rownames and take out the team column so that rows in plot will have team names
# hc_team <- data.frame(hc_team)
# rownames(hc_team) <- hc_team[["team"]]
# hc_team <- as_tibble(hc_team[, 2:ncol(hc_team)])

# scale the variables of interest (everything except team, which was included in the group_by)
# scale_vars <- function(dat) {
#   vars <- dat[, 1:ncol(dat)]
#   for (row in vars) {
#     var_scaled <- scale(row)
#     dat <- data.frame(dat, var_scaled = var_scaled)
#   }
#   dat
# }
# hc_team <- scale_vars(hc_team)

# change the new names to something meaningful (try to get this in the function)
# names(hc_team)[3:4] <- c("s_amount_scaled", "s_level_scaled")

hc_team_dist <- dist(hc_team[1:(nrow(hc_team) - 1)])
hc_team_fit <- hclust(hc_team_dist, method = "centroid")

# plot the cluster
plot(hc_team_fit, hang = -1, cex = 0.8, srt = 60,
     main = paste0("Cluster based on Satisfaction Amount and Satisfaction Level Per Team"),
     xlab = "Groups", 
     ylab = "")

# get optimal number of clusters
num_clust <- NbClust(hc_team[3:4], min.nc = 2,
                     max.nc = 8,   # set max number of clusters to less than number of groups
                     method = "centroid")






