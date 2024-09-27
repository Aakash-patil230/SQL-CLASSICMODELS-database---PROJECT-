USE `classicmodels`;


 --#Q1-a #--------------------------------------------------------------------------------------------

SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep'
AND reportsTo = 1102;

--#Q1-b #--------------------------------------------------------------------------------------------

SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';

--#Q2 #-------------------------------------------------------------------------------------------

SELECT customerNumber, customerName,
CASE 
    WHEN country IN ('USA', 'Canada') THEN 'North America'
    WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
    ELSE 'Other'
END AS CustomerSegment
FROM customers;

--#Q3-a #--------------------------------------------------------------------------------------

SELECT productCode, SUM(quantityOrdered) AS totalQuantity
FROM orderdetails
GROUP BY productCode
ORDER BY totalQuantity DESC
LIMIT 10;

--#Q3-b #---------------------------------------------------------------------------------------

SELECT MONTHNAME(paymentDate) AS month, COUNT(*) AS paymentCount
FROM payments
GROUP BY month
HAVING paymentCount > 20
ORDER BY paymentCount DESC;

--#Q4-a #---------------------------------------------------------------------------------------

create database Customers_Orders;

use  Customers_Orders;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

--#Q4-b #----------------------------------------------------------------------------------------

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2) CHECK (total_amount > 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

--#Q5 #-------------------------------------------------------------------------------------------
use classicmodels;

SELECT country, COUNT(*) AS orderCount
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY country
ORDER BY orderCount DESC
LIMIT 5;

--#Q6 #-------------------------------------------------------------------------------------------

CREATE TABLE project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female'),
    ManagerID INT
);

INSERT INTO project (EmployeeID, FullName, Gender, ManagerID)
VALUES 
(1, 'pranaya', 'Male', 3),
(2, 'priyanka', 'Female', 1),
(3, 'preety', 'Female', NULL),
(4, 'anurag', 'Male', 1),
(5, 'sambit', 'Male', 1),
(6, 'rajayesh', 'Male', 3),
(7, 'hina', 'Female', 3);

SELECT 
    m.FullName AS ManagerName, 
    e.FullName AS EmpName
FROM 
    project e
JOIN 
    project m ON e.ManagerID = m.EmployeeID
ORDER BY 
    m.FullName, e.FullName;

--#Q7 #---------------------------------------------------------------------------------

CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);

select * from facility;

-- Adding auto increment and primary key
ALTER TABLE facility
MODIFY COLUMN Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

select * from facility;

-- Adding not null city column
ALTER TABLE facility
ADD COLUMN city VARCHAR(50) NOT NULL AFTER Name;

--#Q8 #--------------------------------------------------------------------------------------------------

use classicmodels;

CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine AS productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM 
    ProductLines pl
JOIN 
    Products p ON pl.productLine = p.productLine
JOIN 
    OrderDetails od ON p.productCode = od.productCode
JOIN 
    Orders o ON od.orderNumber = o.orderNumber
GROUP BY 
    pl.productLine;

SELECT * FROM product_category_sales;


--#Q9 #---------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE Get_country_payments (
    IN input_year INT,
    IN input_country VARCHAR(50)
)
BEGIN
    SELECT 
        YEAR(p.paymentDate) AS Year,
        c.country AS Country,
        CONCAT(ROUND(SUM(p.amount) / 1000), 'K') AS Total_Amount
    FROM 
        Customers c
    JOIN 
        Payments p ON c.customerNumber = p.customerNumber
    WHERE 
        YEAR(p.paymentDate) = input_year 
        AND c.country = input_country
    GROUP BY 
        YEAR(p.paymentDate), c.country;
END //

DELIMITER ;

CALL Get_country_payments(2003, 'France');


--#Q10-a #------------------------------------------------------------------------------------------
use classicmodels;

SELECT 
    c.customerName, 
    COUNT(o.orderNumber) AS order_count,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.customerName
ORDER BY 
    order_frequency_rnk;
    
    --#Q10-b #-------------------------------------------------------------------------------

use classicmodels;


WITH MonthlyOrders AS (
    SELECT 
        YEAR(orderDate) AS Year,
        MONTH(orderDate) AS Month,
        COUNT(orderNumber) AS Total_Orders
    FROM 
        Orders
    GROUP BY 
        YEAR(orderDate), MONTH(orderDate)
)

SELECT 
    Year,
    MONTHNAME(DATE(CONCAT(Year, '-', Month, '-01'))) AS Month,  -- Get month name
    Total_Orders,
    CASE 
        WHEN LAG(Total_Orders) OVER (ORDER BY Year, Month) IS NULL THEN NULL
        ELSE CONCAT(ROUND(((Total_Orders - LAG(Total_Orders) OVER (ORDER BY Year, Month)) 
        / LAG(Total_Orders) OVER (ORDER BY Year, Month) * 100), 0), '%')
    END AS YoY_Change
FROM 
    MonthlyOrders
ORDER BY 
    Year, Month;
    
    SELECT 
    YEAR(orderDate) AS Year,
    MONTH(orderDate) AS Month,
    COUNT(orderNumber) AS Total_Orders
FROM 
    Orders
GROUP BY 
    YEAR(orderDate), MONTH(orderDate)
ORDER BY 
    Year, Month;

--#Q11 #----------------------------------------------------------------------
use classicmodels;

SELECT productLine, COUNT(*) AS productCount
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine;

--#Q12 #---------------------------------------------------------------------------

CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    EmailAddress VARCHAR(100)
);

DELIMITER //
CREATE PROCEDURE Add_Emp (IN EmpID INT, IN EmpName VARCHAR(50), IN Email VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred';
    END;
    
    INSERT INTO Emp_EH VALUES (EmpID, EmpName, Email);
END //
DELIMITER ;

CALL Add_Emp(1, 'John Doe', 'john@example.com');

SHOW PROCEDURE STATUS WHERE Name = 'Add_Emp';


 --#Q13 #-------------------------------------------------------------------------------
 
CREATE TABLE Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

SELECT * FROM Emp_BIT;


DELIMITER //

CREATE TRIGGER before_insert_emp_bit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //

DELIMITER ;


INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Test User', 'Tester', '2020-10-04', -5);

SELECT * FROM Emp_BIT;
----------------------------------THANK YOU--------------------------------------------------------


















