USE AdventureWorks2008R2

--1. Display the number of records in the [SalesPerson] table. (Schema(s) involved: Sales)
SELECT COUNT(*) 
FROM Sales.SalesPerson ;

--2. Select both the FirstName and LastName of records from the Person table where the FirstName begins with the letter ‘B’. 
-- (Schema(s) involved: Person)
SELECT FirstName AS 'F.Name'
	 , LastName AS 'L.Name'
FROM Person.Person 
WHERE FirstName LIKE 'B%' ;

--3. Select a list of FirstName and LastName for employees where Title is one of Design Engineer, 
-- Tool Designer or Marketing Assistant. (Schema(s) involved: HumanResources, Person)
SELECT pp.FirstName AS 'F.Name'
	 , pp.LastName AS 'L.Name'
FROM HumanResources.employee AS hre
	 JOIN Person.Person AS pp ON
     hre.BusinessEntityID= pp.BusinessEntityID 
WHERE JobTitle= 'Design Enginer' 
	  OR JobTitle= 'Tool Designer' 
	  OR JobTitle= 'Marketing Assistant' ;

--4. Display the Name and Color of the Product with the maximum weight. (Schema(s) involved: Production)
SELECT Name
     , Color
FROM Production.Product
WHERE Weight= (SELECT MAX(Weight) FROM Production.Product);

--5. Display Description and MaxQty fields from the SpecialOffer table. 
-- Some of the MaxQty values are NULL, in this case display the value 0.00 instead. (Schema(s) involved: Sales)
SELECT MaxQty
FROM Sales.SpecialOffer 
WHERE MaxQty IS NOT NULL ;

--6. Display the overall Average of the [CurrencyRate].[AverageRate] values for the exchange rate 
-- ‘USD’ to ‘GBP’ for the year 2005 i.e. FromCurrencyCode = ‘USD’ and ToCurrencyCode = ‘GBP’. 
-- Note: The field [CurrencyRate].[AverageRate] is defined as 'Average exchange rate for the day.' (Schema(s) involved: Sales)
SELECT AVG(AverageRate)
FROM Sales.CurrencyRate 
WHERE ToCurrencyCode= 'GBP' 
	 AND (SELECT YEAR(CurrencyRateDate))= '2005' ;

--7. Display the FirstName and LastName of records from the Person table where FirstName contains the letters ‘ss’.
-- Display an additional column with sequential numbers for each row returned beginning at integer 1. (Schema(s) involved: Person)
SELECT ROW_NUMBER() OVER (ORDER BY FirstName) As 'Row no.'
	 , FirstName AS 'F.Name'
	 , LastName AS 'L.Name'
FROM Person.Person AS p
WHERE FirstName LIKE '%ss%' ;   

--8. Sales people receive various commission rates that belong to 1 of 4 bands. (Schema(s) involved: Sales)
-- Display the [SalesPersonID] with an additional column entitled ‘Commission Band’ indicating the appropriate band as above
SELECT BusinessEntityID AS 'SalesPersonID' ,
CASE 
	 WHEN CommissionPct=0 THEN 'BAND 0'
	 WHEN CommissionPct>0 AND CommissionPct<=0.01 THEN 'BAND 1'
	 WHEN CommissionPct>0.01 AND CommissionPct<=0.015 THEN 'BAND 2'
	 WHEN CommissionPct>0.015 THEN 'BAND 3'
END AS 'Comission Band'
FROM Sales.SalesPerson ORDER BY CommissionPct;

--9. Display the managerial hierarchy from Ruth Ellerbrock (person type – EM) up to CEO Ken Sanchez. 
-- Hint: use [uspGetEmployeeManagers] (Schema(s) involved: [Person], [HumanResources])
DECLARE @ID INT;
SELECT @ID= hre.BusinessEntityID
FROM HumanResources.Employee AS hre INNER JOIN Person.Person AS pp ON
hre.BusinessEntityID= pp.BusinessEntityID
WHERE pp.FirstName+ ' '+ pp.LastName= 'Ruth Ellerbrock'
AND pp.PersonType= 'EM';
EXEC dbo.uspGetEmployeeManagers @BusinessEntityID= @ID

-- 10. Display the ProductId of the product with the largest stock level. 
-- Hint: Use the Scalar-valued function [dbo]. [UfnGetStock]. (Schema(s) involved: Production)

SELECT ProductId 
FROM Production.Product 
WHERE dbo.ufnGetStock(ProductID) in (SELECT MAX(dbo.ufnGetStock(ProductID))
FROM Production.Product);