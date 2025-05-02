-- Digging out insights out of data.

/*
1. Directors who have created both movies and tv shows and display numer of movies and number of
tv shows by them in separate columns.
*/
SELECT nd.director,
	COUNT (DISTINCT CASE WHEN type = 'Movie' THEN nc.show_id END) AS movie_count,
	COUNT (DISTINCT CASE WHEN type = 'TV Show' THEN nc.show_id END) AS tvshow_count
FROM netflix_clean nc
INNER JOIN netflix_director nd ON nc.show_id = nd.show_id
GROUP BY nd.director
HAVING COUNT(DISTINCT type) > 1
ORDER BY nd.director

/*
2. Which country has the highest number of comedy movies?
*/
SELECT TOP 1 nc.country, COUNT(*) count_comedy
FROM netflix_genre ng
INNER JOIN netflix_country AS nc ON nc.show_id = ng.show_id
INNER JOIN netflix_clean ncl ON ncl.show_id = nc.show_id
WHERE ng.genre = 'Comedies' AND ncl.type = 'Movie'
GROUP BY nc.country
ORDER BY count_comedy DESC;

/*
3. For each year which director has maximum number of movies released. There are two columns wrt date
one is DATE which is when it was added on netflix and release year which is actual release year for 
movie. Since this is about performance of various movies/tv shows on netflix we will consider Date the
time it is.

If there are mulitple directors for maximum number of movies in a year include all of them.
*/
WITH movies_by_dir_in_year AS (
	SELECT YEAR(nc.date) year, nd.director director, COUNT(*) no_of_movies,
		RANK() OVER(PARTITION BY YEAR(DATE)  ORDER BY COUNT(*) DESC) AS rn
	FROM netflix_clean nc
	INNER JOIN netflix_director nd ON nd.show_id = nc.show_id
	WHERE nc.type = 'Movie'
	GROUP BY YEAR(date), nd.director 
)

SELECT year, director, no_of_movies 
FROM movies_by_dir_in_year 
WHERE rn = 1
ORDER BY year;

/*
4. Average duration of movies in each genre.
*/

SELECT ng.genre, 
	AVG (CAST( REPLACE(duration, ' min','') AS INT)) as avg_duration
FROM netflix_clean nc
INNER JOIN netflix_genre ng ON ng.show_id = nc. show_id
WHERE type = 'Movie'
GROUP BY ng.genre;

/*
5. Find the list of director who have created horror and comedy movies both. As this is an unusal pair
and since each director kind of specializes in some kind of movies we want to pick such director.
Display director names along with number of comedy and horror movies directed by them.
*/
SELECT director, 
	SUM(CASE WHEN ng.genre = 'Horror Movies' THEN 1 ELSE 0 END) count_horror,
	SUM(CASE WHEN ng.genre = 'Comedies' THEN 1 ELSE 0 END) count_comedies
FROM netflix_director nd
INNER JOIN netflix_genre ng ON ng.show_id = nd.show_id
INNER JOIN netflix_clean nc ON nc.show_id = nd.show_id
WHERE ng.genre IN ('Horror Movies', 'Comedies') AND nc.type = 'Movie'
GROUP BY director
HAVING COUNT(DISTINCT ng.genre) = 2 ;





