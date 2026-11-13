select * from album2 ;
 -- Q : who is the sernior most employee base on Job title ?
 
select  * from employee 
order by levels desc 
limit 1 ;

-- Q which country have most invoices ?

select count(*) as Count,billing_country from  invoice
group by billing_country
order by count desc ;

-- Q : What are top 3 values of total invoices ?

select * from invoice 
order by total desc  limit 3 ;

--  Q : Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals.
--  Return both the city name & sum of all invoice totals 

select  Sum(total) as Invoice_total , billing_city
from invoice
group by billing_city
order by Invoice_total desc ;

-- Q : Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money 

select  c.first_name, c.last_name, c.customer_id , sum(i.total) as invoice_total 
from customer  as c
join invoice  as i
on c.customer_id = i.customer_id
group by c.customer_id , c.first_name, c.last_name
order by invoice_total desc
limit 1 ;

-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A

select distinct customer.email,customer.first_name,customer.last_name
from customer 
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
WHERE track_id in (
	select track_id from track
    join genre on track.genre_id = genre.genre_id
    where genre.name like 'Rock%' )
 order by customer.email;
 
 
-- Q :  Artist who have most rock music in our dataset.
-- Query that returns artist name and total track count of the top 10 rock bands 

select artist.artist_id, artist.name , count(artist.artist_id) as Number_of_songs 
from track
join album2
on album2.album_id = track.album_id
join artist 
on artist.artist_id =  album2.artist_id
join genre 
on genre.genre_id =track.genre_id
where genre.name like 'Rock%'
group by artist.artist_id , artist.name
order by Number_of_songs
limit 10 ;

-- Q : Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select  name, milliseconds 
from track 
where milliseconds > (
	select avg(milliseconds) as avg_track_length
    from  track )
order by milliseconds desc;


-- Q : Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

with best_selling_artist  As (
select artist.artist_id as artist_id , artist.name  as artist_name,  sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album2 on album2.album_id = track.album_id 
join artist on artist.artist_id = album2.artist_id
group by 1,2
order by 3 desc
limit 1
)
select customer.customer_id,customer.first_name,customer.last_name,bsa.artist_name,
sum(invoice_line.unit_price * invoice_line.quantity) as amount_spent
from invoice 
join customer 
on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album2 on album2.album_id = track.album_id
join best_selling_artist  as  bsa
on bsa.artist_id = album2.artist_id
group by 1,2,3,4
order by 5 desc;


-- Q : We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres

with popular_genre AS
(
	select count(invoice_line.quantity)  as  purchased, customer.country, genre.name, genre.genre_id ,
	row_number () over (partition By  customer.country order by count(invoice_line.quantity) desc) as row_num 
	from invoice_line
	join invoice on invoice.invoice_id =  invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc ,1 desc 
)
select * from popular_genre  where row_num <= 1;

-- Q : Write a query that determines the customer that has spent the most on music for each
-- Country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

with spending_customer AS (
	select customer.customer_id,first_name, last_name, billing_country ,sum(total) as Total_spending ,
    row_number () over(partition by billing_country order by sum(total)desc )  as Row_Numb
    from customer 
    join invoice on  invoice.customer_id =  customer.customer_id
    group by 1,2,3,4
    order by 4 asc ,5 desc )
    select * 
    from spending_customer
    where Row_Numb <=1;







