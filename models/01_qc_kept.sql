{{ config(materialized='view') }}

with
measurement_pipeline as (
	select
		item_id,
		item_type,
		product_line,
		event_date,
		event_type,
		age_days,
		round(cast(age_days / {{ var('period_days') }} as numeric), 0) as ages,
		mass,
		case when age_days != lag(age_days) over(partition by item_id order by event_date asc)
			then (mass - lag(mass) over(partition by item_id order by event_date asc)) / (age_days - lag(age_days) over(partition by item_id order by event_date asc))
		 	when age_days = lag(age_days) over(partition by item_id order by event_date asc) then 999 end as growth,
		factory_id
	from
		(select
			est.item_id,
			pas.item_type,
			pas.product_line,
			event_date,
			event_type,
			est.event_date - pas.start_date as age_days,
			mass,
			est.factory_id
		from
			{{ ref('measurements') }} as est
		left join
			{{ ref('items') }} as pas on est.item_id = pas.item_id) as subquery_1
	where
		age_days >= 0 and
		mass > 0
),
outliers_detection as (
	select
		ages,
		item_type,
		product_line,
		case when lower_value between avg_lower_value / {{ var('left_coef') }} and avg_lower_value * {{ var('left_coef') }} then lower_value else avg_lower_value / {{ var('left_coef') }} end as lower_value,
		case when upper_value between avg_upper_value / {{ var('right_coef') }} and avg_upper_value * {{ var('right_coef') }} then upper_value else avg_upper_value * {{ var('right_coef') }} end as upper_value
	from
		(select
			ages,
			item_type,
			product_line,
			lower_value,
			upper_value,
			avg(lower_value) over(partition by ages) as avg_lower_value,
			avg(upper_value) over(partition by ages) as avg_upper_value,
			count
		from
			(select
				ages,
				product_line,
				item_type,
				q1 - ((q3 - q1) * ({{ var('iqr_min') }} + ((({{ var('iqr_max') }} - {{ var('iqr_min') }}) / maxtime) * ages))) as lower_value,
				q3 + ((q3 - q1) * ({{ var('iqr_min') }} + ((({{ var('iqr_max') }} - {{ var('iqr_min') }}) / maxtime) * ages))) as upper_value,
				count
			from
				(select
					ages,
					product_line,
					item_type,
					percentile_cont({{ var('q_1_max') }} - ((({{ var('q_1_max') }} - {{ var('q_1_min') }}) / maxtime) * ages)) within group (ORDER BY mass) AS q1,
					percentile_cont({{ var('q_3_min') }} + ((({{ var('q_3_max') }} - {{ var('q_3_min') }}) / maxtime) * ages)) within group (ORDER BY mass) AS q3,
					maxtime,
					count(*) as count
				from
					(select
						ages,
						product_line,
						item_type,
						mass,
						max(ages) over() as maxtime
					from
						measurement_pipeline
					where
						(growth between -3 and 3 or growth is null) and
						event_type != 'transfer'
					group by
						ages,
						product_line,
						item_type,
						mass) as subquery_1
				group by
					ages,
					product_line,
					item_type,
					maxtime) as subquery_2
			order by
				ages) as subquery_3
	) as subquery_4
)
select
	item_id,
	event_date,
	age_days,
	event_type,
	mass,
	factory_id
from
	measurement_pipeline as ds
left join
	outliers_detection as od on ds.ages = od.ages and ds.product_line = od.product_line and ds.item_type = od.item_type
where
	ds.mass between lower_value and upper_value and (growth between -3 and 3 or growth is null)
order by
	ds.item_id asc, 
	event_date asc
