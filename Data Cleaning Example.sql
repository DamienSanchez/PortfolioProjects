/*
	CLEANING DATA IN SQL QUERIES
*/

SELECT *
FROM ProtfolioProject..NashvilleHouseCleaning;

-- Standardize Date Format
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM ProtfolioProject..NashvilleHouseCleaning;

ALTER TABLE ProtfolioProject..NashvilleHouseCleaning
ADD SaleDateConverted DATE;

UPDATE ProtfolioProject..NashvilleHouseCleaning
SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT SaleDateConverted
FROM ProtfolioProject..NashvilleHouseCleaning;

-- Populate Property Address data
SELECT PropertyAddress
FROM ProtfolioProject..NashvilleHouseCleaning
WHERE PropertyAddress is null;

SELECT a.PropertyAddress, a.parcelid, b.PropertyAddress, b.parcelid, ISNULL(a.propertyaddress, b.propertyaddress)
FROM ProtfolioProject..NashvilleHouseCleaning a
JOIN ProtfolioProject..NashvilleHouseCleaning b
	ON a.parcelid = b.parcelid
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a. PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM ProtfolioProject..NashvilleHouseCleaning a
JOIN ProtfolioProject..NashvilleHouseCleaning b
	ON a.parcelid = b.parcelid
	AND a.[UniqueID ] <> b.[UniqueID ]

--Breaking out address into individual columns (address,city,state)
SELECT PropertyAddress
FROM ProtfolioProject..NashvilleHouseCleaning;

SELECT 
SUBSTRING(propertyaddress,1, CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PropertyAddress) +1, LEN(propertyaddress)) as city
FROM ProtfolioProject..NashvilleHouseCleaning;

ALTER TABLE ProtfolioProject..NashvilleHouseCleaning
ADD PropertySPLITAddress NVARCHAR(255);

UPDATE ProtfolioProject..NashvilleHouseCleaning
SET PropertySPLITAddress = SUBSTRING(propertyaddress,1, CHARINDEX(',',PropertyAddress)-1) ;

ALTER TABLE ProtfolioProject..NashvilleHouseCleaning
ADD PropertySPLITcity NVARCHAR(255);

UPDATE ProtfolioProject..NashvilleHouseCleaning
SET  PropertySPLITcity = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PropertyAddress) +1, LEN(propertyaddress)) ;

--owner address split (easy way)
SELECT 
PARSENAME(REPLACE(owneraddress, ',' , '.'), 3)
,PARSENAME(REPLACE(owneraddress, ',' , '.'), 2)
,PARSENAME(REPLACE(owneraddress, ',' , '.'), 1)
FROM ProtfolioProject..NashvilleHouseCleaning

ALTER TABLE ProtfolioProject..NashvilleHouseCleaning
ADD ownerSPLITAddress NVARCHAR(255);

UPDATE ProtfolioProject..NashvilleHouseCleaning
SET ownerSPLITAddress = PARSENAME(REPLACE(owneraddress, ',' , '.'), 3) ;

ALTER TABLE ProtfolioProject..NashvilleHouseCleaning
ADD ownerSPLITcity NVARCHAR(255);

UPDATE ProtfolioProject..NashvilleHouseCleaning
SET  ownerSPLITcity = PARSENAME(REPLACE(owneraddress, ',' , '.'), 2) ;

ALTER TABLE ProtfolioProject..NashvilleHouseCleaning
ADD ownerSPLITstate NVARCHAR(255);

UPDATE ProtfolioProject..NashvilleHouseCleaning
SET  ownerSPLITstate = PARSENAME(REPLACE(owneraddress, ',' , '.'), 1) ;

-- Change y and n to yes and no in "sold as vacant" feild
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProtfolioProject..NashvilleHouseCleaning
GROUP BY SoldAsVacant;

SELECT DISTINCT(SoldAsVacant),
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
FROM ProtfolioProject..NashvilleHouseCleaning; 

UPDATE  ProtfolioProject..NashvilleHouseCleaning
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

--Remove Duplicates
WITH rownumcte as (
SELECT *, 
ROW_NUMBER() OVER(
	PARTITION BY parcelid,
	propertyaddress,
	saleprice,
	saledate,
	legalreference
	ORDER BY uniqueid) row_num
FROM ProtfolioProject..NashvilleHouseCleaning
)
SELECT *
FROM rownumcte
WHERE row_num >1

--DELETE COLUMNS ---> demo only not best practice
SELECT *
FROM ProtfolioProject..NashvilleHouseCleaning;

ALTER TABLE ProtfolioProject..NashvilleHouseCleaning
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress, SaleDate
