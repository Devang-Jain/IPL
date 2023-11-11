-- Matches Per season
SELECT YEAR(date) AS season, COUNT(id) AS matches_per_season
FROM IPL..match
GROUP BY YEAR(date)
ORDER BY season;

--Most Player of the match
SELECT top 3 player_of_match, COUNT(player_of_match) AS num_awards
FROM ipl..match
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY num_awards DESC;

--Most Player of the match by season
SELECT 
    YEAR(date) AS season,
    player_of_match,
    COUNT(player_of_match) AS num_awards
FROM ipl..match
WHERE player_of_match IS NOT NULL
GROUP BY YEAR(date), player_of_match
ORDER BY season, num_awards DESC;

--Most Wins by any team
SELECT Top 1 winner AS team, COUNT(winner) AS wins
FROM IPL..match
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY wins DESC

--Top 5 Venues where match is played
SELECT TOP 5 venue, COUNT(id) AS matches_count
FROM IPL..match
GROUP BY venue
ORDER BY matches_count DESC;

-- Most runs by any team
SELECT TOP 1 batting_team AS team, SUM(total_runs) AS total_runs
FROM IPL..ball
GROUP BY batting_team
ORDER BY total_runs DESC;

-- Most runs by any batsman
SELECT TOP 1 batsman, SUM(batsman_runs) AS total_runs
FROM IPL..ball
GROUP BY batsman
ORDER BY total_runs DESC;

-- Percentage of total runs scored by each batsman
SELECT batsman, 
       SUM(batsman_runs) AS total_runs,
       (SUM(batsman_runs) * 100.0) / SUM(SUM(batsman_runs)) OVER () AS percentage_of_total_runs
FROM IPL..ball
GROUP BY batsman
ORDER BY total_runs DESC;

-- Most sixes by any batsman
SELECT TOP 1 batsman, 
            COUNT(CASE WHEN non_boundary = 0 AND batsman_runs = 6 THEN 1 END) AS sixes_count
FROM IPL..ball
GROUP BY batsman
ORDER BY sixes_count DESC;

-- Most fours by any batsman
SELECT TOP 1 batsman, 
            COUNT(CASE WHEN non_boundary = 0 AND batsman_runs = 4 THEN 1 END) AS fours_count
FROM IPL..ball
GROUP BY batsman
ORDER BY fours_count DESC;

-- Batsman with the highest strike rate in the 3000 runs club
WITH BatsmanStats AS (
    SELECT batsman, 
           SUM(batsman_runs) AS total_runs,
           count(ball) AS total_balls,
           COUNT(DISTINCT id) AS total_matches
    FROM IPL..ball
    GROUP BY batsman
    HAVING SUM(batsman_runs) >= 3000
)
SELECT TOP 1 batsman, 
            (SUM(total_runs) * 100.0) / SUM(total_balls) AS strike_rate
FROM BatsmanStats
GROUP BY batsman
ORDER BY strike_rate DESC;

-- Bowler with the lowest economy rate (min 50 overs bowled)
WITH BowlerStats AS (
    SELECT bowler, 
           SUM(total_runs) AS total_runs,
           count(ball) AS total_balls
    FROM IPL..ball
    GROUP BY bowler
    HAVING count(ball) >= 300 -- Assuming 6 balls per over, so 50 overs = 300 balls
)
SELECT TOP 1 bowler, 
            (SUM(total_runs) * 6.0) / SUM(total_balls) AS economy_rate
FROM BowlerStats
GROUP BY bowler
ORDER BY economy_rate ASC;


-- Total number of matches till 2020
select 'IPL' Series_name  , a.* from	
(SELECT COUNT(Distinct id) AS total_matches
FROM IPL..match
WHERE YEAR(date) <= 2020)a

-- Total number of matches won by each team
SELECT winner AS team, COUNT(winner) AS total_wins
FROM IPL..match
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY total_wins DESC;

-- Correlation between winning the toss and winning the match
SELECT toss_winner, winner, COUNT(*) AS matches_count
FROM IPL..match
WHERE toss_winner IS NOT NULL
GROUP BY toss_winner, winner
ORDER BY matches_count DESC;

-- Toss and match win ratio for each team
SELECT winner as team,
       COUNT(CASE WHEN winner IS NOT NULL THEN 1 END) AS total_wins,
       COUNT(CASE WHEN winner IS NOT NULL AND winner = toss_winner THEN 1 END) AS total_toss_wins,
       CAST(COUNT(CASE WHEN winner IS NOT NULL THEN 1 END) AS FLOAT) / NULLIF(COUNT(CASE WHEN winner IS NOT NULL AND winner = toss_winner THEN 1 END), 0) AS win_ratio
FROM IPL..match
WHERE winner IS NOT NULL AND toss_winner IS NOT NULL
GROUP BY winner;


-- Average score of each team per season
SELECT b.batting_team AS team,
       YEAR(m.date) AS season,
       AVG(b.total_runs) AS average_score
FROM IPL..ball b
INNER JOIN IPL..match m ON b.id = m.id
GROUP BY b.batting_team, YEAR(m.date)
ORDER BY team, season;

-- Number of times each team scored above 200
SELECT batting_team AS team,
       COUNT(CASE WHEN total_runs > 200 THEN 1 END) AS above_200_count
FROM IPL..ball
GROUP BY batting_team
ORDER BY above_200_count DESC;

-- Top 10 players with the most runs
SELECT Top 10 batsman, 
       SUM(batsman_runs) AS total_runs
FROM IPL..ball
GROUP BY batsman
ORDER BY total_runs DESC;

-- Top 10 bowlers by total wickets
SELECT Top 10 bowler, 
       COUNT(CASE WHEN is_wicket = 1 THEN 1 END) AS total_wickets
FROM IPL..ball
WHERE is_wicket = 1
GROUP BY bowler
ORDER BY total_wickets DESC;

-- Top 10 cities by the number of matches
SELECT Top 10 city, 
       COUNT(id) AS matches_count
FROM IPL..match
GROUP BY city
ORDER BY matches_count DESC;

-- Matches where the target was set to 100 runs or more
SELECT *
FROM IPL..match
WHERE result = 'runs' AND result_margin >= 100;

-- Umpire with the most appearances
SELECT Top 5 umpire, COUNT(*) AS matches_count
FROM (
    SELECT umpire1 AS umpire FROM IPL..match
    UNION ALL
    SELECT umpire2 FROM IPL..match
) AS UmpireList
WHERE umpire IS NOT NULL
GROUP BY umpire
ORDER BY matches_count DESC;

-- Season-wise summary of matches won while defending
SELECT YEAR(date) AS season,
       COUNT(id) AS matches_won_by_runs,
       AVG(result_margin) AS average_margin
FROM IPL..match
WHERE result = 'runs'
GROUP BY YEAR(date)
ORDER BY season;

-- Season-wise summary of matches won while chasing
SELECT YEAR(date) AS season,
       COUNT(id) AS matches_won_by_wickets,
       AVG(result_margin) AS average_margin
FROM IPL..match
WHERE result = 'wickets'
GROUP BY YEAR(date)
ORDER BY season;

-- Top dismissal reason
SELECT dismissal_kind, COUNT(*) AS dismissal_count
FROM IPL..ball
WHERE is_wicket = 1
GROUP BY dismissal_kind
ORDER BY dismissal_count DESC;

-- Count of matches played in each season
SELECT YEAR(date) AS season,
       COUNT(id) AS matches_count
FROM IPL..match
GROUP BY YEAR(date)
ORDER BY season;

-- Runs scored in each season
SELECT YEAR(m.date) AS season,
       SUM(b.total_runs) AS total_runs
FROM IPL..ball b
INNER JOIN IPL..match m ON b.id = m.id
GROUP BY YEAR(m.date)
ORDER BY season;

-- Runs scored per match in different seasons
SELECT YEAR(m.date) AS season,
       m.id AS match_id,
	   m.team1,m.team2,
       SUM(b.total_runs) AS runs_scored_per_match
FROM IPL..ball b
INNER JOIN IPL..match m ON b.id = m.id
GROUP BY YEAR(m.date), m.id,team1,team2
ORDER BY season, match_id;

-- Team that won the most tosses
SELECT Top 5 team, COUNT(toss_winner) AS toss_wins
FROM (
    SELECT team1 AS team, toss_winner FROM IPL..match
    UNION ALL
    SELECT team2, toss_winner FROM IPL..match
) AS TossList
WHERE toss_winner IS NOT NULL
GROUP BY team
ORDER BY toss_wins DESC;

-- Ratio of decisions made after winning the toss
SELECT toss_decision, COUNT(*) AS decision_count
FROM IPL..match
WHERE toss_winner IS NOT NULL
GROUP BY toss_decision
ORDER BY decision_count DESC;

-- Ratio of decisions made by a particular team after winning the toss
SELECT toss_decision, COUNT(*) AS decision_count
FROM IPL..match
WHERE toss_winner = 'Chennai Super Kings'
GROUP BY toss_decision
ORDER BY decision_count DESC;

-- Toss decision variation across seasons
SELECT YEAR(date) AS season,
       toss_decision,
       COUNT(*) AS decision_count
FROM IPL..match
WHERE toss_winner IS NOT NULL
GROUP BY YEAR(date), toss_decision
ORDER BY season, decision_count DESC;

-- Correlation between winning the toss and winning the game
SELECT toss_winner,
       winner,
       COUNT(*) AS matches_count
FROM IPL..match
WHERE toss_winner IS NOT NULL AND winner IS NOT NULL
GROUP BY toss_winner, winner
ORDER BY matches_count DESC;

-- Batsman with the highest strike rate
WITH BatsmanStats AS (
    SELECT batsman, 
           SUM(batsman_runs) AS total_runs,
           count(ball) AS total_balls
    FROM IPL..ball
    GROUP BY batsman
)
SELECT TOP 10 batsman, 
            (SUM(total_runs) * 100.0) / NULLIF(SUM(total_balls), 0) AS strike_rate
FROM BatsmanStats
GROUP BY batsman
HAVING SUM(total_balls) >= 200 -- Assuming a minimum of 200 balls faced
ORDER BY strike_rate DESC;


-- Lucky venue for a particular team

SELECT Top 1 venue, COUNT(*) AS matches_won
FROM IPL..match
WHERE winner = 'Chennai Super Kings'
GROUP BY venue
ORDER BY matches_won DESC

-- Team with the best scoring run rate in the first six overs
WITH TeamRunRates AS (
    SELECT batting_team,
           COUNT(*) AS matches_played,
           SUM(total_runs) AS total_runs,
           SUM(CASE WHEN over_no <= 6 THEN 1 ELSE 0 END) AS balls_in_first_six
    FROM IPL..ball
    GROUP BY batting_team
)
SELECT batting_team,
       AVG(total_runs * 6.0 / NULLIF(balls_in_first_six, 0)) AS run_rate
FROM TeamRunRates
WHERE balls_in_first_six > 0
GROUP BY batting_team
ORDER BY run_rate DESC;

--Percentage of Total Runs Scored in Powerplays by Each Team
WITH PowerplayRuns AS (
    SELECT batting_team, 
           SUM(total_runs) AS runs_in_powerplay
    FROM IPL..ball
    WHERE over_no BETWEEN 1 AND 6
    GROUP BY batting_team
)
SELECT pr.batting_team, 
       pr.runs_in_powerplay,
       tr.total_runs,
       Round((pr.runs_in_powerplay * 100.0) / NULLIF(tr.total_runs, 0),2) AS percentage_of_total_runs
FROM PowerplayRuns pr
INNER JOIN (
    SELECT batting_team, SUM(total_runs) AS total_runs
    FROM IPL..ball
    GROUP BY batting_team
) tr ON pr.batting_team = tr.batting_team;

--Team-wise Total Runs, Wickets, and Extras in Each Match
SELECT m.id AS match_id, 
       m.team1, 
       m.team2, 
       b.batting_team, 
       SUM(b.total_runs) AS total_runs, 
       COUNT(CASE WHEN b.is_wicket = 1 THEN 1 END) AS total_wickets,
       SUM(b.extra_runs) AS total_extras
FROM IPL..match m
JOIN IPL..ball b ON m.id = b.id
GROUP BY m.id, m.team1, m.team2, b.batting_team
ORDER BY match_id, batting_team;

--Season-wise Average Powerplay Run Rate
WITH PowerplayRuns AS (
    SELECT YEAR(m.date) AS season,
           b.batting_team,
           COUNT(*) AS matches_played,
           SUM(b.total_runs) AS total_runs,
           SUM(CASE WHEN b.over_no BETWEEN 1 AND 6 THEN 1 ELSE 0 END) AS balls_in_powerplay
    FROM IPL..ball b
    JOIN IPL..match m ON b.id = m.id
    GROUP BY YEAR(m.date), b.batting_team
)
SELECT season,
       batting_team,
       AVG(total_runs * 6.0 / NULLIF(balls_in_powerplay, 0)) AS average_run_rate
FROM PowerplayRuns
GROUP BY season, batting_team
ORDER BY season, average_run_rate DESC;

-- Top 5 Run Scorers in Each Season:
WITH SeasonRunners AS (
    SELECT YEAR(m.date) AS season,
           b.batsman,
           SUM(b.batsman_runs) AS total_runs,
           RANK() OVER (PARTITION BY YEAR(m.date) ORDER BY SUM(b.batsman_runs) DESC) AS run_rank
    FROM IPL..ball b
    JOIN IPL..match m ON b.id = m.id
    GROUP BY YEAR(m.date), b.batsman
)
SELECT season, 
       batsman, 
       total_runs
FROM SeasonRunners
WHERE run_rank <= 5
ORDER BY season, run_rank;

--Team-wise Average Opening Partnership Runs
WITH OpeningPartnerships AS (
    SELECT m.id AS match_id,
           m.team1,
		   m.team2,
           b.inning,
           b.over_no,
           b.ball,
           b.batting_team,
           b.batsman,
           b.non_striker,
           b.total_runs,
           ROW_NUMBER() OVER (PARTITION BY m.id, b.inning ORDER BY b.over_no, b.ball) AS run_order
    FROM IPL..ball b
    JOIN IPL..match m ON b.id = m.id
    WHERE b.over_no = 1 AND b.ball = 1
)
SELECT team1 AS team,
       AVG(total_runs) AS avg_opening_partnership
FROM OpeningPartnerships
WHERE run_order = 1
GROUP BY team1
UNION ALL
SELECT team2 AS team,
       AVG(total_runs) AS avg_opening_partnership
FROM OpeningPartnerships
WHERE run_order = 1
GROUP BY team2
ORDER BY avg_opening_partnership DESC;

--Top 5 Bowlers with the Best Economy Rate (min 50 overs bowled)

WITH BowlerOvers AS (
    SELECT bowler, COUNT(*) AS total_balls
    FROM IPL..ball
    WHERE is_wicket = 0
    GROUP BY bowler
    HAVING COUNT(*) >= 50
)
SELECT Top 5 b.bowler, 
       (SUM(b.total_runs) * 6.0) / NULLIF(bo.total_balls, 0) AS economy_rate
FROM IPL..ball b
JOIN BowlerOvers bo ON b.bowler = bo.bowler
GROUP BY b.bowler, bo.total_balls
ORDER BY economy_rate ASC

--Batsmen with the Best Average in Powerplays (min 50 balls faced)
WITH PowerplayBatsmanStats AS (
    SELECT batsman,
           SUM(batsman_runs) AS total_runs,
           count(ball) AS total_balls
    FROM IPL..ball
    WHERE over_no BETWEEN 1 AND 6
    GROUP BY batsman
)
SELECT Top 5 batsman, 
       total_runs / NULLIF(total_balls, 0) AS batting_average
FROM PowerplayBatsmanStats
WHERE total_balls >= 50
ORDER BY batting_average DESC

--Average Partnership Runs for Each Wicket
WITH PartnershipStats AS (
    SELECT inning,
           batsman,
           non_striker,
           SUM(total_runs) AS partnership_runs
    FROM IPL..ball
    WHERE is_wicket = 0
    GROUP BY inning, batsman, non_striker
)
SELECT inning,
       AVG(partnership_runs) AS average_partnership_runs
FROM PartnershipStats
GROUP BY inning
ORDER BY inning;

-- Most Prolific Opening Pairs:
WITH OpeningPartners AS (
    SELECT
        inning,
        batsman,
        non_striker,
        COUNT(*) AS partnership_count
    FROM
        IPL..ball
    WHERE
        over_no = 1 AND ball = 1
    GROUP BY
        inning, batsman, non_striker
)
SELECT
    inning,
    batsman,
    non_striker,
    MAX(partnership_count) AS partnership_count
FROM
    OpeningPartners
GROUP BY
    inning, batsman, non_striker
ORDER BY
    inning, partnership_count DESC;


--Players Who Have Batted in All Seasons

SELECT
    batsman,
    COUNT(DISTINCT YEAR(date)) AS seasons_played
FROM
    IPL..ball
    JOIN IPL..match ON ball.id = match.id
WHERE
    batsman IS NOT NULL
GROUP BY
    batsman
HAVING
    COUNT(DISTINCT YEAR(date)) = (SELECT COUNT(DISTINCT YEAR(date)) FROM IPL..match);
