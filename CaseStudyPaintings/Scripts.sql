
/*Data Cleaning*/
	
	delete from work 
	where ctid not in (select min(ctid)
						from work
						group by work_id );

	delete from product_size 
	where ctid not in (select min(ctid)
						from product_size
						group by work_id, size_id );

	delete from subject 
	where ctid not in (select min(ctid)
						from subject
						group by work_id, subject );

	delete from image_link 
	where ctid not in (select min(ctid)
						from image_link
						group by work_id );
	
	select * from museum 
	where city ~ '^[0-9]'


/*1) Are there museuems without any paintings?*/
	
	select * from museum m
	where not exists (select 1 from work w
					 where w.museum_id=m.museum_id)



/*2) Identify the museums which are open on both Sunday and Monday. Display museum name, city.*/
	
	select distinct m.name as museum_name, m.city, m.state,m.country
	from museum_hours mh 
	join museum m on m.museum_id=mh.museum_id
	where day='Sunday'
	and exists (select 1 from museum_hours mh2 
				where mh2.museum_id=mh.museum_id 
			    and mh2.day='Monday');


/*3) How many museums are open every single day?*/

	select count(1)
	from (select museum_id, count(1)
		  from museum_hours
		  group by museum_id
		  having count(1) = 7) x;

/*4) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)*/
	select m.name as museum, m.city,m.country,x.no_of_painintgs
	from (	select m.museum_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			group by m.museum_id) x
	join museum m on m.museum_id=x.museum_id
	where x.rnk<=5;


/*5) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)*/
	
	select a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;

/*6) Display the country and the city with most no of museums. */
	
	with cte_country as 
			(select country, count(1)
			, rank() over(order by count(1) desc) as rnk
			from museum
			group by country),
		cte_city as
			(select city, count(1)
			, rank() over(order by count(1) desc) as rnk
			from museum
			group by city)
	select string_agg(distinct country.country,', '), string_agg(city.city,', ')
	from cte_country country
	cross join cte_city city
	where country.rnk = 1
	and city.rnk = 1;


/*7) Which country has the 5th highest no of paintings?*/
	
	with cte as 
		(select m.country, count(1) as no_of_Paintings
		, rank() over(order by count(1) desc) as rnk
		from work w
		join museum m on m.museum_id=w.museum_id
		group by m.country)
	select country, no_of_Paintings
	from cte 
	where rnk=5;


/*8) Which are the 3 most popular and 3 least popular painting styles?*/
	
	with cte as 
		(select style, count(1) as cnt
		, rank() over(order by count(1) desc) rnk
		, count(1) over() as no_of_records
		from work
		where style is not null
		group by style)
	select style
	, case when rnk <=3 then 'Most Popular' else 'Least Popular' end as remarks 
	from cte
	where rnk <=3
	or rnk > no_of_records - 3;