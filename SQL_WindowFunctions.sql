SELECT * FROM Sales.SalesOrderHeader

-- In the quarter 3 of 2013, make a list of customers who ordered up from 3 orders and total orders they made so far 
SELECT
DISTINCT CustomerID,
t.TotalOrder
FROM 
(
	SELECT CustomerID,
	ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY CustomerID) as RowNum,
	COUNT(*) OVER (PARTITION BY CustomerID) as TotalOrder
	FROM Sales.SalesOrderHeader
	WHERE DATEPART(QUARTER, OrderDate) = 3
	AND YEAR(OrderDate) = '2013'
) t
WHERE t.RowNum >= 3

--or
SELECT CustomerID, Count(*)
FROM Sales.SalesOrderHeader
WHERE DATEPART(QUARTER, OrderDate) = 3
AND YEAR(OrderDate) = '2013'
GROUP BY CustomerID
Having Count(*) >= 3

--in 2013, how much were the subtotal in each month and rank them into 5 different groups 
WITH CTE AS 
(
	SELECT 
	MONTH(OrderDate) [Month],
	ROUND(SUM(SubTotal),2) TotalSub
	FROM Sales.SalesOrderHeader
	WHERE YEAR(OrderDate) = 2013
	GROUP BY MONTH(OrderDate)
) 

SELECT Month, TotalSub,
NTILE(5) OVER (ORDER BY TotalSub desc) as _Rank
From CTE

-- in 2013, list 3 first customers who made total order value over 500000 so that the company could have a special promotion
SELECT DISTINCT TOP 3 CustomerID,
OrderDate,
Total_Order
FROM
(
	SELECT CustomerID,
	OrderDate,
	ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS _index,
	Sum(SubTotal) OVER (PARTITION BY CustomerID) AS Total_Order
	FROM Sales.SalesOrderHeader
	GROUP BY CustomerID, OrderDate
) T
WHERE OrderDate = Min(OrderDate)
AND Total_Order > 500000
GROUP BY CustomerID, OrderDate;

-- in 2013, make a list of N customers who had the highest subtotal in each month
WITH CTE AS 
(
	SELECT 
	MONTH(OrderDate) [Month],
	ROUND(SUM(SubTotal),2) TotalSub
	FROM Sales.SalesOrderHeader
	WHERE YEAR(OrderDate) = 2013
	GROUP BY MONTH(OrderDate)
) 

SELECT Month, TotalSub,
NTILE(1) OVER (ORDER BY TotalSub desc) as _Rank
From CTE;

-- in 2013, calculate subtotal of orders that each saleperson made for each month, rank into different groups, and reward them following total amount they collected for
the company (ex: less than 1 mil => reward 100, greater than 2 mil => reward 200, etc...)
wITH CTE AS
	(	SELECT SalesPersonID,
		ROUND(SUM(SubTotal),2) as TotalSub
		FROM Sales.SalesOrderHeader
		WHERE YEAR(OrderDate) = 2013
		GROUP BY SalesPersonID
	)

SELECT SalesPersonID,
RANK() OVER (ORDER BY TotalSub),
CASE WHEN TotalSub <= 2000000 Then 100 else 0 end,
CASE WHEN TotalSub > 2000000 Then 200 else 0 end,
CASE WHEN TotalSub >= 3000000 Then 300 else 0 end,
CASE WHEN TotalSub >= 4000000 Then 400 else 0 end,
CASE WHEN TotalSub >= 5000000 Then 500 else 0 end
FROM CTE
