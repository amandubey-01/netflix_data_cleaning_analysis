SELECT * FROM netflix_raw;

--On data inspection there are some records having title value as '?', this perhaps is some
-- discrepancies. Lets order by title.
SELECT * FROM netflix_raw ORDER BY title
/* 
Lets look why title at certain records like s5023 shows as '?'.

Title of certain shows is in different language while the data type of title in sql server is varchar, 
which can't contain the non english characters. Hence, we have to change the data type to nvarchar 
that can handle characters from other languages as well, also checking the collation settings.

Also, the size of various columns having varchar is max which kind of makes it inefficient 
in terms of memory utilisation. This usually happens when we export from pandas to sql, therefore we
define the table structure and then append the table.
*/
DROP TABLE netflix_raw; 

SELECT DATABASEPROPERTYEX('master', 'Collation');


CREATE TABLE netflix_raw(
	show_id	VARCHAR (10),
	type VARCHAR (10) NULL,
	title NVARCHAR (200),
	director VARCHAR (250) NULL,	
	cast VARCHAR (1000) NULL,	
	country VARCHAR (250) NULL,	
	date_added VARCHAR (20) NULL,	
	release_year INT NULL,	
	rating VARCHAR (10) NULL,	
	duration VARCHAR (10) NULL,	
	listed_in VARCHAR (200) NULL,	
	description VARCHAR (500) NULL
); 


-- 1. Handling duplicates.

SELECT show_id, COUNT(*) 
FROM netflix_raw
GROUP BY show_id
HAVING COUNT(*) > 1;

SELECT * 
FROM netflix_raw 
WHERE show_id IS NULL; 

/* 
 Since the above two queries returns no record, hence there show_id is fit for a primary key.
 We can add the constraint or we can drop the table and define the table structure with show_id
 being a primary key.
*/

ALTER TABLE netflix_raw
ALTER COLUMN show_id VARCHAR (10) NOT NULL;

ALTER TABLE netflix_raw
ADD CONSTRAINT pk PRIMARY KEY (show_id);

/* 
Since this table contains the information of show/films so if it contains same title, it is a
duplicate record.
*/

-- Checking movies with same title.
SELECT * FROM netflix_raw 
WHERE upper(title) IN (
	SELECT upper(title) 
	FROM netflix_raw
	GROUP BY upper(title)
	HAVING COUNT(*) > 1
)
ORDER BY upper(title);

-- Some records with same title can either be Movie or TV Show and be created again so release year is also consequential. 
-- So in order to find actual duplicates we have to club them together.

SELECT * FROM netflix_raw 
WHERE CONCAT(upper(title), type, release_year) IN (
	SELECT CONCAT(upper(title), type, release_year) 
	FROM netflix_raw
	GROUP BY upper(title), type, release_year 
	HAVING COUNT(*) > 1
)
ORDER BY upper(title);

-- There are three duplicates have one copy each, we need to keep only one. So there will be 8804 rows.

SELECT * FROM(
			SELECT *, 
			ROW_NUMBER() OVER(PARTITION BY title, type, release_year ORDER BY show_id) AS rn
			FROM netflix_raw) mid_query
WHERE rn = 1;

/*
2. New table for listed_in, director, country, cast, genre. This needs to be done as single record 
 contains mulitple values separated by columns, that would limit our analysis, let's say we want to
 dig into movies by director, but movies may have multiple directors so to accurately get the insight
 we should have separate record for each director in a movie.
*/

--Table for directors.
SELECT show_id, TRIM(VALUE) AS director
INTO netflix_director
FROM netflix_raw
CROSS APPLY STRING_SPLIT(director,',');

--Table for country
SELECT show_id, TRIM(VALUE) AS country
INTO netflix_country
FROM netflix_raw
CROSS APPLY STRING_SPLIT(country,',');


--Table for genres.
SELECT show_id, TRIM(VALUE) AS genre
INTO netflix_genre
FROM netflix_raw
CROSS APPLY STRING_SPLIT(listed_in,',');

--Table for casts.
SELECT show_id, TRIM(VALUE) AS casts
INTO netflix_cast
FROM netflix_raw
CROSS APPLY STRING_SPLIT(cast,',');

/*
3. Handling data type conversions. Data type of date_added is varchar, it ought to be DATE type.
So, converting it to DATE dtype.
*/

/*
4. Populate missing values in country, duration columns.
*/
SELECT show_id, country FROM netflix_raw WHERE country IS NULL;

SELECT * FROM netflix_country WHERE show_id = 's1001';
/* 
We can populate null values in country by making a assumption if a director has made some movie
in one country the other movies by the same director will also be in that country. While this isn't a 
guaranteed it is still better than dropping such records as that will be huge loss.
*/
-- String split leaves those record where it is null, so we have to insert rows with country value NULL
-- into netflix_country.
INSERT INTO netflix_country
SELECT show_id, dc.country 
FROM netflix_raw nr
INNER JOIN
	(SELECT director, country 
	FROM netflix_country nc
	INNER JOIN netflix_director nd ON nc.show_id = nd.show_id
	GROUP BY director, country) dc
ON nr.director = dc.director
WHERE nr.country IS NULL;

-- Null in duration.
SELECT * FROM netflix_raw WHERE duration IS NULL; -- Somehow the values got swapped btw rating and duration.

/*
Carving a clean netflix data having no duplicate, handling some of the null values, fixing duration and
rating swap.
As we have different table for cast, country, director, genre we can remove it from this table.
*/

WITH mid_query AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY title, type, release_year ORDER BY show_id) AS rn
FROM netflix_raw
)
SELECT 
	show_id, type, title, CAST(date_added AS DATE) AS DATE, 
	release_year, 
	CASE WHEN duration IS NULL THEN NULL ELSE rating END AS rating, 
	CASE WHEN duration IS NULL THEN RATING ELSE duration END AS duration, 
	description 
INTO netflix_clean
FROM mid_query
WHERE rn = 1 

