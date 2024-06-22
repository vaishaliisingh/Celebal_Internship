-- Task - 1
CREATE TABLE Projects (
    Task_ID INT,
    Start_Date DATE,
    End_Date DATE
);
INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');
-- Initialize variables
SET @prev_end = NULL;
SET @group = 0;

-- Step 1: Assign GroupIDs to each task
DROP TEMPORARY TABLE IF EXISTS TempProjects;
CREATE TEMPORARY TABLE TempProjects AS
SELECT 
    Task_ID, 
    Start_Date, 
    End_Date, 
    @group := IF(@prev_end IS NULL OR Start_Date = DATE_ADD(@prev_end, INTERVAL 1 DAY), @group, @group + 1) AS GroupID,
    @prev_end := End_Date AS tmp
FROM 
    Projects
ORDER BY 
    Start_Date;

-- Step 2: Aggregate the groups into projects
SELECT 
    MIN(Start_Date) AS Project_Start, 
    MAX(End_Date) AS Project_End
FROM 
    TempProjects
GROUP BY 
    GroupID
ORDER BY 
    (MAX(End_Date) - MIN(Start_Date) + 1) ASC, -- Duration
    MIN(Start_Date) ASC; -- Start date

-- Task - 2
    CREATE TABLE Students (
    ID INT PRIMARY KEY,CREATE TABLE Packages (
    ID INT PRIMARY KEY,
    Salary INT -- Assuming salary is stored in whole numbers (thousands of dollars)
);

    Name VARCHAR(100)
);
INSERT INTO Students (ID, Name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');
CREATE TABLE Friends (
    ID INT,
    friend_ID INT,
    PRIMARY KEY (ID),
    FOREIGN KEY (ID) REFERENCES Students(ID),
    FOREIGN KEY (friend_ID) REFERENCES Students(ID)
);
INSERT INTO Friends (ID, friend_ID) VALUES
(1, 2), -- Alice's best friend is Bob
(2, 3), -- Bob's best friend is Charlie
(3, 1); -- Charlie's best friend is Alice
CREATE TABLE Packages (
    ID INT PRIMARY KEY,
    Salary INT -- Assuming salary is stored in whole numbers (thousands of dollars)
);
INSERT INTO Packages (ID, Salary) VALUES
(1, 50), -- Alice's salary
(2, 70), -- Bob's salary
(3, 60); -- Charlie's salary

SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages ps ON s.ID = ps.ID
JOIN Packages pf ON f.friend_ID = pf.ID
WHERE ps.Salary < pf.Salary
ORDER BY pf.Salary;

-- Task - 3
CREATE TABLE Functions (
    X INT,
    Y INT,
    PRIMARY KEY (X, Y) -- Assuming (X, Y) pairs are unique and (Y, X) pairs are not separately inserted
);
INSERT INTO Functions (X, Y) VALUES
(20, 20),
(20, 21),
(22, 23);
SELECT DISTINCT F1.X, F1.Y
FROM Functions F1
JOIN Functions F2 ON F1.X = F2.Y AND F1.Y = F2.X
WHERE F1.X < F1.Y
ORDER BY F1.X, F1.Y;

-- Task - 4
CREATE TABLE Contests (
    contest_id INT PRIMARY KEY,
    contest_name VARCHAR(100) -- Assuming contest_name might also be relevant but not shown in the sample output
);
CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE Submissions (
    contest_id INT,
    hacker_id INT,
    total_submissions INT,
    total_accepted_submissions INT,
    FOREIGN KEY (contest_id) REFERENCES Contests(contest_id),
    FOREIGN KEY (hacker_id) REFERENCES Hackers(hacker_id)
);
CREATE TABLE Views (
    contest_id INT,
    hacker_id INT,
    total_views INT,
    total_unique_views INT,
    FOREIGN KEY (contest_id) REFERENCES Contests(contest_id),
    FOREIGN KEY (hacker_id) REFERENCES Hackers(hacker_id)
);
-- Sample data for Contests table
INSERT INTO Contests (contest_id, contest_name) VALUES
(66406, 'Contest A'),
(66556, 'Contest B'),
(94828, 'Contest C');

-- Sample data for Hackers table
INSERT INTO Hackers (hacker_id, name) VALUES
(17973, 'Rose'),
(79153, 'Angela'),
(80275, 'Frank');

-- Sample data for Submissions table
INSERT INTO Submissions (contest_id, hacker_id, total_submissions, total_accepted_submissions) VALUES
(66406, 17973, 111, 39),
(66556, 79153, 0, 0),
(94828, 80275, 150, 38);

-- Sample data for Views table
INSERT INTO Views (contest_id, hacker_id, total_views, total_unique_views) VALUES
(66406, 17973, 156, 56),
(66556, 79153, 11, 10),
(94828, 80275, 41, 15);

-- Task -5 
CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO Hackers (hacker_id, name) VALUES
(20703, 'Angela'),
(79722, 'Michael');
CREATE TABLE Submissions (
    submission_id INT PRIMARY KEY,
    hacker_id INT,
    submission_date DATE,
    total_submissions INT,
    total_accepted_submissions INT,
    FOREIGN KEY (hacker_id) REFERENCES Hackers(hacker_id)
);
INSERT INTO Submissions (submission_id, hacker_id, submission_date, total_submissions, total_accepted_submissions) VALUES
(1, 20703, '2016-03-01', 111, 39),
(2, 20703, '2016-03-02', 2, 0),
(3, 20703, '2016-03-03', 0, 0),
(4, 79722, '2016-03-01', 156, 56),
(5, 79722, '2016-03-02', 11, 10),
(6, 79722, '2016-03-03', 0, 0),
(7, 80275, '2016-03-01', 150, 38),
(8, 80275, '2016-03-02', 41, 15),
(9, 80275, '2016-03-03', 0, 0);
-- Common Table Expression (CTE) to generate all dates between contest start and end dates
WITH RECURSIVE Dates AS (
    SELECT DATE('2016-03-01') AS Contest_Date
    UNION ALL
    SELECT Contest_Date + INTERVAL 1 DAY
    FROM Dates
    WHERE Contest_Date < '2016-03-15'
),

-- Query to get number of unique hackers and hacker with max submissions per day
DailyStats AS (
    SELECT
        d.Contest_Date AS Contest_Date,
        COUNT(DISTINCT s.hacker_id) AS Num_Unique_Hackers,
        MAX(s.total_submissions) AS Max_Submissions,
        MIN(CASE WHEN s.total_submissions = MAX(s.total_submissions) THEN s.hacker_id END) AS Hacker_With_Max_Submissions
    FROM
        Dates d
    LEFT JOIN
        Submissions s ON d.Contest_Date = DATE(s.submission_date)
    GROUP BY
        d.Contest_Date
)

-- Final query to join with Hackers table to get hacker names
SELECT
    DATE_FORMAT(ds.Contest_Date, '%Y-%m-%d') AS Contest_Date,
    COALESCE(ds.Num_Unique_Hackers, 0) AS Num_Unique_Hackers,
    COALESCE(ds.Max_Submissions, 0) AS Max_Submissions,
    h.name AS Hacker_Name
FROM
    DailyStats ds
LEFT JOIN
    Hackers h ON ds.Hacker_With_Max_Submissions = h.hacker_id
ORDER BY
    ds.Contest_Date;

-- Task - 6
CREATE TABLE STATION (
    ID INT PRIMARY KEY,
    CITY VARCHAR(100),
    LAT_N DECIMAL(10, 8), -- Assuming latitude is stored with precision
    LONG_W DECIMAL(11, 8) -- Assuming longitude is stored with precision
);
INSERT INTO STATION (ID, CITY, LAT_N, LONG_W) VALUES
(1, 'New York', 40.7128, -74.0060),
(2, 'Los Angeles', 34.0522, -118.2437),
(3, 'Chicago', 41.8781, -87.6298),
(4, 'Houston', 29.7604, -95.3698),
(5, 'Phoenix', 33.4484, -112.0740);
SELECT ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4) AS Manhattan_Distance
FROM STATION;

-- Task - 7 
-- MySQL query to find and print all prime numbers <= 1000
SELECT GROUP_CONCAT(prime_number ORDER BY prime_number SEPARATOR '&') AS primes
FROM (
    SELECT num AS prime_number
    FROM (
        SELECT 
            @num := @num + 1 AS num,
            CASE 
                WHEN @num = 1 THEN 0
                WHEN @num = 2 THEN 1
                ELSE NOT EXISTS (
                    SELECT *
                    FROM (
                        SELECT 1 AS x
                        UNION ALL SELECT 2
                        UNION ALL SELECT 3
                        UNION ALL SELECT 5
                        UNION ALL SELECT 7
                        UNION ALL SELECT 11
                        UNION ALL SELECT 13
                        UNION ALL SELECT 17
                        UNION ALL SELECT 19
                        UNION ALL SELECT 23
                        UNION ALL SELECT 29
                        UNION ALL SELECT 31
                        UNION ALL SELECT 37
                        UNION ALL SELECT 41
                        UNION ALL SELECT 43
                        UNION ALL SELECT 47
                        UNION ALL SELECT 53
                        UNION ALL SELECT 59
                        UNION ALL SELECT 61
                        UNION ALL SELECT 67
                        UNION ALL SELECT 71
                        UNION ALL SELECT 73
                        UNION ALL SELECT 79
                        UNION ALL SELECT 83
                        UNION ALL SELECT 89
                        UNION ALL SELECT 97
                        UNION ALL SELECT 101
                        UNION ALL SELECT 103
                        UNION ALL SELECT 107
                        UNION ALL SELECT 109
                        UNION ALL SELECT 113
                        UNION ALL SELECT 127
                        UNION ALL SELECT 131
                        UNION ALL SELECT 137
                        UNION ALL SELECT 139
                        UNION ALL SELECT 149
                        UNION ALL SELECT 151
                        UNION ALL SELECT 157
                        UNION ALL SELECT 163
                        UNION ALL SELECT 167
                        UNION ALL SELECT 173
                        UNION ALL SELECT 179
                        UNION ALL SELECT 181
                        UNION ALL SELECT 191
                        UNION ALL SELECT 193
                        UNION ALL SELECT 197
                        UNION ALL SELECT 199
                        UNION ALL SELECT 211
                        UNION ALL SELECT 223
                        UNION ALL SELECT 227
                        UNION ALL SELECT 229
                        UNION ALL SELECT 233
                        UNION ALL SELECT 239
                        UNION ALL SELECT 241
                        UNION ALL SELECT 251
                        UNION ALL SELECT 257
                        UNION ALL SELECT 263
                        UNION ALL SELECT 269
                        UNION ALL SELECT 271
                        UNION ALL SELECT 277
                        UNION ALL SELECT 281
                        UNION ALL SELECT 283
                        UNION ALL SELECT 293
                        UNION ALL SELECT 307
                        UNION ALL SELECT 311
                        UNION ALL SELECT 313
                        UNION ALL SELECT 317
                        UNION ALL SELECT 331
                        UNION ALL SELECT 337
                        UNION ALL SELECT 347
                        UNION ALL SELECT 349
                        UNION ALL SELECT 353
                        UNION ALL SELECT 359
                        UNION ALL SELECT 367
                        UNION ALL SELECT 373
                        UNION ALL SELECT 379
                        UNION ALL SELECT 383
                        UNION ALL SELECT 389
                        UNION ALL SELECT 397
                        UNION ALL SELECT 401
                        UNION ALL SELECT 409
                        UNION ALL SELECT 419
                        UNION ALL SELECT 421
                        UNION ALL SELECT 431
                        UNION ALL SELECT 433
                        UNION ALL SELECT 439
                        UNION ALL SELECT 443
                        UNION ALL SELECT 449
                        UNION ALL SELECT 457
                        UNION ALL SELECT 461
                        UNION ALL SELECT 463
                        UNION ALL SELECT 467
                        UNION ALL SELECT 479
                        UNION ALL SELECT 487
                        UNION ALL SELECT 491
                        UNION ALL SELECT 499
                        UNION ALL SELECT 503
                        UNION ALL SELECT 509
                        UNION ALL SELECT 521
                        UNION ALL SELECT 523
                        UNION ALL SELECT 541
                        UNION ALL SELECT 547
                        UNION ALL SELECT 557
                        UNION ALL SELECT 563
                        UNION ALL SELECT 569
                        UNION ALL SELECT 571
                        UNION ALL SELECT 577
                        UNION ALL SELECT 587
                        UNION ALL SELECT 593
                        UNION ALL SELECT 599
                        UNION ALL SELECT 601
                        UNION ALL SELECT 607
                        UNION ALL SELECT 613
                        UNION ALL SELECT 617
                        UNION ALL SELECT 619
                        UNION ALL SELECT 631
                        UNION ALL SELECT 641
                        UNION ALL SELECT 643
                        UNION ALL SELECT 647
                        UNION ALL SELECT 653
                        UNION ALL SELECT 659
                        UNION ALL SELECT 661
                        UNION ALL SELECT 673
                        UNION ALL SELECT 677
                        UNION ALL SELECT 683
                        UNION ALL SELECT 691
                        UNION ALL SELECT 701
                        UNION ALL SELECT 709
                        UNION ALL SELECT 719
                        UNION ALL SELECT 727
                        UNION ALL SELECT 733
                        UNION ALL SELECT 739
                        UNION ALL SELECT 743
                        UNION ALL SELECT 751
                        UNION ALL SELECT 757
                        UNION ALL SELECT 761
                        UNION ALL SELECT 769
                        UNION ALL SELECT 773
                        UNION ALL SELECT 787
                        UNION ALL SELECT 797
                        UNION ALL SELECT 809
                        UNION ALL SELECT 811
                        UNION ALL SELECT 821
                        UNION ALL SELECT 823
                        UNION ALL SELECT 827
                        UNION ALL SELECT 829
                        UNION ALL SELECT 839
                        UNION ALL SELECT 853
                        UNION ALL SELECT 857
                        UNION ALL SELECT 859
                        UNION ALL SELECT 863
                        UNION ALL SELECT 877
                        UNION ALL SELECT 881
                        UNION ALL SELECT 883
                        UNION ALL SELECT 887
                        UNION ALL SELECT 907
                        UNION ALL SELECT 911
                        UNION ALL SELECT 919
                        UNION ALL SELECT 929
                        UNION ALL SELECT 937
                        UNION ALL SELECT 941
                        UNION ALL SELECT 947
                        UNION ALL SELECT 953
                        UNION ALL SELECT 967
                        UNION ALL SELECT 971
                        UNION ALL SELECT 977
                        UNION ALL SELECT 983
                        UNION ALL SELECT 991
                        UNION ALL SELECT 997
                        UNION ALL SELECT 1009
                    ) AS primes
                    WHERE @num % x = 0
                ) THEN 0
                ELSE 1
            END AS is_prime
        FROM
            (SELECT @num := 0) AS dummy
        LIMIT 1000 -- Limits the maximum number of rows considered (prime number 997 is the largest prime less than or equal to 1000)
    ) AS primes
    WHERE is_prime = 1
) AS prime_numbers;

-- Task - 8
CREATE TABLE OCCUPATIONS (
    Name VARCHAR(100),
    Occupation VARCHAR(100)
);

INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Doctor'),
('Meera', 'Singer'),
('Ashley', 'Professor'),
('Priya', 'Singer'),
('Jennifer', 'Actor'),
('Ketty', 'Singer'),
('Belvet', 'Professor'),
('Naomi', 'Doctor');
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM OCCUPATIONS
GROUP BY Name
ORDER BY Name;

--Task 9
    WITH RECURSIVE NodeLevels AS (
    -- Base case: Find nodes without parents (root nodes)
    SELECT N, P, 1 AS Level
    FROM BST
    WHERE P IS NULL

    UNION ALL

    -- Recursive case: Join with the CTE to find children nodes
    SELECT b.N, b.P, nl.Level + 1 AS Level
    FROM BST b
    JOIN NodeLevels nl ON b.P = nl.N
)
-- Select from the CTE to get the final result
SELECT N, Level
FROM NodeLevels
ORDER BY N;

-- Task 10
CREATE TABLE Companies (
    company_code INT PRIMARY KEY,
    founder_name VARCHAR(100)
);
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    company_code INT,
    employee_type VARCHAR(20) -- Assuming employee_type can be 'Lead Manager', 'Senior Manager', 'Manager', 'Employee'
);
INSERT INTO Companies (company_code, founder_name) VALUES
(1, 'John Smith'),
(2, 'Jane Doe'),
(3, 'Michael Johnson');
INSERT INTO Employees (employee_id, company_code, employee_type) VALUES
(101, 1, 'Lead Manager'),
(102, 1, 'Senior Manager'),
(103, 1, 'Manager'),
(104, 1, 'Employee'),
(105, 1, 'Employee'),
(106, 2, 'Lead Manager'),
(107, 2, 'Senior Manager'),
(108, 2, 'Manager'),
(109, 3, 'Lead Manager'),
(110, 3, 'Manager'),
(111, 3, 'Employee'),
(112, 3, 'Employee'),
(113, 3, 'Employee');
SELECT
    c.company_code,
    c.founder_name,
    COUNT(CASE WHEN e.employee_type = 'Lead Manager' THEN 1 END) AS total_lead_managers,
    COUNT(CASE WHEN e.employee_type = 'Senior Manager' THEN 1 END) AS total_senior_managers,
    COUNT(CASE WHEN e.employee_type = 'Manager' THEN 1 END) AS total_managers,
    COUNT(CASE WHEN e.employee_type = 'Employee' THEN 1 END) AS total_employees
FROM Companies c
LEFT JOIN Employees e ON c.company_code = e.company_code
GROUP BY c.company_code, c.founder_name
ORDER BY c.company_code ASC;

-- Task 11
CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name VARCHAR(100)
);
CREATE TABLE Friends (
    ID INT PRIMARY KEY,
    Friend_ID INT,
    FOREIGN KEY (ID) REFERENCES Students(ID),
    FOREIGN KEY (Friend_ID) REFERENCES Students(ID)
);
CREATE TABLE Packages (
    ID INT PRIMARY KEY,
    Salary DECIMAL(10, 2) -- Salary offered in thousands per month
);
INSERT INTO Students (ID, Name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David');
INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2), -- Alice's best friend is Bob
(2, 1), -- Bob's best friend is Alice
(3, 4), -- Charlie's best friend is David
(4, 3); -- David's best friend is Charlie
INSERT INTO Packages (ID, Salary) VALUES
(1, 50.00), -- Package ID 1 with salary $50,000
(2, 45.50), -- Package ID 2 with salary $45,500
(3, 55.75), -- Package ID 3 with salary $55,750
(4, 60.25); -- Package ID 4 with salary $60,250
SELECT
    s.ID,
    s.Name,
    p.Salary AS Salary_thousands,
    f.Name AS Best_Friend_Name
FROM Students s
JOIN Friends fship ON s.ID = fship.ID
JOIN Students f ON fship.Friend_ID = f.ID
JOIN Packages p ON s.ID = p.ID
ORDER BY s.ID;

-- Task 12
SELECT 
    Job_Family,
    SUM(CASE WHEN Location = 'India' THEN Cost ELSE 0 END) AS Cost_India,
    SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END) AS Cost_International,
    (SUM(CASE WHEN Location = 'India' THEN Cost ELSE 0 END) / 
     SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END)) * 100 AS Ratio_Percentage
FROM Job_Costs
GROUP BY Job_Family;

-- Task 13
SELECT 
    Month,
    BU,
    SUM(Cost) AS Total_Cost,
    SUM(Revenue) AS Total_Revenue,
    (SUM(Cost) / SUM(Revenue)) AS Ratio_Cost_Revenue
FROM Costs
JOIN Revenue USING (Month, BU)
GROUP BY Month, BU;

-- Task 14 
SELECT 
    Sub_Band,
    Headcount,
    Headcount / SUM(Headcount) OVER () * 100 AS Percentage_Headcount
FROM Employee_Headcount;

-- Task 15
SELECT Employee_ID, Name, Salary
FROM (
    SELECT Employee_ID, Name, Salary,
           ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
    FROM Employees
) AS RankedEmployees
WHERE RowNum <= 5;

-- Task 16
UPDATE SwapTable
SET Column1 = Column1 + Column2,
    Column2 = Column1 - Column2,
    Column1 = Column1 - Column2;

-- TAsk 17
-- Create user
CREATE LOGIN NewUser WITH PASSWORD = 'your_password';

-- Create login
CREATE USER NewUser FOR LOGIN NewUser;

-- Provide permissions of DB_owner
ALTER ROLE db_owner ADD MEMBER NewUser;

-- Task 18
SELECT 
    Month,
    BU,
    SUM(Cost * Employee_Count) / SUM(Employee_Count) AS Weighted_Average_Cost
FROM (
    SELECT Month, BU, Employee_ID, Cost,
           COUNT(Employee_ID) OVER (PARTITION BY Month, BU) AS Employee_Count
    FROM Employee_Costs
) AS WeightedCosts
GROUP BY Month, BU;

-- Task 19
-- Calculate actual average salary
WITH ActualAverage AS (
    SELECT AVG(Salary) AS Actual_Average_Salary
    FROM EMPLOYEES
),

-- Calculate miscalculated average salary (remove zeroes)
MiscalculatedAverage AS (
    SELECT AVG(CAST(REPLACE(CAST(Salary AS VARCHAR), '0', '') AS DECIMAL)) AS Miscalculated_Average_Salary
    FROM EMPLOYEES
)

-- Calculate the difference and round up to the next integer
SELECT CEILING(Actual_Average_Salary - Miscalculated_Average_Salary) AS Salary_Error
FROM ActualAverage, MiscalculatedAverage;

-- Task 20
INSERT INTO TableB (col1, col2, ...)
SELECT col1, col2, ...
FROM TableA
WHERE NOT EXISTS (
    SELECT 1
    FROM TableB
    WHERE TableB.primary_key = TableA.primary_key -- Adjust based on your primary key or unique identifier
);






