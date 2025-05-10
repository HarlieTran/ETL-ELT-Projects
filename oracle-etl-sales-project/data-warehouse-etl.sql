/***************************INSTRUCTION***************************************/
-- Create a new connection name "Assignment45" and run below scrip in this connection
-- Assume that wwidbuser is already set up
-- Drop tables and sequences if exists

/* REQUIREMENT 4 - Extracts (5 Marks ) */
-- CUSTOMERS – Query that joins Customers, CustomerCategories, Cities, StateProvinces, and Countries.
-- 1. Create staging table
--DROP TABLE Customers_Stage;

CREATE TABLE Customers_Stage (
    CustomerName NVARCHAR2(100),
    CustomerCategoryName NVARCHAR2(50),
    DeliveryCityName NVARCHAR2(50),
    DeliveryStateProvinceCode NVARCHAR2(5),
    DeliveryStateProvinceName NVARCHAR2(50),
    DeliveryCountryName NVARCHAR2(50),
    DeliveryFormalName NVARCHAR2(60),
    PostalCityName NVARCHAR2(50),
    PostalStateProvinceCode NVARCHAR2(5),
    PostalStateProvinceName NVARCHAR2(50),
    PostalCountryName NVARCHAR2(50),
    PostalFormalName NVARCHAR2(60)
);

-- 2. Create extract procedure
CREATE OR REPLACE PROCEDURE Customers_Extract 
IS
    RowCt NUMBER(10):=0;
    v_sql VARCHAR2(255) := 'TRUNCATE TABLE assignment45.Customers_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO ASSIGNMENT45.Customers_Stage
    WITH CityDetails AS (
        SELECT ci.CityID,
               ci.CityName,
               sp.StateProvinceCode,
               sp.StateProvinceName,
               co.CountryName,
               co.FormalName
        FROM wwidbuser.Cities ci
        LEFT JOIN wwidbuser.StateProvinces sp
            ON ci.StateProvinceID = sp.StateProvinceID
        LEFT JOIN wwidbuser.Countries co
            ON sp.CountryID = co.CountryID 
    )
    
    SELECT cust.CustomerName,
           cat.CustomerCategoryName,
           dc.CityName,
           dc.StateProvinceCode,
           dc.StateProvinceName,
           dc.CountryName,
           dc.FormalName,
           pc.CityName,
           pc.StateProvinceCode,
           pc.StateProvinceName,
           pc.CountryName,
           pc.FormalName
    FROM wwidbuser.Customers cust
    LEFT JOIN wwidbuser.CustomerCategories cat
        ON cust.CustomerCategoryID = cat.CustomerCategoryID
    LEFT JOIN wwidbuser.CityDetails dc
        ON cust.DeliveryCityID = dc.CityID
    LEFT JOIN wwidbuser.CityDetails pc
        ON cust.PostalCityID = pc.CityID;

    RowCt := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Number of customers added: ' || TO_CHAR(SQL%ROWCOUNT));
END;
/


-- PRODUCTS – Query that joins StockItems and Colours
-- 1. Create staging table
--DROP TABLE Products_Stage;

CREATE TABLE Products_Stage (
    STOCKITEMNAME NVARCHAR2(100),
    BRAND NVARCHAR2(50),
    ITEMSIZE NVARCHAR2(20),
    COLORNAME NVARCHAR2(20)
);

-- 2. Create extract procedure
CREATE OR REPLACE PROCEDURE Products_Extract 
IS
    RowCt NUMBER(10):=0;
    v_sql VARCHAR2(255) := 'TRUNCATE TABLE assignment45.Products_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO ASSIGNMENT45.Products_Stage
    SELECT si.StockItemName,
            si.Brand,
            si.ItemSize,
            co.ColorName
    FROM wwidbuser.StockItems si
    LEFT JOIN wwidbuser.colors co
        ON si.ColorID = co.ColorID;

    RowCt := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Number of products added: ' || TO_CHAR(RowCt));
END;
/


-- SALESPEOPLE – Query of People where IsSalesperson is 1
-- 1. Create staging table
--DROP TABLE SalesPeople_Stage;

CREATE TABLE SalesPeople_Stage (
    FULLNAME NVARCHAR2(100),
    PREFERREDNAME NVARCHAR2(50),
    LOGONNAME NVARCHAR2(50),
    PHONENUMBER NVARCHAR2(20),
    FAXNUMBER NVARCHAR2(20),
    EMAILADDRESS NVARCHAR2(256)
);

-- 2. Create extract procedure
CREATE OR REPLACE PROCEDURE SalesPeople_Extract 
IS
    RowCt NUMBER(10):=0;
    v_sql VARCHAR2(255) := 'TRUNCATE TABLE assignment45.SalesPeople_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO ASSIGNMENT45.SalesPeople_Stage  
    SELECT fullname,
            preferredname,
            logonname,
            phonenumber,
            faxnumber,
            emailaddress        
    FROM wwidbuser.People
    WHERE issalesperson = 1;

    RowCt := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Number of salespeople added: ' || TO_CHAR(SQL%ROWCOUNT));
END;
/


-- SUPPLIERS – Query that joins Suppliers and SupplierCategories
-- 1. Create staging table
--DROP TABLE Suppliers_Stage;

CREATE TABLE Suppliers_Stage (
    SUPPLIERNAME NVARCHAR2(100),
    PHONENUMBER NVARCHAR2(20),
    FAXNUMBER NVARCHAR2(20),
    WEBSITEURL NVARCHAR2(256),
    SUPPLIERCATEGORYNAME NVARCHAR2(50)
);

-- 2. Create extract procedure
CREATE OR REPLACE PROCEDURE Suppliers_Extract 
IS
    RowCt NUMBER(10):=0;
    v_sql VARCHAR2(255) := 'TRUNCATE TABLE assignment45.Suppliers_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO ASSIGNMENT45.Suppliers_Stage
    SELECT s.Suppliername,
            s.PhoneNumber,
            s.FaxNumber,
            s.WebsiteURL,
            sc.SUPPLIERCATEGORYNAME
    FROM wwidbuser.SUPPLIERS s
    LEFT JOIN wwidbuser.SUPPLIERCATEGORIES sc
        ON s.SUPPLIERCATEGORYID = sc.SUPPLIERCATEGORYID;

    RowCt := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Number of suppliers added: ' || TO_CHAR(SQL%ROWCOUNT));
END;
/


-- ORDERS – Query that joins Orders, OrderLines, Customers, and People, and accepts an @OrderDate as a 
--parameter, and only selects records that match that date.
-- 1. Create staging table
--DROP TABLE Orders_Stage;

CREATE TABLE Orders_Stage (
    OrderDate           DATE,
    Quantity            NUMBER(3),
    UnitPrice           NUMBER(18,2),
    TaxRate             NUMBER(18,3),
    CustomerName        NVARCHAR2(100),
    CityName            NVARCHAR2(50),
    StateProvinceName   NVARCHAR2(50),
    CountryName         NVARCHAR2(60),
    StockItemName       NVARCHAR2(100),
    LogonName           NVARCHAR2(50),
    SupplierName        NVARCHAR2(256)
);

-- 2. Create extract procedure
CREATE OR REPLACE PROCEDURE Orders_Extract(p_order_date DATE)
AS
    --RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE assignment45.Orders_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    
    INSERT INTO ASSIGNMENT45.Orders_Stage 
    WITH CityDetails AS (
        SELECT ci.CityID,
               ci.CityName,
               sp.StateProvinceCode,
               sp.StateProvinceName,
               co.CountryName,
               co.FormalName
        FROM wwidbuser.Cities ci
        LEFT JOIN wwidbuser.StateProvinces sp
            ON ci.StateProvinceID = sp.StateProvinceID
        LEFT JOIN wwidbuser.Countries co
            ON sp.CountryID = co.CountryID 
    )

    SELECT o.OrderDate
        ,ol.Quantity
        ,ol.UnitPrice
        ,ol.TaxRate
        ,c.CustomerName
        ,dc.cityname
        ,dc.stateprovincename
        ,dc.countryname
        ,stk.StockItemName
        ,p.LogonName
        ,pp.SupplierName
    FROM wwidbuser.Orders o
        LEFT JOIN wwidbuser.OrderLines ol
            ON o.OrderID = ol.OrderID
        LEFT JOIN wwidbuser.customers c
            ON o.CustomerID = c.CustomerID
        LEFT JOIN CityDetails dc
            ON c.DeliveryCityID = dc.CityID
        LEFT JOIN wwidbuser.stockitems stk
            ON ol.Stockitemid = stk.StockItemID
        LEFT JOIN wwidbuser.suppliers pp
            ON stk.SupplierId = pp.SupplierId
        LEFT JOIN wwidbuser.People p
            ON o.salespersonpersonid = p.personid AND IsSalesPerson = 1
    WHERE o.OrderDate = TO_DATE(p_order_date, 'YYYY-MM-DD');
    
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;
/



/* REQUIREMENT 5 -  Transforms  ( 5 Marks )  */
--CUSTOMERS
-- 4. Create preload table
--DROP TABLE Customers_Preload;

CREATE TABLE Customers_Preload (
   CustomerKey NUMBER(10) NOT NULL,
   CustomerName NVARCHAR2(100) NULL,
   CustomerCategoryName NVARCHAR2(50) NULL,
   DeliveryCityName NVARCHAR2(50) NULL,
   DeliveryStateProvCode NVARCHAR2(5) NULL,
   DeliveryCountryName NVARCHAR2(50) NULL,
   PostalCityName NVARCHAR2(50) NULL,
   PostalStateProvCode NVARCHAR2(5) NULL,
   PostalCountryName NVARCHAR2(50) NULL,
   StartDate DATE NOT NULL,
   EndDate DATE NULL,
   CONSTRAINT PK_Customers_Preload PRIMARY KEY ( CustomerKey )
);


CREATE SEQUENCE CustomerKey START WITH 1;

-- 5. Create transform procedure
CREATE OR REPLACE PROCEDURE Customers_Transform
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Customers_Preload DROP STORAGE';
  StartDate DATE := SYSDATE; 
  EndDate DATE := SYSDATE - 1;
BEGIN
    EXECUTE IMMEDIATE v_sql;
 --BEGIN TRANSACTION;
 -- Add updated records
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT CustomerKey.NEXTVAL AS CustomerKey,
           stg.CustomerName,
           stg.CustomerCategoryName,
           stg.DeliveryCityName,
           stg.DeliveryStateProvinceCode,
           stg.DeliveryCountryName,
           stg.PostalCityName,
           stg.PostalStateProvinceCode,
           stg.PostalCountryName,
           StartDate,
           NULL
    FROM Customers_Stage stg
    JOIN DimCustomers cu
        ON stg.CustomerName = cu.CustomerName AND cu.EndDate IS NULL
    WHERE stg.CustomerCategoryName <> cu.CustomerCategoryName
          OR stg.DeliveryCityName <> cu.DeliveryCityName
          OR stg.DeliveryStateProvinceCode <> cu.DeliveryStateProvCode
          OR stg.DeliveryCountryName <> cu.DeliveryCountryName
          OR stg.PostalCityName <> cu.PostalCityName
          OR stg.PostalStateProvinceCode <> cu.PostalStateProvCode
          OR stg.PostalCountryName <> cu.PostalCountryName;

    -- Add existing records, and expire as necessary
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT cu.CustomerKey,
           cu.CustomerName,
           cu.CustomerCategoryName,
           cu.DeliveryCityName,
           cu.DeliveryStateProvCode,
           cu.DeliveryCountryName,
           cu.PostalCityName,
           cu.PostalStateProvCode,
           cu.PostalCountryName,
           cu.StartDate,
           CASE 
               WHEN pl.CustomerName IS NULL THEN NULL
               ELSE cu.EndDate
           END AS EndDate
    FROM DimCustomers cu
    LEFT JOIN Customers_Preload pl    
        ON pl.CustomerName = cu.CustomerName
        AND cu.EndDate IS NULL;
 -- Create new records
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT CustomerKey.NEXTVAL AS CustomerKey,
           stg.CustomerName,
           stg.CustomerCategoryName,
           stg.DeliveryCityName,
           stg.DeliveryStateProvinceCode,
           stg.DeliveryCountryName,
           stg.PostalCityName,
           stg.PostalStateProvinceCode,
           stg.PostalCountryName,
           StartDate,
           NULL
    FROM Customers_Stage stg
    WHERE NOT EXISTS ( SELECT 1 FROM DimCustomers cu WHERE stg.CustomerName = cu.CustomerName );
    -- Expire missing records
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT cu.CustomerKey,
           cu.CustomerName,
           cu.CustomerCategoryName,
           cu.DeliveryCityName,
           cu.DeliveryStateProvCode,
           cu.DeliveryCountryName,
           cu.PostalCityName,
           cu.PostalStateProvCode,
           cu.PostalCountryName,
           cu.StartDate,
           EndDate
    FROM DimCustomers cu
    WHERE NOT EXISTS ( SELECT 1 FROM Customers_Stage stg WHERE stg.CustomerName = cu.CustomerName )
          AND cu.EndDate IS NULL;

  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;
/


-- LOCATIONS
-- 1. Create preload table
--DROP TABLE Locations_Preload;

CREATE TABLE Locations_Preload (
    LocationKey NUMBER(10) NOT NULL,	
    CityName NVARCHAR2(50) NULL,
    StateProvCode NVARCHAR2(5) NULL,
    StateProvName NVARCHAR2(50) NULL,
    CountryName NVARCHAR2(60) NULL,
    CountryFormalName NVARCHAR2(60) NULL,
    CONSTRAINT PK_Locations_Preload PRIMARY KEY (LocationKey)
);


CREATE SEQUENCE LocationKey START WITH 1 INCREMENT BY 1;

-- 2. Create transform procedure
CREATE OR REPLACE PROCEDURE Locations_Transform
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Locations_Preload DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    INSERT INTO Locations_Preload /* Column list excluded for brevity */
    SELECT LocationKey.NEXTVAL AS LocationKey,
           cu.DeliveryCityName,
           cu.DeliveryStateProvinceCode,
           cu.DeliveryStateProvinceName,
           cu.DeliveryCountryName,
           cu.DeliveryFormalName
    FROM Customers_Stage cu
    WHERE NOT EXISTS 
	( SELECT 1 
              FROM DimCities ci
              WHERE cu.DeliveryCityName = ci.CityName
                AND cu.DeliveryStateProvinceName = ci.StateProvName
                AND cu.DeliveryCountryName = ci.CountryName 
        );
        
    INSERT INTO Locations_Preload /* Column list excluded for brevity */
    SELECT ci.CityKey,
           cu.DeliveryCityName,
           cu.DeliveryStateProvinceCode,
           cu.DeliveryStateProvinceName,
           cu.DeliveryCountryName,
           cu.DeliveryFormalName
    FROM Customers_Stage cu
    JOIN DimCities ci
        ON cu.DeliveryCityName = ci.CityName
        AND cu.DeliveryStateProvinceName = ci.StateProvName
        AND cu.DeliveryCountryName = ci.CountryName;
    
    SELECT COUNT(*) INTO RowCt
    FROM Locations_Preload;
    DBMS_OUTPUT.PUT_LINE('Number of locations added: ' || TO_CHAR(RowCt));
    
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;
/


-- PRODUCTS
-- 4. Create preload table
--DROP TABLE Products_Preload;

CREATE TABLE Products_Preload (
    ProductKey NUMBER(10),
    ProductName NVARCHAR2(100) NULL,
    ProductColour NVARCHAR2(20) NULL,
    ProductBrand NVARCHAR2(50) NULL,
    ProductSize NVARCHAR2(20) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    CONSTRAINT PK_Products_Preload PRIMARY KEY (ProductKey)
);


CREATE SEQUENCE ProductKey START WITH 1 INCREMENT BY 1;

-- 5. Create transform procedure
CREATE OR REPLACE PROCEDURE Products_Transform
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Products_Preload DROP STORAGE';
  StartDate DATE := SYSDATE; 
  EndDate DATE := SYSDATE - 1;
BEGIN
    EXECUTE IMMEDIATE v_sql;
 --BEGIN TRANSACTION;
 -- Add updated records
    MERGE INTO Products_Preload tgt
    USING Products_Stage src
    ON (tgt.ProductName = src.StockItemName AND tgt.EndDate IS NULL)
    WHEN MATCHED THEN
        UPDATE SET 
            tgt.ProductColour = src.ColorName,
            tgt.ProductBrand = src.Brand,
            tgt.ProductSize = src.ItemSize
        WHERE src.ColorName <> tgt.ProductColour
              OR src.Brand <> tgt.ProductBrand
              OR src.ItemSize <> tgt.ProductSize
    WHEN NOT MATCHED THEN
        INSERT (ProductKey, ProductName, ProductColour, ProductBrand, ProductSize, StartDate, EndDate)
        VALUES (ProductKey.NEXTVAL, 
                src.StockItemName, 
                src.ColorName, 
                src.Brand, 
                src.ItemSize, 
                SYSDATE, 
                NULL);
                
    -- Update EndDate
    UPDATE Products_Preload
        SET EndDate = SYSDATE
        WHERE EndDate IS NULL
          AND ProductKey IN (
              SELECT tgt.ProductKey
              FROM Products_Preload tgt
              JOIN Products_Stage src
              ON tgt.ProductName = src.StockItemName
              WHERE src.ColorName <> tgt.ProductColour
                    OR src.Brand <> tgt.ProductBrand
                    OR src.ItemSize <> tgt.ProductSize
          );        

--COMMIT TRANSACTION;
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;
/


-- SALESPEOPLE
-- 4. Create preload table
--DROP TABLE SalesPeople_Preload;

CREATE TABLE SalesPeople_Preload (
    SalespersonKey INT NOT NULL,
    FullName NVARCHAR2(50) NULL,
    PreferredName NVARCHAR2(50) NULL,
    LogonName NVARCHAR2(50) NULL,
    PhoneNumber NVARCHAR2(20) NULL,
    FaxNumber NVARCHAR2(20) NULL,
    EmailAddress NVARCHAR2(256) NULL,
    CONSTRAINT PK_SalesPeople_Preload PRIMARY KEY (SalespersonKey )
);

CREATE SEQUENCE SalespersonKey START WITH 1 INCREMENT BY 1;

-- 5. Create transform procedure
CREATE OR REPLACE PROCEDURE SalesPeople_Transform
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE SalesPeople_Preload DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
 --BEGIN TRANSACTION;
 -- Add updated records
    MERGE INTO SalesPeople_Preload tgt
    USING SalesPeople_Stage src
    ON (tgt.fullname = src.fullname)
    WHEN MATCHED THEN
        UPDATE 
        SET tgt.PreferredName = src.PreferredName,
            tgt.LogonName = src.Logonname,
            tgt.Phonenumber = src.PhoneNumber,
            tgt.FaxNumber = src.Faxnumber,
            tgt.EmailAddress = src.EmailAddress
        WHERE tgt.PreferredName = src.PreferredName
            OR tgt.LogonName = src.Logonname
            OR tgt.Phonenumber = src.PhoneNumber
            OR tgt.FaxNumber = src.Faxnumber
            OR tgt.EmailAddress = src.EmailAddress
    WHEN NOT MATCHED THEN
            INSERT (SalespersonKey, FullName, PreferredName, LogonName, PhoneNumber, FaxNumber, EmailAddress)
            VALUES (SalespersonKey.NEXTVAL, 
                    src.FullName, 
                    src.PreferredName, 
                    src.LogonName, 
                    src.PhoneNumber, 
                    src.FaxNumber, 
                    src.EmailAddress);

--COMMIT TRANSACTION;
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;
/


-- SUPPLIERS
-- 4. Create preload table

CREATE TABLE Suppliers_Preload (
   SupplierKey NUMBER(10) NOT NULL,
   SupplierName NVARCHAR2(100) NULL,
   PhoneNumber NVARCHAR2(50) NULL,
   FaxNumber NVARCHAR2(50) NULL,
   WebsiteUrl NVARCHAR2(256) NULL,
   SupplierCategoryName NVARCHAR2(50),
   StartDate DATE NOT NULL,
   EndDate DATE NULL,
   CONSTRAINT PK_Suppliers_Preload PRIMARY KEY ( SupplierKey )
);

CREATE SEQUENCE SupplierKey START WITH 1;

-- 5. Create transform procedure
CREATE OR REPLACE PROCEDURE Suppliers_Transform
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Suppliers_Preload DROP STORAGE';
  StartDate DATE := SYSDATE; 
  EndDate DATE := SYSDATE - 1;
BEGIN
    EXECUTE IMMEDIATE v_sql;
 --BEGIN TRANSACTION;
 -- Add updated records
    MERGE INTO Suppliers_Preload tgt
    USING Suppliers_Stage src
    ON (tgt.SupplierName = src.SupplierName)
    WHEN MATCHED THEN
        UPDATE SET 
            tgt.PhoneNumber = src.PhoneNumber,
            tgt.FaxNumber = src.FaxNumber,
            tgt.WebsiteUrl = src.WebsiteUrl,
            tgt.SupplierCategoryName = src.SupplierCategoryName
    WHEN NOT MATCHED THEN
        INSERT (SupplierKey, SupplierName, PhoneNumber, FaxNumber, WebsiteUrl, SupplierCategoryName, StartDate, EndDate)
        VALUES (
                SupplierKey.NEXTVAL,
                src.SupplierName,
                src.PhoneNumber,
                src.FaxNumber,
                src.WebsiteUrl,
                src.SupplierCategoryName,
                SYSDATE,
                NULL);
                
    -- Update EndDate for Changed Records
    UPDATE Suppliers_Preload tgt
    SET EndDate = SYSDATE
    WHERE EndDate IS NULL
      AND EXISTS (
          SELECT 1 
          FROM Suppliers_Stage src
          WHERE tgt.SupplierName = src.SupplierName
            AND (tgt.PhoneNumber <> src.PhoneNumber
                 OR tgt.FaxNumber <> src.FaxNumber
                 OR tgt.WebsiteUrl <> src.WebsiteUrl
                 OR tgt.SupplierCategoryName <> src.SupplierCategoryName)
      );

    --COMMIT TRANSACTION;
    EXCEPTION
        WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line(v_sql);
END;
/

-- ORDERS
-- 4. Create preload table
--DROP TABLE Orders_Preload;

CREATE TABLE Orders_Preload (
    CustomerKey NUMBER(10) NOT NULL,
    CityKey NUMBER(10) NOT NULL,
    ProductKey NUMBER(10) NOT NULL,
    SalespersonKey NUMBER(10) NOT NULL,
    SupplierKey NUMBER(10) NOT NULL,
    DateKey NUMBER(8) NOT NULL,
    Quantity NUMBER(3) NOT NULL,
    UnitPrice NUMBER(18, 2) NOT NULL,
    TaxRate NUMBER(18, 3) NOT NULL,
    TotalBeforeTax NUMBER(18, 2) NOT NULL,
    TotalAfterTax NUMBER(18, 2) NOT NULL
);

-- 5. Create transform procedure
CREATE OR REPLACE PROCEDURE Orders_Transform (p_date DATE)
AS
    v_sql VARCHAR(255) := 'TRUNCATE TABLE Orders_Preload DROP STORAGE';
BEGIN
    -- Clear the Preload table
    EXECUTE IMMEDIATE v_sql;

    -- Transform and load data within the date range
    INSERT INTO Orders_Preload (CustomerKey, CityKey, ProductKey, SalespersonKey, SupplierKey, DateKey, Quantity, UnitPrice, TaxRate, TotalBeforeTax, TotalAfterTax)
    SELECT cu.CustomerKey,
           ci.LocationKey,
           pr.ProductKey,
           sp.SalespersonKey,
           pp.SupplierKey,
           EXTRACT(YEAR FROM ord.OrderDate) * 10000 + EXTRACT(MONTH FROM ord.OrderDate) * 100 + EXTRACT(DAY FROM ord.OrderDate),
           SUM(ord.Quantity) AS Quantity,
           AVG(ord.UnitPrice) AS UnitPrice,
           AVG(ord.TaxRate) AS TaxRate,
           SUM(ord.Quantity * ord.UnitPrice) AS TotalBeforeTax,
           SUM(ord.Quantity * ord.UnitPrice * (1 + ord.TaxRate / 100)) AS TotalAfterTax
    FROM Orders_Stage ord
    JOIN Customers_Preload cu ON ord.CustomerName = cu.CustomerName
    JOIN Locations_Preload ci ON ord.CityName = ci.CityName AND ord.StateProvinceName = ci.StateProvName AND ord.CountryName = ci.CountryName
    JOIN Products_Preload pr ON ord.StockItemName = pr.ProductName
    JOIN SalesPeople_Preload sp ON ord.LogonName = sp.LogonName
    JOIN Suppliers_Preload pp ON ord.SupplierName = pp.SupplierName
    WHERE ord.OrderDate = TO_DATE(p_date, 'YYYY-MM-DD')
    GROUP BY cu.CustomerKey,
           ci.LocationKey,
           pr.ProductKey,
           sp.SalespersonKey,
           pp.SupplierKey, 
             EXTRACT(YEAR FROM ord.OrderDate) * 10000 + EXTRACT(MONTH FROM ord.OrderDate) * 100 + EXTRACT(DAY FROM ord.OrderDate);

    DBMS_OUTPUT.PUT_LINE('Orders_Transform completed for date: ' || p_date ||'. Rows have been extracted: ' || TO_CHAR(SQL%ROWCOUNT));
END Orders_Transform;

/

/* REQUIREMENT 6 - Create ETL Loads (3 Marks) */

-- CUSTOMERS
-- 7. Create load procedure
CREATE OR REPLACE PROCEDURE Customers_Load
AS
BEGIN
    --START TRANSACTION;

    DELETE FROM DimCustomers cu
    WHERE EXISTS (SELECT null FROM Customers_Preload pl
                    WHERE cu.CustomerKey = pl.CustomerKey);

    INSERT INTO DimCustomers /* Columns excluded for brevity */
    SELECT * /* Columns excluded for brevity */
    FROM Customers_Preload;

    COMMIT;
END;
/

-- LOCATIONS/CITIES
CREATE OR REPLACE PROCEDURE Cities_Load
AS
BEGIN
    --START TRANSACTION;

    DELETE FROM DimCities ci
    WHERE EXISTS (SELECT null FROM Locations_Preload pl
                    WHERE ci.CityKey = pl.LocationKey);

    INSERT INTO DimCities /* Columns excluded for brevity */
    SELECT * /* Columns excluded for brevity */
    FROM Locations_Preload;

    COMMIT;
END;
/

-- PRODUCTS
CREATE OR REPLACE PROCEDURE Products_Load
AS
BEGIN
    --START TRANSACTION;

    DELETE FROM DimProducts cu
    WHERE EXISTS (SELECT null FROM Products_Preload pl
                    WHERE cu.ProductKey = pl.ProductKey);

    INSERT INTO DimProducts /* Columns excluded for brevity */
    SELECT * /* Columns excluded for brevity */
    FROM Products_Preload;

    COMMIT;
END;
/

-- SALESPEOPLE
-- 7. Create load procedure
CREATE OR REPLACE PROCEDURE SalesPeople_Load
AS
BEGIN
    --START TRANSACTION;

    DELETE FROM DimSalesPeople cu
    WHERE EXISTS (SELECT null FROM SalesPeople_Preload pl
                    WHERE cu.SalespersonKey = pl.SalespersonKey);

    INSERT INTO DimSalesPeople /* Columns excluded for brevity */
    SELECT * /* Columns excluded for brevity */
    FROM SalesPeople_Preload;

    COMMIT;
END;
/

-- SUPPLIERS
-- 7. Create load procedure
CREATE OR REPLACE PROCEDURE Suppliers_Load
AS
BEGIN
    --START TRANSACTION;

    DELETE FROM DIMSUPPLIERS cu
    WHERE EXISTS (SELECT null FROM Suppliers_Preload pl
                    WHERE cu.SupplierKey = pl.SupplierKey);

    INSERT INTO DIMSUPPLIERS /* Columns excluded for brevity */
    SELECT * /* Columns excluded for brevity */
    FROM Suppliers_Preload;

    COMMIT;
END;
/

-- ORDERS
-- 7. Create load procedure
CREATE OR REPLACE PROCEDURE Orders_Load
AS
BEGIN
    INSERT INTO FactSales /* Columns excluded for brevity */
    SELECT * /* Columns excluded for brevity */
    FROM Orders_Preload;
END;
/
--------------------------------- ETL Process --------------------------------
CREATE OR REPLACE PROCEDURE sp_run_etl_process(p_start_date DATE, p_end_date DATE)
IS
    current_date DATE := p_start_date;
BEGIN
    BEGIN
        -- Start Transaction
        DBMS_OUTPUT.PUT_LINE('Starting ETL Process from ' || TO_CHAR(p_start_date, 'YYYY-MM-DD') || ' to ' || TO_CHAR(p_end_date, 'YYYY-MM-DD'));

            -- Call individual ETL procedures with date parameter if needed
            Customers_Extract;
            Customers_Transform;
            Customers_Load;
            DBMS_OUTPUT.PUT_LINE('Customer load completed.');
            
            Locations_Transform;
            Cities_Load;
            DBMS_OUTPUT.PUT_LINE('City load completed.');

            Products_Extract;
            Products_Transform;
            Products_Load;
            DBMS_OUTPUT.PUT_LINE('Product load completed.');

            SalesPeople_Extract;
            SalesPeople_Transform;
            SalesPeople_Load;
            DBMS_OUTPUT.PUT_LINE('Salespeople load completed.');
            
            Suppliers_Extract;
            Suppliers_Transform;
            Suppliers_Load;
            DBMS_OUTPUT.PUT_LINE('Supplier load completed.');
            
            -- Loop through each date from p_start_date to p_end_date
        WHILE current_date <= p_end_date LOOP
        
            DBMS_OUTPUT.PUT_LINE('Processing date: ' || TO_CHAR(current_date, 'YYYY-MM-DD'));
            
            Orders_Extract(current_date);
            Orders_Transform(current_date);
            Orders_Load; -- Ensure sp_load_orders accepts a date parameter
            DBMS_OUTPUT.PUT_LINE('Order load for ' || TO_CHAR(current_date, 'YYYY-MM-DD') || ' completed.');

            -- Increment the current_date by 1 day
            current_date := current_date + 1;
        END LOOP;

        -- Commit if all procedures succeed
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('ETL Process completed successfully.');

    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback in case of error
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            -- Optionally, you can re-raise the exception if you want it to propagate
            RAISE;
    END;
END sp_run_etl_process;
/

/* REQUIREMENT 7 - Load rest of data to DWH and Query (2 Marks) */
-- Execute the summary procedure for 4 days
BEGIN
    -- Call the ETL procedure for the date range 2013-01-01 to 2013-01-04
    sp_run_etl_process(
                        TO_DATE('2013-01-01', 'YYYY-MM-DD'), 
                        TO_DATE('2013-01-04', 'YYYY-MM-DD')
                        );
END;
/

-- Run the query that is created in Requirement 3
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