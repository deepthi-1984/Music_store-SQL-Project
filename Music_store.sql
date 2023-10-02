create table album(album_id int not null primary key,
				  title varchar(255) not null,
				  artist_id int not null);

alter table album add constraint fk_album_artist_id foreign key(artist_id) references artist(artist_id);

create table artist(artist_id serial not null primary key,
				   name varchar(255) not null);
				   
create table genre(genre_id serial not null primary key,
				  name varchar(255) not null);	
				  
create table media_type(media_type_id serial not null primary key,
					   name varchar(255) not null);	
					   
create table track(track_id serial not null primary key,
				  name varchar(255) not null,
				  album_id int not null references album(album_id),
				  media_type_id int not null references media_type(media_type_id),
				  genre_id int not null references genre(genre_id),
				  composer varchar(255) not null,
				  milliseconds int not null,
				  bytes int not null,
				  unit_price float not null);
				  
alter table track alter column composer drop not null;		

select * from track;

create table playlist(playlist_id serial not null primary key,
					 name varchar(255) not null);
					 
create table playlist_track(playlist_id int not null references playlist(playlist_id),
						   track_id int not null references track(track_id));
						   
create table invoice_line(invoice_line_id serial not null primary key,
						 invoice_id int not null references invoice(invoice_id),
						 track_id int not null references track(track_id),
						 unit_price float not null,
						 quantity int not null);
						 
create table invoice(invoice_id serial not null primary key,
					customer_id int not null,
					invoice_date timestamp not null,
					billing_address varchar(255) not null,
					billing_city varchar(255) not null,
					billing_state varchar(255) not null,
					billing_country varchar(50) not null,
					billing_postal_code varchar(50) not null,
					total float not null);
					
alter table invoice add constraint fk_invoice_customer_id foreign key(customer_id)
references customer(customer_id)

create table customer(customer_id serial not null primary key,
					 first_name varchar(255) not null,
					 last_name varchar(255) not null,
					 company varchar(255),
					 address varchar(255) not null,
					 city varchar(255) not null,
					 state varchar(20),
					 country varchar(50) not null, 
					 postal_code varchar(50) not null,
					 phone varchar(50) not null,
					 fax varchar(50),
					 email varchar(50) not null,
					 support_rep_id int not null);

alter table customer alter column postal_code drop not null;
					
alter table customer alter column phone drop not null;
					
select * from customer;	

create table employee(employee_id serial not null primary key,
					 last_name varchar(50) not null,
					 first_name varchar(50) not null,
					 title varchar(255) not null,
					 reports_to int,
					 levels varchar(10) not null,
					 birthdate timestamp not null,
					 hire_date timestamp not null,
					 address varchar(255) not null,
					 city varchar(50) not null,
					 state varchar(10) not null,
					 country varchar(50) not null,
					 postal_code varchar(10) not null,
					 phone varchar(50) not null,
					 fax varchar(50) not null,
					 email varchar(100)not null);
					 
alter table customer add constraint fk_customer_support_rep_id foreign key(support_rep_id)
references employee(employee_id)

/* Analysis */
/* Q1: Who is the senior most employee, find name and job title */

select last_name,first_name,title from employee 
order by levels desc limit 1;

/* Q2: Which countries have the most Invoices? */

select count(customer_id),billing_country from invoice
group by billing_country
order by count(customer_id) desc limit 1;

/* Q3: What are the top 3 values of total invoices? */

select total from invoice
order by total desc limit 3;

/* Q4: Which city has the best customers? We would like to throw a
promotional Music Festival in the City we made the most money. Write a
query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals.*/

select * from invoice;

select billing_city,sum(total) from invoice
group by billing_city
order by sum(total) desc limit 1;

/*Q5: Who is the best customer? The customer who has spent the most
money will be declared the best customer. Write a query that returns
the person who has spent the most money.*/

select * from invoice;

select c.*, sum(i.total) as total from customer as c
join invoice as i on i.customer_id=c.customer_id
group by c.customer_id
order by total desc limit 1;

/*Q6: Find city wise best customer? The customer who has spent the most
money will be declared the best customer in that city. Write a query that returns
the person who has spent the most money city wise.*/

select c.customer_id,c.first_name,c.last_name,c.city,sum(i.total) as total from customer as c
join invoice as i on i.customer_id=c.customer_id
group by c.city,c.customer_id
order by total desc;

/*Q7: Write query to return the email, first name, last name, & Genre
of all Rock Music listeners. Return your list ordered alphabetically
by email starting with A */

select distinct c.email as mail,c.first_name as first_name,c.last_name as last_name,g.genre_id from 
customer c
join invoice as i on i.customer_id=c.customer_id
join invoice_line as il on il.invoice_id=i.invoice_id
join track as t on t.track_id=il.track_id
join genre as g on g.genre_id=t.genre_id
where g.name='Rock'
order by 1;

/* Using joins and suquery */
select distinct c.email as mail,c.first_name as first_name,c.last_name as last_name from
customer c
join invoice i using(customer_id)
join invoice_line il using(invoice_id)
where track_id in(select track_id from track join genre g using(genre_id) where g.name='Rock');

/*Q8: Let's invite the artists who have written the most rock music in
our dataset. Write a query that returns the Artist name and total
track count of the top 10 rock bands*/

SELECT ar.name,count(*) as total,ar.artist_id from artist ar
join album a using(artist_id)
join track t using(album_id)
join genre g using(genre_id)
where g.name='Rock'
group by ar.name,ar.artist_id
order by total desc
limit 10;


/*Q9: Return all the track names that have a song length longer than
the average song length. Return the Name and Milliseconds for
each track. Order by the song length with the longest songs listed
first.*/

select * from track;

select name,milliseconds from track
group by name,milliseconds
having (milliseconds >  avg(milliseconds))
order by milliseconds desc;

select name,milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

/*Q10: Find how much amount spent by each customer on artists? Write a
query to return customer name, artist name and total spent*/

select  c.first_name||' '||c.last_name as customer_name,ar.name as artist_name,
		sum(il.unit_price * il.quantity) as total_spent
		from customer c
		join invoice using(customer_id)
		join invoice_line il using(invoice_id)
		join track t using(track_id)
		join album al using(album_id)
		join artist ar using(artist_id)
		group by c.customer_id,ar.artist_id
		order by customer_name,artist_name;
		
/*Q11: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest
amount of purchases. Write a query that returns each country along with
the top Genre. For countries where the maximum number of purchases
is shared return all Genres.*/

select  g.genre_id,g.name as Genre_name, c.country as Country ,count(il.quantity) as Total_purhcases
from genre g
join track t using(genre_id)
join invoice_line il using(track_id)
join invoice i using(invoice_id)
join customer c using(customer_id)
group by g.genre_id,Genre_name,Country
order by count(il.quantity) desc;


with cte as(
				select genre.genre_id as genre_id,
						genre.name as genre_name,
						customer.country as country,
						count(invoice_line.quantity) as Total_purchases,
						row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as ranking
				from genre
				join track using(genre_id)
				join invoice_line using(track_id)
				join invoice using(invoice_id)
				join customer using(customer_id)
				group by 1,3
)

select country,genre_id,genre_name,total_purchases from cte where ranking=1;


/* Q12: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

select * from invoice;

with cte as(
				select (customer.first_name || ' '|| customer.last_name) as customer_name,
						customer.customer_id as customer_id,
						sum(invoice.total) as total_spent,
						customer.country as country,
						row_number() over(partition by customer.country order by sum(invoice.total) desc) as Ranking
				from customer
				join invoice using(customer_id)
				group by 1,2,4
				order by 2,3 desc
)	
select customer_name,customer_id,total_spent,country from cte where ranking =1;