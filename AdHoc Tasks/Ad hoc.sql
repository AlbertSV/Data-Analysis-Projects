/*  Project: "Secrets of Darkwood"
* Goal: to explore how player characteristics and their in-game characters 
* influence the purchase of the in-game currency "Paradise Petals",
* and to assess player activity during in-game purchases.
*/

-- Part 1. Exploratory Data Analysis
-- Task 1. Analyzing the share of paying players

-- 1.1. Share of paying users across all data:
-- title: Query 1.1
SELECT 
COUNT(id) AS total_users,             
SUM(payer) AS payer_users,                     -- users with payment 
ROUND(AVG(payer::numeric),3) AS payer_share    -- their share of the total number of users
FROM fantasy.users;


-- 1.2. Share of paying users by character race:
-- Write your query here
-- title: Query 1.2
SELECT 
r.race,
COUNT(u.id) AS total_users,     					
SUM(payer) AS payer_users,             				-- users with payments (sum of values equal to 1 in the payer column)
ROUND(AVG(payer::numeric),3) AS payer_share         
FROM fantasy.users u
LEFT JOIN fantasy.race r USING(race_id)
GROUP BY r.race
ORDER BY payer_share DESC;


-- Task 2. Analysis of in-game purchases
-- 2.1. Statistical metrics for the amount field:
-- title: Query 2.1
SELECT
COUNT(transaction_id) AS total_tr,
SUM(amount) AS total_amount,
MAX(amount) AS max_amount,
MIN(amount) AS min_amount,
AVG(amount)::NUMERIC(10,2) AS avg_amount,
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY amount) AS median_amount,
STDDEV(amount)::NUMERIC(10,2) AS stand_dev_amount
FROM fantasy.events
WHERE amount != 0;

-- 2.2. Anomalous zero-amount purchases:
-- title: Query 2.2
SELECT
COUNT(transaction_id) AS total_tr, 																	-- ALL transactions
COUNT(CASE WHEN amount = 0 THEN transaction_id END) AS total_null_amount,						 	-- transactions WITH 0
ROUND((COUNT(CASE WHEN amount = 0 THEN transaction_id END)::float / COUNT(transaction_id))::NUMERIC ,5) AS null_share_percent
FROM fantasy.events;

-- title: Query 2.2b
-- Analysis of zero-value purchases
SELECT
id,
game_items,
COUNT(transaction_id) AS amount_of_item
FROM fantasy.users u
LEFT JOIN fantasy.events e USING(id)
LEFT JOIN fantasy.items i USING(item_code)
WHERE amount = 0
GROUP BY id, game_items
ORDER BY COUNT(transaction_id) DESC;

-- 2.3. Comparative analysis of paying and non-paying player activity:
-- title: Query 2.3
WITH user_stats AS (
    SELECT 
        id,
        payer,
        COUNT(transaction_id) AS total_transactions, 	
        SUM(amount) AS total_amount 					
    FROM fantasy.events
    RIGHT JOIN fantasy.users u USING(id)
    WHERE amount != 0 
    GROUP BY id, payer
),
group_stats AS (
    SELECT 
        payer,
        COUNT(id) AS total_users, 							
        ROUND(AVG(total_transactions)::NUMERIC ,2) AS avg_user_transactions, 	-- average number of transactions per paying player
        ROUND(AVG(total_amount)::NUMERIC ,2) AS avg_sum_amount_user 			-- average amount per paying player
    FROM user_stats
    GROUP BY payer
)
SELECT 
    CASE 
        WHEN payer = 1 THEN 'Paying Users'
        ELSE 'Non-Paying Users'
    END AS user_group,
    total_users,
    avg_user_transactions,
    avg_sum_amount_user
FROM group_stats;

-- title: Query 2.3b
-- Analysis of paying vs. non-paying players by race
WITH user_stats AS (
    SELECT 
        id,
        payer,
        race,
        COUNT(transaction_id) AS total_transactions, 	
        SUM(amount) AS total_amount 					
    FROM fantasy.events
    RIGHT JOIN fantasy.users u USING(id)
    LEFT JOIN fantasy.race r USING(race_id)
    WHERE amount != 0 
    GROUP BY id, payer, race
),
group_stats AS (
    SELECT 
        payer,
        race,
        COUNT(id) AS total_users, 							
        ROUND(AVG(total_transactions)::NUMERIC ,2) AS avg_user_transactions, 	-- average number of transactions per paying player
        ROUND(AVG(total_amount)::NUMERIC ,2) AS avg_sum_amount_user 			-- average amount per paying player
    FROM user_stats
    GROUP BY payer, race
)
SELECT 
	race,
    CASE 
        WHEN payer = 1 THEN 'Paying Users'
        ELSE 'Non-Paying Users'
    END AS user_group,
    total_users,
    avg_user_transactions,
    avg_sum_amount_user
FROM group_stats
ORDER BY race, user_group;


-- 2.4. Popular epic items:
-- title: Query 2.4
WITH total_unique_users AS (
    SELECT COUNT(DISTINCT id) AS total_users  -- total number of unique players
    FROM fantasy.events
    WHERE amount != 0
)
SELECT
    game_items,
    COUNT(transaction_id) AS transactions_by_item,  													-- number of transactions per item
    ROUND(COUNT(transaction_id)::NUMERIC / SUM(COUNT(transaction_id)) OVER (),7) AS items_share,  		
    ROUND(COUNT(DISTINCT id)::NUMERIC / (SELECT total_users FROM total_unique_users), 4) AS users_share -- share of players who purchased the item
FROM fantasy.events e
LEFT JOIN fantasy.items i USING(item_code)
LEFT JOIN fantasy.users u USING(id)
WHERE amount != 0
GROUP BY game_items
ORDER BY users_share DESC;

-- title: Query 2.4b
-- Unclaimed items
SELECT
game_items 
FROM fantasy.items i 
WHERE item_code NOT IN (SELECT item_code FROM fantasy.events e)

-- Part 2. Ad hoc task solutions
-- Task 1. Player activity dependency on character race: 
-- title: Part2.Task1
WITH non_0_amount AS (
SELECT 
	id,
	transaction_id,
	amount
	FROM fantasy.events
	WHERE amount != 0
),
player_stats AS (
    SELECT 
        u.id,  
        r.race, 
        u.payer,
        COUNT(transaction_id) AS transactions_count,  	
        COUNT(DISTINCT e.id) AS buyers_count, 
        COUNT(DISTINCT CASE WHEN payer = 1 THEN e.id END) AS payer_users_count, -- whether real money was spent on this
        SUM(amount) AS total_spent,  					
        AVG(amount) AS avg_per_user 					
    FROM fantasy.users u
    LEFT JOIN fantasy.race r USING(race_id)
    LEFT JOIN non_0_amount e USING(id)
    GROUP BY u.id, r.race, u.payer
)
SELECT 
race,
COUNT(DISTINCT id) AS total_users, 																														
COUNT(DISTINCT CASE WHEN transactions_count > 0 THEN id END) AS users_with_transaсtions,																																					
(COUNT(DISTINCT CASE WHEN transactions_count > 0 THEN id END)::float / COUNT(DISTINCT id))::NUMERIC(5,4) AS transaсtions_users_share,					
(COUNT(DISTINCT CASE WHEN payer_users_count > 0 THEN id END)::float / COUNT(DISTINCT CASE WHEN buyers_count > 0 THEN id END))::NUMERIC(5,4)  AS payer_share,	-- share of paying players
ROUND((AVG(CASE WHEN transactions_count > 0 THEN transactions_count END)),2) AS avg_transactions_per_user, 												-- Average number of transactions per purchasing user																				-- Среднее количество транзакций на всех пользователей
ROUND(AVG(total_spent)::NUMERIC,2) AS avg_spent_per_user, 																								-- Average total cost of all purchases per player
ROUND((SUM(total_spent) / SUM(transactions_count))::NUMERIC ,2) AS avg_transaction_cost																	-- Average cost per purchase per player
FROM player_stats
GROUP BY race
ORDER BY avg_spent_per_user DESC;

-- Task 2: Purchase Frequency
-- title: Part2.Task2
 WITH transactions_days AS (
	SELECT
	id,
	transaction_id,
	EXTRACT(DAY FROM date::timestamp - LAG(date::timestamp) OVER(PARTITION BY id ORDER BY date::timestamp)) AS days_between_transactions -- дни между транзакциями
	FROM fantasy.events
	WHERE amount != 0
),
player_stats AS (
	SELECT  
	id,
	payer,
	COUNT(transaction_id) AS transactions_count,				
	ROUND(AVG(days_between_transactions),2) AS avg_days			-- Average number of days between transactions
	FROM fantasy.users u
	LEFT JOIN transactions_days e USING(id)
	GROUP BY u.id, u.payer	
	HAVING COUNT(transaction_id) >= 25
),
ranking AS (
	SELECT 
	id,
	payer,
	transactions_count,
	avg_days,
	NTILE(3) OVER(ORDER BY avg_days DESC) AS users_ranks 	-- Dividing players into three groups based on average days between transactions
	FROM player_stats
)
SELECT
CASE WHEN users_ranks = 1 THEN 'low frequency'
WHEN users_ranks = 2 THEN 'med frequency'
WHEN users_ranks = 3 THEN 'high frequency'
END AS player_group,
COUNT(DISTINCT CASE WHEN transactions_count > 0 THEN id END) AS total_users_with_transactions, 																
COUNT(DISTINCT CASE WHEN payer = 1 THEN id END) AS payer_users,																								
ROUND((COUNT(DISTINCT CASE WHEN payer = 1 THEN id END)::float / COUNT(DISTINCT CASE WHEN transactions_count > 0 THEN id END))::NUMERIC,2) AS payer_share,	
ROUND(AVG(transactions_count)::NUMERIC,2) AS avg_user_transactions,																							-- Average number of transactions per player
ROUND(AVG(avg_days)::NUMERIC,2) AS avg_days_per_user																										-- Average number of days between transactions per player
FROM ranking
GROUP BY users_ranks
ORDER BY player_group;


