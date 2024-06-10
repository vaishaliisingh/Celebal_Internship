use AdventureWorksDW2017
go
Select * from dbo.DimCustomer;

SELECT * FROM dbo.DimCustomer WHERE dbo.DimOrganization_lname = 'n';

SELECT *
FROM dbo.DimCustomer
WHERE AddressLine1 IN ('Berlin', 'London');

SELECT *
FROM dbo.DimCustomer
WHERE AddressLine2 IN ('Us', 'UK');

SELECT *
FROM dbo.DimProduct
ORDER BY EnglishProductName DESC;

SELECT *
FROM dbo.DimProduct
WHERE EnglishProductName LIKE 'A%';



SELECT DISTINCT c.FirstName, c.LastName
FROM dbo.DimCustomer c
JOIN dbo.FactInternetSales s ON c.CustomerKey = s.CustomerKey;

SELECT DISTINCT c.FirstName, c.LastName
FROM dbo.DimCustomer c
JOIN dbo.FactInternetSales s ON c.CustomerKey = s.CustomerKey
JOIN dbo.DimProduct p ON s.ProductKey = p.ProductKey
JOIN dbo.DimGeography g ON c.GeographyKey = g.GeographyKey
WHERE g.City = 'London' AND p.EnglishProductName = 'Chai';

SELECT c.FirstName, c.LastName
FROM dbo.DimCustomer c
LEFT JOIN dbo.FactInternetSales s ON c.CustomerKey = s.CustomerKey
WHERE s.SalesOrderNumber IS NULL;


SELECT DISTINCT c.FirstName, c.LastName
FROM dbo.DimCustomer c
JOIN dbo.FactInternetSales s ON c.CustomerKey = s.CustomerKey
JOIN dbo.DimProduct p ON s.ProductKey = p.ProductKey
WHERE p.EnglishProductName = 'Tofu';

SELECT *
FROM dbo.FactInternetSales
WHERE OrderDate = (
    SELECT MIN(OrderDate)
    FROM dbo.FactInternetSales
);

SELECT TOP 1 *
FROM dbo.FactInternetSales
ORDER BY DueDate DESC;

SELECT SalesOrderNumber, AVG(OrderQuantity) AS AvgQuantity
FROM dbo.FactInternetSales
GROUP BY SalesOrderNumber;

SELECT SalesOrderNumber, MIN(OrderQuantity) AS MinQuantity, MAX(OrderQuantity) AS MaxQuantity
FROM dbo.FactInternetSales
GROUP BY SalesOrderNumber;

SELECT 
    M.Employeekey AS ManagerID,
    M.FirstName AS ManagerFirstName,
    M.LastName AS ManagerLastName,
    E.EmployeeID AS EmployeeID,
    E.FirstName AS EmployeeFirstName,
    E.LastName AS EmployeeLastName
FROM 
    Employee M
JOIN 
    Employee E ON M.EmployeeID = E.ManagerID
ORDER BY 
    M.EmployeeID, E.EmployeeID;

SELECT SalesOrderNumber, SUM(OrderQuantity) AS TotalQuantity
FROM FactInternetSales
GROUP BY SalesOrderNumber
HAVING SUM(OrderQuantity) > 300;

SELECT *
FROM FactInternetSales
WHERE salesOrdernumber <= '1996-12-31';


SELECT *
FROM FactInternetSales AS s
JOIN DimCustomer AS c ON s.CustomerKey = c.CustomerKey
JOIN DimGeography AS g ON c.GeographyKey = g.GeographyKey
WHERE g.City = 'Canada';

SELECT *
FROM FactInternetSales
WHERE DueDateKey > 200;


SELECT g.City, SUM(s.TotalProductCost) AS TotalSales
FROM FactInternetSales AS s
JOIN DimCustomer AS c ON s.CustomerKey = c.CustomerKey
JOIN DimGeography AS g ON c.GeographyKey = g.GeographyKey
GROUP BY g.City
ORDER BY TotalSales DESC;


SELECT 
    c.FirstName + ' ' + c.LastName AS ContactName,
    COUNT(s.SalesOrderNumber) AS NumberOfOrders
FROM 
    DimCustomer AS c
JOIN 
    FactInternetSales AS s ON c.CustomerKey = s.CustomerKey
GROUP BY 
    c.FirstName, c.LastName
ORDER BY 
    NumberOfOrders DESC;


	SELECT 
    c.FirstName + ' ' + c.LastName AS ContactName,
    COUNT(s.SalesOrderNumber) AS NumberOfOrders
FROM 
    DimCustomer AS c
JOIN 
    FactInternetSales AS s ON c.CustomerKey = s.CustomerKey
GROUP BY 
    c.FirstName, c.LastName
HAVING 
    COUNT(s.SalesOrderNumber) > 3
ORDER BY 
    NumberOfOrders DESC;

	SELECT 
    DISTINCT p.ProductKey, 
    p.EnglishProductName
FROM 
    FactInternetSales AS s
JOIN 
    DimProduct AS p ON s.ProductKey = p.ProductKey
WHERE 
    s.OrderDate BETWEEN '1997-01-01' AND '1998-01-01'
    AND p.StartDate IS NOT NULL
ORDER BY 
    p.EnglishProductName;

SELECT 
    e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName,
    m.FirstName AS SupervisorFirstName,
    m.LastName AS SupervisorLastName
FROM 
    dbo.DimEmployee AS e
LEFT JOIN 
    dbo.DimEmployee AS m ON e.ManagerID = m.EmployeeKey
ORDER BY 
    e.LastName, e.FirstName;


	SELECT 
    e.Employeekey,
    COUNT(s.SalesOrderNumber) AS TotalSales
FROM 
    DimEmployee AS e
LEFT JOIN 
    FactInternetSales AS s ON e.EmployeeKey = s.SalesTerritoryKey
GROUP BY 
    e.EmployeeKey
ORDER BY 
    e.EmployeeKey;


SELECT *
FROM DimEmployee
WHERE FirstName LIKE '%a%';


SELECT 
    ManagerID,
    COUNT(Employeekey) AS NumberOfReports
FROM 
   dbo.DimEmployee Employee
GROUP BY 
    ManagerID
HAVING 
    COUNT(Employeekey) > 4;

SELECT 
    s.SalesOrderNumber AS OrderID,
    p.EnglishProductName AS ProductName
FROM 
    FactInternetSales AS s
JOIN 
    DimProduct AS p ON s.ProductKey = p.ProductKey;


SELECT TOP 1
    c.CustomerKey,
    c.FirstName,
    c.LastName,
    s.SalesOrderNumber,
    p.EnglishProductName AS ProductName
FROM 
    FactInternetSales AS s
JOIN 
    DimCustomer AS c ON s.CustomerKey = c.CustomerKey
JOIN 
    DimProduct AS p ON s.ProductKey = p.ProductKey
WHERE
    c.CustomerKey IN (
        SELECT TOP 1 
            CustomerKey
        FROM 
            FactInternetSales
        GROUP BY 
            CustomerKey
        ORDER BY 
            COUNT(*) DESC
    )
ORDER BY 
    s.SalesOrderNumber;



SELECT 
    s.SalesOrderNumber,
    c.CustomerKey,
    c.FirstName,
    c.LastName
FROM 
    FactInternetSales AS s
JOIN 
    DimCustomer AS c ON s.CustomerKey = c.CustomerKey
WHERE 
    c.FaxNumber IS NULL
ORDER BY 
    s.SalesOrderNumber;


SELECT DISTINCT
    c.CustomerPOnumber
FROM 
   dbo.FactInternetSales FactInternetSales AS s
JOIN 
    DimProduct AS p ON s.ProductKey = p.ProductKey
JOIN 
    DimCustomer AS c ON s.CustomerKey = c.CustomerKey
WHERE 
    p.EnglishProductName = 'Tofu'
ORDER BY 
    c.PostalCode;



SELECT DISTINCT
    p.EnglishProductName
FROM 
    FactInternetSales AS s
JOIN 
    DimProduct AS p ON s.ProductKey = p.ProductKey
JOIN 
    DimCustomer AS c ON s.CustomerKey = c.CustomerKey
JOIN 
    DimGeography AS g ON c.GeographyKey = g.GeographyKey
WHERE 
    g.City = 'France'
ORDER BY 
    p.EnglishProductName;


SELECT 
    p.EnglishProductName AS ProductName,
    c.EnglishProductCategoryName AS Category
FROM 
    DimProduct AS p
JOIN 
    DimProductSubcategory AS sc ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
JOIN 
    DimProductCategory AS c ON sc.ProductCategoryKey = c.ProductCategoryKey
JOIN 
    DimSupplier AS s ON p.ProductKey = s.ProductKey
WHERE 
    s.SupplierName = 'Specialist Biscuit Limited'
ORDER BY 
    Category, ProductName;

SELECT 
    p.EnglishProductName AS ProductName
FROM 
    DimProduct AS p
LEFT JOIN 
    FactInternetSales AS s ON p.ProductKey = s.ProductKey
WHERE 
    s.ProductKey IS NULL;




SELECT 
    EnglishProductName
FROM 
   dbo.DimProduct 
WHERE 
    SafetyStockLevel < 10 
    AND SafetyStockLevel = 0;


SELECT 
    g.City AS Country,
    SUM(s.DueDate) AS TotalSales
FROM 
    FactInternetSales AS s
JOIN 
    DimCustomer AS c ON s.CustomerKey = c.CustomerKey
JOIN 
    DimGeography AS g ON c.GeographyKey = g.GeographyKey
GROUP BY 
    g.City
ORDER BY 
    TotalSales DESC
LIMIT 10;


SELECT 
    e.EmployeeKey,
    COUNT(s.SalesOrderNumber) AS NumberOfOrders
FROM 
    FactInternetSales AS s
JOIN 
    DimCustomer AS c ON s.CustomerKey = c.CustomerKey
JOIN 
    DimEmployee AS e ON s.EmployeeKey = e.EmployeeKey
WHERE 
    c.CustomerID BETWEEN 'a' AND 'ao'
GROUP BY 
    e.EmployeeKey
ORDER BY 
    e.EmployeeKey;


SELECT
    OrderDate
FROM
    FactInternetSales
WHERE
    TotalDue = (
        SELECT
            MAX(TotalDue)
        FROM
            FactInternetSales
    );


SELECT 
    p.EnglishProductName AS ProductName,
    SUM(s.TotalDue) AS TotalRevenue
FROM 
    FactInternetSales AS s
JOIN 
    DimProduct AS p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.EnglishProductName
ORDER BY 
    TotalRevenue DESC;



SELECT 
    s.SupplierID,
    COUNT(p.ProductID) AS NumberOfProducts
FROM 
    Suppliers AS s
JOIN 
    Products AS p ON s.SupplierID = p.SupplierID
GROUP BY 
    s.SupplierID
ORDER BY 
    NumberOfProducts DESC;



SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    SUM(s.TotalDue) AS TotalRevenue
FROM 
    DimCustomer AS c
JOIN 
    FactInternetSales AS s ON c.CustomerKey = s.CustomerKey
GROUP BY 
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY 
    TotalRevenue DESC
LIMIT 10;



SELECT 
    SUM(TotalDue) AS TotalRevenue
FROM 
    FactInternetSales;





