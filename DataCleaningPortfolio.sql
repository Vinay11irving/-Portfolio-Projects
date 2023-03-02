--Data Cleaning

SELECT *
FROM Nashville_Housing

--Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date;

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT *
FROM Nashville_Housing

--Populate Property Address

SELECT *
FROM Nashville_Housing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing AS a
	JOIN Nashville_Housing AS b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing AS a
	JOIN Nashville_Housing AS b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into invidual columns

SELECT PropertyAddress
FROM Nashville_Housing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,		-- Getting the address
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address   -- Getting the City
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Nashville_Housing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity nvarchar(255);	

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(255);	

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity nvarchar(255);	

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState nvarchar(255);	

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


-- Changing Y/N to yes and no in the SoldAsVacant column

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END 
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END 


-- Checking if they changed

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant;

-- Removing Duplicates
-- Create a CTE to see if there are any duplicates
-- Using Partition by over major columns and if we see rownumber greater than 1 it means there is a duplicate

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS RowNum

FROM Nashville_Housing)

SELECT *
FROM RowNumCTE
WHERE RowNum >1

-- Deleting Unused Columns

SELECT * 
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate