-- Task 1
-- 1. Find the total number of employees.
SELECT COUNT(employeeNumber) as employeeCount
FROM employees
ORDER BY employeeCount DESC;

-- 2. List all employees with their basic information.
SELECT * FROM employees;

-- 3. Count the number of employees holding each job title.
SELECT jobTitle, COUNT(employeeNumber) as employeeCount
FROM employees
GROUP BY jobTitle
ORDER BY employeeCount DESC;

-- 4.Find the employees who don't have a manager (reports To is NULL).
SELECT employeeNumber, firstName, lastName, reportsTo FROM employees
WHERE reportsTo is NULL;

-- 5. Calculate total sales generated by each sales representative.
SELECT e.employeeNumber, e.firstName, e.lastName, SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM employees e 
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY e.employeeNumber, e.firstName, e.lastName
ORDER BY totalSales DESC;

-- 6. Find the most profitable sales representative based on total sales.
SELECT e.employeeNumber, e.firstName, e.lastName, SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM employees e 
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY e.employeeNumber, e.firstName, e.lastName
ORDER BY totalSales DESC LIMIT 1;

-- 7. Find the names of all employees who have sold more than the average sales amount for their office.
SELECT e.employeeNumber, e.firstName, e.lastName, e.officeCode, SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM employees e 
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY e.employeeNumber, e.firstName, e.lastName, e.officeCode
HAVING totalSales > 
					(SELECT AVG(totalSales)
					FROM (
                    SELECT e2.officeCode, SUM(od2.quantityOrdered * od2.priceEach) AS totalSales
                    FROM employees e2
                    JOIN customers c2 ON e2.employeeNumber = c2.salesRepEmployeeNumber
                    JOIN orders o2 ON c2.customerNumber = o2.customerNumber
                    JOIN orderdetails od2 ON o2.orderNumber = od2.orderNumber
                    GROUP BY e2.officeCode
                    ) AS avgSalesPerOffice
				)
                ORDER BY totalSales DESC;


-- Order Data Analysis
-- 1. Find the average order amount for each customer.
SELECT c.customerName, AVG(od.quantityOrdered * od.priceEach) as avg_order_amount
FROM customers c 
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName;

-- 2. Find the number of orders placed in each month.
SELECT MONTH(orderDate) AS order_month, COUNT(orderNumber) as total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 3. Identify orders that are still pending shipment.
SELECT orderNumber, customerNumber, status 
FROM orders
WHERE status = 'In Process';


-- 4. List orders along with customer details.
SELECT o.orderNumber, c.customerNumber, c.customerName, o.orderDate, o.status
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber;

-- 5. Retrieve the most recent orders.
SELECT orderNumber, customerNumber, orderDate
FROM orders
ORDER BY orderDate DESC LIMIT 10;

-- 6. Calculate total sales for each order.
SELECT orderNumber, SUM(quantityOrdered * priceEach) as total_sales
FROM orderdetails
GROUP BY orderNumber;


-- 7.Find the highest-value order based on total sales. 
SELECT orderNumber, SUM(quantityOrdered * priceEach) as total_sales
FROM orderdetails
GROUP BY orderNumber
ORDER BY total_sales DESC LIMIT 1;

-- 8. List all orders with their corresponding order details
SELECT o.orderNumber, o.orderDate, od.productCode, od.quantityOrdered, od.priceEach
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber;


-- 9. List the most frequently ordered products
SELECT productCode, COUNT(*) AS order_count
FROM orderdetails
GROUP BY productCode
ORDER BY order_count DESC;


-- 10. Calculate total revenue for each order
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS total_revenue
FROM orderdetails
GROUP BY orderNumber;

-- 11. Identify the most profitable orders based on total revenue
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS total_profit
FROM orderdetails
GROUP BY orderNumber
ORDER BY total_profit DESC
LIMIT 10;

-- 12. List all orders with detailed product information
SELECT o.orderNumber, o.orderDate, p.productName, od.quantityOrdered, od.priceEach
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode;

-- 13. Identify orders with delayed shipping (shippedDate > requiredDate)
SELECT orderNumber, orderDate, requiredDate, shippedDate
FROM orders
WHERE shippedDate > requiredDate;

-- 14. Find the most popular product combinations within orders
SELECT od1.productCode AS product1, od2.productCode AS product2, COUNT(*) AS frequency
FROM orderdetails od1
JOIN orderdetails od2 ON od1.orderNumber = od2.orderNumber AND od1.productCode < od2.productCode
GROUP BY product1, product2
ORDER BY frequency DESC
LIMIT 10;

-- 15. Calculate revenue for each order and identify the top 10 most profitable
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS total_revenue
FROM orderdetails
GROUP BY orderNumber
ORDER BY total_revenue DESC
LIMIT 10;

-- 16. Create a trigger that automatically updates a customer's credit limit after a new order is placed, reducing it by the order total
DELIMITER //
CREATE TRIGGER update_credit_limit
AFTER INSERT ON orders
FOR EACH ROW
UPDATE customers
SET creditLimit = creditLimit - (
	SELECT SUM(quantityOrdered * priceEach)
    FROM orderdetails
    WHERE orderNumber = NEW.orderNumber
)
WHERE customerNumber = NEW.customerNumber;
END //
DELIMITER ;

-- 17. Create a trigger that logs product quantity changes whenever an order detail is inserted or updated
DELIMITER //
CREATE TRIGGER log_product_quantity_changes_insert
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
    INSERT INTO product_quantity_log (productCode, orderNumber, quantityChanged, changeDate)
    VALUES (NEW.productCode, NEW.orderNumber, NEW.quantityOrdered, NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER log_product_quantity_changes_update
AFTER UPDATE ON orderdetails
FOR EACH ROW
BEGIN
    INSERT INTO product_quantity_log (productCode, orderNumber, quantityChanged, changeDate)
    VALUES (NEW.productCode, NEW.orderNumber, NEW.quantityOrdered - OLD.quantityOrdered, NOW());
END //
DELIMITER ;


