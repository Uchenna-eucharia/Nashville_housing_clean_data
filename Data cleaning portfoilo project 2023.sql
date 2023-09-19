select * from nashville_housing
use [PortfolioProject]

--standardize Date Format
select sale_date_converted, CONVERT(date,saledate)
from nashville_housing

alter table nashville_housing 
add sale_date_converted date

update nashville_housing
set sale_date_converted = CONVERT(date,saledate)


-- populate property address data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from nashville_housing a
join nashville_housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress =  ISNULL(a.propertyaddress, b.PropertyAddress)
from nashville_housing a
join nashville_housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into columns( address, city, state)
select * from nashville_housing

select SUBSTRING(propertyaddress, 1, charindex(',',propertyaddress)-1) as Address, 
substring (propertyaddress, charindex(',',propertyaddress)+1, len(propertyaddress)) as address
from nashville_housing

alter table nashville_housing
add property_split_address Nvarchar(255)

update nashville_housing
set property_split_address = SUBSTRING(propertyaddress, 1, charindex(',',propertyaddress)-1)

alter table nashville_housing
add property_split_city Nvarchar(255)

update nashville_housing
set property_split_city= substring (propertyaddress, charindex(',',propertyaddress)+1, len(propertyaddress)) 

select * from nashville_housing

select owneraddress from nashville_housing

select
PARSENAME(replace(owneraddress, ',','.') , 3),
PARSENAME(replace(owneraddress, ',','.') , 2),
PARSENAME(replace(owneraddress, ',','.') , 1)

from nashville_housing

alter table nashville_housing
add owner_split_address Nvarchar(255)

update nashville_housing
set owner_split_address = PARSENAME(replace(owneraddress, ',','.') , 3)

alter table nashville_housing
add owner_split_city Nvarchar(255)

update nashville_housing
set owner_split_city= PARSENAME(replace(owneraddress, ',','.') , 2)

alter table nashville_housing
add owner_split_state Nvarchar(255)

update nashville_housing
set owner_split_state= PARSENAME(replace(owneraddress, ',','.') , 1)

select * from nashville_housing

--change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), COUNT(soldasvacant)
from nashville_housing
group by SoldAsVacant
order by 2

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'NO'
	else soldasvacant 
	end
from nashville_housing


-- remove duplicates
with row_num_cte as(
select *, 
	row_number() over(
	partition by parcelid,
	propertyaddress,
	saledate,
	saleprice,
	legalreference
	order by 
		uniqueid
		) row_num


from nashville_housing
--order by ParcelID
)
select * from row_num_cte
where row_num > 1
--order by propertyaddress


--delete unused columns

alter table nashville_housing
drop column owneraddress, taxdistrict,propertyaddress, saledate

select * from nashville_housing

