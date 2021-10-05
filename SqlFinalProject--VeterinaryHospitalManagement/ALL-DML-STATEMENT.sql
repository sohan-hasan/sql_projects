USE PetDB
/*-------------------------------------
      ANS TO THE QUE. NO 2
-------------------------------------*/
GO
INSERT INTO PetOwner VALUES (101,'Sam','Cook'),(102,'Terry', 'Kim')
GO
INSERT INTO PetType VALUES (201,'Dog'),(202,'Cat'),(203,'Bird')
GO
INSERT INTO Pet VALUES (246,'Rover',101,201,12),(298,'Spot',102,201,2),(341,'Morris',101,202,4),(519,'Tweedy',101,203,4)
GO
INSERT INTO TreatmentProcedure VALUES ('01','Rabies Vaccination'),('05','Heart Worm Test'),('08','Tetanus Vaccination'),
('10','Treat Wound'),('12','Eye Wash'),('20','Annul Check Up')
GO
INSERT INTO PatientRecord VALUES (1001,246,'2018-01-13','01'),(1002,246,'2018-03-27','10'),(1003,246,'2018-04-02','05'),
(1004,298,'2018-01-21','08'),(1005,298,'2018-03-10','05'),(1006,341,'2018-01-23','01'),(1007,341,'2018-01-13','01'),
(1008,519,'2018-04-30','20'),(1009,519,'2018-04-30','12')
GO
/*-------------------------------------
      ANS TO THE QUE. NO 3
-------------------------------------*/
DELETE FROM PatientRecord Where patientId = 1009
GO
/*-------------------------------------
      ANS TO THE QUE. NO 4
-------------------------------------*/
UPDATE PatientRecord SET visitDate = '2018-01-24' Where patientId = 1008
GO
/*-------------------------------------
      ANS TO THE QUE. NO 7
-------------------------------------*/
SELECT po.ownerFirstName +' '+po.ownerLastName as 'Owner Name', COUNT(p.petId) as 'Pet Number' FROM Pet as p JOIN PetOwner as po
ON p.ownerId = po.ownerId
GROUP BY po.ownerFirstName, po.ownerLastName
HAVING po.ownerFirstName = 'Sam' and po.ownerLastName ='Cook'
GO
/*-------------------------------------
      ANS TO THE QUE. NO 8
-------------------------------------*/
SELECT pet.petId as 'Pet Id', pet.petName as 'Pet Name', pt.petTypeName as 'Pet Type', pet.petAge as 'Age',
po.ownerFirstName+' '+po.ownerLastName as 'Owner',CONVERT(varchar, p.visitDate, 0) as 'Visit Date',tp.procedureId+' - '+tp.procedureName as 'Procedure'  FROM PatientRecord as p JOIN Pet as pet
ON p.petId = pet.petId join TreatmentProcedure as tp
ON p.procedureId = tp.procedureId JOIN PetOwner as po
ON pet.ownerId = po.ownerId JOIN PetType as pt
ON pet.petTypeId = pt.petTypeId 
Where pet.petTypeId in
(SELECT petTypeId FROM PetType Where petTypeName = 'Dog')
GO
/*-------------------------------------
      ANS TO THE QUE. NO 17-CTE
-------------------------------------*/
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
/*-------------------------------------
      ANS TO THE QUE. NO 18-CASE
-------------------------------------*/
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
/*-------------------------------------
      ANS TO THE QUE. NO 20
-------------------------------------*/
-----NTILE
SELECT petId,NTILE(2) OVER (PARTITION BY petId ORDER BY visitDate Desc) FROM PatientRecord
SELECT petId,NTILE(3) OVER (PARTITION BY petId ORDER BY visitDate Desc) FROM PatientRecord
SELECT petId,NTILE(4) OVER (PARTITION BY petId ORDER BY visitDate Desc) FROM PatientRecord
GO
/*-------------------------------------
      ANS TO THE QUE. NO 21-(b)
-------------------------------------*/
----target Table Data
INSERT INTO PetOwnerCopy VALUES (102,'Monir', 'Khan')
,(107,'Sabbir', 'Khan'),(108,'Ratul', 'Khan')
GO
MERGE PetOwnerCopy as poc
USING PetOwner AS po
ON poc.ownerId = po.ownerId
When MATCHED THEN
UPDATE SET poc.ownerFirstName = po.ownerFirstName, poc.ownerLastName = po.ownerLastName
When NOT MATCHED BY TARGET THEN
INSERT (ownerId, ownerFirstName, ownerLastName) Values(po.ownerId, po.ownerFirstName, po.ownerLastName)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;