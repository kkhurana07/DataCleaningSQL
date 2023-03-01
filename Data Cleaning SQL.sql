--- Cleaning Data in SQL Queries

Select *
from PortfolioProject..NashvilleHousing


--Stadardize date format

Select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Adress, city, state)

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))  as City

from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))


SELECT *
From PortfolioProject..NashvilleHousing



--- splitting without substring

SELECT OwnerAddress
From PortfolioProject..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)



------------------------------------------------------------------------------------------------

--- change Y and N to Yes and No in "sold as vacant" field

Select Distinct(SoldAsVacant) , count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2





Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END





---------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

From PortfolioProject..NashvilleHousing	
)

DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress





----------------------------------------------------------------------------------------------------


-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate