-- Create DWH

CREATE DATABASE Sales_DWH
go 

USE Sales_DWH

----------------------------------------------------------------------------------
-- Dim Product

CREATE TABLE dim_product
  (
     product_key         INT NOT NULL IDENTITY(1, 1), -- SK 
     product_id          INT NOT NULL,                --BK
     product_name        NVARCHAR(50),
     Product_description NVARCHAR(400),
     product_subcategory NVARCHAR(50),
     product_category    NVARCHAR(50),
     color               NVARCHAR(15),
     model_name          NVARCHAR(50),
     reorder_point       SMALLINT,
     standard_cost       MONEY,
     source_system_code  TINYINT NOT NULL,
     start_date          DATETIME NOT NULL DEFAULT (Getdate()),
     end_date            DATETIME,
     is_current          TINYINT NOT NULL DEFAULT (1),
     CONSTRAINT pk_dim_product PRIMARY KEY CLUSTERED (product_key)
  );


  -- Insert unknown record
SET IDENTITY_INSERT dim_product ON

INSERT INTO dim_product
            (product_key,product_id,product_name,Product_description,product_subcategory,product_category,
             color,model_name,reorder_point,standard_cost,source_system_code,start_date,end_date,is_current)
VALUES(0, 0, 'Unknown', 'Unknown','Unknown','Unknown','Unknown','Unknown',0,0,0,'1900-01-01',NULL,1)

SET IDENTITY_INSERT dim_product OFF

--Indexes

CREATE INDEX dim_product_product_id
ON dim_product(product_id);

CREATE INDEX dim_prodct_product_category
ON dim_product(product_category); 
-------------------------------------------------------------------
--Dim Customer

CREATE TABLE dim_customer
  (
     customer_key       INT NOT NULL IDENTITY(1, 1),
     customer_id        INT NOT NULL,
     customer_name      NVARCHAR(150),
     address1           NVARCHAR(100),
     address2           NVARCHAR(100),
     city               NVARCHAR(30),
     phone              NVARCHAR(25),
     source_system_code TINYINT NOT NULL,
     start_date         DATETIME NOT NULL DEFAULT (Getdate()),
     end_date           DATETIME NULL,
     is_current         TINYINT NOT NULL DEFAULT (1),
     CONSTRAINT pk_dim_customer PRIMARY KEY CLUSTERED (customer_key)
  );


  -- Insert unknown record
SET IDENTITY_INSERT dim_customer ON

INSERT INTO dim_customer
            (customer_key,customer_id,customer_name,address1,address2,city,phone,source_system_code,start_date,end_date,is_current)
VALUES(0,0,'Unknown','Unknown','Unknown','Unknown','Unknown',0,'1900-01-01',NULL,1 )

SET IDENTITY_INSERT dim_customer OFF

--Indexes

CREATE INDEX dim_customer_customer_id
ON dim_customer(customer_id);

CREATE INDEX dim_customer_city
ON dim_customer(city); 

---------------------------------------------------------------------------------------------------------------
--Dim Territory

CREATE TABLE dim_territory
  (
     territory_key      INT NOT NULL IDENTITY(1, 1),
     territory_id       INT NOT NULL,
     territory_name     NVARCHAR(50),
     territory_country  NVARCHAR(400),
     territory_group    NVARCHAR(50),
     source_system_code TINYINT NOT NULL,
     start_date         DATETIME NOT NULL DEFAULT (Getdate()),
     end_date           DATETIME,
     is_current         TINYINT NOT NULL DEFAULT (1),
     CONSTRAINT pk_dim_territory PRIMARY KEY CLUSTERED (territory_key)
  );

  -- Insert unknown record
SET IDENTITY_INSERT dim_territory ON

INSERT INTO dim_territory
            (territory_key,territory_id,territory_name,territory_country,territory_group,source_system_code,start_date,end_date,is_current)
VALUES(0,0,'Unknown','Unknown','Unknown',0,'1900-01-01',NULL,1)

SET IDENTITY_INSERT dim_territory OFF

--Indexes
CREATE INDEX dim_territory_territory_id
ON dim_territory(territory_id); 

-------------------------------------------------------------------------------------------------------------------
--Dim Date

CREATE TABLE dim_date(
  date_key INT PRIMARY KEY,
  date date,
  year INT,
  month INT,
  month_name NVARCHAR(15),
  day INT,
  day_name NVARCHAR(15),
  day_of_week INT,
  week INT,
  quarter INT,
  is_weekend TINYINT
);
----

DECLARE @StartDate DATE ,@EndDate DATE ;

SELECT
    @StartDate = MIN([OrderDate]),
    @EndDate = MAX([OrderDate])
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader];

WITH DateSequence AS (
    SELECT @StartDate AS [date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [date])
    FROM DateSequence
    WHERE [date] < @EndDate
)
INSERT INTO dim_date
SELECT
    CAST(FORMAT([date], 'yyyyMMdd') AS INT) AS date_key,
    [date],
    DATEPART(YEAR, [date]) AS year,
    DATEPART(MONTH, [date]) AS month,
    DATENAME(MONTH, [date]) AS month_name,
    DATEPART(DAY, [date]) AS day,
    DATENAME(WEEKDAY, [date]) AS day_name,
    DATEPART(WEEKDAY, [date]) AS day_of_week,
    DATEPART(WEEK, [date]) AS week,
    DATEPART(QUARTER, [date]) AS quarter,
    CASE
        WHEN DATEPART(WEEKDAY, [date]) IN (1, 7) THEN 1 ELSE 0
    END AS is_weekend

FROM DateSequence
OPTION (MAXRECURSION 10000);


select * from dim_date

---------------------------------------------------------------------------
--Fact Sales
CREATE TABLE fact_sales
  (
     ID  INT PRIMARY KEY IDENTITY(1,1),  --SK
	 [SalesOrderDetailID] INT ,  
	 [SalesOrderID] INT  ,        
     product_key    INT NOT NULL,
     customer_key   INT NOT NULL,
     territory_key  INT NOT NULL,
     order_date_key INT NOT NULL,
     quantity       INT,
     unit_price     MONEY,
     unit_cost      MONEY,
     tax_amount     MONEY,
     freight        MONEY,
     extended_sales MONEY,
     extened_cost   MONEY,
     created_at     DATETIME NOT NULL DEFAULT(Getdate()),

     CONSTRAINT fk_fact_sales_dim_product FOREIGN KEY (product_key) 
	 REFERENCES dim_product(product_key),

     CONSTRAINT fk_fact_sales_dim_customer FOREIGN KEY (customer_key) 
	 REFERENCES dim_customer(customer_key),

     CONSTRAINT fk_fact_sales_dim_territory FOREIGN KEY (territory_key)
     REFERENCES dim_territory(territory_key),

     --CONSTRAINT fk_fact_sales_dim_date FOREIGN KEY (order_date_key)
	 --REFERENCES dim_date(date_key)
  );

ALTER TABLE fact_sales
ADD  CONSTRAINT fk_fact_sales_dim_product FOREIGN KEY (product_key) 
	 REFERENCES dim_product(product_key)

ALTER TABLE fact_sales
ADD  CONSTRAINT fk_fact_sales_dim_customer FOREIGN KEY (customer_key) 
	 REFERENCES dim_customer(customer_key)

ALTER TABLE fact_sales
ADD  CONSTRAINT fk_fact_sales_dim_territory FOREIGN KEY (territory_key)
     REFERENCES dim_territory(territory_key)

ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_sales_dim_date FOREIGN KEY (order_date_key)
	REFERENCES dim_date(date_key)

-- Indexes

CREATE INDEX fact_sales_dim_product
ON fact_sales(product_key);

CREATE INDEX fact_sales_dim_customer
ON fact_sales(customer_key);

CREATE INDEX fact_sales_dim_territory
ON fact_sales(territory_key);

CREATE INDEX fact_sales_dim_date
ON fact_sales(order_date_key); 


  -----------------------------------------------------------------------------------
--meta_control_table
CREATE TABLE meta_control_table(
id int identity(1,1),
source_table nvarchar(50) not null,
last_load_date datetime
);

insert into meta_control_table
values('sales order header','1990-01-01')

------------------------------------------------------------
--lookup country

CREATE TABLE [AdventureWorks2017].Sales.lookup_country 
  ( 
     country_id     INT NOT NULL IDENTITY(1, 1), 
     counttry_name  NVARCHAR(50) NOT NULL, 
     country_code   NVARCHAR(2) NOT NULL, 
     country_region NVARCHAR(50) 
  ); 

INSERT INTO [AdventureWorks2017].Sales.lookup_country 
            (counttry_name, country_code, country_region) 
VALUES
('United States', 'US', 'North America'), 
('Canada', 'CA', 'North America'), 
('France', 'FR', 'Europe'), 
('Germany', 'DE', 'Europe'), 
('Australia', 'AU', 'Pacific'), 
('United Kingdom', 'GB', 'Europe'); 

------------------------------------------------------------------------------