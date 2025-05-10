/***************************INSTRUCTION***************************************/
-- Create a new connection name "Assignment45" and run below scrip in this connection
-- Assume that wwidbuser is already set up
-- Drop tables and sequences if exists

/* REQUIREMENT 1 - Dimensional Model tables */
----------------------- CREATE FINAL DIM FACT TABLES --------------------------

CREATE TABLE DimCustomers(   -- Type 2 SCD
	CustomerKey 		NUMBER(10),
	CustomerName 		NVARCHAR2(100) NULL,
	CustomerCategoryName NVARCHAR2(50) NULL,
	DeliveryCityName 	NVARCHAR2(50) NULL,
	DeliveryStateProvCode NVARCHAR2(5) NULL,
	DeliveryCountryName NVARCHAR2(50) NULL,
	PostalCityName 		NVARCHAR2(50) NULL,
	PostalStateProvCode NVARCHAR2(5) NULL,
	PostalCountryName 	NVARCHAR2(50) NULL,
	StartDate 			DATE NOT NULL,
	EndDate 			DATE NULL,
    CONSTRAINT PK_DimCustomers PRIMARY KEY ( CustomerKey )
);

CREATE TABLE DimCities(  -- Type 1 SCD
	CityKey 	    NUMBER(10),
	CityName 		NVARCHAR2(50) NULL,
	StateProvCode 	NVARCHAR2(5) NULL,
	StateProvName 	NVARCHAR2(50) NULL,
	CountryName 	NVARCHAR2(60) NULL,
	CountryFormalName NVARCHAR2(60) NULL,
    CONSTRAINT PK_DimCities PRIMARY KEY ( CityKey )
);

CREATE TABLE DimProducts(   -- Type 2 SCD
	ProductKey 		NUMBER(10),
	ProductName 	NVARCHAR2(100) NOT NULL,
	ProductColour 	NVARCHAR2(20) NULL,
	ProductBrand 	NVARCHAR2(50) NULL,
	ProductSize 	NVARCHAR2(20) NULL,
	StartDate 		DATE NOT NULL,
	EndDate 		DATE NULL,
    CONSTRAINT PK_DimProducts PRIMARY KEY ( ProductKey )
);

CREATE TABLE DimSalesPeople(    -- Type 1 SCD
	SalespersonKey 	NUMBER(10),
	FullName 		NVARCHAR2(50) NULL,
	PreferredName 	NVARCHAR2(50) NULL,
	LogonName 		NVARCHAR2(50) NULL,
	PhoneNumber 	NVARCHAR2(20) NULL,
	FaxNumber 		NVARCHAR2(20) NULL,
	EmailAddress 	NVARCHAR2(256) NULL,
    CONSTRAINT PK_DimSalesPeople PRIMARY KEY (SalespersonKey )
);

CREATE TABLE DimSuppliers (     -- Type 2 SCD
    SupplierKey             NUMBER(10),
    FullName                NVARCHAR2(255) NOT NULL,
    PhoneNumber             NVARCHAR2(50),
    FaxNumber               NVARCHAR2(50),
    WebsiteURL              NVARCHAR2(256),
    SupplierCategoryName    NVARCHAR2(50),
    StartDate 	            DATE NOT NULL,
	EndDate 	            DATE NULL,
    CONSTRAINT PK_DimSuppliers PRIMARY KEY (SupplierKey)
);

CREATE TABLE DimDate (
    DateKey    	    NUMBER(10) NOT NULL,
    DateValue  	    DATE NOT NULL,
    CYear 	        NUMBER(10) NOT NULL,
    CQtr 	        NUMBER(1) NOT NULL,
    CMonth 	        NUMBER(2) NOT NULL,
    DayNo 	        NUMBER(2) NOT NULL,
    StartOfMonth    DATE NOT NULL,
    EndOfMonth  	DATE NOT NULL,
    MonthName   	VARCHAR2(9) NOT NULL,
    DayOfWeekName   VARCHAR2(9) NOT NULL,    

    CONSTRAINT PK_DimDate PRIMARY KEY ( DateKey )
);

CREATE TABLE FactSales (
    CustomerKey      	NUMBER(10) NOT NULL,
    CityKey      	    NUMBER(10) NOT NULL,
    ProductKey       	NUMBER(10) NOT NULL,
    SalespersonKey   	NUMBER(10) NOT NULL,
    SupplierKey         NUMBER(10) NOT NULL,
    DateKey 	      	NUMBER(8) NOT NULL,
    Quantity 	      	NUMBER(4) NOT NULL,
    UnitPrice        	NUMBER(18,2) NOT NULL,
    TaxRate 	      	NUMBER(18,3) NOT NULL,
    TotalBeforeTax   	NUMBER(18,2) NOT NULL,
    TotalAfterTax    	NUMBER(18,2) NOT NULL,
    CONSTRAINT FK_FatcSales_DimCustomers    FOREIGN KEY (CustomerKey)       REFERENCES DimCustomers(CustomerKey),
    CONSTRAINT FK_FatcSales_DimCities       FOREIGN KEY (CityKey)           REFERENCES DimCities(CityKey),
    CONSTRAINT FK_FatcSales_DimProducts     FOREIGN KEY (ProductKey)        REFERENCES DimProducts(ProductKey),
    CONSTRAINT FK_FatcSales_DimSalesPeople  FOREIGN KEY (SalespersonKey)    REFERENCES DimSalesPeople(SalespersonKey),
    CONSTRAINT FK_FatcSales_DimSuppliers    FOREIGN KEY (SupplierKey)       REFERENCES DimSuppliers(SupplierKey),
    CONSTRAINT FK_FatcSales_DimDate         FOREIGN KEY (DateKey)           REFERENCES DimDate(DateKey)    
);

CREATE INDEX IX_FactSales_CustomerKey 	    ON FactSales(CustomerKey);
CREATE INDEX IX_FactSales_CityKey 	        ON FactSales(CityKey);
CREATE INDEX IX_FactSales_ProductKey 	    ON FactSales(ProductKey);
CREATE INDEX IX_FactSales_SalespersonKey    ON FactSales(SalespersonKey);
CREATE INDEX IX_FactSales_SupplierKey       ON FactSales(SupplierKey);
CREATE INDEX IX_FactSales_DateKey 	        ON FactSales(DateKey);

/* REQUIREMENT 2 - Date dimension & Stored Procedure to load it (3 Marks) */
-- 1. Create Stored Procedure to load DimDate (5 years)
CREATE OR REPLACE PROCEDURE DimDate_Load ( DateValue IN DATE )
IS
    v_current_date DATE := DateValue;  -- Start date
    v_end_date DATE := ADD_MONTHS(DateValue, 70);  -- End date (3 years later)
BEGIN
    WHILE v_current_date < v_end_date LOOP
        INSERT INTO DimDate
        SELECT  
            EXTRACT(YEAR FROM v_current_date) * 10000 + EXTRACT(MONTH FROM v_current_date) * 100 + EXTRACT(DAY FROM v_current_date) AS DateKey,
            v_current_date AS DateValue,
            EXTRACT(YEAR FROM v_current_date) AS CYear,
            CAST(TO_CHAR(v_current_date, 'Q') AS INT) AS CQtr,
            EXTRACT(MONTH FROM v_current_date) AS CMonth,
            EXTRACT(DAY FROM v_current_date) AS "Day",
            TRUNC(v_current_date) - (TO_NUMBER(TO_CHAR(v_current_date, 'DD')) - 1) AS StartOfMonth,
            ADD_MONTHS(TRUNC(v_current_date) - (TO_NUMBER(TO_CHAR(v_current_date, 'DD')) - 1), 1) -1 AS EndOfMonth,
            TO_CHAR(v_current_date, 'MONTH') AS MonthName,
            TO_CHAR(v_current_date, 'DY') AS DayOfWeekName
        FROM dual;

        -- Move to the next day
        v_current_date := v_current_date + 1;
    END LOOP;

    -- Commit the transaction
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
END DimDate_Load;
/
-- 2. Run load procedure
EXEC DimDate_Load('2012-01-01');

/* REQUIREMENT 3 - Create Compelling Warehouse Query (2 Marks) */
-- Query to identify supplier performance patterns and predict future sales trends
-- This analysis helps identify which supplier-product-salesperson combinations generate the highest revenue
-- and how these patterns vary by customer, city, and time period
WITH AggregatedData AS (
    SELECT 
        dc.FullName AS SalesPerson,
        dp.ProductName,
        ds.FullName AS SupplierName,
        dd.CYear,
        dd.MonthName,
        SUM(fs.TotalAfterTax) AS TotalRevenue
    FROM 
        FactSales fs
        INNER JOIN DimSalesPeople dc ON fs.SalespersonKey = dc.SalespersonKey
        INNER JOIN DimProducts dp ON fs.ProductKey = dp.ProductKey
        INNER JOIN DimSuppliers ds ON fs.SupplierKey = ds.SupplierKey
        INNER JOIN DimDate dd ON fs.DateKey = dd.DateKey
    GROUP BY 
        dc.FullName, dp.ProductName, ds.FullName, dd.CYear, dd.MonthName
),
GrowthRateData AS (
    SELECT 
        AggregatedData.*,
        LAG(TotalRevenue) OVER 
            (PARTITION BY SalesPerson, ProductName, SupplierName 
             ORDER BY CYear, MonthName) AS PreviousRevenue
    FROM AggregatedData
)
SELECT 
    SalesPerson,
    Productname,
    SupplierName,
    CYear,
    MonthName,
    TotalRevenue,
    PreviousRevenue,
    (TotalRevenue - PreviousRevenue) / NULLIF(PreviousRevenue, 0) * 100 AS MonthlyGrowthRate
FROM GrowthRateData
ORDER BY MonthlyGrowthRate DESC;