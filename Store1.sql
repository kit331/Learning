------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT max(quantity), COUNT(Quantity)
FROM [dbo].[TR_OrderDetails]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2. Find how many Unique product in Product ID

SELECT COUNT(DISTINCT ProductID)
FROM [dbo].[TR_OrderDetails]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--3. Find what is the maximum & minimum quantity sold for each ProductID

SELECT DISTINCT ProductID, MAX(Quantity)
FROM [dbo].[TR_OrderDetails]
GROUP BY ProductID
ORDER BY ProductID

SELECT DISTINCT ProductID, MIN(Quantity)
FROM [dbo].[TR_OrderDetails]
GROUP BY ProductID
ORDER BY ProductID


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--4. Find which product category have the most product name

SELECT DISTINCT PRODUCTCATEGORY, COUNT(ProductName) as A
FROM [dbo].[TR_Products]
GROUP BY ProductCategory
ORDER BY A DESC -- FURNISHING HAS THE MOST PRODUCT



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--5. Fin dhow many store in each state

SELECT DISTINCT PropertyState, COUNT(PropertyCity) as A
FROM [Store].[dbo].[TR_PropertyInfo]
GROUP BY PropertyState 
ORDER BY A DESC


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--6. Find how much total quantity sold for each product

SELECT ProductID, SUM(Quantity) as A
FROM [Store].[dbo].[TR_OrderDetails]
GROUP BY ProductID
ORDER BY A DESC -- ProductID 78 has the highest sales quantity of 153

--6.1 Find revenue for each productID

SELECT DISTINCT OrderDetails.ProductID, SUM(Quantity) AS TotalQuantity, Price, (SUM(Quantity) * Price) as Revenue
FROM [Store].[dbo].[TR_OrderDetails] as OrderDetails
JOIN [Store].[dbo].[TR_Products] as Products on OrderDetails.ProductID = Products.ProductID
GROUP BY OrderDetails.ProductID, Price
ORDER BY OrderDetails.ProductID  



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2. Find how many Unique product in Product ID


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2. Find how many Unique product in Product ID



