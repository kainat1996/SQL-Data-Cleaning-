SELECT * 
FROM
cleaningProject.dbo.Sheet1$


--STANDARDIZED THE DATE FORMAT
SELECT SaleDateConverted,CONVERT(date,SaleDate) 
FROM
cleaningProject.dbo.Sheet1$

update cleaningProject.dbo.Sheet1$
SET SaleDateConverted= CONVERT(DATE,SaleDate)

ALTER TABLE cleaningProject.dbo.Sheet1$
ADD SaleDateCOnverted Date;


----------------------------------------------------------------------------

--Populate Property address

SELECT *
FROM
cleaningProject.dbo.Sheet1$
where Propertyaddress is null;

-- we have checked that the ParcelID have same address so we are going to populate the PROPERTY address by joinig 


SELECT a.PropertyAddress, b.PropertyAddress, a.ParcelID, b.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
cleaningProject.dbo.Sheet1$ a
join cleaningProject.dbo.Sheet1$ b 
ON a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- now we have found the address and going to update the table with adress that has null address

update a
set PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
cleaningProject.dbo.Sheet1$ a
join cleaningProject.dbo.Sheet1$ b 
on a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-----------------------------------------------------------------------------------------------
-- Breaking out address into Parts

SELECT PropertyAddress
FROM
cleaningProject.dbo.Sheet1$

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address

,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from cleaningProject.dbo.Sheet1$

-- WE Have split the address into two separate columns now will update the table with these splited columns

alter table cleaningProject.dbo.Sheet1$
add PropertyAddresssplitted nvarchar(255);

update cleaningProject.dbo.Sheet1$
set PropertyAddresssplitted= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) ;

alter table cleaningProject.dbo.Sheet1$
add Propertysplittedcity nvarchar(255);

update cleaningProject.dbo.Sheet1$
set Propertysplittedcity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) ;



--------------------------------------------------------------------------------------------------------------

-- split owner address 

SELECT OwnerAddress
FROM
cleaningProject.dbo.Sheet1$

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from
cleaningProject.dbo.Sheet1$

alter table cleaningProject.dbo.Sheet1$
add Ownersplittedaddress nvarchar(255);

update cleaningProject.dbo.Sheet1$
set Ownersplittedaddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3);

alter table cleaningProject.dbo.Sheet1$
add Ownersplittedcity nvarchar(255);

update cleaningProject.dbo.Sheet1$
set Ownersplittedcity= PARSENAME(REPLACE(OwnerAddress,',','.'),2);

alter table cleaningProject.dbo.Sheet1$
add Ownersplittedstate nvarchar(255);

update cleaningProject.dbo.Sheet1$
set Ownersplitedstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1);



------------------------------------------------------------------------------------------------------

-- check soldasvacant
SELECT SoldAsVacant, count(SoldAsVacant)
FROM
cleaningProject.dbo.Sheet1$
group by SoldAsVacant
order by SoldAsVacant;

select SoldAsVacant, CASE when SoldAsVacant = 'Y' then 'Yes'
					   when SoldAsVacant = 'N' then 'No'
					   else SoldAsVacant
					   end
from cleaningProject.dbo.Sheet1$

update cleaningProject.dbo.Sheet1$
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
					    when SoldAsVacant = 'N' then 'No'
					    else SoldAsVacant
					    end

-------------------------------------------------------------------------------------------------

--Remove duplicates


with row_numCTE as(
select *, ROW_NUMBER() over(Partition by ParcelId, PropertyAddress, SaleDate, SalePrice, legalReference order by uniqueID) as row_num
from cleaningProject.dbo.Sheet1$
)
Delete from row_numCTE
where row_num>1

---------------------------------------------------------------------------------------------------------------------

--Delete unused columns

SELECT * FROM cleaningProject.dbo.Sheet1$

ALTER TABLE cleaningProject.dbo.Sheet1$
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict





