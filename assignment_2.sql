CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(18, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(18, 2) = 0
AS
BEGIN
    DECLARE @ProductUnitPrice DECIMAL(18, 2);
    DECLARE @UnitsInStock INT;
    DECLARE @ReorderLevel INT;

    -- Fetch UnitPrice and UnitsInStock from Product table if UnitPrice is not provided
    SELECT @ProductUnitPrice = UnitPrice, @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel
    FROM Products
    WHERE ProductID = @ProductID;

    -- Use Product UnitPrice if not provided
    SET @UnitPrice = ISNULL(@UnitPrice, @ProductUnitPrice);

    -- Check if sufficient stock exists
    IF @UnitsInStock >= @Quantity
    BEGIN
        INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Failed to place the order. Please try again.';
            RETURN;
        END

        -- Update stock
        UPDATE Products
        SET UnitsInStock = UnitsInStock - @Quantity
        WHERE ProductID = @ProductID;

        -- Check if stock falls below reorder level
        IF @UnitsInStock - @Quantity < @ReorderLevel
        BEGIN
            PRINT 'Warning: Quantity in stock has dropped below its Reorder Level.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Insufficient stock to fill the order. Order aborted.';
    END
END;


CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(18, 2) = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(18, 2) = NULL
AS
BEGIN
    DECLARE @CurrentUnitPrice DECIMAL(18, 2);
    DECLARE @CurrentQuantity INT;
    DECLARE @CurrentDiscount DECIMAL(18, 2);

    -- Fetch current values from OrderDetails
    SELECT @CurrentUnitPrice = UnitPrice, @CurrentQuantity = Quantity, @CurrentDiscount = Discount
    FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Use current values if new values are NULL
    SET @UnitPrice = ISNULL(@UnitPrice, @CurrentUnitPrice);
    SET @Quantity = ISNULL(@Quantity, @CurrentQuantity);
    SET @Discount = ISNULL(@Discount, @CurrentDiscount);

    -- Update OrderDetails
    UPDATE OrderDetails
    SET UnitPrice = @UnitPrice, Quantity = @Quantity, Discount = @Discount
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Adjust stock in Products table
    DECLARE @StockChange INT;
    SET @StockChange = @CurrentQuantity - @Quantity;

    UPDATE Products
    SET UnitsInStock = UnitsInStock + @StockChange
    WHERE ProductID = @ProductID;
END;


CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM OrderDetails WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist';
        RETURN 1;
    END

    SELECT * FROM OrderDetails WHERE OrderID = @OrderID;
END;


CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Invalid parameters: The given OrderID or ProductID does not exist in the Order Details table';
        RETURN -1;
    END

    DELETE FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID;
END;


CREATE FUNCTION FormatDateMMDDYYYY (@InputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CONVERT(VARCHAR(10), @InputDate, 101);
END;

CREATE VIEW vwCustomerOrders
AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS TotalPrice
FROM 
    Orders o
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID;


CREATE VIEW vwCustomerOrdersYesterday
AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS TotalPrice
FROM 
    Orders o
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
WHERE 
    CAST(o.OrderDate AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);


CREATE VIEW MyProducts
AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.QuantityPerUnit,
    p.UnitPrice,
    s.CompanyName,
    c.CategoryName
FROM 
    Products p
JOIN 
    Suppliers s ON p.SupplierID = s.SupplierID
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    p.Discontinued = 0;


CREATE TRIGGER trgInsteadOfDeleteOrders
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM OrderDetails WHERE OrderID IN (SELECT OrderID FROM DELETED);
    DELETE FROM Orders WHERE OrderID IN (SELECT OrderID FROM DELETED);
END;


CREATE TRIGGER trgCheckStockBeforeInsert
ON OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @UnitsInStock INT;

    SELECT @ProductID = ProductID, @Quantity = Quantity FROM INSERTED;

    SELECT @UnitsInStock = UnitsInStock FROM Products WHERE ProductID = @ProductID;

    IF @UnitsInStock >= @Quantity
    BEGIN
        INSERT INTO OrderDetails
        SELECT * FROM INSERTED;

        UPDATE Products
        SET UnitsInStock = UnitsInStock - @Quantity
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        PRINT 'Insufficient stock to fill the order. Order not inserted.';
    END
END;




