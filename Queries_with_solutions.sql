/*ANALYSIS USING SQL QUERIES*/

/* Q1: Who is the senior most employee, find name and job title */

SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;



/* Q2: Which countries have the most Invoices? */

SELECT 
    COUNT(*) AS total_invoices, billing_country as country
FROM
    invoice
GROUP BY billing_country
ORDER BY total_invoices DESC
LIMIT 1;



/* Q3: What are top 3 values of total invoice? */

SELECT DISTINCT
    (total) AS top_three_invoice
FROM
    invoice
ORDER BY total DESC
LIMIT 3;



/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT 
    billing_city as city, ROUND(SUM(total), 2) AS invoice_total
FROM
    invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;



/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(i.total) AS total_invoice
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id,c.first_name, c.last_name
ORDER BY total_invoice DESC
LIMIT 1;




/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT 
    distinct first_name, last_name, email,genre.name as genre_name
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        JOIN
    track ON il.track_id = track.track_id
        JOIN
    genre ON track.genre_id = genre.genre_id
WHERE
    genre.name = 'rock'
    order by email;




/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT 
    artist.name, COUNT(*) as track_count
FROM
    artist
        JOIN
    album ON artist.artist_id = album.artist_id
        JOIN
    track ON album.album_id = track.album_id
        JOIN
    genre ON track.genre_id = genre.genre_id
WHERE
    genre.name LIKE 'rock'
GROUP BY artist.name
ORDER BY COUNT(*) DESC
LIMIT 10;



/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_length
        FROM
            track)
ORDER BY milliseconds DESC;



/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT 
    c.first_name AS customer_name,
    artist.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        JOIN
    track ON il.track_id = track.track_id
        JOIN
    album ON track.album_id = album.album_id
        JOIN
    artist ON album.artist_id = artist.artist_id
GROUP BY c.customer_id , c.first_name , c.last_name , artist.name
ORDER BY total_spent DESC;



/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH genre_total_purchase AS (
    SELECT 
        i.billing_country,
        COUNT(il.quantity) AS tp,
        g.name AS genre_name,
        RANK() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS rn
    FROM 
        invoice i
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id
    JOIN 
        track t ON il.track_id = t.track_id
    JOIN 
        genre g ON t.genre_id = g.genre_id
    GROUP BY 
        i.billing_country, g.name
)
SELECT 
    billing_country,
    genre_name,
    tp
FROM 
    genre_total_purchase 
WHERE 
    rn = 1;




/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with total_spent as (SELECT 
    CONCAT(first_name, ' ', last_name) AS customer_name,
    i.customer_id,
    ROUND(SUM(i.total), 2) AS total_spent,
    billing_country AS country,rank() over(partition by billing_country order by ROUND(SUM(i.total), 2) desc) as rn
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY first_name , last_name , customer_id , billing_country)
select customer_name,country,total_spent from total_spent where rn=1
order by country ;

