/***************************INSTRUCTION***************************************/
-- Create HR_DM connection
-- Columns that end with "Key" are surrogate key
-- Columns that end with "Code" are business key

----------------------- CREATE FINAL DIM FACT TABLES --------------------------

CREATE TABLE DimLocations(   -- Type 1 SCD
	LocationKey 		NUMBER(10),
    LocationCode        NUMBER(10),   -- BusinessKey
	StreetAddress       NVARCHAR2(40) NOT NULL,
	PostalCode          NVARCHAR2(12),
	City                NVARCHAR2(30),
	StateProvince       NVARCHAR2(25),
    CountryName 	    NVARCHAR2(60) NOT NULL,
    RegionName 		    NVARCHAR2(25) NOT NULL,
    
    CONSTRAINT PK_DimLocations PRIMARY KEY ( LocationKey ),
    CONSTRAINT UK_DimLocations_StreetAddress UNIQUE(StreetAddress)
);

CREATE TABLE DimDepartments(    -- Type 2 SCD
	DepartmentKey 	                NUMBER(10),
    DepartmentCode                  NUMBER(10),         -- BusinessKey
	DepartmentName                  NVARCHAR2(30) NOT NULL,
    DepartmentManagerCode           NUMBER(10),         -- BusinessKey
    DepartmentManagerFirstName      NVARCHAR2(25),
    DepartmentManagerLastName       NVARCHAR2(25),
	StartDate 		                DATE NOT NULL,
	EndDate 		                DATE NULL,
    IsCurrent                       CHAR(1) NOT NULL,
    
    CONSTRAINT PK_DimDepartments PRIMARY KEY (DepartmentKey)
);

CREATE TABLE DimJobs (     -- Type 2 SCD
    JobKey             NUMBER(10),
    JobCode            NVARCHAR2(10) NOT NULL,  -- BusinessKey
    JobTitle           NVARCHAR2(35) NOT NULL,
    MinSalary          NUMBER(6),
    MaxSalary          NUMBER(6),
    SalaryCategory     NVARCHAR2(25) NOT NULL,
    StartDate 	       DATE NOT NULL,
	EndDate 	       DATE NULL,
    IsCurrent          CHAR(1) NOT NULL,
    
    CONSTRAINT PK_DimJobs PRIMARY KEY (JobKey)
);

CREATE TABLE DimEmployees (     -- Type 2 SCD
    EmployeeKey         NUMBER(10),
    EmployeeCode        NUMBER(10) NOT NULL,    -- BusinessKey
    FirstName           NVARCHAR2(20)NOT NULL,
    LastName            NVARCHAR2(25),
    Gender              NVARCHAR2(10) NOT NULL,     
    MaritalStatus       NVARCHAR2(10) NOT NULL,
    Email               NVARCHAR2(25),
    PhoneNumber         NVARCHAR2(20),
    HireDate            DATE,
    StartDate 	        DATE NOT NULL,
	EndDate 	        DATE NULL,
    IsCurrent           CHAR(1) NOT NULL,
    
    CONSTRAINT PK_DimEmployees PRIMARY KEY (EmployeeKey)
);

CREATE TABLE DimDate (          -- Type 0 SCD
    DateKey    	    NUMBER(10) NOT NULL,
    DateValue  	    DATE NOT NULL,
    Day             NUMBER(2) NOT NULL,         -- from 1 to 31
    Month 	        NUMBER(2) NOT NULL,         -- from 1 to 12
    Quarter 	    NUMBER(1) NOT NULL,         -- from 1 to 4
    Year 	        NUMBER(10) NOT NULL, 
    StartOfMonth    DATE NOT NULL,
    EndOfMonth  	DATE NOT NULL,
    MonthName   	NVARCHAR2(9) NOT NULL,      -- should be "Jan"
    QuarterName     NVARCHAR2(15) NOT NULL,     -- should be "Qtr. 1"
    DayOfWeekName   NVARCHAR2(9) NOT NULL,      -- should be "Mon"   

    CONSTRAINT PK_DimDate PRIMARY KEY ( DateKey )
);


CREATE TABLE FactJobHistory (
    JobHistoryKey           NUMBER(10) NOT NULL,
    DateKey                 NUMBER(10) NOT NULL,
    EmployeeKey             NUMBER(10) NOT NULL,
    JobKey                  NUMBER(10) NOT NULL,
    DepartmentKey           NUMBER(10) NOT NULL,
    LocationKey             NUMBER(10) NOT NULL,
    Salary                  NUMBER(8,2),
    CommissionPct           NUMBER(2,2),
    
    
    CONSTRAINT PK_FactJobHistory                 PRIMARY KEY (JobHistoryKey),
    CONSTRAINT FK_FactJobHistory_DimDate         FOREIGN KEY (DateKey)         REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactJobHistory_DimEmployees    FOREIGN KEY (EmployeeKey)     REFERENCES DimEmployees(EmployeeKey),
    CONSTRAINT FK_FactJobHistory_DimJobs         FOREIGN KEY (JobKey)          REFERENCES DimJobs(JobKey),
    CONSTRAINT FK_FactJobHistory_DimDepartments  FOREIGN KEY (DepartmentKey)   REFERENCES DimDepartments(DepartmentKey),
    CONSTRAINT FK_FactJobHistory_DimLocations    FOREIGN KEY (LocationKey)     REFERENCES DimLocations(LocationKey)
);

-- Create indexes

CREATE INDEX IX_PK_FactJobHistory_JobKey 	    ON FactJobHistory(JobKey);
CREATE INDEX IX_FactJobHistory_DepartmentKey 	ON FactJobHistory(DepartmentKey);
CREATE INDEX IX_FactJobHistory_LocationKey 	    ON FactJobHistory(LocationKey);
CREATE INDEX IX_FactJobHistory_DateKey 	        ON FactJobHistory(DateKey);
CREATE INDEX IX_FactJobHistory_EmployeeKey 	    ON FactJobHistory(EmployeeKey);


-- Create sequences for surrogate keys

CREATE SEQUENCE seq_location_key    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_department_key  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_job_key         START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_employee_key    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_position_key    START WITH 1 INCREMENT BY 1 NOCACHE;





