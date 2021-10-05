USE master
GO
IF DB_ID('DonationDB') is not null
DROP database DonationDB
GO
/*-------------------------------------
      ANS TO THE QUE. NO 1
-------------------------------------*/
CREATE DATABASE DonationDB 
ON(
Name='DonationDB_data_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\DonationDB_data_1.mdf',
Size=25MB,
Maxsize=100MB,
FileGrowth=5%
)
LOG ON(
Name='DonationDB_log_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\DonationDB_log_1.ldf',
Size=2MB,
Maxsize=25MB,
FileGrowth=1%
)
GO
USE DonationDB
GO
CREATE TABLE Donor(
donorId int primary key not null,
donorFname varchar(20),
donorLname varchar(20),
)
----CREATE CLUSTERED INDEX IX_customerName ON Customer(customerName) exec hp_index 't'
GO
INSERT INTO Donor values 
(101,'Peter', 'Mark'),(102,'Victor', 'Gomez'),(103,'Young', 'Lee')
GO
CREATE TABLE Project(
projectId int primary key not null,
projectName varchar(20),
projectDescription varchar(50),
)
GO
INSERT INTO Project values 
(201,'Solor Scholars', 'Powering School with solar panel'),(202,'Creek Cleanup', 'Cleaning up litter and pollutants from Creek'),
(203,'Land Trust', 'Purchasing and preserving land in the watershed'),(204,'Forest Asia', 'Planting tree in Asia')
GO
CREATE TABLE DonationDetails(
donationNo CHAR(4) primary key not null,
donorId int references donor(donorId),
donationAmount money default 0,
donationDate date,
projectId int references Project(projectId)
)
GO
INSERT INTO DonationDetails VALUES 
('DN01','101',200,'01Aug2019',201),('DN02','102',100,'05Aug2019',202),
('DN03','102',100,'05Aug2019',203),('DN04','102',500,'05Aug2019',204),
('DN05','103',150,'06Aug2019',204)
GO
SELECT * FROM DonationDetails
GO
/*-------------------------------------
      ANS TO THE QUE. NO 2
-------------------------------------*/
DELETE FROM DonationDetails Where donationId = 'DN01'
GO
/*-------------------------------------
      ANS TO THE QUE. NO 3
-------------------------------------*/
UPDATE DonationDetails SET donationAmount = 201 Where donationId = 'DN01'
GO
/*-------------------------------------
      ANS TO THE QUE. NO 4
-------------------------------------*/
DROP TABLE DonationDetails
GO
/*-------------------------------------
      ANS TO THE QUE. NO 5
-------------------------------------*/
ALTER TABLE Project
DROP COLUMN projectName
GO
/*-------------------------------------
      ANS TO THE QUE. NO 6
-------------------------------------*/
SELECT projectId,projectName,projectDescription FROM Project 
Where EXISTS
(SELECT * FROM DonationDetails where DonationDetails.projectId = Project.projectId)
GO

/*-------------------------------------
      ANS TO THE QUE. NO 7----FIND THE PROJECT WISE DONER LIST USING HAVING & GROUP BY
-------------------------------------*/
SELECT d.donorFname+' '+d.donorLname AS Donor, p.projectName 
FROM DonationDetails AS dd JOIN Donor AS d
ON dd.donorId = d.donorId JOIN Project AS p
ON dd.projectId = p.projectId
GROUP BY d.donorFname , d.donorLname, p.projectName
Having p.projectName='Forest Asia'
GO
/*-------------------------------------
      ANS TO THE QUE. NO 8
-------------------------------------*/
CREATE VIEW vu_DonorDetails
SELECT dd.donationNo AS 'Donation No', d.donorFname+' '+d.donorLname AS 'Donor Name',
dd.donationAmount as Amount,dd.donationDate AS 'Date',p.projectName AS Project, p.projectDescription as 'Description' 
FROM DonationDetails AS dd JOIN Donor AS d
ON dd.donorId = d.donorId JOIN Project AS p
ON dd.projectId = p.projectId

GO
/*-------------------------------------
      ANS TO THE QUE. NO 9
-------------------------------------*/
CREATE TRIGGER trDonorNameUpperCase_Insert
ON Donor
AFTER INSERT, UPDATE
AS
UPDATE Donor
SET donorFname=UPPER(donorFname),donorLname=UPPER(donorLname)
Where donorId IN (SELECT donorId FROM inserted)
GO

/*-------------------------------------
      ANS TO THE QUE. NO 10
-------------------------------------*/

CREATE Function fnProjectName
(@projectId int)
RETURNS varchar(25)
BEGIN
RETURN(SELECT projectName FROM Project 
Where projectId = @projectId)
END
GO
SELECT dbo.fnProjectName(201)
GO
/*-------------------------------------
      ANS TO THE QUE. NO 11
-------------------------------------*/
CREATE FUNCTION fnGetDonationMoreThan200()
RETURNS TABLE
RETURN(
SELECT dd.donationNo AS 'Donation No', d.donorFname+' '+d.donorLname AS 'Donor Name',
dd.donationAmount as Amount,dd.donationDate AS 'Date',p.projectName AS Project, p.projectDescription as 'Description' 
FROM DonationDetails AS dd JOIN Donor AS d
ON dd.donorId = d.donorId JOIN Project AS p
ON dd.projectId = p.projectId

WHERE dd.donationAmount > 200)
GO
SELECT * FROM dbo.fnGetDonationMoreThan200()
GO

/*-------------------------------------
      ANS TO THE QUE. NO 12
-------------------------------------*/
CREATE TRIGGER trInsertShowError
ON Project
AFTER INSERT
AS 
BEGIN
DECLARE @NAME VARCHAR(20);
SELECT @NAME=I.projectName FROM INSERTED AS I
IF (@NAME='Project')
RAISERROR ('Project Name CANNOT BE Project',11,1)
ROLLBACK TRAN
RETURN
END

/*-------------------------------------
      ANS TO THE QUE. NO 13
-------------------------------------*/
GO
CREATE PROC spReadInsertUpdateDeleteDonor
@taskType varchar(10),
@donorId int,
@donorFName varchar(20),
@donorLName varchar(20),
@donorCount int output
AS
BEGIN

If @taskType='Select'
BEGIN
SELECT * FROM Donor
END
If @taskType='Insert'
BEGIN TRY
Insert Into Donor Values(@donorId,@donorFName,@donorLName)
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE() as ErrorMessege,
ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() AS ErrorLine
END CATCH
If @taskType='Update'
BEGIN 
Update Donor set  donorFname = @donorFName,donorLname = @donorLName Where donorId = @donorId
END
If @taskType='DELETE'
BEGIN 
DELETE FROM Donor Where donorId = @donorId
END
If @taskType='COUNT'
BEGIN 
SELECT @donorCount=COUNT(@donorId) FROM Donor
END
END
GO
----Check
exec spReadInsertUpdateDeleteDonor 'SELECT','','','',''
exec spReadInsertUpdateDeleteDonor 'INSERT','505','MONIR','HASAN',''
exec spReadInsertUpdateDeleteDonor 'Udated','501','SOHAN','SOHAN',''
exec spReadInsertUpdateDeleteDonor 'Delete','213','','',''
DECLARE @totalcustomer int
EXEC spReadInsertUpdateDeleteDonor 'COUNT','','','',@totalcustomer output
select @totalcustomer
SELECT * FROM Custo