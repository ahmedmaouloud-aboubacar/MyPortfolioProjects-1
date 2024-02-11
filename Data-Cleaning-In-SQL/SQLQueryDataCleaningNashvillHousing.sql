-----------------------------------------------------------------
--------------- Cleanining Data in SQL Query---------------------
-----------------------------------------------------------------

SELECT * FROM PortfolioProject..NashvilleHousing$
-----------------------------------------------------------------
-- Stadrdize Data Format
SELECT SaleDate, convert(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing$

/*UPDATE NashvilleHousing$
SET NashvilleHousing$.SaleDate = cast(SaleDate as Date)
*/
ALTER TABLE NashvilleHousing$
ALTER COLUMN SaleDate Date NOT NULL

SELECT SaleDate,SalePrice FROM PortfolioProject..NashvilleHousing$ Order by SalePrice DESC
-----------------------------------------------------------------

--Populate Property Adress data
-- Shows different PropertyAdress for the same ParcelID where one of them is null and populate it 
SELECT NHV.ParcelID, NHV.PropertyAddress,NSHV.ParcelID, NSHV.PropertyAddress, ISNULL(NHV.PropertyAddress,NSHV.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ as NHV
JOIN PortfolioProject..NashvilleHousing$ as NSHV
ON NHV.ParcelID=NSHV.ParcelID AND NHV.[UniqueID ] <> NSHV.[UniqueID ]
WHERE NHV.PropertyAddress IS  NULL 

UPDATE NHV
SET PropertyAddress = ISNULL(NHV.PropertyAddress,NSHV.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ as NHV
JOIN PortfolioProject..NashvilleHousing$ as NSHV
ON NHV.ParcelID=NSHV.ParcelID AND NHV.[UniqueID ]<>NSHV.[UniqueID ]
WHERE NHV.PropertyAddress IS  NULL 
-- TEST if This is Working or Not
SELECT SaleDate,PropertyAddress FROM PortfolioProject..NashvilleHousing$ WHERE PropertyAddress IS  NULL

--Breaking out Adress into Induvidual Coulmns (Adress,City,State)
-- First Lets Take a Look At PropertyAddress
SELECT PropertyAddress  FROM NashvilleHousing$
--Lets Now Substring PropertyAddress 
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
	  ,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From NashvilleHousing$
--Lets Create Two Column In NashvilleHousing$ TO Seprate PropertyAddress In it
ALTER TABLE NashvilleHousing$ 
ADD  PropertySplitAddress nvarchar(255) ;
UPDATE PortfolioProject..NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);
ALTER TABLE PortfolioProject..NashvilleHousing$
ADD PropertySplitCity nvarchar(255);
UPDATE PortfolioProject..NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing$ 

--Breaking out OWnerAdress into Induvidual Coulmns (Adress,City,State)
-- First Lets Take a Look At PropertyAddress
SELECT OwnerAddress  FROM PortfolioProject..NashvilleHousing$
--Lets Now Parse OwnerAddress TO Seperate it
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),--
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2),--
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)--
FROM PortfolioProject..NashvilleHousing$

--Lets Create Two Column In NashvilleHousing$ TO Seprate PropertyAddress In it
ALTER TABLE PortfolioProject..NashvilleHousing$ 
ADD  OwnerSplitAddress nvarchar(255) ;
UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
---------------------------------
ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitCity nvarchar(255);
UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);
---------------------------------
ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitState nvarchar(255);
UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);
---------------------------------
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity,OwnerSplitState
FROM PortfolioProject..NashvilleHousing$ 

-- Change Y and  N to Yes and NO in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant
	,Case WHEN SoldAsVacant='Y' THEN 'YES'
		 WHEN SoldAsVacant='N' THEN 'NO'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing$
UPDATE PortfolioProject..NashvilleHousing$
SET SoldAsVacant =
	Case WHEN SoldAsVacant='Y' THEN 'YES'
		 WHEN SoldAsVacant='N' THEN 'NO'
		 ELSE SoldAsVacant
	END


--Rmove Duplicate
	--CTE
WITH RowNumCTE AS (
	SELECT *,ROW_NUMBER() OVER (
		PARTITION BY ParcelID,PropertyAddress,SalePrice,LegalReference
		ORDER BY UniqueID
	) row_num
	FROM PortfolioProject..NashvilleHousing$
	--ORDER BY ParcelID 
)
--DELETE FROM RowNumCTE 
--WHERE row_num>1 
SELECT * FROM RowNumCTE 
WHERE row_num>1

--Delete Unused Column (PropertyAddress,OwnerAddress,TaxDistrict and )
SELECT * FROM PortfolioProject..NashvilleHousing$
ALTER TABLE PortfolioProject..NashvilleHousing$
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict