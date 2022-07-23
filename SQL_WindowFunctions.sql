SELECT * FROM Sales.SalesOrderHeader

-------------------- In the quarter 3 of 2013, make a list of customers who ordered up from 3 orders and total orders they made so far 
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

----------------------------------in 2013, how much were the subtotal in each month and rank them into 5 different groups 
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

------------------------- in 2013, list 3 first customers who made total order value over 27722 so that the company could have a special promotion
SELECT CustomerID,
t.Total_Order
FROM 
	(SELECT Month(OrderDate) as _month,
	CustomerID,
	ROW_NUMBER() OVER (PARTITION BY Month(OrderDate) ORDER BY OrderDate) as RowNum,
	SubTotal as Total_Order
	FROM Sales.SalesOrderHeader
	WHERE Subtotal > 27722
	)t
WHERE t.RowNum <= 3

---------------------------- in 2013, make a list of 5 customers who had the highest subtotal in each month

WITH CTE AS
	( SELECT MONTH(OrderDate) as _month,
	CustomerID, 
	ROW_NUMBER() OVER (PARTITION BY Month(OrderDate) ORDER BY Subtotal DESC) as _index,
	SubTotal as Total_Order
	FROM Sales.SalesOrderHeader
	WHERE YEAR(OrderDate) = '2013'
	)
SELECT *
FROM CTE
WHERE _index <= 5;

-- in 2013, calculate subtotal of orders that each saleperson made for each month, rank into different groups, and reward them following total amount they collected for
the company
WITH CTE AS
	(	SELECT SalesPersonID,
		ROUND(SUM(SubTotal),2) as TotalSub
		FROM Sales.SalesOrderHeader
		WHERE YEAR(OrderDate) = 2013
		GROUP BY SalesPersonID
	)
SELECT SalesPersonID,
RANK() OVER (ORDER BY TotalSub) _Rank,
CASE WHEN TotalSub <= 2000000 Then 100
     WHEN TotalSub BETWEEN 2000000 AND 4000000 Then 200
     ELSE 300
     END AS Reward_Amount
FROM CTE
Where SalesPersonID is not null;
