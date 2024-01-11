
-- Create New DATABASE for Backup
SELECT *
INTO new_online_retail
FROM [dbo].[online_retail$]

-- Data Exploration And Data Cleaning
select *
FROM [dbo].[online_retail_new1]


SELECT *
FROM online_retail_new1

DELETE FROM online_retail_new1
WHERE InvoiceNo is NULL;

SELECT InvoiceNo
FROM online_retail_new1
WHERE InvoiceNo is NULL;


SELECT Description
FROM online_retail_new1
WHERE Description IS NULL;

DELETE FROM online_retail_new1
WHERE Description is NULL;

SELECT Description
FROM online_retail_new1
WHERE Description IS NULL;

SELECT Description
FROM online_retail_new1
WHERE Description LIKE '%?%' ;


SELECT DISTINCT Description
FROM online_retail_new1
WHERE Description LIKE '%?%'

DELETE FROM online_retail_new1
WHERE Description LIKE '%?%';


SELECT Description
FROM online_retail_new1
WHERE Description = '20713';

DELETE FROM online_retail_new1
WHERE Description  = '20713';

SELECT *
FROM online_retail_new1
WHERE Description LIKE '%*%'


UPDATE online_retail_new1
SET Description =
	CASE 
		WHEN Description= '*Boombox Ipod Classic' THEN 'Boombox Ipod Classic'
		WHEN Description= '*USB Office Mirror Ball' THEN 'USB Office Mirror Ball'
		ELSE Description
	END;


SELECT *
FROM online_retail_new1
WHERE Description = 'USB Office Mirror Ball'


SELECT *
FROM online_retail_new1
WHERE Quantity LIKE '%-%'

UPDATE online_retail_new1
SET Quantity = REPLACE(Quantity, '-', '')
WHERE Quantity LIKE '-%';

SELECT *
FROM online_retail_new1
WHERE CustomerID IS NULL;

DELETE FROM online_retail_new1
WHERE CustomerID IS NULL;



-- Customer Segmentation


--- RFM Analysis

WITH RFMData11 AS (
    SELECT
        CustomerID,
      DATEDIFF(DAY, MAX(InvoiceDate), GETDATE()) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(Quantity * UnitPrice) AS Monetary
    FROM
        online_retail_new1
    GROUP BY
        CustomerID
)

--- Normalizing RFM values (optional)
, NormalizedRFM AS (
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        PERCENT_RANK() OVER (ORDER BY Recency) AS RecencyRank,
        PERCENT_RANK() OVER (ORDER BY Frequency DESC) AS FrequencyRank,
        PERCENT_RANK() OVER (ORDER BY Monetary DESC) AS MonetaryRank
    FROM
        RFMData11
)


--- Display the RFM scores
SELECT
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    RecencyRank,
    FrequencyRank,
    MonetaryRank
FROM
    NormalizedRFM
ORDER BY
    MonetaryRank DESC 


--- Customer Segment
SELECT
    CustomerID,
    DATEDIFF(DAY, MAX(InvoiceDate), GETDATE()) AS Recency,
    COUNT(DISTINCT InvoiceNo) AS Frequency,
    SUM(Quantity * UnitPrice) AS Monetary,
    CASE
        WHEN PERCENT_RANK() OVER (ORDER BY DATEDIFF(DAY, MAX(InvoiceDate), GETDATE())) <= 0.2 AND
             PERCENT_RANK() OVER (ORDER BY COUNT(DISTINCT InvoiceNo) DESC) >= 0.8 AND
             PERCENT_RANK() OVER (ORDER BY SUM(Quantity * UnitPrice) DESC) >= 0.8 THEN 'High-Value'
        WHEN PERCENT_RANK() OVER (ORDER BY DATEDIFF(DAY, MAX(InvoiceDate), GETDATE())) <= 0.5 AND
             PERCENT_RANK() OVER (ORDER BY COUNT(DISTINCT InvoiceNo)) <= 0.5 AND
             PERCENT_RANK() OVER (ORDER BY SUM(Quantity * UnitPrice)) <= 0.5 THEN 'Low-Value'
        ELSE 'Medium-Value'
    END AS CustomerSegment
FROM
    online_retail_new1
GROUP BY
    CustomerID
ORDER BY
    Monetary DESC;  


-- PRODUCT Analysis

--- Total Sales Revenue
SELECT
    TOP 10
	StockCode,
    Description,
    SUM(Quantity) AS TotalUnitsSold,
    SUM(Quantity * UnitPrice) AS TotalSalesRevenue
FROM
    online_retail_new1
GROUP BY
    StockCode, Description
ORDER BY
    TotalSalesRevenue DESC

--- Total Unit Sold
SELECT
    TOP 10
	StockCode,
    Description,
    SUM(Quantity) AS TotalUnitsSold,
    SUM(Quantity * UnitPrice) AS TotalSalesRevenue
FROM
    online_retail_new1
GROUP BY
    StockCode, Description
ORDER BY
    TotalUnitsSold DESC


--- Geographical Analysis

--- Total Sales Revenue By Country
SELECT
    Country,
    SUM(Quantity) AS TotalUnitsSold,
    SUM(Quantity * UnitPrice) AS TotalSalesRevenue
FROM
    online_retail_new1
GROUP BY
    Country
ORDER BY
    TotalSalesRevenue DESC

--- Average of Unit Price And Quantity
SELECT
    Country,
    AVG(UnitPrice) AS AverageUnitPrice,
    AVG(Quantity) AS AverageQuantity,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM
    online_retail_new1
GROUP BY
    Country;

--specific time of sales

--1.Analyze Sales by Time of the Day:

SELECT DATEPART(HOUR, InvoiceDate) AS hoursofday,
		SUM(Quantity * Unitprice) AS totalsales
FROM online_retail_new1
GROUP BY DATEPART(HOUR, InvoiceDate)
ORDER BY hoursofday

-- 2. Analyze Sales by Time of the week:

SELECT
    DATENAME(WEEKDAY, InvoiceDate) AS DayOfWeek,
    SUM(Quantity * UnitPrice) AS TotalSales
FROM
    online_retail_new1
GROUP BY
    DATENAME(WEEKDAY, InvoiceDate)
ORDER BY
    CASE 
        WHEN DATENAME(WEEKDAY, InvoiceDate) = 'Monday' THEN 1
        WHEN DATENAME(WEEKDAY, InvoiceDate) = 'Tuesday' THEN 2
        WHEN DATENAME(WEEKDAY, InvoiceDate) = 'Wednesday' THEN 3
        WHEN DATENAME(WEEKDAY, InvoiceDate) = 'Thursday' THEN 4
        WHEN DATENAME(WEEKDAY, InvoiceDate) = 'Friday' THEN 5
        WHEN DATENAME(WEEKDAY, InvoiceDate) = 'Saturday' THEN 6
        WHEN DATENAME(WEEKDAY, InvoiceDate) = 'Sunday' THEN 7
    END;

-- 3. Analyze Sales by Time of the month

SELECT
	Month(InvoiceDate) AS Months,
	SUM(Quantity * UnitPrice) AS TotalSales
FROM online_retail_new1
GROUP BY Month(InvoiceDate)
ORDER BY Months;

-- 4.Analyze Customer Purchasing Behavior Over Time:

SELECT 
	YEAR(InvoiceDate) AS Years,
	Month(InvoiceDate) AS Months,
	AVG(Quantity) AS Average_quantity,
	AVG(Unitprice) AS Average_unitprice,
	SUM(Quantity * UnitPrice) AS TotalSales
FROM online_retail_new1
GROUP BY YEAR(InvoiceDate) , Month(InvoiceDate)
ORDER BY Years , Months;





