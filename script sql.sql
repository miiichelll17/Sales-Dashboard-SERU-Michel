 SELECT 
    d.*,
    o."Order Date" 
FROM details d
INNER JOIN orders o ON d."Order ID" = o."Order ID";

SELECT
    DATEPART(Month, O.OrderDate) AS OrderMonth,
    B.Category AS Segment,
    SUM(D.Amount) AS SalesAmount,
    NULL AS OrderCount,
    NULL AS Year,
    NULL AS GrowthRate
FROM
    ORDERS O
INNER JOIN
    BUDGET B ON O.State = B.State AND O.City = B.City
INNER JOIN
    DETAILS D ON O.OrderID = D.OrderID
GROUP BY
    DATEPART(Month, O.OrderDate),
    B.Category

UNION ALL

SELECT
    DATEPART(Month, OrderDate) AS OrderMonth,
    NULL AS Segment,
    NULL AS SalesAmount,
    COUNT(OrderID) AS OrderCount,
    NULL AS Year,
    NULL AS GrowthRate
FROM
    ORDERS
GROUP BY
    DATEPART(Month, OrderDate)

UNION ALL

SELECT
    NULL AS OrderMonth,
    NULL AS Segment,
    NULL AS SalesAmount,
    NULL AS OrderCount,
    Year,
    (SUM(Amount) - LAG(SUM(Amount), 1, 0) OVER (ORDER BY Year)) / LAG(SUM(Amount), 1, 1) OVER (ORDER BY Year) AS GrowthRate
FROM
    BUDGET
GROUP BY
    Year

UNION ALL

SELECT
    NULL AS OrderMonth,
    B.Category AS Segment,
    NULL AS SalesAmount,
    NULL AS OrderCount,
    DATEPART(Year, O.OrderDate) AS Year,
    (SUM(D.Amount) - LAG(SUM(D.Amount), 1, 0) OVER (PARTITION BY B.Category ORDER BY DATEPART(Year, O.OrderDate))) / LAG(SUM(D.Amount), 1, 1) OVER (PARTITION BY B.Category ORDER BY DATEPART(Year, O.OrderDate)) AS GrowthRate
FROM
    ORDERS O
INNER JOIN
    BUDGET B ON O.State = B.State AND O.City = B.City
INNER JOIN
    DETAILS D ON O.OrderID = D.OrderID
GROUP BY
    DATEPART(Year, O.OrderDate),
    B.Category;


