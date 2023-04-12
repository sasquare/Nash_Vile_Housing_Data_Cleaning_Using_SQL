CREATE PROCEDURE NasViles_Housing
AS
--Standardize the SalesDate column
  SELECT SaleDate,SaleDateConverted FROM Nashville_Housing


  ALTER TABLE  Nashville_Housing
  ADD SaleDateConverted DATE

  UPDATE Nashville_Housing
  SET SaleDateConverted = CONVERT(DATE,SaleDate)

--Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress,  b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking out Address into individual columns (Address,City,Stae)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Nashville_Housing

--
SELECT PropertySplitAddress,PropertySplitCity  FROM Nashville_Housing

ALTER TABLE  Nashville_Housing
ADD PropertySplitAddress NVARCHAR(225);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE  Nashville_Housing
ADD PropertySplitCity NVARCHAR(225);
UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM Portfolio.dbo.Nashville_Housing


ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitSate NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitSate = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


SELECT SoldAsVacant 
,(CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	  WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END) AS SoldAsVacant2
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	  WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM Nashville_Housing Group By SoldAsVacant ORDER BY 2

--REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Nashville_Housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--Delete Unused Columns
SELECT *
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress



ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate
