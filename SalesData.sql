-- KUDOS to https://www.youtube.com/@AngelinaFrimpong

---Inspecting Data
select * FROM [dbo].[sales_data_sample]


---Checking unique values
select distinct status from [dbo].[sales_data_sample] --Nice one to plot
select distinct year_id from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample] ---Nice to plot
select distinct COUNTRY from [dbo].[sales_data_sample] ---Nice to plot
select distinct DEALSIZE from [dbo].[sales_data_sample] ---Nice to plot
select distinct TERRITORY from [dbo].[sales_data_sample] ---Nice to plot

--ANALYSIS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Look at Revenue
Select PRODUCTLINE, sum(sales) as Revenue
FROM [dbo].[sales_data_sample]
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

--Which year has the most Revenue
Select YEAR_ID, sum(sales) as Revenue
FROM [dbo].[sales_data_sample]
GROUP BY YEAR_ID
ORDER BY 2 DESC

--Find out why 2005 revenue drop 
select distinct MONTH_ID
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2005

--Find out which dealsize bring more revenue
Select DEALSIZE, sum(sales) as Revenue
FROM [dbo].[sales_data_sample]
GROUP BY DEALSIZE
ORDER BY 2 DESC

--What was the best month for sales in a specific year? How much was earned that month? 
SELECT MONTH_ID, SUM(SALES) as Revenue, COUNT(ORDERNUMBER) as Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2003
GROUP BY MONTH_ID
ORDER BY 2 DESC

SELECT MONTH_ID, SUM(SALES) as Revenue, COUNT(ORDERNUMBER) as Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2004
GROUP BY MONTH_ID
ORDER BY 2 DESC

SELECT MONTH_ID, SUM(SALES) as Revenue, COUNT(ORDERNUMBER) as Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2005
GROUP BY MONTH_ID
ORDER BY 2 DESC

--November seems like the best month, what product do they sell in November?
SELECT MONTH_ID, PRODUCTLINE, SUM(SALES) as Revenue, COUNT(ORDERNUMBER) as Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2003 and MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC -- CLASSIC CAR is the highest sales


SELECT MONTH_ID, PRODUCTLINE, SUM(SALES) as Revenue, COUNT(ORDERNUMBER) as Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2004 and MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC -- CLASSIC CAR is the highest sales

--Who is our best custoemr--------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #rfm
;with rfm as 
(
	SELECT CUSTOMERNAME, 
		SUM(sales) as MonetaryValue,
		AVG(sales) as AvgMonetaryValue,
		COUNT(ORDERNUMBER) as Frequency,
		MAX(ORDERDATE) last_order_date,
		(SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample]) as max_order_date,
		DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample])) Recency
	FROM [dbo].[sales_data_sample]
	GROUP BY CUSTOMERNAME
),
rfm_calc as(

select r.*, 
	NTILE(4) OVER (ORDER BY Recency DESC) as rfm_recency,
	NTILE(4) OVER (ORDER BY Frequency) as rfm_frequency,
	NTILE(4) OVER (ORDER BY MonetaryValue) as rfm_monetary
FROM rfm r

)
select 
	c.*, rfm_recency + rfm_frequency + rfm_monetary as rfm_cell,
	cast(rfm_recency as VARCHAR) + cast(rfm_frequency as VARCHAR) + CAST(rfm_monetary as VARCHAR) as rfm_cell_string
into #rfm
FROM rfm_calc c

select  CUSTOMERNAME, rfm_recency , rfm_frequency , rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
FROM #rfm

--What products are most sold together
--SELECT * FROM [dbo].[sales_data_sample] WHERE ORDERNUMBER = 10411

SELECT DISTINCT OrderNumber, stuff(

	(SELECT ',' + PRODUCTCODE
	FROM [dbo].[sales_data_sample] as p
	WHERE ORDERNUMBER in (

			SELECT ORDERNUMBER
			FROM (
				Select ORDERNUMBER, COUNT(*) as rn
				FROM [dbo].[sales_data_sample]
				WHERE STATUS = 'Shipped'
				GROUP BY ORDERNUMBER
			)as n
			WHERE rn = 2
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path ('')), 
		1,1, '') as PRODUCTCODES

FROM [dbo].[sales_data_sample] s
ORDER BY 2 DESC
