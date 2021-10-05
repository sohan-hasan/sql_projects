Use master
Go
If DB_ID('ProductDB') is not null
Drop Database ProductDB

/*ANSWER TO THE QUESTION NUMBER 18*/

Create Database ProductDB
on 
(
Name='ProductDB_Data_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\ProductDB_Data_1.mdf',
Size=25MB,
Maxsize=100MB,
FileGrowth=5%
)
Log on
(
Name='ProductDB_Log_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\ProductDB_Log_1.ldf',
Size=2MB,
Maxsize=25MB,
FileGrowth=1%
)

Go

use productDB

Create Table Item 
(
		itemId int not null,
		itemName varchar(20),
		colorId int not null,
		primary key(itemId, colorId)
)

Go
Insert into Item values
		(1,'Denim Shirt',101),
		(2,'T-Shirt',102),
		(3,'Jeans Shorts',102),
		(4,'Fatua',103),
		(5,'Shirt',102)
Go
Create Table Color
(
		colorId int primary key not null,
		colorName varchar (20)
)

Go
Create Table Lot
(
		lotName varchar(10),
		itemId int,
		colorId int,
		price money default 0,
		vat decimal(3,2) default 0,
		quantity int default 0,
		unitPriceWithVat int,
		FOREIGN KEY(itemId, colorId) REFERENCES Item(itemId, colorId)
)

GO
ALTER TABLE dbo.Lot
  
Go

Insert into Lot values
		('Lot-1',1,15000.00,0.15,12,1437),
		('Lot-2',2,14500.00,0.15,12,1389),
		('Lot-3',3,6000.00,0.15,12,575),
		('Lot-4',4,12000.00,0.15,12,1150),
		('Lot-5',5,24000.00,0.15,12,2300)

Insert into Color values
	(101,'Black'),(102,'Blue'),(103,'Red')

Go