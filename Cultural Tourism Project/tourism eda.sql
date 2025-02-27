# Cultural Tourism Exploratory Data Analysis
# Data Used: Cultural Tourism Dataset from Kaggle https://www.kaggle.com/datasets/ziya07/cultural-tourism-dataset

USE tourism;

# Observing dataset as a whole
SELECT *
FROM tourism_data
LIMIT 50
;

# Observing how many different sites were evaluated in this dataset
SELECT DISTINCT `Site Name`
FROM tourism_data
;

# Observing counts of sites to make sure there aren't small counts
SELECT `Site Name`, COUNT(`Site Name`)
FROM tourism_data
GROUP BY `Site Name`
;

# Observing average satisfaction by tour site
SELECT `Site Name`, AVG(`Tourist Rating`) AS `Average Rating`
FROM tourism_data
GROUP BY `Site Name`
ORDER BY 2 DESC
;

# Little variation in average rating on the whole, let's explore whether that changes by age
# Observing the range of ages in this dataset
SELECT MIN(Age), MAX(AGE)
FROM tourism_data
;

# Oberving highest rating among younger people
SELECT `Site Name`, AVG(`Tourist Rating`) AS `Average Rating`
FROM tourism_data
WHERE AGE BETWEEN 18 AND 44
GROUP BY `Site Name`
ORDER BY 2 DESC
;

# Oberving highest satisfaction among older people
SELECT `Site Name`, AVG(`Tourist Rating`) AS `Average Rating`
FROM tourism_data
WHERE AGE BETWEEN 45 AND 70
GROUP BY `Site Name`
ORDER BY 2 DESC
;

# Still little variation, but we can see that tourist ratings of the Eiffel Tower were highest among younger people, 
# while tourist ratings of the Colosseum were highest among older people

# Observing variation in ratings by interest
SELECT `Site Name`, AVG(`Tourist Rating`) AS `Average Rating`
FROM tourism_data
WHERE Interests LIKE '%Architecture%'
GROUP BY `Site Name`
ORDER BY 2 DESC
;
# Macchu Picchu is the highest rated site among those intersted in architecture

SELECT `Site Name`, AVG(`Tourist Rating`) AS `Average Rating`
FROM tourism_data
WHERE Interests LIKE '%Art%'
GROUP BY `Site Name`
ORDER BY 2 DESC
;
# Macchu Picchu is the highest rated site among those intersted in art

SELECT `Site Name`, AVG(`Tourist Rating`) AS `Average Rating`
FROM tourism_data
WHERE Interests LIKE '%Cultural%'
GROUP BY `Site Name`
ORDER BY 2 DESC
;
# Eiffel Tower is the highest rated site among those with cultural interests

# Observing expected vs actual tour times by site
SELECT `Site Name`, 
AVG(`Preferred Tour Duration`) AS `Average Preferred Duration`,
AVG(`Tour Duration`) AS `Average Duration`
FROM tourism_data
GROUP BY `Site Name`
;

# Observing difference between expected and actual tour times by site
SELECT `Site Name`, 
AVG(`Preferred Tour Duration`) - AVG(`Tour Duration`) AS `Average Difference`
FROM tourism_data
GROUP BY `Site Name`
ORDER BY 2 ASC
;
# Macchu Picchu was the closest to preferred tour time on average

