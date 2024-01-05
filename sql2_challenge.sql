-- Challenge 2 - Esports Tournament

-- QUESTIONS

-- 1. What are the names of the players whose salary is greater than 100,000?
SELECT player_name
FROM Players
WHERE salary > 100000;

-- Sol1:
| player_name |
|-------------|
| Faker       |
| Perkz       |
| Castle09    |
| Daron       |
| ForceZ      |
| Joker       |
| Wringer     |

-- 2. What is the team name of the player with player_id = 3?
SELECT team_name
FROM Teams
WHERE team_id IN (
    SELECT team_id 
    FROM Players 
    WHERE player_id = 3
    );

-- Sol2:
| team_name     | 
|---------------|
| SK Telecom T1 |

-- 3. What is the total number of players in each team?
SELECT Teams.team_name,
    COUNT(player_id) AS num_of_players
FROM Players
INNER JOIN Teams ON Players.team_id = Teams.team_id
GROUP BY Teams.team_name;

-- Sol3:
| team_name     | num_of_players |
|---------------|----------------|
| Cloud9        | 3              |
| G2 Esports    | 3              |
| SK Telecom T1 | 3              |
| Team Liquid   | 3              |
| Fnatic        | 3              |

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

-- Sol4:
| team_name | captain_name |
|-----------|--------------|
| Fnatic    | JW           |

-- 5. What are the player names and their roles in the team with team_id = 1?
SELECT team_id,
    player_name,
    role
FROM Players
WHERE team_id = 1;

-- Sol5:
| team_id | player_name | role      |
|---------|-------------|-----------|
| 1       | Shroud      | Rifler    |
| 1       | Castle09    | AWP       |
| 1       | KL34        | Mid Laner |

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

-- Sol6:
| team_name       | matches_won |
|-----------------|-------------|
| SK Telecom T1   | 4           |
| Cloud9          | 3           |
| Fnatic          | 1           |
| Team Liquid     | 1           |
| G2 Esports      | 1           |

-- 7. What is the average salary of players in the teams with country 'USA'?
SELECT ROUND(AVG(salary), 2) AS average_salary_usa_teams
FROM Players
WHERE team_id IN (
    SELECT team_id
    FROM Teams
    WHERE country = 'USA'
);

-- Sol7:
| average_salary_usa_teams |
|--------------------------|
| 97166.67                 |

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

-- Sol8:
| team_name       |
|-----------------|
| SK Telecom T1   |

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

-- Sol9:
| team_name       | num_of_players_with_salary_above_100000 |
|-----------------|-----------------------------------------|
| SK Telecom T1   | 3                                       |
| G2 Esports      | 2                                       |
| Cloud9          | 1                                       |
| Fnatic          | 1                                       |

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

-- Sol10:
| match_id_3_date | team1_name  | team2_name | winner_team_name | score_team1 | score_team2 |
|-----------------|-------------|------------|------------------|-------------|-------------|
| 2022-03-01      | Team Liquid | Cloud9     | Cloud9           | 17          | 13          |
