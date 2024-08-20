** EDA **

-- check no. of unique apps in both tables --

select count(distinct id) as unique_ids
from applestore;

select count(distinct id) as unique_ids
from applestore_description_combined;

-- check for missing values in key fields --

select count(*)
from applestore
where track_name isnull or user_rating isnull or prime_genre isnull;

select count(*)
from applestore_description_combined
where app_desc isnull;

-- No. of apps per genre --

select prime_genre, count(track_name)
from applestore
group by prime_genre
order by count(track_name) desc;

-- Overview of app's ratings --

select min(user_rating) as min_rating,
       max(user_rating) as max_rating,
	   round(avg(cast(user_rating as decimal)),2) as avg_rating
from applestore;

** Analysis **

-- check whether free apps or paid apps have better rating --

select case
            when cast(price as decimal)> 0 then 'paid'
			else 'free'
		end as app_type,
		round(avg(cast(user_rating as decimal)),2) as avg_rating
from applestore
group by app_type;

-- check whether apps that support more languages have higher rating --

select case
            when cast(lang_num as int)< 10 then '<10 languages'
			when cast(lang_num as int) between 10 and 30 then '10-30 languages'
			else '> 30 languages'
		end as lang_count,
		round(avg(cast(user_rating as decimal)),2) as avg_rating
from applestore
group by lang_count
order by lang_count desc;

-- check genres with low ratings --

select prime_genre, round(avg(cast(user_rating as decimal)),2) as avg_rating
from applestore
group by prime_genre
order by round(avg(cast(user_rating as decimal)),2) asc
limit 10;

-- check whether description length has effect on ratings --

select case
            when length(adc.app_desc)< 500 then 'short'
			when length(adc.app_desc) between 500 and 1000 then 'medium'
			else 'long'
		end as desc_length,
		round(avg(cast(user_rating as decimal)),2) as avg_rating
from applestore aps
join applestore_description_combined adc 
on aps.id= adc.id
group by desc_length
order by round(avg(cast(user_rating as decimal)),2) desc;

-- check top rated apps for each genre --
with t1 as
(
select prime_genre, user_rating, track_name, rank() over(partition by prime_genre order by cast(user_rating as decimal) desc, cast(rating_count_tot as int) desc) as rnk
from applestore
)

select prime_genre, user_rating, track_name
from t1
where rnk= 1;




	  