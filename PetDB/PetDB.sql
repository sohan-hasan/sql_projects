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
INSERT INTO PetOwner VALUES (101,'Sam','Cook'),(102,'Terry', 'Kim')
GO
CREATE TABLE PetType(
petTypeId int primary key nonclustered not null,
petTypeName varchar(20)
)
GO
INSERT INTO PetType VALUES (201,'Dog'),(202,'Cat'),(203,'Bird')
GO
CREATE TABLE Pet(
petId int primary key not null,
petName varchar(20),
ownerId int references PetOwner(ownerId),
petTypeId int references PetType(petTypeId),
petAge int
)
GO
INSERT INTO Pet VALUES (246,'Rover',101,201,12),(298,'Spot',102,201,2),(341,'Morris',101,202,4),(519,'Tweedy',101,203,4)
GO
CREATE TABLE TreatmentProcedure(
procedureId char(2) primary key not null,
procedureName varchar(30),
)
GO
INSERT INTO TreatmentProcedure VALUES ('01','Rabies Vaccination'),('05','Heart Worm Test'),('08','Tetanus Vaccination'),
('10','Treat Wound'),('12','Eye Wash'),('20','Annul Check Up')
GO
CREATE TABLE PatientRecord(
patientId int Primary key not null,
petId int references Pet(petId),
visitDate date,
procedureId char(2) references TreatmentProcedure(procedureId)
)
GO
INSERT INTO PatientRecord VALUES (1001,246,'2018-01-13','01'),(1002,246,'2018-03-27','10'),(1003,246,'2018-04-02','05'),
(1004,298,'2018-01-21','08'),(1005,298,'2018-03-10','05'),(1006,341,'2018-01-23','01'),(1007,341,'2018-01-13','01'),
(1008,519,'2018-04-30','20'),(1009,519,'2018-04-30','12')
GO
DELETE FROM PatientRecord Where patientId = 1009
GO
UPDATE PatientRecord SET visitDate = '2018-01-24' Where patientId = 1008
GO
DROP TABLE PatientRecord
GO
ALTER TABLE PatientRecord 
DROP COLUMN visitDate
GO
SELECT po.ownerFirstName +' '+po.ownerLastName as 'Owner Name', COUNT(p.petId) as 'Pet Number' FROM Pet as p JOIN PetOwner as po
ON p.ownerId = po.ownerId
GROUP BY po.ownerFirstName, po.ownerLastName
HAVING po.ownerFirstName = 'Sam' and po.ownerLastName ='Cook'
GO
SELECT pet.petId as 'Pet Id', pet.petName as 'Pet Name', pt.petTypeName as 'Pet Type', pet.petAge as 'Age',
po.ownerFirstName+' '+po.ownerLastName as 'Owner',CONVERT(varchar, p.visitDate, 0) as 'Visit Date',tp.procedureId+' - '+tp.procedureName as 'Procedure'  FROM PatientRecord as p JOIN Pet as pet
ON p.petId = pet.petId join TreatmentProcedure as tp
ON p.procedureId = tp.procedureId JOIN PetOwner as po
ON pet.ownerId = po.ownerId JOIN PetType as pt
ON pet.petTypeId = pt.petTypeId 
Where pet.petTypeId in
(SELECT petTypeId FROM PetType Where petTypeName = 'Dog')
GO
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
SELECT * FROM vu_SamCookPetInfo
GO
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
----Check
exec spReadInsertUpdateDeletePetType 'INSERT','505','MONIR','HASAN',''
exec spReadInsertUpdateDeletePetType 'Updated','505','SOHAN','SOHAN',''
exec spReadInsertUpdateDeletePetType 'Delete','505','','',''
DECLARE @totalOwoner int
EXEC spReadInsertUpdateDeletePetType 'COUNT','','','',@totalOwoner output
select @totalOwoner  AS 'Total Pet Owner'
SELECT * FROM PetOwner
GO
CREATE CLUSTERED INDEX IX_petTypeName ON PetType(petTypeName)
GO
CREATE Function fnSetNextVisitDate
(@patientId int)
RETURNS varchar(25)
BEGIN
RETURN(SELECT  CONVERT(varchar, DATEADD(MONTH, 3, visitDate), 0) AS 'Next Visit Date' FROM PatientRecord 
Where patientId = @patientId)
END
GO
SELECT dbo.fnSetNextVisitDate(1004)  as 'Next Visit Date' 
GO
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
SELECT * FROM dbo.fnGetOwnerWisePetInfo('Sam', 'Cook')
GO
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
INSERT INTO PetType VALUES (2124,'Pakhi')
UPDATE PetType SET petTypeName='MON' where petTypeId=203
DELETE FROM PetType where petTypeId=2123
GO

------CTE
WITH TotalTreatmentForApet(petId, totalVisit)
AS
(
SELECT p.petId as 'petId', COUNT(p.petId) as 'totalVisit' FROM PatientRecord as p
GROUP BY p.petId
HAVING p.petId = '246'
)
SELECT po.ownerId, po.ownerFirstName+' '+po.ownerLastName as 'Owner',p.petId as 'Pet ID',p.petName as 'Pet Name',p.petAge as 'Pet Age' , tt.totalVisit as 'Total Visit'  from Pet as p join TotalTreatmentForApet as tt
on p.petId = tt.petId JOIN PetOwner as po
ON p.ownerId = po.ownerId
GO
----SIMPLE CASE
SELECT petId as 'Pet ID', petName as 'Pet Name',petAge as 'Pet Age',
CASE petName
WHEN 'Rover' THEN 'Tiger'
WHEN 'Spot' THEN 'Lion'
ELSE 'Panda' 
END
FROM Pet
----SEARCH CASE
SELECT petId as 'Pet ID', petName as 'Pet Name',petAge as 'Pet Age',
CASE
WHEN  petName = 'Rover' THEN 'Tiger'
WHEN  petName = 'Spot' THEN 'Lion'
ELSE 'Panda' 
END
FROM Pet

GO
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
SELECT * FROM PetOwner
GO
-----NTILE
SELECT petId,NTILE(2) OVER (PARTITION BY petId ORDER BY visitDate Desc) FROM PatientRecord
SELECT petId,NTILE(3) OVER (PARTITION BY petId ORDER BY visitDate Desc) FROM PatientRecord
SELECT petId,NTILE(4) OVER (PARTITION BY petId ORDER BY visitDate Desc) FROM PatientRecord

GO
-----MARGE TABLE
----Table For Marge

CREATE TABLE PetOwnerCopy(
ownerId int primary key not null,
ownerFirstName varchar(20),
ownerLastName varchar(20),
)
GO
INSERT INTO PetOwnerCopy VALUES (102,'Monir', 'Khan')
,(107,'Sabbir', 'Khan'),(108,'Ratul', 'Khan')

----Marge
MERGE PetOwnerCopy as poc
USING PetOwner AS po
ON poc.ownerId = po.ownerId
When MATCHED THEN
UPDATE SET poc.ownerFirstName = po.ownerFirstName, poc.ownerLastName = po.ownerLastName
When NOT MATCHED BY TARGET THEN
INSERT (ownerId, ownerFirstName, ownerLastName) Values(po.ownerId, po.ownerFirstName, po.ownerLastName)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;

select * FROM PetOwnerCopy
select * FROM PetOwner