-- test 
SELECT CATEGORY_NAME, sum(PRICE *QUANTITY)/sum(QUANTITY)
FROM business_value as bv
left join dim_product as dp
    on bv.PRODUCT_ID = dp.PRODUCT_ID and bv.ORDER_DATE BETWEEN dp.DATE_FROM and dp.DATE_TO
left join dim_category as dc
    on dp.LOWEST_LEVEL_ID = dc.LOWEST_LEVEL_ID
where extract(year from bv.ORDER_DATE) = 2024 
group by CATEGORY_NAME;



SELECT distinct FAMILY_NAME, sum(BV_EURO) over(partition by FAMILY_NAME)/ sum(BV_EURO) over () as pec,
FROM business_value as bv
left join dim_product as dp
    on bv.PRODUCT_ID = dp.PRODUCT_ID and bv.ORDER_DATE BETWEEN dp.DATE_FROM and dp.DATE_TO
left join dim_category as dc
    on dp.LOWEST_LEVEL_ID = dc.LOWEST_LEVEL_ID
where extract(year from bv.ORDER_DATE) = 2024 
-- group by FAMILY_NAME;


select count(distinct case when bv2.TRANSACTION_ID is not null then bv1.TRANSACTION_ID end) / count(distinct bv1.TRANSACTION_ID)
from business_value as bv1 
left join business_value as bv2 
    on bv1.USER_ID = bv2.USER_ID
where datediff(bv1.ORDER_DATE, bv2.ORDER_DATE) between 1 and  365 
    and year(bv1.ORDER_DATE) = 2023
    and year(bv2.ORDER_DATE) >= 2023

select post, round(avg(TIMESTAMPDIFF(minute, first_clockin,last_clockin)/60),3) as work_hours
from attendent_tb as a
join staff_tb as s
    on a.staff_id = s.staff_id
group by post
order by work_hours desc