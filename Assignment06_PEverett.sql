--*************************************************************************--
-- Title: Assignment06
-- Author: PEverett
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,PEverett,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_PEverett')
	 Begin 
	  Alter Database [Assignment06DB_PEverett] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_PEverett;
	 End
	Create Database Assignment06DB_PEverett;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_PEverett;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Go
Create view vwCategories
With SCHEMABINDING
    as 
    Select CategoryID, CategoryName from dbo.Categories
GO

CREATE view vwEmployees
With SCHEMABINDING
    AS
    Select Employeeid, EmployeeFirstName, EmployeeLastName, ManagerID
        from dbo.Employees
GO

Create View vwInventories
With SCHEMABINDING
    AS
    Select InventoryID, InventoryDate, EmployeeID, ProductID, COUNT
    from dbo.Inventories
GO

GO
Create View vwProducts
With SCHEMABINDING
    as 
    Select ProductID, ProductName, CategoryID, UnitPrice
    From dbo.Products
Go



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select on Categories to PUBLIC
Deny Select on Employees to PUBLIC
Deny Select on Inventories to PUBLIC
Deny Select on Products to PUBLIC
Go
Grant Select on vwCategories to PUBLIC;
Grant Select on vwEmployees to PUBLIC
Grant Select on vwInventories to PUBLIC
Grant Select on vwProducts to PUBLIC
Go 
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
GO
Create view vwProductsByCategory
    as 
Select TOP 10000000 c.CategoryName, p.ProductName, p.UnitPrice
from vwCategories c
    inner join vwProducts p
        on c.CategoryID = p.Categoryid  
ORDER BY CategoryName, ProductName 

GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
GO
Create view vwInventoryByProdbyDates
    as 
    Select TOP 1000000 p.ProductName, i.count, i.InventoryDate
    from vwProducts p
        inner join Inventories i 
            on p.Productid = i.Productid 
    Order by 1,2,3
go 


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
GO

Create view vwInventoryEmployeesByDate
AS 
Select Distinct  Top 1000000
i.InventoryDate, e.EmployeeFirstName + ' ' + EmployeeLastName  as Employee
from vwInventories i
    inner join vwEmployees e 
    on i.EmployeeID = e.EmployeeID
    Order by 1,2

Go


Select * from vwInventoryEmployeesByDate


-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
GO
Create view vwCategoriesByProdbyInventories
AS
Select TOP 1000000 c.CategoryName, 
p.ProductName, 
i.InventoryDate, 
i.COUNT

from vwCategories c inner join vwProducts p 
    on c.categoryid = p.categoryid
inner join vwInventories i 
    on i.ProductID = p.ProductID
ORDER BY 1,2,3,4
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
GO
Create view vwCategoriesByProductsByInventoryByEmployee
AS
Select TOP 1000000 c.CategoryName, 
p.ProductName, 
i.InventoryDate, 
i.COUNT,
e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee

from vwCategories c inner join vwProducts p 
    on c.categoryid = p.categoryid
inner join vwInventories i 
    on i.ProductID = p.ProductID
inner join vwEmployees e 
    on i.EmployeeId = e.EmployeeID
ORDER BY 3,1,2,4
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
GO
Create view vwInventoriesChaiandChangByEmployees
    as 
Select Top 1000000
c.CategoryName,
p.ProductName, 
i.InventoryDate, 
i.Count,
e.EmployeeFirstName + ' ' + EmployeeLastName as Employee

from vwCategories c inner join vwProducts p
    on c.CategoryID = p.CategoryID 
inner join vwInventories i  
    on i.ProductID = p.ProductID 
Inner join vwEmployees e
    on i.EmployeeID = e.EmployeeID
where ProductName in ('Chai','Chang')

GO
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

GO
Create View vwEmployeeManagerRollup
as
select TOP 1000000
e.Employeeid,
 (m.EmployeeFirstName + ' ' + m.EmployeeLastName) as ManagerName, 
(e.EmployeeFirstName + ' ' + e.EmployeeLastName) as EmployeeName
from vwEmployees e 
inner join vwEmployees m 
	on e.ManagerID = m.EmployeeID
	order by 1,2

GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
GO 

Create view vwInventoryByProdByCategoryByEmployees
as 

Select TOP 1000000 
c.CategoryID, 
c.CategoryName, 
P.ProductID, 
p.ProductName, 
p.UnitPrice, 
i.InventoryID, 
i.InventoryDate, 
i.count, 
e.EmployeeID, 
e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee, 
m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager


from vwCategories c 
    inner join vwProducts p 
        on c.CategoryID = p.CategoryID 
    inner join vwInventories i  
        on p.productid = i.productid
   inner join vwEmployees e
    on i.employeeid = e.EmployeeID 
   inner join vwEmployees m 
    on e.employeeid = m.employeeid

GO








-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'

---NOTE I CHANGED THESE TO WHAT I NAMED MINE
Select * From [dbo].[vwCategories]
Select * From [dbo].[vwProducts]
Select * From [dbo].[vwInventories]
Select * From [dbo].[vwEmployees]

Select * From [dbo].[vwProductsByCategory]  --3 vwProductsByCategory
Select * From [dbo].[vwInventoryByProdbyDates]  -4 
Select * From [dbo].[vwInventoryEmployeesByDate]  --5
Select * From [dbo].[vwCategoriesByProdbyInventories] --6
Select * From [dbo].[vwCategoriesByProductsByInventoryByEmployee] --7
Select * From [dbo].[vwInventoriesChaiandChangByEmployees]
Select * From [dbo].[vwEmployeeManagerRollup]
Select * From [dbo].[vwInventoryByProdByCategoryByEmployees]

/***************************************************************************************/