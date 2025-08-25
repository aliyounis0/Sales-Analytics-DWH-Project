--Territory 

SELECT
	TerritoryID AS territory_id,
	Name AS territory_name,
	CountryRegionCode AS country_code
FROM [AdventureWorks2017].Sales.SalesTerritory

SELECT
	[country_id],
	[counttry_name] AS territory_country,
	[country_code],
	[country_region] AS territory_group
FROM [AdventureWorks2017].[Sales].[lookup_country]

select * from [dbo].[dim_territory]
truncate table [dbo].[dim_territory]
---------------------------------------------------------------------
--Customer

select [CustomerID],[PersonID]
from [AdventureWorks2017].[Sales].[Customer]
where [PersonID] is not null

select c.[PersonID],
 CAST( 
		( ISNULL(p.FirstName, '') +' ' + ISNULL(p.MiddleName, '') +' '+ ISNULL(p.LAStName, '') ) 
	AS NVARCHAR(150)) AS customer_name,
 [AddressLine1],
 [AddressLine2],
 [City],
 pp.[PhoneNumber]
from [AdventureWorks2017].[Sales].[Customer] c 
left Join [AdventureWorks2017].[Person].[Person] p 
on c.PersonID=p.BusinessEntityID
inner  join [AdventureWorks2017].[Person].[BusinessEntity] be
on p.BusinessEntityID=be.BusinessEntityID
inner  join [AdventureWorks2017].[Person].[BusinessEntityAddress] bea
on be.BusinessEntityID=bea.BusinessEntityID
inner  join [AdventureWorks2017].[Person].[Address] ba
on bea.AddressID=ba.AddressID
inner  join [AdventureWorks2017].[Person].[PersonPhone] pp
on p.BusinessEntityID=pp.BusinessEntityID
union all
select null,null,null,null,null,null

select * from [dbo].[dim_customer]
truncate table [dbo].[dim_customer]
---------------------------------------------
--Product 

SELECT
[ProductID],
[Name] AS Product_Name,
[Color],
[ReorderPoint],
[StandardCost],
[ProductSubcategoryID],
[ProductModelID]
FROM [AdventureWorks2017].[Production].[Product];

SELECT
p.[ProductSubcategoryID],
psc.[Name] as Product_SubCategory,
pc.[Name] as Product_Category
FROM [AdventureWorks2017].[Production].[Product] p LEFT JOIN [AdventureWorks2017].[Production].[ProductSubcategory] psc
ON p.[ProductSubcategoryID]=psc.[ProductSubcategoryID] LEFT JOIN  [AdventureWorks2017].[Production].[ProductCategory] pc
ON psc.[ProductCategoryID]=pc.[ProductCategoryID]
union all 
select null,null,null

SELECT 
  p.[ProductModelID],
  pm.[Name] as Model_Name,
  pd.Description as Product_Description
FROM [AdventureWorks2017].[Production].[Product] p LEFT JOIN [AdventureWorks2017].[Production].[ProductModel] pm
on p.[ProductModelID]=pm.[ProductModelID] LEFT JOIN [AdventureWorks2017].[Production].[ProductModelProductDescriptionCulture] pmdc 
on pm.[ProductModelID]=pmdc.[ProductModelID] LEFT JOIN [AdventureWorks2017].[Production].[ProductDescription] pd
on pmdc.[ProductDescriptionID]=pd.[ProductDescriptionID]
union all 
select null,null,null

select * from [dbo].[dim_product]
truncate table [dbo].[dim_product]

---------------------------------------------------------------------------
--Fact Sales

--Full Load

select [SalesOrderID],[SalesOrderNumber],[CustomerID],[TerritoryID],CONVERT(DATE ,[OrderDate] )AS [OrderDate],[SubTotal],[TaxAmt],[Freight],[TotalDue]
from [AdventureWorks2017].[Sales].[SalesOrderHeader]
where [OnlineOrderFlag]=1

select [SalesOrderID],[SalesOrderDetailID],[OrderQty],[UnitPrice],[ProductID],[UnitPriceDiscount],[LineTotal]
from [AdventureWorks2017].[Sales].[SalesOrderDetail]

select [product_key],[product_id],[standard_cost]
from [dbo].[dim_product]
where is_current=1

select [customer_key],[customer_id]
from [dbo].[dim_customer]
where is_current=1

select [territory_key],[territory_id]
from [dbo].[dim_territory]
where is_current=1

select [date_key],[date]
from [dbo].[dim_date]

truncate table [fact_sales]

select * from [dbo].[fact_sales]
---------------------
--Incremental Load

select [SalesOrderID],[SalesOrderNumber],[CustomerID],[TerritoryID],CAST([OrderDate] AS DATE) AS [OrderDate],[SubTotal],[TaxAmt],[Freight],[TotalDue]
from [AdventureWorks2017].[Sales].[SalesOrderHeader]
where [OnlineOrderFlag]=1 and [ModifiedDate] >= ? --last load date
and [ModifiedDate] < ?  --start time package

select d.[SalesOrderID],[SalesOrderDetailID],[OrderQty],[UnitPrice],[ProductID],[UnitPriceDiscount],[LineTotal]
from [AdventureWorks2017].[Sales].[SalesOrderDetail] d inner join [AdventureWorks2017].[Sales].[SalesOrderHeader] h
on d.SalesOrderID=h.SalesOrderID
where [OnlineOrderFlag]=1 and h.[ModifiedDate] >= ? --last load date
and h.[ModifiedDate] < ?  --start time package

select max(last_load_date)
from meta_control_table
where source_table='sales order header';

Update meta_control_table
set last_load_date=?
where  source_table='sales order header';

---------------
set identity_insert [AdventureWorks2017].[Sales].[SalesOrderHeader] on 

insert into [AdventureWorks2017].[Sales].[SalesOrderHeader]    -- one row inserted in [SalesOrderHeader] in 1:33 
([SalesOrderID],[OrderDate],[DueDate],[ShipDate],[CustomerID],[BillToAddressID],ShipToAddressID,[ShipMethodID])
values
(11,'20190918','20190918','20190918',11019,921,921,5),
(21,'20190918','20190918','20190918',11019,921,921,5),
(31,'20190918','20190918','20190918',11019,921,921,5),
(41,'20190918','20190918','20190918',11019,921,921,5),
(51,'20190918','20190918','20190918',11019,921,921,5)
set identity_insert [AdventureWorks2017].[Sales].[SalesOrderHeader] off

set identity_insert [AdventureWorks2017].[Sales].[SalesOrderDetail] on 

insert into [AdventureWorks2017].[Sales].[SalesOrderDetail]    -- one row inserted in [[SalesOrderDetail]] in 1:45
([SalesOrderID],[SalesOrderDetailID],[ProductID],[OrderQty],[UnitPrice],[SpecialOfferID])
values
(11,1,771,1,1,1),
(21,1,771,1,1,1),
(31,1,771,1,1,1),
(41,1,771,1,1,1),
(51,1,771,1,1,1)

set identity_insert [AdventureWorks2017].[Sales].[SalesOrderDetail] off

-----------------

truncate table fact_sales
truncate table [dbo].[dim_customer]
truncate table [dbo].[dim_date]
truncate table [dbo].[dim_product]
truncate table [dbo].[dim_territory]

update [dbo].[meta_control_table]
set [last_load_date]='1900-01-01'
----------------------

select * from fact_sales

select * from [dim_date]
select * from [dim_customer]
select * from [dim_territory]
select * from [dim_product]



