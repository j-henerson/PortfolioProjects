Use Portfolio

-- Change Date Format
Select SaleDateConverted
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)



-- Populate Property Address Data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID 
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID 
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null 

-- Breaking Out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

-- Property Address and City Columns
Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) As City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress))

-- Splitting Owner Address Columns
Select OwnerAddress
From NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3) As Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) As City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) As State
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Changing Y and N to Yes and No in Sold As Vacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant) As Count
From NashvilleHousing
Group By SoldAsVacant
Order By Count

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

-- Remove Duplicates

With RowNumCTE As (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By UniqueID) row_num
From NashvilleHousing)
Delete
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
