--leet code proble number 175 Combine two tables
    --solution:-
SELECT
    p.firstName,
    p.lastName,
    a.city,
    a.state
FROM
    Person p
LEFT JOIN
    Address a ON p.personId = a.personId;

--leetcode problem number 182 Diplicate Email
--solution:-
SELECT
    email
FROM
    Person
GROUP BY
    email
HAVING
    COUNT(email) > 1;

--leetcode problem 183 Customer who never order
--solution:-
SELECT
    c.name AS Customers
FROM
    Customers c
LEFT JOIN
    Orders o ON c.id = o.customerId
WHERE
    o.customerId IS NULL;
