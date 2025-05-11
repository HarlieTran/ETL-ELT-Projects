--- HUMAN RESOURCE ETL PROCESS -----
--- STEP 3: TRANSFORM AND LOAD TO DIMENSIONS TABLES ------


--- TRANSFORM LOAD DIMJOBS -----
create or replace NONEDITIONABLE PROCEDURE SP_LOAD_DM_DIMJOBS 
AS
    RowCt NUMBER(10) := 0;
BEGIN
    BEGIN
        --Expire old records where changes detected
        MERGE INTO DIMJOBS tgt
        USING STGJOBS src
        ON (tgt.JobCode = src.JobCode)
        WHEN MATCHED THEN
            UPDATE SET 
                tgt.EndDate = SYSDATE - 1,
                tgt.IsCurrent = 'N'
            WHERE tgt.EndDate IS NULL
              AND (
                  tgt.JobTitle <> src.JobTitle
                  OR tgt.MinSalary <> src.MinSalary
                  OR tgt.MaxSalary <> src.MaxSalary
                  OR tgt.SalaryCategory <> src.SalaryCategory
              );

        --Insert new or changed rows
        INSERT INTO DIMJOBS (
            JobKey,
            JobCode,
            JobTitle,
            MinSalary,
            MaxSalary,
            SalaryCategory,
            StartDate,
            EndDate,
            IsCurrent
        )
        SELECT 
            SEQ_JOB_KEY.NEXTVAL,
            src.JobCode,
            src.JobTitle,
            src.MinSalary,
            src.MaxSalary,
            src.SalaryCategory,
            SYSDATE,
            NULL,
            'Y'
        FROM STGJOBS src
        LEFT JOIN DIMJOBS tgt
          ON src.JobCode = tgt.JobCode
        WHERE tgt.JobCode IS NULL
           OR tgt.EndDate = SYSDATE - 1;

        
        RowCt := SQL%ROWCOUNT;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Number of rows added to DimJobs is : ' || TO_CHAR(RowCt));

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error in loading DimJobs: ' || SQLERRM);
    END;
END;

--- TRANSFORM LOAD DIMDEPARTMENTS -----
create or replace NONEDITIONABLE PROCEDURE sp_load_dm_dimdepartments
AS
    v_count NUMBER;
BEGIN
	BEGIN
        MERGE INTO DIMDEPARTMENTS tgt
        USING STGDEPARTMENTS src
        ON (tgt.DEPARTMENTCODE = src.DEPARTMENTCODE)
        WHEN MATCHED THEN
            UPDATE SET 
                tgt.ENDDATE = SYSDATE - 1,
                tgt.ISCURRENT = 'N'
            WHERE tgt.ENDDATE IS NULL
              AND (
                  tgt.DEPARTMENTNAME <> src.DEPARTMENTNAME
                  OR tgt.DEPARTMENTMANAGERCODE <> src.DEPARTMENTMANAGERCODE
                  OR tgt.DEPARTMENTMANAGERFIRSTNAME <> src.DEPARTMENTMANAGERFIRSTNAME
                  OR tgt.DEPARTMENTMANAGERLASTNAME <> src.DEPARTMENTMANAGERLASTNAME
              );
              
      -- Step 2: Insert new or changed records
        INSERT INTO DIMDEPARTMENTS (
                DEPARTMENTKEY
               , DEPARTMENTCODE
               , DEPARTMENTNAME
               , DEPARTMENTMANAGERCODE
               , DEPARTMENTMANAGERFIRSTNAME
               , DEPARTMENTMANAGERLASTNAME
               , STARTDATE
               , ENDDATE
               , ISCURRENT
                )
        SELECT  SEQ_DEPARTMENT_KEY.NEXTVAL
                , src.DEPARTMENTCODE
                , src.DEPARTMENTNAME
                , src.DEPARTMENTMANAGERCODE
                , src.DEPARTMENTMANAGERFIRSTNAME
                , src.DEPARTMENTMANAGERLASTNAME
                , SYSDATE
                , NULL
                , 'Y'
        FROM STGDEPARTMENTS src
        LEFT JOIN DIMDEPARTMENTS tgt
          ON src.DEPARTMENTCODE = tgt.DEPARTMENTCODE
        WHERE tgt.DEPARTMENTCODE IS NULL
           OR tgt.ENDDATE = SYSDATE - 1;
        
        v_count := SQL%ROWCOUNT;
        COMMIT;
		DBMS_OUTPUT.PUT_LINE('Number of rows added to DIMDEPARTMENTS: ' || TO_CHAR(v_count));
		
		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Error in loading DIMDEPARTMENTS ' || SQLERRM);
	END;
	
END;


--- TRANSFORM LOAD DIMEMPLOYEES -----
create or replace NONEDITIONABLE PROCEDURE SP_LOAD_DM_DIMEMPLOYEES 
AS
    v_count NUMBER;
BEGIN
	BEGIN
		-- Step 1: Exprie old records
		MERGE INTO DIMEMPLOYEES tgt
		USING STGEMPLOYEES  src
		ON (tgt.EmployeeCode = src.EmployeeCode)
		WHEN MATCHED THEN 
			UPDATE SET
				tgt.EndDate = SYSDATE -1
                ,tgt.IsCurrent = 'N'
			WHERE 
                tgt.EndDate IS NULL
                AND (
                    tgt.FirstName <> src.FirstName
                    OR tgt.LastName <> src.LastName
                    OR tgt.Email <> src.Email
                    OR tgt.PhoneNumber <> src.PhoneNumber
                    OR tgt.HireDate <> src.HireDate
                    );
                    
		-- Step 2: Insert new or changed records
        INSERT INTO DIMEMPLOYEES (
                EMPLOYEEKEY
                , EMPLOYEECODE
                , FIRSTNAME
                , LASTNAME
                , GENDER
                , MARITALSTATUS
                , EMAIL
                , PHONENUMBER
                , HIREDATE
                , STARTDATE
                , ENDDATE
                , ISCURRENT
                )
        SELECT seq_employee_key.NEXTVAL
                , src.EMPLOYEECODE
                , src.FIRSTNAME
                , src.LASTNAME
                , src.GENDER
                , src.MARITALSTATUS
                , src.EMAIL
                , src.PHONENUMBER
                , src.HIREDATE
                , SYSDATE
                , NULL
                , 'Y'
        FROM STGEMPLOYEES src
        LEFT JOIN DIMEMPLOYEES tgt
          ON src.EMPLOYEEcode = tgt.EMPLOYEECODE
        WHERE tgt.EMPLOYEECODE IS NULL
           OR tgt.ENDDATE = SYSDATE - 1;
           
		v_count := SQL%ROWCOUNT;
        COMMIT;
		DBMS_OUTPUT.PUT_LINE('Number of rows added to DimEmployees: ' || TO_CHAR(v_count));
		
		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Error in loading DimEmployees: ' || SQLERRM);
	END;
	
END;



--- TRANSFORM LOAD FACTJOBHISTORY -----
create or replace NONEDITIONABLE PROCEDURE SP_LOAD_DM_FACTJOBHISTORY 
AS
    v_count NUMBER;
BEGIN
	BEGIN
        INSERT INTO FACTJOBHISTORY(
                JOBHISTORYKEY
                , DATEKEY
                , EMPLOYEEKEY
                , JOBKEY
                , DEPARTMENTKEY
                , LOCATIONKEY
                , SALARY
                , COMMISSIONPCT)
        SELECT
                seq_position_key.NEXTVAL,
                jd.HIREDATE,
                COALESCE(e.EMPLOYEEKEY, -1),
                COALESCE(j.JOBKEY, -1),
                COALESCE(d.DEPARTMENTKEY, -1),
                COALESCE(l.LOCATIONKEY, -1),
                COALESCE(jd.SALARY,0),
                COALESCE(jd.COMMISSIONPCT,0)
            FROM STGJOBHISTORY jd

            -- Dimension Joins
            LEFT JOIN DIMEMPLOYEES e
                ON e.EMPLOYEECODE = jd.EMPLOYEECODE 
                AND e.ENDDATE IS NULL

            LEFT JOIN DIMJOBS j
                ON j.JOBCODE = jd.JOBCODE
                AND j.ENDDATE IS NULL

            LEFT JOIN DIMDEPARTMENTS d
                ON d.DEPARTMENTCODE = jd.DEPARTMENTCODE
                AND d.ENDDATE IS NULL

            LEFT JOIN DIMLOCATIONS l
                ON l.LOCATIONCODE = jd.LOCATIONCODE 

            LEFT JOIN DIMDATE dt
                ON dt.DATEKEY = jd.HIREDATE
            ;

		v_count := SQL%ROWCOUNT;
        COMMIT;
		DBMS_OUTPUT.PUT_LINE('Number of rows added to FactJobHistory: ' || TO_CHAR(v_count));

		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Error in loading FactJobHistory: ' || SQLERRM);
	END;

END;

--- RUN PROCEDURES TO POPULATE STAGING TABLES ---
    -- Load Departments
    BEGIN
        SP_LOAD_DM_DIMJOBS;
        DBMS_OUTPUT.PUT_LINE(' Extracted: DIMJOBS');
     WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in SP_LOAD_DM_DIMJOBS: ' || SQLERRM);
    END;

    -- Load Jobs
    BEGIN
         SP_LOAD_DM_DIMDEPARTMENTS;;
        DBMS_OUTPUT.PUT_LINE(' LOADED: DIMDEPARTMENTS');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in SP_LOAD_DM_DIMDEPARTMENTS: ' || SQLERRM);
    END;

    -- Load Employees
    BEGIN
        SP_LOAD_DM_DIMEMPLOYEES;
        DBMS_OUTPUT.PUT_LINE(' LOADED: DIMEMPLOYEES');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in SP_LOAD_DM_DIMEMPLOYEES: ' || SQLERRM);
    END;

    -- Load Job History
    BEGIN
        SP_LOAD_DM_FACTJOBHISTORY ;
        DBMS_OUTPUT.PUT_LINE(' LOADED: DIMJOBHISTORY');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' Error in SP_LOAD_DM_FACTJOBHISTORY: ' || SQLERRM);
    END;
/

--- CROSS CHECK ----
select 'DIMDEPARTMENTS' as tablename, count(*) from DIMDEPARTMENTS union
select 'DIMEMPLOYEES' as tablename, count(*) from DIMEMPLOYEES union
select 'DIMLOCATIONS' as tablename, count(*) from DIMLOCATIONS union
select 'DIMDATE' as tablename,count(*) from DIMDATE union
select 'DIMJOBS' as tablename, count(*) from DIMJOBS union
select 'FACTJOBHISTORY' as tablename, count(*) from FACTJOBHISTORY;