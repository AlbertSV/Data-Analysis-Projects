# Project: Analytical Tasks

The analytical project consists of several parts:

- **Exploratory Data Analysis**  
- **Ad hoc task solutions** from the marketing team of the game *Secrets of Darkwood*

## Data Description
General information about the data:

## Data Description

### Table: users  
Contains information about players.

| Field           | Description                                                                                     |
|-----------------|-------------------------------------------------------------------------------------------------|
| id              | Player identifier (Primary key)                                                                |
| tech_nickname   | Player's nickname                                                                              |
| class_id        | Class identifier (Foreign key linked to `class_id` in `classes` table)                         |
| ch_id           | Legendary skill identifier (Foreign key linked to `ch_id` in `skills` table)                   |
| birthdate       | Player's birth date                                                                            |
| pers_gender     | Character gender                                                                              |
| registration_dt | User registration date                                                                         |
| server          | Server where the user plays                                                                   |
| race_id         | Character race identifier (Foreign key linked to `race_id` in `race` table)                    |
| payer           | Indicator if the player is paying (1 = paying, 0 = non-paying)                                |
| loc_id          | Country identifier (Foreign key linked to `loc_id` in `country` table)                         |

### Table: events  
Contains information about purchases.

| Field          | Description                                                                                   |
|----------------|-----------------------------------------------------------------------------------------------|
| transaction_id | Purchase identifier (Primary key)                                                            |
| id             | Player identifier (Foreign key linked to `id` in `users` table)                              |
| date           | Purchase date                                                                               |
| time           | Purchase time                                                                               |
| item_code      | Epic item code (Foreign key linked to `item_code` in `items` table)                         |
| amount         | Purchase cost in the in-game currency “Paradise Petals”                                     |
| seller_id      | Seller identifier                                                                           |

### Table: skills  
Contains information about legendary skills.

| Field          | Description                                                                                   |
|----------------|-----------------------------------------------------------------------------------------------|
| ch_id          | Legendary skill identifier (Primary key)                                                     |
| legendary_skill| Name of the legendary skill                                                                  |

### Table: race  
Contains information about character races.

| Field          | Description                                                                                   |
|----------------|-----------------------------------------------------------------------------------------------|
| race_id        | Character race identifier (Primary key)                                                      |
| race           | Name of the race                                                                             |

### Table: country  
Contains information about players’ countries.

| Field          | Description                                                                                   |
|----------------|-----------------------------------------------------------------------------------------------|
| loc_id         | Country identifier (Primary key)                                                             |
| location       | Country name                                                                                |

### Table: classes  
Contains information about character classes.

| Field          | Description                                                                                   |
|----------------|-----------------------------------------------------------------------------------------------|
| class_id       | Class identifier (Primary key)                                                               |
| class          | Name of the character class                                                                 |

### Table: items  
Contains information about epic items.

| Field          | Description                                                                                   |
|----------------|-----------------------------------------------------------------------------------------------|
| item_code      | Epic item code (Primary key)                                                                 |
| game_items     | Name of the epic item                                                                        |

<img width="2881" height="1906" alt="image" src="https://github.com/user-attachments/assets/abce4424-1be4-442d-bd47-5612dad286ee" />


## Task 1: Analyzing the Share of Paying Players

1. Calculate the share of paying players across the entire dataset and output the following fields:  
   a. Total number of players registered in the game  
   b. Number of paying players  
   c. Share of paying players relative to the total number of registered players  

2. Investigate whether the share of paying players depends on the chosen character race. For each character race, output:  
   a. Character race  
   b. Number of paying players of this race  
   c. Total number of registered players of this race  
   d. Share of paying players among all registered players of this race

## Task 2: Analysis of In-Game Purchases

Obtain key statistical metrics for the `amount` field of purchases, including:  
- Total number of purchases  
- Total cost of all purchases  
- Minimum and maximum purchase amounts  
- Mean, median, and standard deviation of purchase amounts  

Check if there are any purchases with a zero amount.  
Study the popularity of epic items.

## Part 2: Ad hoc Task Solutions

### Task: Player Activity Dependence on Character Race

For each character race, calculate the following metrics:  
- Total number of registered players  
- Number of players who make in-game purchases and their share of the total registered players  
- Share of paying players among those who made in-game purchases  
- Average number of purchases per player who made in-game purchases  
- Average cost per purchase per player who made in-game purchases  
- Average total cost of all purchases per player who made in-game purchases


