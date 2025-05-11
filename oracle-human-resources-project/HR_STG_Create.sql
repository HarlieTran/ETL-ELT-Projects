--- HUMAN RESOURCE ETL PROCESS -----
--- STEP 1: CREATE STAGE TABLES ------

--DROP TABLE STGREGIONS
CREATE TABLE STGREGIONS
    ( region_id      NUMBER 
          , region_name    VARCHAR2(25) 
    );

--DROP TABLE STGCOUNTRIES
CREATE TABLE STGCOUNTRIES
    ( country_id      CHAR(2) 
    , country_name    VARCHAR2(60) 
    , region_id       NUMBER 
    ) ;
    
--DROP TABLE STGLOCATIONS 
CREATE TABLE STGLOCATIONS 
    ( LocationCode    NUMBER(10)       -- BusinessKey
    , StreetAddress   NVARCHAR2(40)
    , PostalCode      NVARCHAR2(12)
    , City            NVARCHAR2(30)
    , StateProvince   NVARCHAR2(25)
    , CountryName     NVARCHAR2(60)
    , RegionName      NVARCHAR2(25)
    ) ;


--DROP TABLE StgJobs
CREATE TABLE STGJOBS(    
    JobCode             NVARCHAR2(30) NOT NULL,    -- BusinessKey
    JobTitle            NVARCHAR2(35) NOT NULL,
    MinSalary           NUMBER(6),
    MaxSalary           NUMBER(6),     
    SalaryCategory      NVARCHAR2(20) NOT NULL 
);

-- Staging table StgEmployees
CREATE TABLE STGEMPLOYEES(    
    EmployeeCode        NUMBER(10) NOT NULL,    -- BusinessKey
    FirstName           NVARCHAR2(20)NOT NULL,
    LastName            NVARCHAR2(25),
    Gender              NVARCHAR2(10) NOT NULL,     
    MaritalStatus       NVARCHAR2(10) NOT NULL,
    Email               NVARCHAR2(25),
    PhoneNumber         NVARCHAR2(20),
    HireDate            DATE
);

--DROP TABLE STGDEPARTMENTS  
CREATE TABLE STGDEPARTMENTS(   
    DepartmentCode                  NUMBER(10),         -- BusinessKey
	DepartmentName                  NVARCHAR2(30) NOT NULL,
    DepartmentManagerCode           NUMBER(10),         -- BusinessKey
    DepartmentManagerFirstName      NVARCHAR2(25),
    DepartmentManagerLastName       NVARCHAR2(25)   
);


--DROP TABLE STGJOBHISTORY
CREATE TABLE STGJOBHISTORY(    
    EmployeeCode            NUMBER(10) NOT NULL,
    FirstName               NVARCHAR2(20)NOT NULL,
    LastName                NVARCHAR2(25),
    Email                   NVARCHAR2(25),
    PhoneNumber             NVARCHAR2(20),
    HireDate                NUMBER(10),
    JobCode                 NVARCHAR2(25),
    Salary                  NUMBER(8,2),
    CommissionPct           NUMBER(2,2),
    ManagerCode             NUMBER(10),
    DepartmentCode          NUMBER(10),
    LocationCode            NUMBER(10),
    CountryCode             NVARCHAR2(25),
    RegionCode              NUMBER(10)
);