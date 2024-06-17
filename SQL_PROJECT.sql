-- Create Departments Table
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

-- Insert data into Departments Table
INSERT INTO Departments (DepartmentID, Name) VALUES
(1, 'Marketing'),
(2, 'Research'),
(3, 'Development');

-- Create Employees Table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    DepartmentID INT,
    Salary DECIMAL(10, 2),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Insert data into Employees Table
INSERT INTO Employees (EmployeeID, Name, DepartmentID, Salary) VALUES
(1, 'John Doe', 1, 60000.00),
(2, 'Jane Smith', 1, 70000.00),
(3, 'Alice Johnson', 1, 65000.00),
(4, 'Bob Brown', 1, 75000.00),
(5, 'Charlie Wilson', 1, 80000.00),
(6, 'Eva Lee', 2, 70000.00),
(7, 'Michael Clark', 2, 75000.00),
(8, 'Sarah Davis', 2, 80000.00),
(9, 'Ryan Harris', 2, 85000.00),
(10, 'Emily White', 2, 90000.00),
(11, 'David Martinez', 3, 95000.00),
(12, 'Jessica Taylor', 3, 100000.00),
(13, 'William Rodriguez', 3, 105000.00);

-- Query to find the average salary of employees in each department
-- where the average salary is higher than the overall average salary
WITH OverallAverage AS (
    SELECT AVG(Salary) AS OverallAvgSalary
    FROM Employees
),
DepartmentStats AS (
    SELECT 
        d.Name AS DepartmentName,
        COUNT(e.EmployeeID) AS NumberOfEmployees,
        AVG(e.Salary) AS AverageSalary
    FROM 
        Employees e
    JOIN 
        Departments d ON e.DepartmentID = d.DepartmentID
    GROUP BY 
        d.Name
)
SELECT 
    ds.DepartmentName,
    ds.AverageSalary,
    ds.NumberOfEmployees
FROM 
    DepartmentStats ds
JOIN 
    OverallAverage oa ON ds.AverageSalary > oa.OverallAvgSalary;
