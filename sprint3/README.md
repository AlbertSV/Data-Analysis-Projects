# Project Overview

## Task

You are an analyst at **Megaset**, a federal mobile network operator. The company offers basic service packages that include phone calls, internet traffic, and messages.

Every year, customers increasingly use communication services, leading to growth in the number of calls and internet traffic volume. The product team wants to analyze the current tariff plans and client activity, as well as estimate the share of clients who exceed their tariff limits.

This analysis will help update the tariff plan lineup according to customer needs and develop special offers for the most active users.

**Megaset** offers two tariff plans: **Smart** and **Ultra**. They differ by monthly fee and the included service packages:
### Tariff Plans

| Tariff | Monthly Fee | Call Duration (minutes) | Internet Traffic (GB) | Number of Messages |
|--------|-------------|------------------------|----------------------|--------------------|
| Smart  | 550 RUB     | 500                    | 15                   | 50                 |
| Ultra  | 1950 RUB    | 3000                   | 30                   | 1000               |

### Prices for Services Exceeding the Tariff Limits

| Tariff | Call Minute Price | Internet Traffic Price (per GB) | Message Price |
|--------|-------------------|---------------------------------|---------------|
| Smart  | 3 RUB             | 200 RUB                        | 3 RUB         |
| Ultra  | 1 RUB             | 150 RUB                        | 1 RUB         |


## Data Description

The database consists of several tables in the **telecom** schema: `users`, `calls`, `internet`, `messages`, and `tariffs`.

### Table: users

Contains information about users.

| Field       | Description                                      |
|-------------|------------------------------------------------|
| user_id     | User identifier (Primary key)                   |
| age         | User age                                       |
| churn_date  | Contract end date (empty string if active)     |
| city        | User's city of residence                         |
| first_name  | User's first name                               |
| last_name   | User's last name                                |
| reg_date    | User registration date                          |
| tariff      | User's tariff plan (Foreign key linked to `tariff_name` in `tariffs` table) |

### Table: calls

Contains information about calls.

| Field     | Description                                       |
|-----------|-------------------------------------------------|
| id        | Call identifier (Primary key)                    |
| call_date | Call date                                        |
| duration  | Call duration in minutes                          |
| user_id   | User identifier (Foreign key linked to `users`) |

### Table: internet

Contains information about internet sessions.

| Field        | Description                                      |
|--------------|------------------------------------------------|
| id           | Session identifier (Primary key)                |
| mb_used      | Megabytes of internet traffic used during session |
| session_date | Session date                                    |
| user_id      | User identifier (Foreign key linked to `users`) |

### Table: messages

Contains information about sent messages.

| Field        | Description                                    |
|--------------|------------------------------------------------|
| id           | Message identifier (Primary key)               |
| message_date | Date the message was sent                      |
| user_id      | User identifier (Foreign key linked to `users`) |

### Table: tariffs

Contains information about tariff plans.

| Field               | Description                                                   |
|---------------------|---------------------------------------------------------------|
| tariff_name         | Tariff name (Primary key)                                      |
| messages_included   | Number of free messages included in the tariff                |
| mb_per_month_included | Amount of internet traffic (MB) included in the tariff       |
| minutes_included    | Number of free call minutes included in the tariff            |
| rub_monthly_fee     | Monthly subscription fee in rubles                             |
| rub_per_gb          | Cost per additional gigabyte of internet traffic (1 GB = 1024 MB) |
| rub_per_message     | Cost per message beyond the included package                   |
| rub_per_minute      | Cost per call minute beyond the included package               |


<img width="2880" height="1691" alt="image" src="https://github.com/user-attachments/assets/1eae9896-8659-4ed3-acdb-4955c9663d61" />

