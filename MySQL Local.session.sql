-- start by validating our data 
USE NBA_stats;
SELECT COUNT(*) AS total_rows 
FROM nba_final_dataset_2006_2025;

-- we see that we have 600 rows in our dataset which makes the 20 seasons of 30 teams 

-- check and make sure we have the correct number of teams for each season
SELECT Season, Count(*) AS team_count
FROM nba_final_dataset_2006_2025
GROUP BY Season
ORDER BY Season;
-- every season shows 30 teams which is correct

-- we will check to make sure there is 1 championship winner for each season 
SELECT Season, Count(*) AS champion_count
FROM nba_final_dataset_2006_2025
WHERE Championship = 1
GROUP BY Season
ORDER BY Season;
-- every season shows 1 champion which is correct

-- check the finals teams per season to make sure that there are 2 teams in the finals each season
SELECT Season, Count(*) AS finals_teams
FROM nba_final_dataset_2006_2025
WHERE Finals_Appearance = 1
GROUP BY Season
ORDER BY Season;
-- every season shows 2 finals teams which is correct

-- check for any duplicate team names in the same season
SELECT Season, Franchise, COUNT(*) AS row_count
FROM nba_final_dataset_2006_2025
GROUP BY Season, Franchise
HAVING COUNT(*) > 1;
-- nothing was returned which means there are no duplicate team names in the same season which is correct

-- now we will check of any null values in our dataset
SELECT
    SUM(CASE WHEN W IS NULL THEN 1 ELSE 0 END) AS W_nulls,
    SUM(CASE WHEN ORtg IS NULL THEN 1 ELSE 0 END) AS ORtg_nulls,
    SUM(CASE WHEN DRtg IS NULL THEN 1 ELSE 0 END) AS DRtg_nulls,
    SUM(CASE WHEN NRtg IS NULL THEN 1 ELSE 0 END) AS NRtg_nulls,
    SUM(CASE WHEN SRS IS NULL THEN 1 ELSE 0 END) AS SRS_nulls,
    SUM(CASE WHEN Pace IS NULL THEN 1 ELSE 0 END) AS Pace_nulls,
    SUM(CASE WHEN `Offense Four Factors_eFG%` IS NULL THEN 1 ELSE 0 END) AS Offense_Four_Factors_eFG_nulls,
    SUM(CASE WHEN `Offense Four Factors_ORB%` IS NULL THEN 1 ELSE 0 END) AS Offense_Four_Factors_ORB_nulls,
    SUM(CASE WHEN `Offense Four Factors_TOV%` IS NULL THEN 1 ELSE 0 END) AS Offense_Four_Factors_TOV_nulls,
    SUM(CASE WHEN `Defense Four Factors_DRB%` IS NULL THEN 1 ELSE 0 END) AS Defense_Four_Factors_DRB_nulls,
    SUM(CASE WHEN `Defense Four Factors_TOV%` IS NULL THEN 1 ELSE 0 END) AS Defense_Four_Factors_TOV_nulls
FROM nba_final_dataset_2006_2025;
-- we see that there are no null values in our dataset which is correct

-- verify that round reach values are between 0 and 4
SELECT DISTINCT Round_Reached
FROM nba_final_dataset_2006_2025
ORDER BY Round_Reached;
-- we see that the round reached values are between 0 and 4 which is correct


-- we will now start our analysis into defense and championship success
-- to start we will see what stat appears to have a strong correlation with championship outcomes
-- we will want to see if there is a pattern amongst champion teams each year and what metrics are most common among them. Keep in mind that the DRtg and TOV is better the lower it is so we want to order it by ASC

-- how highly did the eventual champion rank in each stat during their championship season?

DROP TABLE IF EXISTS ranked_team;

CREATE TABLE ranked_team AS
SELECT
    Season,
    Franchise,
    Championship,

    W,
    RANK() OVER (PARTITION BY Season ORDER BY W DESC) AS W_rank,

    ORtg,
    RANK() OVER (PARTITION BY Season ORDER BY ORtg DESC) AS ORtg_rank,

    DRtg,
    RANK() OVER (PARTITION BY Season ORDER BY DRtg ASC) AS DRtg_rank,

    NRtg,
    RANK() OVER (PARTITION BY Season ORDER BY NRtg DESC) AS NRtg_rank,

    SRS,
    RANK() OVER (PARTITION BY Season ORDER BY SRS DESC) AS SRS_rank,

    Pace,
    RANK() OVER (PARTITION BY Season ORDER BY Pace DESC) AS Pace_rank,

    `Offense Four Factors_eFG%`,
    RANK() OVER (
        PARTITION BY Season
        ORDER BY `Offense Four Factors_eFG%` DESC
    ) AS Offense_Four_Factors_eFG_rank,

    `Offense Four Factors_ORB%`,
    RANK() OVER (
        PARTITION BY Season
        ORDER BY `Offense Four Factors_ORB%` DESC
    ) AS Offense_Four_Factors_ORB_rank,

    `Offense Four Factors_TOV%`,
    RANK() OVER (
        PARTITION BY Season
        ORDER BY `Offense Four Factors_TOV%` ASC
    ) AS Offense_Four_Factors_TOV_rank,

    `Defense Four Factors_DRB%`,
    RANK() OVER (
        PARTITION BY Season
        ORDER BY `Defense Four Factors_DRB%` DESC
    ) AS Defense_Four_Factors_DRB_rank,

    `Defense Four Factors_TOV%`,
    RANK() OVER (
        PARTITION BY Season
        ORDER BY `Defense Four Factors_TOV%` DESC
    ) AS Defense_Four_Factors_TOV_rank

FROM nba_final_dataset_2006_2025;

SELECT Count(*) AS total_rows
FROM ranked_team; -- this should also return 600 rows which is correct

-- Preview the 20 championship teams and their rankings
SELECT *
FROM ranked_team
WHERE Championship = 1
ORDER BY Season;

-- Calculate the average rank for each metric among championship teams
SELECT 'W' AS Metric, AVG(W_rank) AS Average_Rank
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'ORtg', AVG(ORtg_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'DRtg', AVG(DRtg_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'NRtg', AVG(NRtg_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'SRS', AVG(SRS_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'Pace', AVG(Pace_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'Offense Four Factors eFG%', AVG(Offense_Four_Factors_eFG_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'Offense Four Factors ORB%', AVG(Offense_Four_Factors_ORB_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'Offense Four Factors TOV%', AVG(Offense_Four_Factors_TOV_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'Defense Four Factors DRB%', AVG(Defense_Four_Factors_DRB_rank)
FROM ranked_team
WHERE Championship = 1

UNION ALL
SELECT 'Defense Four Factors TOV%', AVG(Defense_Four_Factors_TOV_rank)
FROM ranked_team
WHERE Championship = 1

ORDER BY Average_Rank ASC;

-- The lowest average rank is the Wins metric meanig that the team with the most wins in the regular seems have the best chance of winning the championship. If we look past wins, then SRS appears to be the next best indicator, followed closely by NRtg and Offense Four Factors eFG%.

-- How often did champions rank among the top 3 and top 5 in each metric?
DROP TABLE IF EXISTS champion_top3_top5_frequency;

CREATE TABLE champion_top3_top5_frequency AS

SELECT
    'W' AS Metric,
    SUM(CASE WHEN W_rank <= 3 THEN 1 ELSE 0 END) AS Top_3_Count,
    SUM(CASE WHEN W_rank <= 5 THEN 1 ELSE 0 END) AS Top_5_Count,
    COUNT(*) AS Total_Champions,
    ROUND(SUM(CASE WHEN W_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS Top_3_Pct,
    ROUND(SUM(CASE WHEN W_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS Top_5_Pct
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'ORtg',
    SUM(CASE WHEN ORtg_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN ORtg_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN ORtg_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN ORtg_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'DRtg',
    SUM(CASE WHEN DRtg_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN DRtg_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN DRtg_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN DRtg_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'NRtg',
    SUM(CASE WHEN NRtg_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN NRtg_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN NRtg_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN NRtg_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'SRS',
    SUM(CASE WHEN SRS_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN SRS_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN SRS_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN SRS_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'Pace',
    SUM(CASE WHEN Pace_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN Pace_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN Pace_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN Pace_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'Offense Four Factors eFG%',
    SUM(CASE WHEN Offense_Four_Factors_eFG_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN Offense_Four_Factors_eFG_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN Offense_Four_Factors_eFG_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN Offense_Four_Factors_eFG_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'Offense Four Factors ORB%',
    SUM(CASE WHEN Offense_Four_Factors_ORB_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN Offense_Four_Factors_ORB_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN Offense_Four_Factors_ORB_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN Offense_Four_Factors_ORB_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'Offense Four Factors TOV%',
    SUM(CASE WHEN Offense_Four_Factors_TOV_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN Offense_Four_Factors_TOV_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN Offense_Four_Factors_TOV_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN Offense_Four_Factors_TOV_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'Defense Four Factors DRB%',
    SUM(CASE WHEN Defense_Four_Factors_DRB_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN Defense_Four_Factors_DRB_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN Defense_Four_Factors_DRB_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN Defense_Four_Factors_DRB_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1

UNION ALL

SELECT
    'Defense Four Factors TOV%',
    SUM(CASE WHEN Defense_Four_Factors_TOV_rank <= 3 THEN 1 ELSE 0 END),
    SUM(CASE WHEN Defense_Four_Factors_TOV_rank <= 5 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(SUM(CASE WHEN Defense_Four_Factors_TOV_rank <= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1),
    ROUND(SUM(CASE WHEN Defense_Four_Factors_TOV_rank <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM ranked_team
WHERE Championship = 1;    

SELECT *
FROM champion_top3_top5_frequency
ORDER BY Top_3_Pct DESC, Top_5_Pct DESC;


-- focusing on the finals, what metric often separated the champion team from the runner up?
DROP TABLE IF EXISTS finals_comparison;

CREATE TABLE finals_comparison AS
SELECT
    champ.Season,

    champ.Franchise AS Champion,
    runner.Franchise AS Runner_Up,

    champ.W AS Champion_W,
    runner.W AS Runner_Up_W,
    champ.W - runner.W AS W_Diff,

    champ.ORtg AS Champion_ORtg,
    runner.ORtg AS Runner_Up_ORtg,
    champ.ORtg - runner.ORtg AS ORtg_Diff,

    champ.DRtg AS Champion_DRtg,
    runner.DRtg AS Runner_Up_DRtg,
    runner.DRtg - champ.DRtg AS DRtg_Diff,

    champ.NRtg AS Champion_NRtg,
    runner.NRtg AS Runner_Up_NRtg,
    champ.NRtg - runner.NRtg AS NRtg_Diff,

    champ.SRS AS Champion_SRS,
    runner.SRS AS Runner_Up_SRS,
    champ.SRS - runner.SRS AS SRS_Diff,

    champ.Pace AS Champion_Pace,
    runner.Pace AS Runner_Up_Pace,
    champ.Pace - runner.Pace AS Pace_Diff,

    champ.`Offense Four Factors_eFG%` AS Champion_Off_eFG,
    runner.`Offense Four Factors_eFG%` AS Runner_Up_Off_eFG,
    champ.`Offense Four Factors_eFG%` - runner.`Offense Four Factors_eFG%` AS Off_eFG_Diff,

    champ.`Offense Four Factors_ORB%` AS Champion_Off_ORB,
    runner.`Offense Four Factors_ORB%` AS Runner_Up_Off_ORB,
    champ.`Offense Four Factors_ORB%` - runner.`Offense Four Factors_ORB%` AS Off_ORB_Diff,

    champ.`Offense Four Factors_TOV%` AS Champion_Off_TOV,
    runner.`Offense Four Factors_TOV%` AS Runner_Up_Off_TOV,
    runner.`Offense Four Factors_TOV%` - champ.`Offense Four Factors_TOV%` AS Off_TOV_Diff,

    champ.`Defense Four Factors_DRB%` AS Champion_Def_DRB,
    runner.`Defense Four Factors_DRB%` AS Runner_Up_Def_DRB,
    champ.`Defense Four Factors_DRB%` - runner.`Defense Four Factors_DRB%` AS Def_DRB_Diff,

    champ.`Defense Four Factors_TOV%` AS Champion_Def_TOV,
    runner.`Defense Four Factors_TOV%` AS Runner_Up_Def_TOV,
    champ.`Defense Four Factors_TOV%` - runner.`Defense Four Factors_TOV%` AS Def_TOV_Diff

FROM nba_final_dataset_2006_2025 champ
JOIN nba_final_dataset_2006_2025 runner
    ON champ.Season = runner.Season
WHERE champ.Championship = 1
  AND runner.Finals_Appearance = 1
  AND runner.Championship = 0;    

-- summarize how often the champion had an advantage in a stat compared to the runner up
DROP TABLE IF EXISTS finals_metric_advantage_summary;

CREATE TABLE finals_metric_advantage_summary AS
SELECT 'W' AS Metric, 
       SUM(CASE WHEN W_Diff > 0 THEN 1 ELSE 0 END) AS Champion_Advantage_Count, 
       COUNT(*) AS Finals_Matchups,
       ROUND(SUM(CASE WHEN W_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS Champion_Advantage_Pct
FROM finals_comparison

UNION ALL
SELECT 'ORtg',
       SUM(CASE WHEN ORtg_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN ORtg_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'DRtg',
       SUM(CASE WHEN DRtg_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN DRtg_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'NRtg',
       SUM(CASE WHEN NRtg_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN NRtg_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'SRS',
       SUM(CASE WHEN SRS_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN SRS_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'Pace',
       SUM(CASE WHEN Pace_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN Pace_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'Offensive eFG%',
       SUM(CASE WHEN Off_eFG_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN Off_eFG_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'Offensive ORB%',
       SUM(CASE WHEN Off_ORB_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN Off_ORB_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'Offensive TOV%',
       SUM(CASE WHEN Off_TOV_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN Off_TOV_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'Defensive DRB%',
       SUM(CASE WHEN Def_DRB_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN Def_DRB_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison

UNION ALL
SELECT 'Defensive TOV%',
       SUM(CASE WHEN Def_TOV_Diff > 0 THEN 1 ELSE 0 END),
       COUNT(*),
       ROUND(SUM(CASE WHEN Def_TOV_Diff > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1)
FROM finals_comparison;

SELECT *
FROM finals_metric_advantage_summary
ORDER BY Champion_Advantage_Pct DESC, Champion_Advantage_Count DESC;

-- Analyze how regular-season metrics change by playoff round reached
DROP TABLE IF EXISTS round_reached_analysis;

CREATE TABLE round_reached_analysis AS
SELECT
    Round_Reached,
    CASE
        WHEN Round_Reached = 0 THEN 'Missed Playoffs'
        WHEN Round_Reached = 1 THEN 'First Round'
        WHEN Round_Reached = 2 THEN 'Conference Semifinals'
        WHEN Round_Reached = 3 THEN 'Conference Finals'
        WHEN Round_Reached = 4 THEN 'NBA Finals'
    END AS Round_Label,

    COUNT(*) AS Team_Count,
    ROUND(AVG(W), 2) AS Avg_W,
    ROUND(AVG(ORtg), 2) AS Avg_ORtg,
    ROUND(AVG(DRtg), 2) AS Avg_DRtg,
    ROUND(AVG(NRtg), 2) AS Avg_NRtg,
    ROUND(AVG(SRS), 2) AS Avg_SRS,
    ROUND(AVG(Pace), 2) AS Avg_Pace,
    ROUND(AVG(`Offense Four Factors_eFG%`), 3) AS Avg_Off_eFG,
    ROUND(AVG(`Offense Four Factors_ORB%`), 2) AS Avg_Off_ORB,
    ROUND(AVG(`Offense Four Factors_TOV%`), 2) AS Avg_Off_TOV,
    ROUND(AVG(`Defense Four Factors_DRB%`), 2) AS Avg_Def_DRB,
    ROUND(AVG(`Defense Four Factors_TOV%`), 2) AS Avg_Def_TOV
FROM nba_final_dataset_2006_2025
GROUP BY
    Round_Reached,
    Round_Label
ORDER BY Round_Reached;

SELECT *
FROM round_reached_analysis
ORDER BY Round_Reached;