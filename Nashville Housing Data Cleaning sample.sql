/* 
	Queries below are cleaning for a Housing Dataset, called Nashville 

*/
--------------------------------------------------------------------------------------------------------------------
-- Viewing All

	Select *
	From [PortFolio  Project]..[Nashville Housing]

-- Converting Sale date columns from Datetime to only Date

Select SaleDateConverted, CONVERT(date,SaleDate)
From [PortFolio  Project]..[Nashville Housing]

Update [Nashville Housing]
Set SaleDate = CONVERT(date,SaleDate)


--Select CAST(SaleDate as date)
--From [PortFolio  Project]..[Nashville Housing]

ALTER TABLE [Nashville Housing]
Add SaleDateConverted Date;

Update [Nashville Housing]
Set SaleDateConverted = CONVERT(date,SaleDate)


-- This below query tells us NULLS in property address

Select *
From [PortFolio  Project]..[Nashville Housing]
where PropertyAddress is NULL
order by ParcelID

-- Here we made a Joins to see tables,Cells where ParcelID is duplicate to check the address.
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
From [PortFolio  Project]..[Nashville Housing] a
JOIN [PortFolio  Project]..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Here we are updating the address from duplicate's ParcelID reffereing address to parcelsID where adddress is NULL/blank

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
From [PortFolio  Project]..[Nashville Housing] a
JOIN [PortFolio  Project]..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


--- Breaking out address Into Individuals Columns like Address, City, State

Select PropertyAddress
From [PortFolio  Project]..[Nashville Housing]


SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, 1000) as City

From [PortFolio  Project]..[Nashville Housing]



ALTER TABLE [dbo].[Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing]
Set [PropertySplitAddress] = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [dbo].[Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing]
Set [PropertySplitCity] =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, 1000)


-------------------DOing same spliting of address on Owner address with parsename function

Select OwnerAddress
From [PortFolio  Project]..[Nashville Housing]

Select
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
,PARSENAME(Replace(OwnerAddress, ',','.'), 2)
,PARSENAME(Replace(OwnerAddress, ',','.'), 1)
From [PortFolio  Project]..[Nashville Housing]

--------------------------------------
ALTER TABLE [dbo].[Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)
--------------------------------------

ALTER TABLE [dbo].[Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

ALTER TABLE [dbo].[Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

------------------------------------------------------------------------
------------- Converting Y to yes and n to No in Sold as Vacant column for uniformity



Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [PortFolio  Project]..[Nashville Housing]
Group by SoldAsVacant
order by 2


Select SoldAsVacant
	,case When soldasvacant = 'Y' Then 'YES'
		When soldasvacant = 'N' then 'NO'
	Else Soldasvacant
	end
From [PortFolio  Project]..[Nashville Housing]


Update [Nashville Housing]
SET SoldAsVacant = case When soldasvacant = 'Y' Then 'YES'
		When soldasvacant = 'N' then 'NO'
	Else Soldasvacant
	END

------------- ---
-- REMOVE DUPLICATES

With RowNumCTE as (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) row_num

From [PortFolio  Project]..[Nashville Housing]
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num>1


--With RowNumCTE as (
--SELECT *,
--	ROW_NUMBER() OVER(
--	PARTITION BY ParcelID,
--				PropertyAddress,
--				SalePrice,
--				SaleDate,
--				LegalReference
--				Order by UniqueID
--				) row_num

--From [PortFolio  Project]..[Nashville Housing]
----Order by ParcelID
--)
--Select *
--From RowNumCTE
--Where row_num>1




-- Delete Unused Columns

Select *
From [PortFolio  Project]..[Nashville Housing]

Alter Table [PortFolio  Project]..[Nashville Housing]
Drop Column PropertyAddress, Owneraddress,  SaleDate, TaxDistrict