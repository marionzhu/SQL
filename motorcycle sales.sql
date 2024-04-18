/* 
Create a query to return product_line, the month from date, displayed as 'June', 'July', and 'August', the warehouse, and net_revenue.
net_revenue is calculated by getting the sum of total and multiplying by 1 - payment_fee, rounding to two decimal places.
You will need to filter client_type so that only 'Wholesale' orders are returned.
The results should first be sorted by product_line and month in ascending order, then by net_revenue in descending order. 
*/

SELECT product_line,
    CASE WHEN EXTRACT('month' from date) = 6 THEN 'June'
        WHEN EXTRACT('month' from date) = 7 THEN 'July'
        WHEN EXTRACT('month' from date) = 8 THEN 'August'
    END as month,
    warehouse,
    ROUND(SUM(total * (1 - payment_fee))::numeric, 2) AS net_revenue
FROM sales
WHERE client_type = 'Wholesale'
GROUP BY product_line, warehouse, month
ORDER BY product_line, month, net_revenue DESC;