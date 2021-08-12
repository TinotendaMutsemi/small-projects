/*

cleaning housing data

*/

select *
from covid_deaths_vac..housing
--------------------------------------------------------------------------------------------------------------------------------

 -- standardize date

select SaleDateConverted, convert(Date, SaleDate)
from covid_deaths_vac..housing

Update covid_deaths_vac..housing
set SaleDate = convert(Date, SaleDate)
-- sql refuses to update, lets try adding a new column instead

Alter Table housing
ADD SaleDateConverted Date

Update covid_deaths_vac..housing
set SaleDateConverted = convert(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------

--property address

select *
from covid_deaths_vac..housing
order by PacelID

select *
from covid_deaths_vac..housing
where PropertyAddress is Null

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from covid_deaths_vac..housing a
join covid_deaths_vac..housing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from covid_deaths_vac..housing a
join covid_deaths_vac..housing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------

-- separating city from the property address

select PropertyAddress
from covid_deaths_vac..housing
--order by PacelID


select 
substring (PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring (PropertyAddress, charindex(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
from covid_deaths_vac..housing


Alter Table covid_deaths_vac..housing
ADD PropertyAddressSplit nvarchar(255)

Update covid_deaths_vac..housing
set PropertyAddressSplit = substring (PropertyAddress, 1, charindex(',', PropertyAddress)-1)


Alter Table covid_deaths_vac..housing
ADD PropertyCitySplit nvarchar(255)

Update covid_deaths_vac..housing
set PropertyCitySplit = substring (PropertyAddress, charindex(',', PropertyAddress) + 2, LEN(PropertyAddress))


select *
from covid_deaths_vac..housing



--spliting owner address

select OwnerAddress
from covid_deaths_vac..housing

select
parsename(replace(OwnerAddress,',', '.'), 3),
parsename(replace(OwnerAddress,',', '.'), 2),
parsename(replace(OwnerAddress,',', '.'), 1)
from covid_deaths_vac..housing



Alter Table covid_deaths_vac..housing
ADD OwnerAddressSplit nvarchar(255)

Update covid_deaths_vac..housing
set OwnerAddressSplit = parsename(replace(OwnerAddress,',', '.'), 3)

Alter Table covid_deaths_vac..housing
ADD OwnerCitySplit nvarchar(255)

Update covid_deaths_vac..housing
set OwnerCitySplit = parsename(replace(OwnerAddress,',', '.'), 2)

Alter Table covid_deaths_vac..housing
ADD OwnerStateSplit nvarchar(255)

Update covid_deaths_vac..housing
set OwnerStateSplit = parsename(replace(OwnerAddress,',', '.'), 1)

select *
from covid_deaths_vac..housing


------------------------------------------------------------------------------------------------------------------------
--Sold as vacant change all values to Y and N

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from covid_deaths_vac..housing
group by SoldAsVacant
order by 2


select Substring(SoldAsVacant, 1, 1)
from covid_deaths_vac..housing


Alter Table covid_deaths_vac..housing
add SoldAsVacantChar char

Update covid_deaths_vac..housing
set SoldAsVacantChar = Convert(char,Substring(SoldAsVacant, 1, 1))

select *
from covid_deaths_vac..housing

--using a case statement to update the Sold as vaccant column

select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 END
from covid_deaths_vac..housing

update covid_deaths_vac..housing
set SoldAsVacant =  Case when SoldAsVacant = 'Y' Then 'Yes'
					 when SoldAsVacant = 'N' Then 'No'
					 else SoldAsVacant
					 END

 ----------------------------------------------------------------------------------------------------------------

 --removing duplicates

with row_numCTE AS(
select *,
row_number() over (
			partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by UniqueID
			) as row_num
from covid_deaths_vac..housing
--order by ParcelID
)
delete --check using select to see if all duplicates are deleted.
from row_numCTE
where row_num > 1
 

 ---------------------------------------------------------------------------------------------------------------

 --deleting unused coloumns

 
select *
from covid_deaths_vac..housing

Alter table covid_deaths_vac..housing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

