/*

Cleaning Data in SQL Queries

*/


Select *
From Nashville_DataCleaning.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format



--Select SaleDateConverted, CONVERT(Date,Saledate)
--From Nashville_DataCleaning.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--ALTER TABLE NashvilleHousing
--ADD SaleDateConverted Date;

--Update NashvilleHousing
--SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From Nashville_DataCleaning.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville_DataCleaning.dbo.NashvilleHousing a
JOIN Nashville_DataCleaning.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville_DataCleaning.dbo.NashvilleHousing a
JOIN Nashville_DataCleaning.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Nashville_DataCleaning.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address


From Nashville_DataCleaning.dbo.NashvilleHousing


ALTER TABLE Nashville_DataCleaning..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update Nashville_DataCleaning..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE Nashville_DataCleaning..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update Nashville_DataCleaning..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * FROM Nashville_DataCleaning..NashvilleHousing




Select OwnerAddress 
FROM Nashville_DataCleaning..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
FROM Nashville_DataCleaning..NashvilleHousing


------------------------------------------------------------------

ALTER TABLE Nashville_DataCleaning..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update Nashville_DataCleaning..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

-------------------------------------------------------------------

ALTER TABLE Nashville_DataCleaning..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update Nashville_DataCleaning..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

----------------------------------------------------------------

ALTER TABLE Nashville_DataCleaning..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update Nashville_DataCleaning..NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

-----------------------------------------------------------------------

Select * FROM Nashville_DataCleaning..NashvilleHousing






--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldasVacant)
FROM Nashville_DataCleaning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Nashville_DataCleaning..NashvilleHousing


Update Nashville_DataCleaning..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num


FROM Nashville_DataCleaning..NashvilleHousing
)
Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

Select *
FROM Nashville_DataCleaning..NashvilleHousing
--where row_num > 1 


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE Nashville_DataCleaning..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Nashville_DataCleaning..NashvilleHousing
DROP COLUMN SaleDate


















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















