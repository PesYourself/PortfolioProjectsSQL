/**Data Cleaning Using SQL. Data on Nashville Housing Information**/

-- Data Overview --

SELECT *
FROM Portfolio_project.dbo.NashvilleHousing

-- Changing sales data. Removing time from data --
SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Portfolio_project.dbo.NashvilleHousing

Update Portfolio_project..NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Portfolio_project..NashvilleHousing
ADD SaleDateConverted Date;
Update Portfolio_project..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


--Populating property address. Checking Null Values--
SELECT *
FROM Portfolio_project.dbo.NashvilleHousing
WHERE PropertyAddress is null

--understanding relation between ParcelID and PropertyAddress--
SELECT *
FROM Portfolio_project.dbo.NashvilleHousing
order by ParcelID

-- Using parcel id to populate null porperty addresses using self join--
SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM Portfolio_project.dbo.NashvilleHousing as a
Join Portfolio_project.dbo.NashvilleHousing AS b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Updating propertyaddress in table--
Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM Portfolio_project.dbo.NashvilleHousing as a
Join Portfolio_project.dbo.NashvilleHousing AS b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking Property address into individual columns (address, city) using substring and index--
Select
propertyaddress,
SUBSTRING (PropertyAddress, 1 , CHARINDEX(',',propertyaddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',propertyaddress)+1, LEN(PropertyAddress)) as City

From Portfolio_project.dbo.NashvilleHousing

ALTER TABLE Portfolio_project..NashvilleHousing
ADD Address nvarchar(255);
Update Portfolio_project..NashvilleHousing
SET Address = SUBSTRING (PropertyAddress, 1 , CHARINDEX(',',propertyaddress)-1)

ALTER TABLE Portfolio_project..NashvilleHousing
ADD City nvarchar(255);
Update Portfolio_project..NashvilleHousing
SET City = SUBSTRING (PropertyAddress, CHARINDEX(',',propertyaddress)+1, LEN(PropertyAddress))

--Using parcename to split owner address--
SELECT 
PARSENAME( Replace(OwnerAddress , ',','.'),1) as ownerstate,
PARSENAME( Replace(OwnerAddress , ',','.'),2) as ownercity,
PARSENAME( Replace(OwnerAddress , ',','.'),3) as owneradd
FROM Portfolio_project.dbo.NashvilleHousing

ALTER TABLE Portfolio_project..NashvilleHousing
ADD OwnerAdd nvarchar(255);
Update Portfolio_project..NashvilleHousing
SET OwnerAdd = PARSENAME(Replace(OwnerAddress , ',','.'),3)

ALTER TABLE Portfolio_project..NashvilleHousing
ADD OwnerCity nvarchar(255);
Update Portfolio_project..NashvilleHousing
SET OwnerCity = PARSENAME(Replace(OwnerAddress , ',','.'),2)

ALTER TABLE Portfolio_project..NashvilleHousing
ADD OwnerState nvarchar(255);
Update Portfolio_project..NashvilleHousing
SET OwnerState = PARSENAME(Replace(OwnerAddress , ',','.'),3)

--Making SoldAsVacant coloumn consistent with 'yes' and 'no' answers--
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio_project..NashvilleHousing
Group By SoldAsVacant

Select Soldasvacant,
Case When SoldAsVacant = 'y' then 'Yes'
When SoldAsVacant = 'n' then 'No'
Else SoldAsVacant
END
From Portfolio_project..NashvilleHousing

Update Portfolio_project..NashvilleHousing
SET SoldasVacant = Case When SoldAsVacant = 'y' then 'Yes'
When SoldAsVacant = 'n' then 'No'
Else SoldAsVacant
END

-- Removing Duplicates--
With RowNumCTE AS(
Select*,
      Row_Number() Over (
      Partition By ParcelId, 
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
      Order By UniqueId)
	  as row_num
FROM Portfolio_project..NashvilleHousing
)
Select*
From RownumCTE
WHERE row_num > 1


--Deleting Unused Coloumns--
SELECT *
FROM Portfolio_project.dbo.NashvilleHousing

Alter Table Portfolio_project..NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate
