/***********************
 DIMENSION TABLES
***********************/

-- SUPPLIERS DIMENSION
CREATE TABLE dbo.DimSuppliers (
    SupplierSK INT IDENTITY(1,1) PRIMARY KEY,
    AlternateSupplierID INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    Address NVARCHAR(200),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    HomePage NVARCHAR(255),
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- CATEGORIES DIMENSION
CREATE TABLE dbo.DimCategories (
    CategorySK INT IDENTITY(1,1) PRIMARY KEY,
    AlternateCategoryID INT NOT NULL,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX),
    Picture VARBINARY(MAX),
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- PRODUCTS DIMENSION
CREATE TABLE dbo.DimProducts (
    ProductSK INT IDENTITY(1,1) PRIMARY KEY,
    AlternateProductID INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    SupplierSK INT NULL,
    CategorySK INT NULL,
    QuantityPerUnit NVARCHAR(50),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- CUSTOMERS DIMENSION
CREATE TABLE dbo.DimCustomers (
    CustomerSK INT IDENTITY(1,1) PRIMARY KEY,
    AlternateCustomerID NVARCHAR(10) NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    Address NVARCHAR(200),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- SHIPPERS DIMENSION
CREATE TABLE dbo.DimShippers (
    ShipperSK INT IDENTITY(1,1) PRIMARY KEY,
    AlternateShipperID INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(50),
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- EMPLOYEES DIMENSION
CREATE TABLE dbo.DimEmployees (
    EmployeeSK INT IDENTITY(1,1) PRIMARY KEY,
    AlternateEmployeeID INT NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    Title NVARCHAR(50),
    TitleOfCourtesy NVARCHAR(50),
    BirthDate DATE,
    HireDate DATE,
    Address NVARCHAR(200),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    HomePhone NVARCHAR(50),
    Extension NVARCHAR(10),
    ReportsTo NVARCHAR(50),
    PhotoPath NVARCHAR(255),
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- EMPLOYEE TERRITORIES DIMENSION
CREATE TABLE dbo.DimEmployeeTerritories (
    EmployeeTerritorySK INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeSK INT NOT NULL,
    TerritoryDescription NVARCHAR(100),
    RegionDescription NVARCHAR(100),
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- DATE DIMENSION already exists from DateMaster.sql

/***********************
 Northwind DW FACT TABLE
***********************/

CREATE TABLE dbo.FactOrders (
    OrderSK INT IDENTITY(1,1) PRIMARY KEY,
    AlternateOrderID INT NOT NULL,
    CustomerSK INT NOT NULL,
    EmployeeSK INT NOT NULL,
    OrderDateKey INT NOT NULL REFERENCES dbo.DimDate(DateKey),
    RequiredDateKey INT NULL REFERENCES dbo.DimDate(DateKey),
    ShippedDateKey INT NULL REFERENCES dbo.DimDate(DateKey),
    ProductSK INT NOT NULL,
    Quantity INT,
	ShipName NVARCHAR(100),
	ShipAddress NVARCHAR(200),
	ShipCity NVARCHAR(50),
    ShipRegion NVARCHAR(50),
	ShipPostalCode NVARCHAR(20),
	ShipCountry NVARCHAR(50),
	ShipVia NVARCHAR(100),
	CreatedAt DATETIME,
	UpdatedAt DATETIME,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
);


/***************************************
 STORED PROCEDURES FOR DIMENSIONS
****************************************/

-- 1. DimCategories
CREATE PROCEDURE dbo.UpdateDimCategories
@CategoryID INT,
@CategoryName NVARCHAR(50),
@Description NVARCHAR(MAX),
@Picture VARBINARY(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.DimCategories WHERE AlternateCategoryID = @CategoryID)
    BEGIN
        INSERT INTO dbo.DimCategories (
            AlternateCategoryID, CategoryName, Description, Picture,
            InsertDate, ModifiedDate
        )
        VALUES (
            @CategoryID, @CategoryName, @Description, @Picture,
            GETDATE(), GETDATE()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.DimCategories
        SET CategoryName = @CategoryName,
            Description = @Description,
            Picture = @Picture,
            ModifiedDate = GETDATE()
        WHERE AlternateCategoryID = @CategoryID;
    END
END
GO

-- 2. DimProducts
CREATE PROCEDURE dbo.UpdateDimProducts
@ProductID INT,
@ProductName NVARCHAR(100),
@SupplierSK INT,
@CategorySK INT,
@QuantityPerUnit NVARCHAR(50),
@UnitsInStock INT,
@UnitsOnOrder INT,
@ReorderLevel INT,
@Discontinued BIT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.DimProducts WHERE AlternateProductID = @ProductID)
    BEGIN
        INSERT INTO dbo.DimProducts (
            AlternateProductID, ProductName, SupplierSK, CategorySK,
            QuantityPerUnit, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued,
            InsertDate, ModifiedDate
        )
        VALUES (
            @ProductID, @ProductName, @SupplierSK, @CategorySK,
            @QuantityPerUnit, @UnitsInStock, @UnitsOnOrder, @ReorderLevel, @Discontinued,
            GETDATE(), GETDATE()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.DimProducts
        SET ProductName = @ProductName,
            SupplierSK = @SupplierSK,
            CategorySK = @CategorySK,
            QuantityPerUnit = @QuantityPerUnit,
            UnitsInStock = @UnitsInStock,
            UnitsOnOrder = @UnitsOnOrder,
            ReorderLevel = @ReorderLevel,
            Discontinued = @Discontinued,
            ModifiedDate = GETDATE()
        WHERE AlternateProductID = @ProductID;
    END
END
GO

-- 3. DimEmployeeTerritories
CREATE PROCEDURE dbo.UpdateDimEmployeeTerritories
@EmployeeSK INT,
@TerritoryDescription NVARCHAR(100),
@RegionDescription NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM dbo.DimEmployeeTerritories
        WHERE EmployeeSK = @EmployeeSK AND TerritoryDescription = @TerritoryDescription
    )
    BEGIN
        INSERT INTO dbo.DimEmployeeTerritories (
            EmployeeSK, TerritoryDescription, RegionDescription, InsertDate, ModifiedDate
        )
        VALUES (
            @EmployeeSK, @TerritoryDescription, @RegionDescription, GETDATE(), GETDATE()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.DimEmployeeTerritories
        SET RegionDescription = @RegionDescription,
            ModifiedDate = GETDATE()
        WHERE EmployeeSK = @EmployeeSK AND TerritoryDescription = @TerritoryDescription;
    END
END
GO