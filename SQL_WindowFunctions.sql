SELECT * FROM Sales.SalesOrderHeader

-- Trong qui 3, nam 2013, list khach hang mua tu 3 don hang tro len va cho biet tong so don hang ma ho da mua trong qui nay
SELECT
DISTINCT CustomerID,
t.TotalOrder
FROM 
(SELECT CustomerID,
ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY CustomerID) as RowNum,
COUNT(*) OVER (PARTITION BY CustomerID) as TotalOrder
FROM Sales.SalesOrderHeader
WHERE DATEPART(QUARTER, OrderDate) = 3
AND YEAR(OrderDate) = '2013') t
WHERE t.RowNum >= 3

--or
SELECT CustomerID, Count(*)
FROM Sales.SalesOrderHeader
WHERE DATEPART(QUARTER, OrderDate) = 3
AND YEAR(OrderDate) = '2013'
GROUP BY CustomerID
Having Count(*) >= 3

--Trong 2013, tinh tong doanh thu trong tung thang va phan thanh 5 nhom theo doanh thu
WITH CTE AS 
(SELECT 
MONTH(OrderDate) [Month],
ROUND(SUM(SubTotal),2) TotalSub
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY MONTH(OrderDate)) 

SELECT Month, TotalSub,
NTILE(5) OVER (ORDER BY TotalSub desc) as _Rank
From CTE

-- Trong 2013, list ra 3 khach hang mua dau tien va co hoa don tri gia tren xx.xxx de cty co chinh sach uu dai 
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

-- Trong 2013, list ra n khach hang co hoa don mua hang cao nhat o moi thang
WITH CTE AS 
(SELECT 
MONTH(OrderDate) [Month],
ROUND(SUM(SubTotal),2) TotalSub
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY MONTH(OrderDate)) 

SELECT Month, TotalSub,
NTILE(1) OVER (ORDER BY TotalSub desc) as _Rank
From CTE;

-- Trong 2013, tinh tong doanh thu cua cac nhan vien ban hang, sau do chia thanh n nhom, thuong theo tung nhom vs So tien 
----lan luot la (5tr, 4tr, 3tr...)
wITH CTE AS
	(	SELECT SalesPersonID,
		ROUND(SUM(SubTotal),2) as TotalSub
		FROM Sales.SalesOrderHeader
		WHERE YEAR(OrderDate) = 2013
		GROUP BY SalesPersonID
	)

SELECT SalesPersonID,
RANK() OVER (ORDER BY TotalSub),
CASE WHEN TotalSub <= 1000000 Then 100 else 0 end,
CASE WHEN TotalSub >= 2000000 Then 200 else 0 end,
CASE WHEN TotalSub >= 3000000 Then 300 else 0 end,
CASE WHEN TotalSub >= 4000000 Then 400 else 0 end,
CASE WHEN TotalSub >= 5000000 Then 500 else 0 end
FROM CTE
--List ra nhan vien va doanh thu ban hang cua moi nv, xep hang cao nhat vs thap nhat (tao ra temp bang, cho no tu join, row_number order by 1
----bang desc, 1 bang asc roi join vs nhau)