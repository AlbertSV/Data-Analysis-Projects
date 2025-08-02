-- After the initial data exploration, we proceed with analysis and statistical calculations for the clients

-- For each tariff plan, count unique active clients whose monthly expenses exceed the subscription fee.

---- Client's total call duration per month:
WITH monthly_duration AS (
    SELECT user_id,
           -- Extracting the month from the call date:
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
---- Total amount of internet traffic used per month:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
---- Total number of messages per month:
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),
---- Creating a unique pair of user_id and dt_month:
user_activity_months AS (
	-- First set of user_id and dt_month values considering client's call activity:
    SELECT user_id, dt_month
    FROM monthly_duration
    UNION
	-- Second set of user_id and dt_month values considering client's internet activity:
    SELECT user_id, dt_month
    FROM monthly_internet   
    UNION
	-- Third set of user_id and dt_month values considering client's internet activity:
    SELECT user_id, dt_month
    FROM monthly_sms
),
---- Joining the calculated client activity values into one table:
users_stat AS (
    SELECT u.user_id,
           u.dt_month,
           month_duration,
           month_mb_traffic,
           month_sms
	-- Using data from the CTE user_activity_months as the main table:
    FROM user_activity_months AS u
	-- Sequentially joining data on calls, internet traffic, and messages.
	-- Using pairs of user_id and dt_month when merging data:
    LEFT JOIN monthly_duration AS md ON u.user_id = md.user_id AND u.dt_month= md.dt_month
    LEFT JOIN monthly_internet AS mi ON u.user_id = mi.user_id AND u.dt_month= mi.dt_month
    LEFT JOIN monthly_sms AS mm ON u.user_id = mm.user_id AND u.dt_month= mm.dt_month
),
---- Limit exceedance by each type of service:
user_over_limits AS (
    SELECT us.user_id,
           us.dt_month,
           u.tariff,
           us.month_duration,
           us.month_mb_traffic,
           us.month_sms,
		-- Condition when client's call duration exceeds the tariff limit:
        CASE 
            WHEN us.month_duration >= t.minutes_included 
            THEN (us.month_duration - t.minutes_included)
            ELSE 0
        END AS duration_over,
		-- Condition when monthly internet traffic exceeds the tariff limit:
        CASE 
            WHEN us.month_mb_traffic >= t.mb_per_month_included 
            THEN (us.month_mb_traffic - t.mb_per_month_included) / 1024::real
            ELSE 0
        END AS gb_traffic_over,
		-- Condition when the number of messages per month exceeds the tariff limit:
        CASE 
            WHEN us.month_sms >= t.messages_included 
            THEN (us.month_sms - t.messages_included)
            ELSE 0
        END AS sms_over
    FROM users_stat AS us
    LEFT JOIN (SELECT tariff, user_id FROM telecom.users) AS u ON us.user_id = u.user_id
    LEFT JOIN telecom.tariffs AS t ON u.tariff = t.tariff_name
),
---- Client expenses for each month:
users_costs AS (
    SELECT uol.user_id,
           uol.dt_month,
           uol.tariff,
           uol.month_duration,
           uol.month_mb_traffic,
           uol.month_sms,
           t.rub_monthly_fee, 
           t.rub_monthly_fee + uol.duration_over * t.rub_per_minute
           + uol.gb_traffic_over * t.rub_per_gb + uol.sms_over * t.rub_per_message AS total_cost 
    FROM user_over_limits AS uol
    LEFT JOIN telecom.tariffs AS t ON uol.tariff = t.tariff_name
)
SELECT
uc.tariff,
COUNT(DISTINCT uc.user_id) as total_users,
ROUND(AVG(uc.total_cost)::numeric,2) as avg_total_cost,
ROUND(AVG(uc.total_cost - uc.rub_monthly_fee)::numeric, 2) as overcost
FROM users_costs as uc
LEFT JOIN telecom.users as u USING(user_id)
WHERE u.churn_date is NULL and uc.total_cost>uc.rub_monthly_fee
GROUP BY uc.tariff

