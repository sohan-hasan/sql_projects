USE master
GO
IF DB_ID('PetDB') is not null
DROP database PetDB
GO
/*-------------------------------------
      ANS TO THE QUE. NO 1
-------------------------------------*/
CREATE DATABASE PetDB 
ON(
Name='PetDB_data_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\PetDB_data_1.mdf',
Size=25MB,
Maxsize=100MB,
FileGrowth=5%
)
LOG ON(
Name='PetDB_log_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\PetDB_data_1.ldf',
Size=2MB,
Maxsize=25MB,
FileGrowth=1%
)
GO
USE PetDB
GO
CREATE TABLE PetOwner(
ownerId int primary key not null,
ownerFirstName varchar(20),
ownerLastName varchar(20),
)
GO
CREATE TABLE PetType(
petTypeId int primary key nonclustered not null,
petTypeName varchar(20)
)
GO
CREATE TABLE Pet(
petId int primary key not null,
petName varchar(20),
ownerId int references PetOwner(ownerId),
petTypeId int references PetType(petTypeId),
petAge int
)
GO
CREATE TABLE TreatmentProcedure(
procedureId char(2) primary key not null,
procedureName varchar(30)
)
GO
CREATE TABLE PatientRecord(
patientId int Primary key not null,
petId int references Pet(petId),
visitDate date,
procedureId char(2) references TreatmentProcedure(procedureId)
)
GO
/*-------------------------------------
      ANS TO THE QUE. NO 5
-------------------------------------*/
DROP TABLE PatientRecord
/*-------------------------------------
      ANS TO THE QUE. NO 6
-------------------------------------*/
ALTER TABLE PatientRecord 
DROP COLUMN visitDate
GO
/*-------------------------------------
      ANS TO THE QUE. NO 9
-------------------------------------*/
CREATE VIEW vu_SamCookPetInfo AS
SELECT pet.petId as 'Pet Id', pet.petName as 'Pet Name', pt.petTypeName as 'Pet Type', pet.petAge as 'Age',
po.ownerFirstName+' '+po.ownerLastName as 'Owner', CONVERT(varchar, p.visitDate, 0) as 'Visit Date',tp.procedureId+' - '+tp.procedureName as 'Procedure'  
FROM PatientRecord as p JOIN Pet as pet
ON p.petId = pet.petId join TreatmentProcedure as tp
ON p.procedureId = tp.procedureId JOIN PetOwner as po
ON pet.ownerId = po.ownerId JOIN PetType as pt
ON pet.petTypeId = pt.petTypeId 
Where po.ownerId in
(SELECT ownerId FROM PetOwner Where ownerFirstName = 'Sam' and ownerLastName = 'Cook')
GO
/*-------------------------------------
      ANS TO THE QUE. NO 10 & 15 & 16
-------------------------------------*/
CREATE PROC spReadInsertUpdateDeletePetType
@taskType varchar(10),
@ownerId int,
@ownerFirstName varchar(20),
@ownerLastName varchar(20),
@petCount int output
AS
BEGIN
If @taskType='Insert'
BEGIN TRY
BEGIN TRAN
Insert Into PetOwner Values(@ownerId,@ownerFirstName,@ownerLastName)
COMMIT TRAN
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE() AS ERRORMESSAGE,
ERROR_NUMBER()AS ERRORNUMBER,
ERROR_LINE()AS ERRORLINE,
ERROR_SEVERITY() AS SEVERITY,
ERROR_STATE() AS ERRORSTATE
ROLLBACK TRAN
END CATCH
If @taskType='Updated'
BEGIN 
Update PetOwner set  ownerFirstName = @ownerFirstName,ownerLastName = @ownerLastName Where ownerId = @ownerId
END
If @taskType='DELETE'
BEGIN 
DELETE FROM PetOwner Where ownerId = @OwnerId
END
If @taskType='COUNT'
BEGIN 
SELECT @petCount = COUNT(@ownerId) FROM PetOwner
END
END
GO
/*-------------------------------------
      ANS TO THE QUE. NO 11
-------------------------------------*/
CREATE CLUSTERED INDEX IX_petTypeName ON PetType(petTypeName)
GO
/*---------------------------------------------
      ANS TO THE QUE. NO 12--Scalar Function
-----------------------------------------------*/
CREATE Function fnSetNextVisitDate
(@patientId int)
RETURNS varchar(25)
BEGIN
RETURN(SELECT  CONVERT(varchar, DATEADD(MONTH, 3, visitDate), 0) AS 'Next Visit Date' FROM PatientRecord 
Where patientId = @patientId)
END
GO
/*----------------------------------------------------
      ANS TO THE QUE. NO 13---Table Valued Function
-------------------------------------------------------*/
CREATE FUNCTION fnGetOwnerWisePetInfo(@ownerFirstName varchar(20), @ownerLastName varchar(20))
RETURNS TABLE
RETURN(
SELECT pet.petId as 'Pet Id', pet.petName as 'Pet Name', pt.petTypeName as 'Pet Type', pet.petAge as 'Age',
po.ownerFirstName+' '+po.ownerLastName as 'Owner', CONVERT(varchar, p.visitDate, 0) as 'Visit Date',tp.procedureId+' - '+tp.procedureName as 'Procedure'  
FROM PatientRecord as p JOIN Pet as pet
ON p.petId = pet.petId join TreatmentProcedure as tp
ON p.procedureId = tp.procedureId JOIN PetOwner as po
ON pet.ownerId = po.ownerId JOIN PetType as pt
ON pet.petTypeId = pt.petTypeId 
Where po.ownerId in
(SELECT ownerId FROM PetOwner where po.ownerFirstName = @ownerFirstName and po.ownerLastName = @ownerLastName)
)
GO
/*-------------------------------------
      ANS TO THE QUE. NO 14--Trigger
-------------------------------------*/
CREATE TRIGGER trPetTypeUpdateInsert
ON PetType
AFTER INSERT, UPDATE
AS
BEGIN
UPDATE PetType
SET petTypeName=UPPER(petTypeName)
Where petTypeId IN (SELECT petTypeId FROM inserted)
SELECT * FROM INSERTED
END
GO
CREATE TRIGGER trPetTypeDeleted
ON PetType
AFTER DELETE
AS
BEGIN
SELECT * FROM DELETED
END
GO
/*-------------------------------------
       ANS TO THE QUE. NO 15
-------------------------------------

	PLEASE CHECK ANS TO THE QUE NO 10
*/
/*-------------------------------------
      ANS TO THE QUE. NO 16
-------------------------------------

   PLEASE CHECK ANS TO THE QUE NO 10

*/

/*-------------------------------------
      ANS TO THE QUE. NO 19
-------------------------------------*/
CREATE TABLE #ForCursorsTable(
ownerId int not null,
ownerFirstName varchar(20),
ownerLastName varchar(20)
)
GO
INSERT INTO #ForCursorsTable values (103,'Kiron', 'Khan')
INSERT INTO #ForCursorsTable values (104,'Mone', 'KIM') 
INSERT INTO #ForCursorsTable values (105,'Jon', 'Din')
Declare @id int, @Fname varchar(20), @Lname varchar(20)
Declare OwnerCursor Cursor FOR
SELECT * FROM #ForCursorsTable
OPEN OwnerCursor
FETCH NEXT FROM OwnerCursor INTO @ID, @Fname, @Lname
WHILE (@@FETCH_STATUS=0)
BEGIN
INSERT INTO PetOwner Values (@ID, @Fname, @Lname)
FETCH NEXT FROM OwnerCursor INTO @ID, @Fname, @Lname
END
CLOSE OwnerCursor
DEALLOCATE OwnerCursor
GO
/*-------------------------------------
      ANS TO THE QUE. NO 21-(a)
-------------------------------------*/
----Table For Marge

CREATE TABLE PetOwnerCopy(
ownerId int primary key not null,
ownerFirstName varchar(20),
ownerLastName varchar(20),
)