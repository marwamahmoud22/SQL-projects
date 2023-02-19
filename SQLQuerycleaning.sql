select * from Portfolioprojects..Nashville
-- standardize Date format
select SaleDate,convert (Date,SaleDate) as convertedDate from Portfolioprojects..Nashville
alter table Nashville add SaleDateconv Date;
Update Portfolioprojects..Nashville set SaleDateconv = convert(Date,SaleDate)
select SaleDateconv from Nashville
alter table Nashville drop column SaleDate
-- populate Property address Data Since that same id has the same address
select propertyAddress from nashville 
--join table to itself
select a.parcelID ,a.PropertyAddress , b.ParcelID,b.PropertyAddress from 
nashville a join nashville b on a.ParcelID= b.parcelID
and a.UniqueID<> b.UniqueID

update a 
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from 
nashville a join nashville b on a.ParcelID= b.parcelID
and a.[UniqueID]<> b.[UniqueID]
where a.PropertyAddress is null

select PropertyAddress from Portfolioprojects..Nashville

--split propertyadress 
select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as Address 
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))as Address from Nashville

alter table Nashville add Address nvarchar(255);
alter table Nashville add City nvarchar(255);
Update Portfolioprojects..Nashville set Address =  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
Update Portfolioprojects..Nashville set City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
alter table Portfolioprojects..Nashville drop column PropertyAddress

--split ownerAddress with another method
select OwnerAddress from Portfolioprojects..Nashville
select
parsename (replace(OwnerAddress,',','.'),1),
parsename (replace(OwnerAddress,',','.'),2),
parsename (replace(OwnerAddress,',','.'),3)
from Portfolioprojects..Nashville 
alter table Portfolioprojects..Nashville add owner_address nvarchar(255)
alter table Portfolioprojects..Nashville add ownerCity nvarchar(255)
alter table Portfolioprojects..Nashville add ownerState nvarchar(255)
update Portfolioprojects..Nashville  set owner_address = parsename (replace(OwnerAddress,',','.'),3) 
update Portfolioprojects..Nashville  set ownerCity= parsename (replace(OwnerAddress,',','.'),2)
update Portfolioprojects..Nashville  set ownerState = parsename (replace(OwnerAddress,',','.'),1) 
select * from Portfolioprojects..Nashville
alter table Portfolioprojects..Nashville drop column OwnerAddress 
--change Y,N in SoldAsVacant to Yes,No
select SoldAsVacant ,case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
end
from Portfolioprojects..Nashville
update Portfolioprojects..Nashville set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
end

--remove Duplicates


WITH dupc AS(
 select*, ROW_NUMBER() over (partition by ParcelID,Address,City,SalePrice,SaleDateconv,LegalReference order by UniqueID)row_num 
from Portfolioprojects..Nashville)
delete from dupc where row_num>1

--remove unused columns 
alter table  Portfolioprojects..Nashville drop column TaxDistrict





