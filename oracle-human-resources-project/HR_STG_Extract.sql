--- HUMAN RESOURCE ETL PROCESS -----
--- STEP 2: EXTRACT TO STAGE TABLES ------

--Extract Procedure for STGREGIONS
CREATE OR REPLACE PROCEDURE EXTRACT_REGIONS AS
BEGIN
    INSERT INTO STGREGIONS (region_id, region_name)
    SELECT region_id, region_name
    FROM  hr_user.regions;

    COMMIT;
END;
/

--Extract Procedure for STGCOUNTRIES
CREATE OR REPLACE PROCEDURE EXTRACT_COUNTRIES AS
BEGIN
    INSERT INTO STGCOUNTRIES (country_id, country_name, region_id)
    SELECT country_id, country_name, region_id
    FROM hr_user.countries;

    COMMIT;
END;
/

--Extract Procedure for StgJobs
 create or replace NONEDITIONABLE PROCEDURE SP_LOAD_STG_JOBS 
IS
    RowCt NUMBER(10):=0;
    v_sql VARCHAR2(255) := 'TRUNCATE TABLE STGJOBS DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO STGJOBS(
        JobCode,
        JobTitle,
        MinSalary,
        MaxSalary,
        SalaryCategory
        )

    SELECT
        Job_Id,
        Job_Title,
        Min_Salary,
        Max_Salary,
        CASE 
            WHEN (NVL(min_salary,0) + NVL(max_salary,0))/2 < 5000 THEN 'Low'
            WHEN (NVL(min_salary,0) + NVL(max_salary,0))/2 BETWEEN 5000 AND 15000 THEN 'Medium'
            WHEN (NVL(min_salary,0) + NVL(max_salary,0))/2 > 15000 THEN 'High'
            ELSE 'N/A'
        END AS SalaryCategory
    FROM HR_user.jobs;

    RowCt := SQL%ROWCOUNT;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Number of Jobs  added is: ' || TO_CHAR(SQL%ROWCOUNT));

    EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Error in loading StgJobs: ' || SQLERRM);
END; 


-- EXTRACT PROCEDURE FOR STGDEPARTMENTS ----
CREATE OR REPLACE PROCEDURE sp_load_stg_departments
AS
    v_truncate VARCHAR(255) := 'TRUNCATE TABLE STGDEPARTMENTS DROP STORAGE';
    v_count NUMBER;
BEGIN
	BEGIN
		EXECUTE IMMEDIATE v_truncate;

		INSERT INTO STGDEPARTMENTS	(
             DepartmentCode,
             DepartmentName,
             DepartmentManagerCode,
             DepartmentManagerFirstName,
             DepartmentManagerLastName
)
            SELECT
                d.DEPARTMENT_ID,
                d.DEPARTMENT_NAME,
                d.MANAGER_ID,
                e.FIRST_NAME,
                e.LAST_NAME
            FROM
                HR_USER.DEPARTMENTS d
            LEFT JOIN
                HR_USER.EMPLOYEES e
                ON d.MANAGER_ID = e.EMPLOYEE_ID;
       
       
        v_count := SQL%ROWCOUNT;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE('Number of rows added to stgdepartment: ' || TO_CHAR(v_count));
		
		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Error in loading stgdepartment: ' || SQLERRM);
	END; 
END;
/



-- EXTRACT PROCEDURE FOR STGEMPLOYEES ----
create or replace NONEDITIONABLE PROCEDURE  SP_LOAD_STG_EMPLOYEES
AS
    v_truncate VARCHAR(255) := 'TRUNCATE TABLE STGEMPLOYEES DROP STORAGE';
    v_count NUMBER;
BEGIN
	BEGIN
		EXECUTE IMMEDIATE v_truncate;

		INSERT INTO STGEMPLOYEES	    
		SELECT EMPLOYEE_id
                , FIRST_NAME
                , LAST_NAME
                , CASE 
                    WHEN DBMS_RANDOM.VALUE(0,2) < 1 
                        THEN 'Male' 
                    ELSE 'Female' 
                    END AS GENDER
                , CASE 
                    WHEN DBMS_RANDOM.VALUE(0,2) < 1 
                        THEN 'Married' 
                    ELSE 'Single' 
                    END AS MARITAL_STATUS
                , EMAIL
                , PHONE_NUMBER
                , HIRE_DATE
        FROM HR_USER.EMPLOYEES;

        v_count := SQL%ROWCOUNT;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE('Number of rows added to StgEmployees: ' || TO_CHAR(v_count));

		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Error in loading StgEmployees: ' || SQLERRM);
	END; 
END;



-- EXTRACT PROCEDURE FOR STGJOBHISTORY ----
create or replace NONEDITIONABLE PROCEDURE SP_LOAD_STGJOBHISTORY
AS
    v_truncate VARCHAR(255) := 'TRUNCATE TABLE STGJOBHISTORY DROP STORAGE';
    v_count NUMBER;
BEGIN
	BEGIN
		EXECUTE IMMEDIATE v_truncate;

		INSERT INTO STGJOBHISTORY
        SELECT
            emp.EMPLOYEE_ID,
            emp.FIRST_NAME,
            emp.LAST_NAME,
            emp.EMAIL,
            emp.PHONE_NUMBER,
            EXTRACT(YEAR FROM emp.HIRE_DATE) * 10000 + EXTRACT(MONTH FROM emp.HIRE_DATE) * 100 + EXTRACT(DAY FROM emp.HIRE_DATE),
            emp.JOB_ID ,
            emp.SALARY,
            emp.COMMISSION_PCT,
            emp.MANAGER_ID,
            emp.DEPARTMENT_ID, 
            l.LOCATION_ID,
            c.COUNTRY_ID,
            r.REGION_ID
        FROM HR_user.EMPLOYEES emp
        LEFT JOIN HR_user.DEPARTMENTS d
            ON emp.DEPARTMENT_ID = d.DEPARTMENT_ID
        LEFT JOIN HR_user.LOCATIONS l
            ON d.LOCATION_ID = l.LOCATION_ID
        LEFT JOIN HR_user.COUNTRIES c
            ON l.COUNTRY_ID = c.COUNTRY_ID
        LEFT JOIN HR_user.REGIONS r
            ON c.REGION_ID = r.REGION_ID;

        v_count := SQL%ROWCOUNT;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE('Number of rows added to StgJobHistory: ' || TO_CHAR(v_count));

		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Error in loading StgJobHistory: ' || SQLERRM);
	END; 
END;


--- RUN PROCEDURES TO POPULATE STAGING TABLES ---
    -- Extract Regions
    BEGIN
        extract_regions;
        DBMS_OUTPUT.PUT_LINE('Extracted: REGIONS');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in extract_regions: ' || SQLERRM);
    END;

    -- Extract Countries
    BEGIN
        extract_countries;
        DBMS_OUTPUT.PUT_LINE(' Extracted: COUNTRIES');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in extract_countries: ' || SQLERRM);
    END;

    -- Extract Departments
    BEGIN
        sp_load_stg_departments;
        DBMS_OUTPUT.PUT_LINE(' Extracted: DEPARTMENTS');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in extract_departments: ' || SQLERRM);
    END;

    -- Extract Jobs
    BEGIN
         sp_load_stg_jobs;;
        DBMS_OUTPUT.PUT_LINE(' Extracted: JOBS');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in extract_jobs: ' || SQLERRM);
    END;

    -- Extract Employees
    BEGIN
        sp_load_stg_employees;
        DBMS_OUTPUT.PUT_LINE(' Extracted: EMPLOYEES');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in extract_employees: ' || SQLERRM);
    END;

    -- Extract Job History
    BEGIN
        sp_load_stgjobhistory;
        DBMS_OUTPUT.PUT_LINE(' Extracted: JOB_HISTORY');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in extract_job_history: ' || SQLERRM);
    END;
/

--- CROSS CHECK ----
select 'STGcountries' as tablename, count(*) from STGcountries union
select 'STGdepartments' as tablename, count(*) from STGdepartments union
select 'STGemployees ' as tablename, count(*) from STGemployees union
select 'STGjobhistory' as tablename,count(*) from STGjobhistory union
select 'STGjobs' as tablename, count(*) from STGjobs union
select 'STGregions' as tablename, count(*) from STGregions;