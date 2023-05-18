--Cleaning Data in SQL

SELECT *
FROM profileprojects.dbo.NashvilleHousing;

--Standardise sale date format

SELECT SaleDate, CONVERT(date,saledate)
FROM profileprojects.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET saledate = CONVERT(date,saledate);

--Didn't update so trying another way

ALTER TABLE Nashvillehousing
ADD Saledateconverted date;

UPDATE NashvilleHousing
SET Saledateconverted = CONVERT(date,saledate);

--Populate Property Address Data

SELECT *
FROM profileprojects.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Populate NULLs with address data where Parcel IDs are equal

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM profileprojects.dbo.NashvilleHousing AS a
JOIN profileprojects.dbo.NashvilleHousing AS b
ON a.parcelid = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM profileprojects.dbo.NashvilleHousing AS a
JOIN profileprojects.dbo.NashvilleHousing AS b
ON a.parcelid = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; 

--Break out property address into individual columns

SELECT PropertyAddress
FROM profileprojects.dbo.NashvilleHousing;
----WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

SELECT SUBSTRING(propertyaddress,1, CHARINDEX(',', propertyaddress)-1) AS Address, 
		SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) AS Address2
FROM profileprojects.dbo.NashvilleHousing;

--create 2 new columns to show above address splits

ALTER TABLE Nashvillehousing
ADD Address1 nvarChar(255), City nvarChar(255)

UPDATE NashvilleHousing
SET Address1 = SUBSTRING(propertyaddress,1, CHARINDEX(',', propertyaddress)-1), 
	City = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress));

--check columns added
SELECT *
FROM profileprojects.dbo.NashvilleHousing;

-- Split Owner address using PARSE

SELECT 
PARSENAME (REPLACE(Owneraddress,',', '.'), 3),
PARSENAME (REPLACE(Owneraddress,',', '.'), 2),
PARSENAME (REPLACE(Owneraddress,',', '.'), 1)
FROM profileprojects.dbo.NashvilleHousing;

--add columns for split owner address details

ALTER TABLE Nashvillehousing
ADD Owneradd1 nvarchar(255), OwnerCity varchar(255), OwnerState nvarchar(255)

UPDATE Nashvillehousing
SET Owneradd1 = PARSENAME (REPLACE(Owneraddress,',', '.'), 3),
	OwnerCity = PARSENAME (REPLACE(Owneraddress,',', '.'), 2),
	OwnerState = PARSENAME (REPLACE(Owneraddress,',', '.'), 1);

	--check columns added
SELECT *
FROM profileprojects.dbo.NashvilleHousing;

--Change Y and N to Yes and No in SoldAsVacant

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM profileprojects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldasVacant, CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
							WHEN Soldasvacant = 'N' THEN 'No' 
							ELSE SoldasVacant END
FROM profileprojects.dbo.NashvilleHousing
GROUP BY SoldAsVacant;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
							WHEN Soldasvacant = 'N' THEN 'No' 
							ELSE SoldasVacant END

--check all updates actioned correctly

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM profileprojects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

--remove duplicates, using Window functions & CTE

SELECT *, ROW_NUMBER() OVER(PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueID) AS ROW_NUM
FROM profileprojects.dbo.NashvilleHousing
ORDER BY parcelId;

--create CTE to select duplicates (any row nums > 1) from
WITH RowNumCTE AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueID) AS ROW_NUM
				FROM profileprojects.dbo.NashvilleHousing)
				

SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress;

--delete duplicates
WITH RowNumCTE AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueID) AS ROW_NUM
				FROM profileprojects.dbo.NashvilleHousing)
				

DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1;

--CHECK
WITH RowNumCTE AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueID) AS ROW_NUM
				FROM profileprojects.dbo.NashvilleHousing)
				

SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1;

--delete unused columns

ALTER TABLE profileprojects.dbo.NashvilleHousing
DROP COLUMN  Owneraddress, propertyaddress, taxdistrict, saledate;

--check
SELECT *
FROM profileprojects.dbo.NashvilleHousing;



