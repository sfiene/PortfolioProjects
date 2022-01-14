-- Cleaning Data in SQL


select *
from nashville_housing

-------------------------------------

-- Standardize Date Format

select saledateconverted
	, convert(date, SaleDate)
from nashville_housing

/* Does not work to standardize date format
update nashville_housing
set SaleDate = cast(SaleDate as date)
*/

alter table nashville_housing
add saledateconverted date

update nashville_housing
set saledateconverted = convert(date, SaleDate)

-------------------------------------

--Populate Property Address Data

select *
from nashville_housing
where PropertyAddress is null

-- ParcelID reflects what the address is
select *
from nashville_housing
where PropertyAddress is null
order by ParcelID

-- Self Join to replace NULL values in address field
select a.ParcelID
	, a.PropertyAddress
	, b.ParcelID
	, b.PropertyAddress
	, isnull(a.PropertyAddress, b.PropertyAddress)
from nashville_housing a
join nashville_housing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from nashville_housing a
join nashville_housing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------

-- Break out address into individual columns (address, city, state)

select PropertyAddress
from nashville_housing

/*
substring(expression, start, length)
charindex(substring, string)

Use substring to extract part of the address before the comma and charindex is used to find the comma to
split address and city on and minus 1 to remove the comma at the end of the substring
*/
select substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as address_before_comma
	, substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as city
from nashville_housing


-- Create new columns with the split address
alter table nashville_housing
add PropertySplitAddress nvarchar(255)

update nashville_housing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table nashville_housing
add PropertySplitCity nvarchar(255)

update nashville_housing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

select *
from nashville_housing

-- Owner Address

/*
parsename parses out given string into parts. It parses based on the period delimiter so using replace
to replace the comma with a period will make this work
*/
select parsename(replace(OwnerAddress, ',', '.'), 3) as address
	, parsename(replace(OwnerAddress, ',', '.'), 2) as city
	, parsename(replace(OwnerAddress, ',', '.'), 1) as state
from nashville_housing

alter table nashville_housing
add OwnerSplitAddress nvarchar(255)

update nashville_housing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table nashville_housing
add OwnerSplitCity nvarchar(255)

update nashville_housing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table nashville_housing
add OwnerSplitState nvarchar(255)

update nashville_housing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from nashville_housing

------------------------------------------------------------

-- Change y and N to Yes and No in 'Sold as Vacant' field

-- yes and no are more populated that Y and N
select distinct SoldAsVacant
	, count(SoldAsVacant)
from nashville_housing
group by SoldAsVacant
order by 2

select SoldAsVacant
	, case when SoldAsVacant = 'Y' then 'Yes'
		   when SoldAsVacant = 'N' then 'No'
		   else SoldAsVacant
		   end
from nashville_housing

update nashville_housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

---------------------------------------------

--Remove Duplicates

with rownumcte as (
select *
	, row_number() over (partition by ParcelId
									, PropertyAddress
									, SalePrice
									, SaleDate
									, LegalReference
						 order by UniqueID) row_num
from nashville_housing)

select *
from rownumcte
where row_num > 1

---------------------------------------------

-- Remove unused columns

select *
from nashville_housing

alter table nashville_housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


























