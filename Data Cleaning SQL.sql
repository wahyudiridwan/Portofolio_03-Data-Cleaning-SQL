/* DATA CLEANING WITH SQL */


-- The dataset used can be downloaded at the following link
-- https://drive.google.com/drive/folders/171EHXvnKDYFAQIg2Ihdx2bAueF97-Jum?usp=sharing


select * from nashville_housing;


-- Change structure column to date model
    -- First try 
select SaleDate, Cast(SaleDate, date) 
from nashville_housing;
                                            
update nashville_housing
set  SaleDate = Cast(SaleDate, date);

    -- Second try
alter table nashville_housing
add sale_date_converted date;

update nashville_housing
set sale_date_converted = cast(SaleDate, date);

select sale_date_converted, Cast(SaleDate, date) 
from nashville_housing;
                        




-- Fill in empty PropertyAddress data
select *
from nashville_housing
where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from nashville_housing as a
join nashville_housing as b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update nashville_housing as a
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from nashville_housing as a
join nashville_housing as b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;






-- Breaking Out Address 
        -- Breaking Out PropertyAddress

select PropertyAddress
from nashville_housing;

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
    substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1), len(PropertyAddress) as City

from nashville_housing;

                                -- OR use 

select substring(PropertyAddress, 1,18) as Address,
    substring(PropertyAddress,20,33) as City

from nashville_housing;


alter table nashville_housing
add column split_property_address varchar(255);

update nashville_housing
set split_property_address = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


alter table nashville_housing
add column split_property_city varchar(255);

update nashville_housing
set split_property_city = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1), len(PropertyAddress);


select * from nashville_housing;



        --Breaking Out OwnerAddress

select OwnerAddress
from nashville_housing;

select parsename(replace(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)

from nashville_housing;


alter table nashville_housing
add column split_owner_address varchar(255);

update nashville_housing
set split_owner_address = parsename(replace(OwnerAddress, ',', '.'),3);


alter table nashville_housing
add column split_owner_city varchar(255);

update nashville_housing
set split_owner_city = parsename(replace(OwnerAddress, ',', '.'),2);


alter table nashville_housing
add column split_owner_state varchar(255);

update nashville_housing
set split_owner_state = parsename(replace(OwnerAddress, ',', '.'),1);


select * from nashville_housing;






-- Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column

select distinct SoldAsVacant, count(SoldAsVacant)
from nashville_housing
group by SoldAsVacant
order by count(SoldAsVacant);


select SoldAsVacant,
        case 
            when SoldAsVacant = 'Y' then 'Yes'
            when SoldAsVacant = 'N' then 'No'
            else SoldAsVacant
        end 
from nashville_housing;


update nashville_housing
set SoldAsVacant = case 
            when SoldAsVacant = 'Y' then 'Yes'
            when SoldAsVacant = 'N' then 'No'
            else SoldAsVacant
        end ;

select distinct SoldAsVacant
from nashville_housing;






-- Remove Duplicates
select * from nashville_housing;

with CTE_row_num as (select *,
        row_number() over(partition by ParcelID,
                                    PropertyAddress,
                                    SaleDate,
                                    SalePrice,
                                    LegalReference
                                    order by UniqueID
                        ) as row_num

from nashville_housing)

delete 
--select * 
from CTE_row_num
where row_num > 1;






-- Delete Unused column

select * from nashville_housing;

alter table nashville_housing
drop column OwnerAddress;

alter table nashville_housing
drop column TaxDistrict;

alter table nashville_housing
drop column PropertyAddress;

alter table nashville_housing
drop column SaleDate;