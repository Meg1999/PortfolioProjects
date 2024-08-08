-- NASHVILLE HOUSING DATA CLEANING IN SQL

select * from NashvilleHousing
order by ParcelID

-- converting SaleDate

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate);

select SaleDateConverted
from NashvilleHousing

-- Updating NULL Values in PropertyAddress Using ParcelID

update hou1
set PropertyAddress = isnull(hou1.PropertyAddress, hou2.PropertyAddress) 
from NashvilleHousing hou1
join NashvilleHousing hou2
on hou1.ParcelID = hou2.ParcelID
where hou1.UniqueID <> hou2.UniqueID
and hou1.PropertyAddress is null


-- Splitting Property Address to seperate city

alter table NashvilleHousing
add SplitPropertyAddress nvarchar(255);

update NashvilleHousing
set SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add SplitPropertyCity nvarchar(255);

update NashvilleHousing
set SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-- Splitting Owner Address to seperate city and state

alter table NashvilleHousing
add SplitOwnerAddress nvarchar(255);

update NashvilleHousing
set SplitOwnerAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add SplitOwnerCity nvarchar(255);

update NashvilleHousing
set SplitOwnerCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add SplitOwnerState nvarchar(255);

update NashvilleHousing
set SplitOwnerState = PARSENAME(replace(OwnerAddress,',','.'),1)


-- Updating SoldAsVacant column

select distinct(SoldAsVacant), count(*) 
from NashvilleHousing
group by SoldAsVacant


update NashvilleHousing
SET SoldAsVacant =
Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END


-- Removing Duplicates

with RowNumCTE as (
select *, ROW_NUMBER() 
over (
partition by 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by
UniqueID
) RowNumber
from NashvilleHousing
)

delete from  RowNumCTE
where RowNumber > 1


-- Deleting unused columns

select * from NashvilleHousing

alter table NashvilleHousing
drop column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict