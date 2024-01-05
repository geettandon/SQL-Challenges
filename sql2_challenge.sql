-- Esports Tournament

-- INTRO
/*
The top eSports competitors from across the globe have gathered to battle it out.
Can you analyse the following data to find out all about the tournament?
*/

-- Query the Teams table;
SELECT *
FROM Teams;

-- Query the Players table;
SELECT *
FROM Players
LIMIT 5;

-- Query the Matches table;
SELECT *
FROM Matches
LIMIT 5;

-- QUESTIONS

-- 1. What are the names of the players whose salary is greater than 100,000?
SELECT player_name
FROM Players
WHERE salary > 100000;

-- 2. What is the team name of the player with player_id = 3?
SELECT team_name
FROM Teams
WHERE team_id IN (
    SELECT team_id 
    FROM Players 
    WHERE player_id = 3
    );

-- 3. What is the total number of players in each team?
SELECT Teams.team_name,
    COUNT(player_id) AS num_of_players
FROM Players
INNER JOIN Teams ON Players.team_id = Teams.team_id
GROUP BY Teams.team_name;

-- 4. What is the team name and captain name of the team with team_id = 2?
WITH team_id_2 AS (
    SELECT team_name,
        captain_id
    FROM Teams
    WHERE team_id = 2
    )

SELECT team_name,
    player_name AS captain_name
FROM Players 
INNER JOIN team_id_2
ON Players.player_id = team_id_2.captain_id;

-- 5. What are the player names and their roles in the team with team_id = 1?
SELECT team_id,
    player_name,
    role
FROM Players
WHERE team_id = 1;

-- 6. What are the team names and the number of matches they have won?
WITH winner_teams AS (
    SELECT winner_id,
        COUNT(*) AS matches_won
    FROM Matches
    GROUP BY winner_id
)

SELECT team_name,
    matches_won
FROM Teams
INNER JOIN winner_teams ON Teams.team_id = winner_teams.winner_id
ORDER BY matches_won DESC;

-- 7. What is the average salary of players in the teams with country 'USA'?
SELECT ROUND(AVG(salary), 2) AS average_salary_usa_teams
FROM Players
WHERE team_id IN (
    SELECT team_id
    FROM Teams
    WHERE country = 'USA'
);

--8. Which team won the most matches?
SELECT team_name
FROM Teams
WHERE team_id IN (
    SELECT winner_id
    FROM Matches
    GROUP BY winner_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
    );

-- 9. What are the team names and the number of players in each team whose salary is greater than 100,000?
WITH high_salary_players AS (
    SELECT player_id,
    team_id
    FROM Players
    WHERE salary > 100000
)

SELECT team_name,
    COUNT(player_id) AS num_of_players_with_salary_above_100000
FROM Teams
INNER JOIN high_salary_players ON Teams.team_id = high_salary_players.team_id
GROUP BY team_name
ORDER BY num_of_players_with_salary_above_100000 DESC;

-- 10. What is the date and the score of the match with match_id = 3?
WITH match_id_3 AS (
    SELECT team1_id,
        team2_id,
        match_date,
        winner_id,
        score_team1,
        score_team2
    FROM Matches
    WHERE match_id = 3
),

team_1 AS (
    SELECT team_name
    FROM Teams
    INNER JOIN match_id_3 ON Teams.team_id = match_id_3.team1_id
),

team_2 AS (
    SELECT team_name
    FROM Teams
    INNER JOIN match_id_3 ON Teams.team_id = match_id_3.team2_id
),

winner_team AS (
    SELECT team_name
    FROM Teams
    INNER JOIN match_id_3 ON Teams.team_id = match_id_3.winner_id
)

SELECT match_date AS match_id_3_date,
    team_1.team_name AS team1_name, 
    team_2.team_name AS team2_name, 
    winner_team.team_name AS winner_team_name,
    score_team1,
    score_team2
FROM team_1, 
    team_2, 
    winner_team,
    match_id_3;