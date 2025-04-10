
-- TASK 1
-- 1. Find the top 10 customers by credit limit.
SELECT customerNumber, customerName, creditLimit
FROM customers
ORDER BY creditLimit DESC
LIMIT 10;

-- 2. Find the average credit limit for customers in each country.
SELECT country, AVG(creditLimit) as avg_credit_limit
FROM customers
GROUP BY country
ORDER BY avg_credit_limit DESC;

-- 3. Find the number of customers in each state.
SELECT state, COUNT(customerNumber) as customer_count
FROM customers
WHERE state is NOT NULL
GROUP BY state
ORDER BY customer_count DESC;

-- 4. Find the customers who haven't placed any orders.
SELECT c.customerNumber, c.customerName
FROM customers c 
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
WHERE o.orderNumber IS NULL;

-- 5. Calculate total sales for each customer.
SELECT c.customerNumber, c.customerName, SUM(od.quantityOrdered * od.priceEach)
AS total_sales FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY total_sales DESC;


-- 6. List customers with their assigned sales representatives.
SELECT c.customerNumber, c.customerName,
	   COALESCE(e.employeeNumber, 'N/A') AS employeeNumber, 
       COALESCE(e.firstName, 'Unknown') AS firstName, 
       COALESCE(e.lastName, 'Unknown') AS lastName
FROM customers c 
LEFT JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
ORDER BY c.customerName;


-- 7. Retrieve customer information with their most recent payment details.
SELECT c.customerNumber, c.customerName, p.paymentDate, p.amount
FROM customers c 
JOIN payments p ON c.customerNumber = p.customerNumber
ORDER BY p.paymentDate DESC;


-- 8.Identify the customers who have exceeded their credit limit.
SELECT c.customerNumber, c.customerName, c.creditLimit, SUM(p.amount) AS total_payment
FROM customers c 
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName, c.creditLimit
HAVING total_payment > c.creditLimit;

-- 9.Find the names of all customers who have placed an order for a product from a specific product line.
SELECT DISTINCT c.customerName
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE p.productLine = 'Motorcycles';

-- 10. Find the names of all customers who have placed an order for the most expensive product.
SELECT DISTINCT c.customerName
FROM customers c 
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE od.priceEach = (SELECT MAX(priceEach) FROM orderdetails);





-- Task 2
-- 1. Find the number of employees working in each office.
SELECT officeCode, COUNT(employeeNumber) as employee_count
FROM employees
GROUP BY officeCode;

-- 2.Identify the offices with less than a certain number of employees.
SELECT officeCode, COUNT(employeeNumber) as employee_count
FROM employees
GROUP BY officeCode
HAVING employee_count < 5;

-- 3.List offices along with their assigned territories.
SELECT officeCode, territory FROM offices;

-- 4.Find the offices that have no employees assigned to them.
SELECT o.officeCode, o.city  FROM offices o 
LEFT JOIN employees e ON o.officeCode = e.officeCode
WHERE e.employeeNumber IS NULL;


-- 5. Retrieve the most profitable office based on total sales.
SELECT e.officeCode, oc.city, SUM(od.quantityOrdered * od.priceEach) as total_sales
FROM employees e 
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN offices oc ON e.officeCode = oc.officeCode
GROUP BY e.officeCode, oc.city
ORDER BY total_sales DESC LIMIT 1;

-- 6. Find the office with the highest number of employees.
SELECT officeCode, COUNT(employeeNumber) AS employee_count
FROM employees
GROUP BY officeCode
ORDER BY employee_count DESC LIMIT 1;

-- 7. Find the average credit limit for customers in each office.
SELECT AVG(c.creditLimit) as avg_credlimit, e.officeCode
FROM employees e 
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY e.officeCode
ORDER BY avg_credlimit DESC;

-- 8. Find the number of offices in each country.
SELECT country, COUNT(officeCode) as office_count
FROM offices
GROUP BY country
ORDER BY office_count DESC;


-- TASK 3
-- Prouct Data Analysis
-- 1. Count the number of products in each product line.
SELECT productLine, COUNT(productName) as productCount
FROM products
GROUP BY productLine
ORDER BY productCount DESC;

-- 2. Find the product line with the highest average product price.
SELECT productLine, AVG(MSRP) as averagePrice
FROM products
GROUP BY productLine
ORDER BY averagePrice DESC LIMIT 1;

-- 3. Find all products with a price between 50 and 100.
SELECT * FROM products
WHERE MSRP BETWEEN 50 AND 100
ORDER BY MSRP DESC;

-- 4. Find the total sales amount for each product line.
SELECT p.productLine, SUM(od.quantityOrdered * od.priceEach) as total_sales
FROM products p 
JOIN orderdetails od ON p.productCode = od.productCode 
GROUP BY p.productLine
ORDER BY total_sales DESC;

-- 5. Identify products with low inventory levels (less than 10 in stock).
SELECT productName, productCode, quantityInStock
FROM products
WHERE quantityInStock < 10
ORDER BY quantityInStock DESC;

-- 6. Retrieve the most expensive product based on MSRP.
SELECT productName, productCode, MSRP
FROM products
ORDER BY MSRP DESC LIMIT 1;

-- 7. Calculate total sales for each product.
SELECT p.productName, p.productCode, SUM(od.quantityOrdered * od.priceEach) as total_sales
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName, p.productCode
ORDER BY total_sales DESC;

-- 8. Identify the top selling products based on total quantity ordered using a stored procedure.
DELIMITER //
CREATE PROCEDURE get_top_selling_products(IN top_products INT)
BEGIN
	SELECT p.productName, p.productCode, SUM(od.quantityOrdered) AS total_quantity_sold
    FROM products p
	JOIN orderdetails od ON p.productCode = od.productCode
    GROUP BY p.productCode, p.productName
    ORDER BY total_quantity_sold DESC
    LIMIT top_products;
END //
DELIMITER ;

CALL get_top_selling_products(3);

-- 9. Retrieve products with low inventory levels (less than 10) within specific product lines ('Classic Cars', 'Motorcycles').
SELECT productName, productCode, quantityInStock
FROM products
WHERE quantityInStock < 10 AND productLine IN ('Classic Cars', 'Motorcycles')
ORDER BY quantityInStock;

-- 10. Find the names of all products that have been ordered by more than 10 customers.
SELECT p.productName, p.productCode 
FROM products p 
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p.productName, p.productCode 
HAVING COUNT(DISTINCT o.customerNumber) > 10;

-- 11. Find the names of all products that have been ordered more than the average number of orders for their product line.
SELECT p.productCode, p.productName
FROM products p 
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
HAVING COUNT(od.orderNumber) > 
		(SELECT AVG(orderCount) FROM
			(SELECT p2.productLine, COUNT(od2.orderNumber) AS orderCount
            FROM products p2 
            JOIN orderdetails od2 ON p2.productCode = od2.productCode
            GROUP BY p2.productLine) AS avg_orders_per_line
		 );





