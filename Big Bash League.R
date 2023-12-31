library(cricketdata)
library(ggplot2)
library(dplyr)
library(ggrepel)

BBL <- fetch_cricsheet("bbb","male","bbl")
#Gathering the data from cricsheet using the package 'cricketdata'

Powerplay <- BBL %>%
  filter(season == "2022/23", over %in% c(1,2,3,4))
#filtering powerplay data

BowlingPP <- Powerplay %>%
  group_by(bowling_team) %>%
  summarize(
    Runs = sum(runs_off_bat) + sum(extras), BallsFaced = n() - sum(!is.na(wides)) - sum(!is.na(noballs)),
    StrikeRate = (Runs / BallsFaced)*100, Dots = sum(runs_off_bat == 0) ,
    Boundaries = sum(runs_off_bat %in% c(4,6)),
    Wickets = sum(wicket == TRUE)
  ) 
#Bowling Record in the powerplay

BowlingPP[c(3,7),] <- NA
BowlingPP[3,c(1:7)] = list("Hobart Hurricanes", 438, 330, (438/330)*100, 172, 63, 17)
BowlingPP[7,c(1:7)] = list("Sydney Sixers", 402, 366, (402/366)*100, 227, 54, 23)
#Two special cases due to rain curtailed games

BowlingPP$Dot_PCT <- BowlingPP$Dots * 100 / BowlingPP$BallsFaced
BowlingPP$Boundary_PCT <- BowlingPP$Boundaries * 100 / BowlingPP$BallsFaced
BowlingPP$BPW <- BowlingPP$BallsFaced / BowlingPP$Wickets
#Bowling Powerplay Record KPIs

BattingPP <- Powerplay %>%
  group_by(batting_team) %>%
  summarize(
    Runs = sum(runs_off_bat), BallsFaced = n() - sum(!is.na(wides)) - sum(!is.na(noballs)),
    StrikeRate = (Runs / BallsFaced)*100, Dots = sum(runs_off_bat == 0) ,
    Boundaries = sum(runs_off_bat %in% c(4,6)),
    Wickets = sum(wicket == TRUE)
  ) 
#Batting Record in the powerplay

BattingPP[c(2,3,7),] <- NA
BattingPP[2,c(1:7)] = list("Hobart Hurricanes", 425, 330, (425/330)*100, 172, 61, 16)
BattingPP[3,c(1:7)] = list("Brisbane Heat", 520, 420, (520/420)*100, 259, 85, 22)
BattingPP[7,c(1:7)] = list("Sydney Sixers", 418, 354, (418/354)*100, 180, 55, 16)
#Three special cases due to rain curtailed games

BattingPP$Dot_PCT <- BattingPP$Dots * 100 / BattingPP$BallsFaced
BattingPP$Boundary_PCT <- BattingPP$Boundaries * 100 / BattingPP$BallsFaced
BattingPP$BPW <- BattingPP$BallsFaced / BattingPP$Wickets
#Batting Powerplay Record KPIs

ggplot(BattingPP, aes(x = Dot_PCT,y = Boundary_PCT)) + 
  geom_point(colour="black", size = 3) +
  geom_point(data = BattingPP[6,], aes(x = Dot_PCT, y = Boundary_PCT), colour="#FF8C00", size = 5) + 
  xlab("Dot Ball Percentage") + ylab("Boundary Ball Percentage") + 
  ggtitle("Dots vs Boundary Comparison in Powerplay (Batting) - BBL 2022/23") + 
  theme(plot.title = element_text(hjust = 0.5)) + geom_text_repel(aes(label = batting_team))

AveragePPRuns <- (sum(BowlingPP$Runs) * 6/ sum(BowlingPP$BallsFaced))*4
AveragePPWickets <- 24/(sum(BowlingPP$BallsFaced) / sum(BowlingPP$Wickets))

ggplot(BowlingPP, aes(x = Dot_PCT,y = Boundary_PCT)) + 
  geom_point(colour="black", size = 3) +
  geom_point(data = BowlingPP[6,], aes(x = Dot_PCT, y = Boundary_PCT), colour="#FF8C00", size = 5) + 
  xlab("Dot Ball Percentage") + ylab("Boundary Ball Percentage") + 
  ggtitle("Dots vs Boundary Comparison in Powerplay (Bowling) - BBL 2022/23") + 
  theme(plot.title = element_text(hjust = 0.5)) + geom_text_repel(aes(label = bowling_team))

#Middle overs spin batting record
Middle_Overs_batting <- data.frame("Melbourne Stars",454,417,28,9,13)
colnames(Middle_Overs_batting) <- c("Team","Runs","Balls","Fours","Sixes","Wickets_Lost")
#All the data was obtained from 'Cricmetric'
Middle_Overs_batting[2,] <- c("Perth Scorchers",536,409,34,16,14)
Middle_Overs_batting[3,] <- c("Brisbane Heat",476,420,28,9,11)
Middle_Overs_batting[4,] <- c("Sydney Sixers",470,390,24,14,18)
Middle_Overs_batting[5,] <- c("Melbourne Renegades",426,365,24,17,17)
Middle_Overs_batting[6,] <- c("Adelaide Strikers",356,324,20,9,18)
Middle_Overs_batting[7,] <- c("Hobart Hurricanes",446,354,33,16,16)
Middle_Overs_batting[8,] <- c("Sydney Thunder",368,294,21,17,12)

Middle_Overs_batting$Runs <- as.numeric(Middle_Overs_batting$Runs)
Middle_Overs_batting$Balls <- as.numeric(Middle_Overs_batting$Balls)
Middle_Overs_batting$Fours <- as.numeric(Middle_Overs_batting$Fours)
Middle_Overs_batting$Sixes <- as.numeric(Middle_Overs_batting$Sixes)
Middle_Overs_batting$Wickets_Lost <- as.numeric(Middle_Overs_batting$Wickets_Lost)

Middle_Overs_batting$Average <- Middle_Overs_batting$Runs / (Middle_Overs_batting$Wickets_Lost)
Middle_Overs_batting$Strike_rate <- Middle_Overs_batting$Runs * 100 / Middle_Overs_batting$Balls
#Spin batting KPIs

ggplot(Middle_Overs_batting, aes(x = Average,y = Strike_rate)) + 
  geom_point(colour="black", size = 3) +
  geom_point(data = Middle_Overs_batting[2,], aes(x = Average, y = Strike_rate), colour="#FF8C00", size = 5) + 
  xlab("Average") + ylab("Strike Rate") + ggtitle("Average v Strike Rate against Spin: Overs 7-16 - BBL 2022/23") + 
  theme(plot.title = element_text(hjust = 0.5)) + geom_text_repel(aes(label = Team))

library(readxl)
Power_Surge <- read_excel("Project/Power Surge.xlsx", 
                          col_types = c("numeric", "numeric", "text", 
                                        "text", "numeric", "numeric", "numeric", 
                                        "numeric", "numeric", "numeric", 
                                        "numeric", "text", "text"))
View(Power_Surge)

Power_Surge$surge_win[Power_Surge$surge_win == "NA"] <- NA
Power_Surge$batting_team_win[Power_Surge$batting_team_win == "NA"] <- NA

data <- table(Power_Surge$surge_win, Power_Surge$batting_team_win)
chisq.test(data)
#Power Surge chi-square test

Surge <- Power_Surge %>%
  group_by(batting_team) %>%
  summarise(
    Runs = sum(runs, na.rm = TRUE), Balls = sum(balls, na.rm = TRUE), Boundaries = (sum(fours, na.rm = TRUE) + 
    sum(sixes, na.rm = TRUE)), Boundary_PCT = Boundaries * 100 / Balls, Dots = sum(dots, na.rm = TRUE)
  )
Surge$Dot_PCT <- Surge$Dots * 100 / Surge$Balls

Death <- BBL %>%
  filter(season == "2022/23", over %in% c(17,18,19,20))
#Filtering the death overs

BattingD <- Death %>%
  group_by(batting_team) %>%
  summarize(
    Runs = sum(runs_off_bat), BallsFaced = n() - sum(!is.na(wides)) - sum(!is.na(noballs)),
    StrikeRate = (Runs / BallsFaced)*100, DotPercent = sum(runs_off_bat == 0) * 100 / BallsFaced,
    BallsBoundary = BallsFaced / sum(runs_off_bat %in% c(4,6)),
    Wickets = sum(wicket == TRUE)
  ) 
#Batting Record at the death

BowlingD <- Death %>%
  group_by(bowling_team) %>%
  summarize(
    Runs = sum(runs_off_bat) + sum(extras), BallsFaced = n() - sum(!is.na(wides)) - sum(!is.na(noballs)),
    StrikeRate = (Runs / BallsFaced)*100, DotPercent = sum(runs_off_bat == 0) * 100 / BallsFaced,
    BallsBoundary = BallsFaced / sum(runs_off_bat %in% c(4,6)),
    Wickets = sum(wicket == TRUE),
    BPW = BallsFaced/Wickets
  ) 
#Bowling Record at the death

ggplot(BowlingD, aes(x = BallsBoundary, y = BPW)) + 
  geom_point(colour="black", size = 3) +
  geom_point(data = BowlingD[6,], aes(x = BallsBoundary, y = BPW), colour="#FF8C00", size = 5) + 
  xlab("Balls per Boundary") + ylab("Balls per Wicket") + 
  ggtitle("Wicket vs Boundary Comparison in Death Overs (Bowling) - BBL 2022/23") + 
  theme(plot.title = element_text(hjust = 0.5)) + geom_text_repel(aes(label = bowling_team))

Team = c("Strikers","Heat", "Hurricanes","Renegades","Stars","Scorchers","Sixers","Thunder")
SR_diff <- data.frame(Team, BattingD$StrikeRate, BowlingD$StrikeRate)
colnames(SR_diff) <- c("Team", "Runs_Scored_SR","Runs_conceeded_SR")
SR_diff$SR_differential <- SR_diff$Runs_Scored_SR - SR_diff$Runs_conceeded_SR
#Strike Rate differential

ggplot(SR_diff, 
       aes(x = reorder(Team, -SR_differential), 
           y = SR_differential, 
           fill = ifelse(Team == "Scorchers", "H", "N") )) + 
  geom_bar(stat = "identity") + 
  scale_fill_manual("legend", values = c("H" = "#FF8C00", "N" = "black")) +
  theme(legend.position = "none") + xlab("") + ylab("Strike Rate differential") + 
  ggtitle("Strike Rate Difference Between Runs Scored and Runs Conceeded - BBL 2022/23") + 
  theme(plot.title = element_text(hjust = 0.5))

Home_PCT <- data.frame(Team = c("Scorchers","Hurricanes","Sixers","Renegades","Strikers","Heat","Thunder","Stars"), 
                       Home_Wins_PCT = c(86, 86, 100, 71, 57,57,57,29))
Home_PCT <- Home_PCT %>% arrange(desc(Home_Wins_PCT))
#Home win/loss record

ggplot(Home_PCT, 
       aes(x = reorder(Team, -Home_Wins_PCT), 
           y = Home_Wins_PCT, 
           fill = ifelse(Team == "Scorchers", "H", "N") )) + 
  geom_bar(stat = "identity") + 
  scale_fill_manual("legend", values = c("H" = "#FF8C00", "N" = "black")) +
  theme(legend.position = "none") + xlab("") + ylab("Percentage of Home Wins") + 
  ggtitle("Completed Home Game Wins Percentage - BBL 2022/23 League Stage") + 
  theme(plot.title = element_text(hjust = 0.5))

Surge_PCT <- data.frame(Team = c("Scorchers","Hurricanes","Sixers","Renegades","Strikers","Heat","Thunder","Stars"), 
                        Surge_outscoring_PCT = c(92,36,33,50,45,47,75,33))
#Surge Outscoring record

ggplot(Surge_PCT, 
       aes(x = reorder(Team, -Surge_outscoring_PCT), 
           y = Surge_outscoring_PCT, 
           fill = ifelse(Team == "Scorchers", "H", "N") )) + 
  geom_bar(stat = "identity") + 
  scale_fill_manual("legend", values = c("H" = "#FF8C00", "N" = "black")) +
  theme(legend.position = "none") + xlab("") + ylab("Outscoring the opponent (in %)") + 
  ggtitle("Outscoring the opponent in Power Surge - BBL 2022/23") + 
  theme(plot.title = element_text(hjust = 0.5))