--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: ZacharyLarmer
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2024-12-08,ZacharyLarmer,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_ZacharyLarmer')
	 Begin 
	  Alter Database [ITFnd130FinalDB_ZacharyLarmer] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_ZacharyLarmer;
	 End
	Create Database ITFnd130FinalDB_ZacharyLarmer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_ZacharyLarmer;

-- Create Tables (Review Module 01)-- 

-- Create table with all identifying course information

CREATE TABLE Courses
	(
		CourseID INT IDENTITY(1,1) NOT NULL,
		CourseName NVARCHAR(100) NOT NULL,
		CourseStartDate DATETIME NULL,
		CourseEndDate DATETIME NULL,
		CourseStartTime TIME NULL,
		CourseEndTime TIME NULL,
		CourseDayOfWeek NVARCHAR(100) NUll,
		CourseCurrentPrice MONEY NULL
	);

GO

-- Create table with all identifying student information

CREATE TABLE Students
	(
		StudentID INT IDENTITY(1,1) NOT NULL,
		StudentFirstName NVARCHAR(100) NOT NULL,
		StudentLastName NVARCHAR(100) NOT NULL,
		StudentNumber NVARCHAR(100) NOT NULL,
		StudentEmail NVARCHAR(100) NOT NULL,
		StudentPhone NVARCHAR(10) NOT NULL,
		StudentAddress NVARCHAR(100) NOT NULL,
		StudentCity NVARCHAR(100) NOT NULL,
		StudentState NVARCHAR(2) NOT NULL,
		StudentZip NVARCHAR (10) NOT NULL
	);

GO

-- Create table with all enrollment information (includes courseID from courses table & StudentID from students table)

CREATE TABLE Enrollment
	(
		EnrollmentID INT IDENTITY(1,1) NOT NULL,
		StudentID INT NOT NULL,
		CourseID INT NOT NULL,
		EnrollmentDateTime DATETIME NOT NULL,
		EnrollmentPaid MONEY NOT NULL
	);

GO

-- Add Constraints (Review Module 02) -- 

-- Add constraints to Courses table

-- CourseID gets Primary Key constraint

ALTER TABLE Courses
	ADD CONSTRAINT pkCourses 
		PRIMARY KEY (CourseID);

GO

-- CourseName gets Unique constraint

ALTER TABLE Courses
	ADD CONSTRAINT uCourseName 
		UNIQUE (CourseName);

GO 

-- CourseStartDate gets Check constraint - Can't be later than end date

ALTER TABLE Courses
	ADD CONSTRAINT cCourseStartDate 
		CHECK (CourseStartDate < CourseEndDate);
	
GO

-- CourseEndDate gets Check constraint - Can't be before start date

ALTER TABLE Courses 
	ADD CONSTRAINT cCourseEndDate
		CHECK (CourseEndDate > CourseStartDate);

GO         

-- CourseStartTime gets Check constraint - Can't be later than end time

ALTER TABLE Courses
    ADD CONSTRAINT cCourseStartTime
        CHECK (CourseStartTime < CourseEndTime);

GO

-- CourseEndTime gets Check constraint - Can't be early than start time

ALTER TABLE Courses
    ADD CONSTRAINT cCourseEndTime
        CHECK (CourseEndTime > CourseStartTime);

GO

-- CourseCurrentPrice gets Check constraint - price must be >= 0

ALTER TABLE Courses
    ADD CONSTRAINT cCourseCurrentPrice
        CHECK (CourseCurrentPrice >= 0);

GO

-- Add constraints to Students table

-- StudentID gets Primary Key constraint

ALTER TABLE Students
    ADD CONSTRAINT pkStudents
        PRIMARY KEY (StudentID);

GO

-- StudentNumber gets Unique constraint

ALTER TABLE Students
    ADD CONSTRAINT uStudentNumber
        UNIQUE (StudentNumber);

GO

-- StudentEmail gets Unique constraint

ALTER TABLE Students
    ADD CONSTRAINT uStudentEmail
        UNIQUE (StudentEmail);

GO

-- StudentEmail gets Check constraint - must match email pattern

ALTER TABLE Students
    ADD CONSTRAINT cStudentEmail
        CHECK (StudentEmail LIKE '%_@__%.__%');

GO

-- StudentPhone gets Check constraint - must be vailid phone number (10 numbers between [0-9])

ALTER TABLE Students
    ADD CONSTRAINT cStudentPhone
        CHECK (StudentPhone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
    
GO

-- StudentZip gets Check constraint - must be valid zip (5 numbers [0-9] OR 9 numbers [0-9] with - after 5th number)

ALTER TABLE Students
    ADD CONSTRAINT cStudentZip
        CHECK (StudentZip LIKE '[0-9][0-9][0-9][0-9][0-9]'
                OR StudentZip LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');

GO

-- Add constraints to Enrollment table

-- EnrollmentID gets Primary Key constraint

ALTER TABLE Enrollment
    ADD CONSTRAINT pkEnrollment
        PRIMARY KEY (EnrollmentID);

GO

-- StudentID gets Foreign Key constraint (references StudentID in Students table)

ALTER TABLE Enrollment
    ADD CONSTRAINT fkStudentID
        FOREIGN KEY (StudentID)
            REFERENCES Students(StudentID);

GO

-- CourseID gets Foreign Key constraint (references CourseID in Courses table)

ALTER TABLE Enrollment
    ADD CONSTRAINT fkCourseID
        FOREIGN KEY (CourseID)
            REFERENCES Courses(CourseID);

GO

-- EnrollmentDateTime get Check constraint - must be before CourseStartDate (must create function to check against different table)

CREATE FUNCTION dbo.fCourseStartDate (@CourseID INT)
RETURNS DATETIME
AS
    BEGIN
        RETURN (SELECT CourseStartDate
                FROM Courses
                WHERE Courses.CourseID = @CourseID);
    END
GO

ALTER TABLE Enrollment
    ADD CONSTRAINT cEnrollmentDateTime
        CHECK (EnrollmentDateTime < dbo.fCourseStartDate(CourseID));

GO

-- EnrollmentPaid gets Check Contstraint - must be >= 0

ALTER TABLE Enrollment
    ADD CONSTRAINT cEnrollmentPaid
        CHECK (EnrollmentPaid >= 0);

GO

-- Enrollment Unique constraint on student AND course ID. 

ALTER TABLE Enrollment
    ADD CONSTRAINT uStudentCourse
        UNIQUE (StudentID, CourseID);

GO

-- Add Views (Review Module 03 and 06) -- 

-- Create Base Views

CREATE VIEW vCourses
    AS
        SELECT CourseID,
               CourseName,
               CourseStartDate,
               CourseEndDate,
               CourseStartTime,
               CourseEndTime,
               CourseDayOfWeek,
               CourseCurrentPrice
        FROM Courses;

GO

CREATE VIEW vStudents
    AS 
        SELECT StudentID,
               StudentFirstName,
               StudentLastName,
               StudentNumber,
               StudentEmail,
               StudentPhone,
               StudentAddress,
               StudentCity,
               StudentState,
               StudentZip
        FROM Students;

GO    

CREATE VIEW vEnrollment
    AS
        SELECT EnrollmentID,
               StudentID,
               CourseID,
               EnrollmentDateTime,
               EnrollmentPaid
        FROM Enrollment;

GO

CREATE VIEW vStudentCourseEnrollment
    AS
        SELECT
            E.EnrollmentID, 
            E.EnrollmentDateTime,
            E.EnrollmentPaid,
            S.StudentID,
            S.StudentFirstName,
            S.StudentLastName,
            S.StudentNumber,
            S.StudentEmail,
            S.StudentPhone,
            S.StudentAddress,
            S.StudentCity,
            S.StudentState,
            S.StudentZip,
            C.CourseID,
            C.CourseName,
            C.CourseStartDate,
            C.CourseEndDate,
            C.CourseStartTime,
            C.CourseEndTime,
            C.CourseDayOfWeek,
            C.CourseCurrentPrice
        FROM Students AS S JOIN Enrollment AS E
            ON S.StudentID = E.StudentID
        JOIN Courses AS C
            ON E.CourseID = C.CourseID;

GO

--< Test Tables by adding Sample Data >--  

INSERT INTO Courses 
    (
        CourseName, 
        CourseStartDate, 
        CourseEndDate, 
        CourseStartTime, 
        CourseEndTime, 
        CourseDayOfWeek, 
        CourseCurrentPrice
    )
VALUES
    (
       'SQL1 - Winter 2017',
       '1/10/2017',
       '1/24/2017',
       '18:50:00',
       '20:50:00',
       'T',
       $399
    ),
    (
       'SQL2 - Winter 2017',
       '1/31/2017',
       '2/14/2017',
       '18:00:00',
       '20:50:00',
       'T',
       $399 
    );

GO

INSERT INTO Students
    (
		StudentFirstName,
		StudentLastName,
		StudentNumber,
		StudentEmail,
		StudentPhone,
		StudentAddress,
		StudentCity,
		StudentState,
		StudentZip
    )
VALUES
    (
        'Bob',
        'Smith',
        'B-Smith-071',
        'Bsmith@HipMail.com',
        '2061112222',
        '123 Main St.',
        'Seattle',
        'WA',
        '98001'
    ),
    (
        'Sue',
        'Jones',
        'S-Jones-003',
        'SueJones@Yayou.com',
        '2062314321',
        '333 1st Ave.',
        'Seattle',
        'WA',
        '98001'
    );

GO

INSERT INTO Enrollment
    (
		StudentID,
		CourseID,
		EnrollmentDateTime,
		EnrollmentPaid 
    )
VALUES
    (
        1,
        1,
        '1/3/2017',
        $399
    ),
    (
        1,
        2,
        '1/12/17',
        $399
    ),
    (
        2,
        1,
        '12/14/16',
        $349
    ),
    (
        2,
        2,
        '12/14/16',
        $349
    );

GO

-- Add Stored Procedures (Review Module 04 and 08) --

-- Courses Insert, Update & Delete Procedures

GO

CREATE PROCEDURE pInsertCourses
    (
		@CourseName NVARCHAR(100),
		@CourseStartDate DATETIME,
		@CourseEndDate DATETIME,
		@CourseStartTime TIME,
		@CourseEndTime TIME,
		@CourseDayOfWeek NVARCHAR(100),
		@CourseCurrentPrice MONEY
    )
-- Author: ZLarmer
-- DESC: Processes inserts of data to the Courses table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                INSERT INTO Courses 
                    (
                        CourseName, 
                        CourseStartDate, 
                        CourseEndDate, 
                        CourseStartTime, 
                        CourseEndTime, 
                        CourseDayOfWeek, 
                        CourseCurrentPrice
                    )
                VALUES
                    (
                        @CourseName, 
                        @CourseStartDate, 
                        @CourseEndDate, 
                        @CourseStartTime, 
                        @CourseEndTime, 
                        @CourseDayOfWeek, 
                        @CourseCurrentPrice
                    )
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

CREATE PROCEDURE pUpdateCourses
    (
        @CourseID INT,
		@CourseName NVARCHAR(100),
		@CourseStartDate DATETIME,
		@CourseEndDate DATETIME,
		@CourseStartTime TIME,
		@CourseEndTime TIME,
		@CourseDayOfWeek NVARCHAR(100),
		@CourseCurrentPrice MONEY
    )
-- Author: ZLarmer
-- DESC: Processes updates to data in the Courses table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                UPDATE Courses
                SET
                    CourseName = @CourseName,
                    CourseStartDate = @CourseStartDate,
                    CourseEndDate = @CourseEndDate,
                    CourseStartTime = @CourseStartTime,
                    CourseEndTime = @CourseEndTime,
                    CourseDayOfWeek = @CourseDayOfWeek,
                    CourseCurrentPrice = @CourseCurrentPrice
                WHERE CourseID = @CourseID
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

CREATE PROCEDURE pDeleteCourses
    (
        @CourseID INT
    )
-- Author: ZLarmer
-- DESC: Processes deltes to data in the Courses table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                DELETE FROM Courses 
                WHERE CourseID = @CourseID
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

-- Students Insert, Update & Delete Procedures

GO

CREATE PROCEDURE pInsertStudents
    (
        @StudentFirstName NVARCHAR(100),
        @StudentLastName NVARCHAR(100),
        @StudentNumber NVARCHAR(100),
        @StudentEmail NVARCHAR(100),
        @StudentPhone NVARCHAR(10),
        @StudentAddress NVARCHAR(100),
        @StudentCity NVARCHAR(100),
        @StudentState NVARCHAR(2),
        @StudentZip NVARCHAR(10)
    )
-- Author: ZLarmer
-- DESC: Processes inserts of data to the Students table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                INSERT INTO Students
                    (
                        StudentFirstName,
                        StudentLastName,
                        StudentNumber,
                        StudentEmail,
                        StudentPhone,
                        StudentAddress,
                        StudentCity,
                        StudentState,
                        StudentZip
                    )
                VALUES
                    (
                        @StudentFirstName,
                        @StudentLastName,
                        @StudentNumber,
                        @StudentEmail,
                        @StudentPhone,
                        @StudentAddress,
                        @StudentCity,
                        @StudentState,
                        @StudentZip
                    )
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

CREATE PROCEDURE pUpdateStudents
    (
        @StudentID INT,
        @StudentFirstName NVARCHAR(100),
        @StudentLastName NVARCHAR(100),
        @StudentNumber NVARCHAR(100),
        @StudentEmail NVARCHAR(100),
        @StudentPhone NVARCHAR(10),
        @StudentAddress NVARCHAR(100),
        @StudentCity NVARCHAR(100),
        @StudentState NVARCHAR(2),
        @StudentZip NVARCHAR(10)
    )
-- Author: ZLarmer
-- DESC: Processes updates to data in the Students table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                UPDATE Students
                SET
                    StudentFirstName = @StudentFirstName,
                    StudentLastName = @StudentLastName,
                    StudentNumber = @StudentNumber,
                    StudentEmail = @StudentEmail,
                    StudentPhone = @StudentPhone,
                    StudentAddress = @StudentAddress,
                    StudentCity = @StudentCity,
                    StudentState = @StudentState,
                    StudentZip = @StudentZip
                WHERE StudentID = @StudentID
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

CREATE PROCEDURE pDeleteStudents
    (
        @StudentID INT
    )
-- Author: ZLarmer
-- DESC: Processes deletes to data in the Students table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                DELETE FROM Students 
                WHERE StudentID = @StudentID
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

-- Enrollment Insert, Update & Delete Procedures

GO

CREATE PROCEDURE pInsertEnrollment
    (
        @StudentID INT,
        @CourseID INT,
        @EnrollmentDateTime DATETIME,
        @EnrollmentPaid MONEY
    )
-- Author: ZLarmer
-- DESC: Processes inserts of data to the Enrollment table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                INSERT INTO Enrollment
                    (
                        StudentID,
                        CourseID,
                        EnrollmentDateTime,
                        EnrollmentPaid
                    )
                VALUES
                    (
                        @StudentID,
                        @CourseID,
                        @EnrollmentDateTime,
                        @EnrollmentPaid
                    )
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

CREATE PROCEDURE pUpdateEnrollment
    (
        @EnrollmentID INT,
        @StudentID INT,
        @CourseID INT,
        @EnrollmentDateTime DATETIME,
        @EnrollmentPaid MONEY
    )
-- Author: ZLarmer
-- DESC: Processes updates to data in the Enrollment table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                UPDATE Enrollment
                SET
                    StudentID = @StudentID,
                    CourseID = @CourseID,
                    EnrollmentDateTime = @EnrollmentDateTime,
                    EnrollmentPaid = @EnrollmentPaid
                WHERE EnrollmentID = @EnrollmentID
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

CREATE PROCEDURE pDeleteEnrollment
    (
        @EnrollmentID INT
    )
-- Author: ZLarmer
-- DESC: Processes deletes to data in the Enrollment table
-- Change Log: When, Who, What
-- 12/9/24, ZLarmer, Create Proc
    AS
        BEGIN
            DECLARE @RC INT = 0;
        BEGIN TRY
            BEGIN TRANSACTION
                DELETE FROM Enrollment
                WHERE EnrollmentID = @EnrollmentID
            COMMIT TRANSACTION
            SET @RC = +1
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            PRINT Error_Message()
            SET @RC = -1
        END CATCH
        RETURN @RC;
        END

GO

-- Set Permissions --
GO
-- Courses Table Permissions
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Courses TO PUBLIC;
GRANT SELECT ON dbo.vCourses TO PUBLIC;
GRANT EXECUTE ON dbo.pInsertCourses TO PUBLIC;
GRANT EXECUTE ON dbo.pUpdateCourses TO PUBLIC;
GRANT EXECUTE ON dbo.pDeleteCourses TO PUBLIC;

-- Students Table Permissions
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Students TO PUBLIC;
GRANT SELECT ON dbo.vStudents TO PUBLIC;
GRANT EXECUTE ON dbo.pInsertStudents TO PUBLIC;
GRANT EXECUTE ON dbo.pUpdateStudents TO PUBLIC;
GRANT EXECUTE ON dbo.pDeleteStudents TO PUBLIC;

-- Enrollment Table Permissions
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Enrollment TO PUBLIC;
GRANT SELECT ON dbo.vEnrollment TO PUBLIC;
GRANT EXECUTE ON dbo.pInsertEnrollment TO PUBLIC;
GRANT EXECUTE ON dbo.pUpdateEnrollment TO PUBLIC;
GRANT EXECUTE ON dbo.pDeleteEnrollment TO PUBLIC;

GO

--< Test Sprocs >-- 

GO

DECLARE @Status INT;
DECLARE @NewCourseID INT;
DECLARE @NewStudentID INT;
DECLARE @NewEnrollmentID INT;

-- Test for Insert Courses
EXECUTE @Status = pInsertCourses
        @CourseName = 'Test Course1', 
        @CourseStartDate = '1/30/2025', 
        @CourseEndDate = '5/30/2025', 
        @CourseStartTime = '18:00:00', 
        @CourseEndTime = '20:50:00', 
        @CourseDayOfWeek = 'W', 
        @CourseCurrentPrice = $399;
SELECT CASE @Status
    WHEN +1 THEN 'Insert to Courses was successful'
    WHEN -1 THEN 'Insert to Courses failed'
END AS [Status];
SET @NewCourseID = @@IDENTITY;
SELECT * FROM vCourses WHERE CourseID = @NewCourseID;

-- Test For Insert Students

EXECUTE @Status = pInsertStudents
        @StudentFirstName = 'Jim',
        @StudentLastName = 'Jam',
        @StudentNumber = 'J-Jam-088',
        @StudentEmail = 'JJam@gmail.com',
        @StudentPhone = '9708849921',
        @StudentAddress = '999 Test Street',
        @StudentCity = 'Portland',
        @StudentState = 'OR',
        @StudentZip = '97201'
SELECT CASE @Status
    WHEN +1 THEN 'Insert to Students was successful'
    WHEN -1 THEN 'Insert to Student failed'
END AS [Status];
SET @NewStudentID = @@IDENTITY;
SELECT * FROM vStudents WHERE StudentID = @NewStudentID;

-- Test for insert Enrollment

EXECUTE @Status = pInsertEnrollment
        @StudentID = 3,
        @CourseID = 3,
        @EnrollmentDateTime = '1/5/2025 12:00:00',
        @EnrollmentPaid = $399
SELECT CASE @Status
    WHEN +1 THEN 'Insert to Enrollment was successful'
    WHEN -1 THEN 'Insert to Enrollment failed'
END AS [Status];
SET @NewEnrollmentID = @@IDENTITY;
SELECT * FROM vEnrollment WHERE EnrollmentID = @NewEnrollmentID;

-- Test Update for Courses

EXECUTE @Status = pUpdateCourses
        @CourseID = 3,
        @CourseName = 'New Name', 
        @CourseStartDate = '1/30/2025', 
        @CourseEndDate = '5/30/2025', 
        @CourseStartTime = '18:00:00', 
        @CourseEndTime = '20:50:00', 
        @CourseDayOfWeek = 'W', 
        @CourseCurrentPrice = $399;
SELECT CASE @Status
    WHEN +1 THEN 'Update to Courses was successful'
    WHEN -1 THEN 'Update to Courses failed'
END AS [Status];
SELECT * FROM vCourses WHERE CourseID = 3;

-- Test Update for Students

EXECUTE @Status = pUpdateStudents
        @StudentID = 3,
        @StudentFirstName = 'Jim',
        @StudentLastName = 'James',
        @StudentNumber = 'J-Jam-088',
        @StudentEmail = 'JJam@gmail.com',
        @StudentPhone = '9708849921',
        @StudentAddress = '999 Test Street',
        @StudentCity = 'Portland',
        @StudentState = 'OR',
        @StudentZip = '97201'
SELECT CASE @Status
    WHEN +1 THEN 'Update to Students was successful'
    WHEN -1 THEN 'Update to Student failed'
END AS [Status];
SELECT * FROM vStudents WHERE StudentID = 3;

-- Test update for Enrollment

EXECUTE @Status = pUpdateEnrollment
        @EnrollmentID = 5,
        @StudentID = 3,
        @CourseID = 3,
        @EnrollmentDateTime = '1/5/2025 12:00:00',
        @EnrollmentPaid = $200
SELECT CASE @Status
    WHEN +1 THEN 'Update to Enrollment was successful'
    WHEN -1 THEN 'Update to Enrollment failed'
END AS [Status];
SELECT * FROM vEnrollment WHERE EnrollmentID = 5;

-- Test Delete Enrollment

EXECUTE @Status = pDeleteEnrollment
        @EnrollmentID = 5
SELECT CASE @Status
    WHEN +1 THEN 'Delete From Enrollment was successful'
    WHEN -1 THEN 'Delete From Enrollment failed'
END AS [Status];
SELECT * FROM vEnrollment WHERE EnrollmentID = 5;

-- Test Delete From Courses

EXECUTE @Status = pDeleteCourses
        @CourseID = 3
SELECT CASE @Status
    WHEN +1 THEN 'Delete From Courses was successful'
    WHEN -1 THEN 'Delete From Courses failed'
END AS [Status];
SELECT * FROM vCourses WHERE CourseID = 3;

-- Test Delete for Students

EXECUTE @Status = pDeleteStudents
        @StudentID = 3
SELECT CASE @Status
    WHEN +1 THEN 'Delete From Students was successful'
    WHEN -1 THEN 'Delete From Student failed'
END AS [Status];
SELECT * FROM vStudents WHERE StudentID = 3;

-- Select all Tables and Views

SELECT * FROM Courses;
SELECT * FROM Students;
SELECT * FROM Enrollment;
SELECT * FROM vCourses;
SELECT * FROM vStudents;
SELECT * FROM vEnrollment;
SELECT * FROM vStudentCourseEnrollment;

--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/