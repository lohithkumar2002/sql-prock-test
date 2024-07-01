create database finalsqlassessment;
use finalsqlassessment;
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);

select*from artists;
select*from artworks;
select*from sales;

--1. Write a query to calculate the price of 'Starry Night' plus 10% tax.

select 1.1*price as priceandtax
from artworks
where title = 'Starry Night';
--2. Write a query to display the artist names in uppercase.

select upper(name) as uppercasenames
from artists;


--3. Write a query to extract the year from the sale date of 'Guernica'.

select year(s.sale_date) as gu_year
from sales s
join artworks a
on s.artwork_id = a.artwork_id
where a.title = 'Guernica';

--4. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.

select sum(s.total_amount)
from sales s
join artworks a
on s.artwork_id = a.artwork_id
where a.title = 'Mona Lisa'
group by s.artwork_id;


select*from artists;
select*from artworks;
select*from sales;
-- Section 2: 2 marks each

--5. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.

select a.artist_id
from artworks a
join sales s
on a.artwork_id = s.artwork_id
where s.quantity  > (select avg(s1.quantity) from sales s1 where s.artwork_id = s1.artwork_id);


--6. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.

select *
from artists a
where a.birth_year < (select avg(a1.birth_year) from artists a1 where a.country = a1.country);

--7. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.

select*from sales
where artwork_id=2;

create nonclustered index s1
on sales(artwork_id);

select*from sales
where artwork_id=2;
--8. Write a query to display artists who have artworks in multiple genres.

select artist_id 
from artworks
group by artist_id 
having count(distinct genre)>1;
--9. Write a query to rank artists by their total sales amount and display the top 3 artists.

select Top 3 ar.artist_id ,s.artwork_id,sum(s.total_amount) as total_sales,
Rank() over(order by sum(s.total_amount) desc) as ranking
from artworks ar
join sales s
on ar.artwork_id = s.artwork_id
group by ar.artist_id ,s.artwork_id;


--10. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.

select artist_id
from artworks 
where genre = 'Cubism'
intersect
select artist_id
from artworks 
where genre = 'Surrealism'


--11. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.

select Top 2 s.artwork_id , sum(s.quantity)
from artworks ar
join
sales s
on ar.artwork_id = s.artwork_id
group by s.artwork_id 
order by sum(ar.price) desc;

--12. Write a query to find the average price of artworks for each artist.
select*from sales;
select*from artworks;
select  artist_id , avg(price) as avg_price
from artworks
group by artist_id;
--13. Write a query to find the artworks that have the highest sale total for each genre.
with 
gross
as
(
select artworks.artwork_id,
Rank() over(partition by genre order by total_amount desc) as ranking
from artworks 
join sales on artworks.artwork_id = sales.artwork_id
)
select*from gross
where ranking =1;

--14. Write a query to find the artworks that have been sold in both January and February 2024.

select artwork_id
from sales 
where format(sale_date , 'MMMM') = 'January 2024'
intersect
select artwork_id
from sales 
where format(sale_date , 'MMMM') = 'February 2024'

--15. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.

--### Section 3: 3 Marks Questions

--16. Write a query to create a view that shows artists who have created artworks in multiple genres.

create view show_artists
as
select artist_id 
from artworks
group by artist_id 
having count(distinct genre)>1;

select*from show_artists;
--17. Write a query to find artworks that have a higher price than the average price of artworks by the same artist.

  select ar.artwork_id
  from artworks ar
  where ar.price > (select avg(ar1.price) from artworks ar1 where ar.artist_id = ar1.artist_id);
--18. Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.

 select a.artist_id , avg(a.price) as avg_price
 from  artworks a
 group by a.artist_id
 having avg(a.price) > (select sum(price) from artworks)
--### Section 4: 4 Marks Questions

--19. Write a query to export the artists and their artworks into XML format.
select artist_id ,
 artwork_id as [artists/artwork_id],
 title as [artists/title],
 genre as [artists/genre],
 price as [artists/price]
 from artworks
 for xml path 


--20. Write a query to convert the artists and their artworks into JSON format.

select artist_id,
 artwork_id as 'artists.artwork_id',
 title as 'artists.title',
 genre as 'artists.genre',
 price as 'artists.price'
 from artworks
 for json path 

### Section 5: 5 Marks Questions
select*from artists;
select*from artworks;
select*from sales;
21. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

create function dbo.t_quant_per_genre()
Returns @t_quant Table (total_quantity int , genre varchar(30))
As
begin
insert into @t_quant 
select sum(s.quantity)  , ar.genre
from artworks ar
join sales s
on ar.artwork_id = s.artwork_id
group by ar.genre 
Return;
end

select *from dbo.t_quant_per_genre();

22. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.

create function dbo.cal_avg(@genre varchar(30))
Returns decimal(10,2)
As
begin
Declare @avg_sales decimal(10,2)
select @avg_sales  = avg(s.total_amount)
from sales s
join artworks ar
on s.artwork_id = ar.artwork_id
where ar.genre = @genre
group by ar.genre;
Return @avg_sales;
end

select dbo.cal_avg('Impressionism') as avg_sales_amount_by_given_genre;
select*from artists;
select*from artworks;
select*from sales;
23. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.

select ar.artist_id, sum(s.total_amount),
Ntile(4) over(order by sum(s.total_amount)) as category
from artworks ar
join sales s
on ar.artwork_id = s.artwork_id
group by ar.artist_id;



24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.

create table artworks_logs(artwork_id int , title varchar(30), descr nvarchar(max) )
create trigger t_change
on 
artworks
for update
as
Begin
insert into artworks_logs(artwork_id,title)
select a.artwork_id, a.title
from inserted a
insert into artworks_logs(descr) values ('title has changed');
end

update artworks 
set title = 'hello'
where artwork_id = 2

select*from artworks_log;

select*from sales;
select*from artworks;
25. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.

create procedure new_sale
@sale_id int , @artwork_id int,@sale_date date,@quantity int,@total_amount decimal(10,2)
as
Begin
Begin Transaction;
Begin try
   if @quantity<0
     Throw 50000,'quantity is negative',1;
   insert into sales values(@sale_id , @artwork_id ,@sale_date ,@quantity ,@total_amount)
   Declare @newprice decimal(10,2);
   select @newprice =  sum(s.total_amount)/sum(s.quantity)
   from sales s
   where s.artwork_id = @artwork_id
   update a
   set price = @newprice
   from sales s
   join artworks a on a.artwork_id = s.artwork_id
   where a.artwork_id = @artwork_id;
commit Transaction;
end try
begin catch
 Rollback Transaction;
 print concat('the error message is' ,Error_message())
end catch
end

Exec  new_sale @sale_id  =5 , @artwork_id =2,@sale_date ='2024-09-09' ,@quantity =4 ,@total_amount = 10000.09;


  

### Normalization (5 Marks)

26. **Question:**
    Given the denormalized table `ecommerce_data` with sample data:

| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

create table customers(
id int primarykey,
customer_name varchar(30) not null,
customer_email nvarchar(100) not null,
)
create table products(
productid int not null,
product_name varchar(30) not null,
product_category varchar(30) not null,
)
create table orders
(
orderid int not null;
order_date date not null,
order_quantity int not null,
order_total_amount decimal(10,2) not null
)
create table injection
(
id int not null,
productid int  not null,
orderid int not null,
foreignkey(id) references customers(id),
foreignkey(productid) references products(productid),
foreignkey(orderid) references orders(orderid)
)


### ER Diagram (5 Marks)

27. Using the normalized tables from Question 26, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.