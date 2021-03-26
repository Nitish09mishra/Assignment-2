USE AdventureWorks2008R2

--2. Write separate queries using a join, a subquery, a CTE, and then an EXISTS to 
-- list all AdventureWorks customers who have not placed an order.

-- using JOIN 
SELECT sc.CustomerID
FROM Sales.Customer AS sc
   LEFT JOIN Sales.SalesOrderHeader AS soh
ON 
sc.CustomerID = soh.CustomerID
WHERE soh.CustomerId IS NULL ;

-- using SUBQUERY
SELECT CustomerID
FROM Sales.Customer
WHERE CustomerID 
NOT IN (SELECT CustomerID 
	FROM Sales.SalesOrderHeader AS soh 
	WHERE soh.CustomerID=Sales.Customer.CustomerID);

--using CTE
WITH customer(ID)
AS
(
	SELECT CustomerID
	FROM Sales.Customer
	WHERE CustomerID 
	NOT IN (SELECT CustomerID 
	FROM Sales.SalesOrderHeader AS soh 
	WHERE soh.CustomerID=Sales.Customer.CustomerID)
)
SELECT * FROM customer ;

-- using EXISTS
SELECT CustomerID
FROM Sales.Customer
WHERE NOT EXISTS (SELECT CustomerID 
	FROM Sales.SalesOrderHeader AS soh 
	WHERE soh.CustomerID=Sales.Customer.CustomerID)

--3. Show the most recent five orders that were purchased from
-- account numbers that have spent more than $70,000 with AdventureWorks.
SELECT TOP 5 SalesOrderID
	 , TotalDue
	 , ModifiedDate AS 'MostRecentOrderYear'
FROM Sales.SalesOrderHeader 
WHERE AccountNumber IN (SELECT AccountNumber 
						FROM Sales.SalesOrderHeader
						GROUP BY AccountNumber HAVING SUM(TotalDue)>70000 )
ORDER BY ModifiedDate DESC ;


--4. Create a function that takes as inputs a SalesOrderID, a Currency Code, and a date, 
-- and returns a table of all the SalesOrderDetail rows for that Sales Order including Quantity, ProductID,
-- UnitPrice,and the unit price converted to the target currency based on the end of day rate for the date provided. 
-- Exchange rates can be found in the Sales.CurrencyRate table. ( Use AdventureWorks)
GO
ALTER FUNCTION  update_table(@OrderID INT, @code VARCHAR(10), @date DATE)

RETURNS TABLE 
AS
	RETURN(SELECT SalesOrderID
				, ProductID
				, OrderQty
				, UnitPrice
				, UnitPrice * (SELECT EndOfDayRate 
							   FROM Sales.CurrencyRate
							   WHERE ToCurrencyCode=@code AND ModifiedDate=@date) AS 'TargetPrice'
		   FROM Sales.SalesOrderDetail AS sod
		   WHERE sod.SalesOrderDetailID= @OrderID
		  )
GO
-- Example statement for the execution of above function
Select * from dbo.update_table(61226,'ARS','2005-07-01');


--5. Write a Procedure supplying name information from the Person.
-- Person table and accepting a filter for the first name.
-- Alter the above Store Procedure to supply Default Values if user does not enter any value.( Use AdventureWorks)
GO
ALTER PROC getDetails @PType NCHAR(2)= 'EM'
AS
SELECT FirstName +' '+ LastName
FROM Person.Person 
WHERE PersonType= @PType
GO
--executing the above procedure
EXEC getDetails 'SC'


--6. Write a trigger for the Product table to ensure the list price can never be raised more than 15 Percent in a single change. 
-- Modify the above trigger to execute its check code only if the ListPrice column is   updated (Use AdventureWorks Database).
GO

ALTER TRIGGER tr_product_ForUpdate 
ON Production.Product
FOR UPDATE
AS 

IF UPDATE(ListPrice)
	BEGIN
	DECLARE @Old_Price FLOAT
	DECLARE @New_Price FLOAT
	SELECT @New_Price= ListPrice FROM inserted
	SELECT @Old_Price= ListPrice FROM deleted
	IF(@New_Price > 0.15 * @Old_Price + @Old_Price)
		BEGIN
		PRINT 'ListPrice cant be incremented to more than 15% .'
		ROLLBACK TRANSACTION
	END
	ELSE
		BEGIN
		PRINT 'Successfully updated ListPrice.'
	END
END

GO

UPDATE Production.Product
SET ListPrice= 40 WHERE ProductID=852

SELECT * FROM Production.Product where ProductID=852