----------------------------------------------------------------------
--DBS Assignment
----------------------------------------------------------------------
CREATE DATABASE DAMS;
USE DAMS;

----------------------------------------------------------------------
--1.0 Create Table
----------------------------------------------------------------------
-- Create the Users table (Include all employee and user)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
	IdentificationNo VARBINARY(MAX),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password VARBINARY(32) NOT NULL,
    Role NVARCHAR(50) NOT NULL, 
    CreatedAt DATETIME DEFAULT GETDATE()
);

--Agents table
CREATE TABLE Agents (
    AgentID INT IDENTITY(1,1) PRIMARY KEY,
	IdentificationNo VARBINARY(MAX),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100), 
    Phone NVARCHAR(30),
    Address NVARCHAR(255),
    Status NVARCHAR(20) DEFAULT 'Active', 
    CreatedAt DATETIME DEFAULT GETDATE(),
);

--Products table
CREATE TABLE Products (
	ProductID INT IDENTITY(1,1) PRIMARY KEY, 
	Name NVARCHAR(100) NOT NULL,
	Description NVARCHAR(255), 
	Price DECIMAL(10,2) NOT NULL,
	CreatedAt DATETIME DEFAULT GETDATE()
);

--Sales table 
CREATE TABLE Sales (
  SaleID INT IDENTITY(1,1) PRIMARY KEY,
  AgentID INT NOT NULL,
  ProductID INT NOT NULL,
  Quantity INT NOT NULL,
  TotalAmount DECIMAL(10,2) NOT NULL,
  SaleDate DATETIME DEFAULT GETDATE(),
FOREIGN KEY(AgentID) REFERENCES Agents(AgentID),
FOREIGN KEY(ProductID) REFERENCES Products(ProductID)
); 

--Commission table 
CREATE TABLE Commission (
  CommissionID INT IDENTITY(1,1) PRIMARY KEY,
  AgentID INT NOT NULL,
  SaleID INT NOT NULL,
  CommissionRate DECIMAL(5,2) NOT NULL,
  CommissionAmount DECIMAL(10,2) NOT NULL,
  CreatedAt DATETIME DEFAULT GETDATE(),
FOREIGN KEY(AgentID) REFERENCES Agents(AgentID),
FOREIGN KEY(SaleID) REFERENCES Sales(SaleID)
);

--Notifications (New add on for UPD roles)
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    Message NVARCHAR(255) NOT NULL,
    Target NVARCHAR(50), -- Optional filter by role
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100)
);

--Marketing Campaigns (New add on for MKT roles)
CREATE TABLE MKT_campaigns (
    CampaignID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100),
    Description NVARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    Budget DECIMAL(10,2),
    Status NVARCHAR(20) DEFAULT 'Planned',
    CreatedBy NVARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Audit Log table  
CREATE TABLE Users_AuditLog (
    U_AuditLogID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Action NVARCHAR(10),  -- INSERT, UPDATE, DELETE
    Username NVARCHAR(50),
    Password NVARCHAR(255),
    Role NVARCHAR(50),
    CreatedAt DATETIME,
    ActionDate DATETIME DEFAULT GETDATE(),
    PerformedBy NVARCHAR(100) -- User who performed the action
);

-- Create Table only Agents_Auditlog
CREATE TABLE Agents_AuditLog (
    A_AuditLogID INT IDENTITY(1,1) PRIMARY KEY,
    AgentID INT,
    Action NVARCHAR(10),  -- INSERT, UPDATE, DELETE
    IdentificationNo VARBINARY(MAX),
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(30),
    Address NVARCHAR(255),
    Status NVARCHAR(20),
    CreatedAt DATETIME,
    ActionDate DATETIME DEFAULT GETDATE(),
    PerformedBy NVARCHAR(100),
);

CREATE TABLE Sales_AuditLog (
    S_AuditLogID INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT,
    AgentID INT,
    ProductID INT,
    Action NVARCHAR(20) NOT NULL,  
    Quantity INT,
    TotalAmount DECIMAL(10,2),
    SaleDate DATETIME,
    ActionDate DATETIME DEFAULT GETDATE(),
    PerformedBy NVARCHAR(100),      
    FOREIGN KEY (AgentID) REFERENCES Agents(AgentID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Commission_AuditLog (
    C_AuditLogID INT IDENTITY(1,1) PRIMARY KEY,
    CommissionID INT,
    AgentID INT,
    SaleID INT,
    Action NVARCHAR(10),  -- INSERT, UPDATE, DELETE
    CommissionRate DECIMAL(5,2),
    CommissionAmount DECIMAL(10,2),
    CreatedAt DATETIME,
    ActionDate DATETIME DEFAULT GETDATE(),
    PerformedBy NVARCHAR(100),
    FOREIGN KEY (AgentID) REFERENCES Agents(AgentID),
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID)
);


----------------------------------------------------------------------
--1.1 Insert Dummy Data
----------------------------------------------------------------------
INSERT INTO Products (Name, Description, Price)
VALUES 
	('Organic Spinach', 'Fresh organic spinach 250g pack', 4.50),
	('Kale', 'Locally grown organic kale', 5.00),
	('Carrot Bundle', 'Sweet organic carrots (500g)', 3.80),
	('Cherry Tomatoes', 'Organic cherry tomatoes pack', 6.20),
	('Cucumber', 'Organic Japanese cucumber (2 pcs)', 4.00);

INSERT INTO Notifications (Title, Message, Target, CreatedBy)
VALUES 
('Welcome!', 'Welcome to our platform. We hope you enjoy your experience!', 'User1', 'System'),
('Update Notice', 'Our system will undergo maintenance on Saturday at 10 PM.', 'User2', 'Admin'),
('Reminder', 'Don’t forget to verify your email address to activate your account.', 'User3', 'System'),
('New Feature', 'A new dashboard feature has been added to enhance your reporting.', 'User4', 'System'),
('Security Alert', 'Your password was changed recently. If this wasn’t you, contact support.', 'User5', 'Admin'),
('Survey', 'We value your feedback. Please take our quick 2-minute survey.', 'User1', 'Marketing'),
('Promotion', 'Get 20% off on your next purchase! Use code SAVE20.', 'User2', 'Marketing'),
('System Alert', 'Unusual login detected on your account. Please confirm your identity.', 'User5', 'System');

INSERT INTO MKT_campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy)
VALUES 
    ('Eat Green Campaign', 'Promote leafy greens to urban areas', '2025-08-01', '2025-08-31', 15000.00, 'Planned', 'elina'),
    ('Healthy Raya Promo', 'Special promo for Hari Raya festive season', '2025-04-01', '2025-04-30', 10000.00, 'Completed', 'elina'),
    ('Agent Booster Drive', 'Encourage more agent sign-ups', '2025-09-01', '2025-09-30', 12000.00, 'Planned', 'elina'),
    ('Digital Wellness Week', 'Educate public on digital detox and mental health', '2025-07-25', '2025-08-10', 18000.00, 'Implementing', 'elina'),
    ('Back to School Health Kit', 'Distribute hygiene kits to students', '2025-07-20', '2025-08-15', 14000.00, 'Implementing', 'elina');

----------------------------------------------------------------------
--1.2 SELECT of Data
----------------------------------------------------------------------
SELECT * FROM Agents;
SELECT * FROM Products;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users;
SELECT * FROM Notifications;
SELECT * FROM MKT_campaigns;


----------------------------------------------------------------------
--2.0 Permission Management
----------------------------------------------------------------------
----------------------------------------------------------------------
-- 2.1 Creating Roles   (Method 1)
----------------------------------------------------------------------
CREATE ROLE DBA;
CREATE ROLE AGT;
CREATE ROLE MKT;
CREATE ROLE UPD;
CREATE ROLE ANL;
CREATE ROLE ADT;
CREATE ROLE USR;


------------------------------------------------------------------------
---- 2.1.1 Drop roles using sp_droprole
------------------------------------------------------------------------
--EXEC sp_droprole 'DBA';  -- Drop 'DBA' role
--EXEC sp_droprole 'AGT';  -- Drop 'AGT' role
--EXEC sp_droprole 'MKT';  -- Drop 'MKT' role
--EXEC sp_droprole 'UPD';  -- Drop 'UPD' role
--EXEC sp_droprole 'ANL';  -- Drop 'ANL' role
--EXEC sp_droprole 'ADT';  -- Drop 'ADT' role
--EXEC sp_droprole 'USR';  -- Drop 'USR' role

----------------------------------------------------------------------
--2.2 Grant Tables Permission 
----------------------------------------------------------------------
-- DBA Role Permissions (Full access)
GRANT SELECT, INSERT, UPDATE, DELETE ON Agents TO DBA;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO DBA;
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO DBA;
GRANT SELECT, INSERT, UPDATE, DELETE ON Commission TO DBA;

GRANT SELECT ON Users_AuditLog TO DBA; 
GRANT SELECT ON Agents_AuditLog TO DBA; 
GRANT SELECT ON Sales_AuditLog TO DBA; 
GRANT SELECT ON Commission_AuditLog TO DBA; 
DENY DELETE, INSERT, UPDATE ON Users_AuditLog TO DBA;
DENY DELETE, INSERT, UPDATE ON Agents_AuditLog TO DBA;
DENY DELETE, INSERT, UPDATE ON Sales_AuditLog TO DBA;
DENY DELETE, INSERT, UPDATE ON Commission_AuditLog TO DBA;

GRANT SELECT, INSERT, UPDATE, DELETE ON Users TO DBA; 
GRANT SELECT, INSERT, UPDATE, DELETE ON Notifications TO DBA; 
GRANT SELECT, INSERT, UPDATE, DELETE ON MKT_campaigns TO DBA;

-- AGT Role Permissions (Agent access)
GRANT SELECT, UPDATE ON Agents TO AGT; -- Only their own data
DENY INSERT, DELETE ON Agents TO AGT;

GRANT SELECT ON Products TO AGT;
DENY INSERT, UPDATE, DELETE ON Products TO AGT;

GRANT SELECT, INSERT, UPDATE ON Sales TO AGT; -- Only their own data 
DENY DELETE ON Sales TO AGT;

GRANT SELECT ON Commission TO AGT; -- Only their own data 
DENY INSERT, UPDATE, DELETE ON Commission TO AGT;

DENY SELECT, INSERT, UPDATE, DELETE ON Users_AuditLog TO AGT;
DENY SELECT, INSERT, UPDATE, DELETE ON Agents_AuditLog TO AGT;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales_AuditLog TO AGT;
DENY SELECT, INSERT, UPDATE, DELETE ON Commission_AuditLog TO AGT;

DENY SELECT, UPDATE, INSERT, DELETE ON Users TO AGT;
DENY SELECT, INSERT, UPDATE, DELETE  ON Notifications TO AGT;
DENY SELECT, INSERT, UPDATE, DELETE  ON MKT_campaigns TO AGT;


-- MKT Role Permissions (Marketing access)
DENY SELECT, INSERT, UPDATE, DELETE ON Agents TO MKT;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO MKT;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales TO MKT;
DENY SELECT, INSERT, UPDATE, DELETE ON Commission TO MKT;
DENY SELECT, INSERT, UPDATE, DELETE ON Users_AuditLog TO MKT;
DENY SELECT, INSERT, UPDATE, DELETE ON Agents_AuditLog TO MKT;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales_AuditLog TO MKT;
DENY SELECT, INSERT, UPDATE, DELETE ON Commission_AuditLog TO MKT;

DENY SELECT, UPDATE, INSERT, DELETE ON Users TO MKT;
DENY SELECT, INSERT, UPDATE, DELETE ON Notifications TO MKT;
GRANT SELECT, INSERT, UPDATE, DELETE ON MKT_campaigns TO MKT;

-- UPD Role Permissions (User Portal Development access)
DENY SELECT, INSERT, UPDATE, DELETE ON Agents TO UPD;

GRANT SELECT ON Products TO UPD;
DENY INSERT, UPDATE, DELETE ON Products TO UPD;

DENY SELECT, INSERT, UPDATE, DELETE ON Sales TO UPD;
DENY SELECT, INSERT, UPDATE, DELETE ON Commission TO UPD;

GRANT SELECT ON Users_AuditLog TO UPD;
DENY INSERT, UPDATE, DELETE ON Users_AuditLog TO UPD;

DENY SELECT, INSERT, UPDATE, DELETE ON Agents_AuditLog TO UPD;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales_AuditLog TO UPD;
DENY SELECT, INSERT, UPDATE, DELETE ON Commission_AuditLog TO UPD;

GRANT SELECT, INSERT, UPDATE, DELETE ON Users TO UPD; 
GRANT SELECT, INSERT, UPDATE, DELETE ON Notifications TO UPD;
DENY SELECT, INSERT, UPDATE, DELETE ON MKT_campaigns TO UPD;

-- ANL Role Permissions (Analytics access)
DENY SELECT, INSERT, UPDATE, DELETE ON Agents TO ANL;

GRANT SELECT ON Products TO ANL;
DENY INSERT, UPDATE, DELETE ON Products TO ANL;

DENY SELECT, INSERT, UPDATE, DELETE ON Sales TO ANL;
DENY SELECT, INSERT, UPDATE, DELETE ON Commission TO ANL;
DENY SELECT, INSERT, UPDATE, DELETE ON Users_AuditLog TO ANL;
DENY SELECT, INSERT, UPDATE, DELETE ON Agents_AuditLog TO ANL;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales_AuditLog TO ANL;
DENY SELECT, INSERT, UPDATE, DELETE ON Commission_AuditLog TO ANL;

DENY SELECT, INSERT, UPDATE, DELETE ON Users TO ANL;
DENY SELECT, INSERT, UPDATE, DELETE ON Notifications TO ANL;

GRANT SELECT ON MKT_campaigns TO ANL;
DENY INSERT, UPDATE, DELETE ON MKT_campaigns TO ANL;

-- ADT Role Permissions (Auditor access)
GRANT SELECT, INSERT, UPDATE, DELETE ON Agents TO ADT;

GRANT SELECT ON Products TO ADT;
DENY INSERT, UPDATE, DELETE ON Products TO ADT;

GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO ADT;
GRANT SELECT, INSERT, UPDATE, DELETE ON Commission TO ADT;

GRANT SELECT ON Users_AuditLog TO ADT;
GRANT SELECT ON Agents_AuditLog TO ADT; 
GRANT SELECT ON Sales_AuditLog TO ADT;
GRANT SELECT ON Commission_AuditLog TO ADT;

DENY INSERT, UPDATE, DELETE ON Users_AuditLog TO ADT;
DENY INSERT, UPDATE, DELETE ON Agents_AuditLog TO ADT;
DENY INSERT, UPDATE, DELETE ON Sales_AuditLog TO ADT;
DENY INSERT, UPDATE, DELETE ON Commission_AuditLog TO ADT;

GRANT SELECT, INSERT, UPDATE,DELETE ON Users TO ADT;

GRANT SELECT ON Notifications TO ADT;
DENY INSERT, UPDATE, DELETE ON Notifications TO ADT;

GRANT SELECT ON MKT_campaigns TO ADT;
DENY INSERT, UPDATE, DELETE ON MKT_campaigns TO ADT;

-- USR Role Permissions (Auditor access)
GRANT SELECT ON Users TO USR;
DENY DELETE, INSERT, UPDATE ON Users TO USR;

--REVOKE INSERT ON Users_AuditLog TO UPD (撤回）

----------------------------------------------------------------------
-- 2.3 Managing User Access
----------------------------------------------------------------------
----------------------------------------------------------------------
--2.3.1 S.P.1 Stored Procedure : Create User (OLD) + 3.3 Hashing
----------------------------------------------------------------------
--DROP PROCEDURE IF EXISTS CreateUserAndAssignRole;

--DROP PROCEDURE CreateUserAndAssignRole;

CREATE PROCEDURE CreateUserAndAssignRole
    @Username NVARCHAR(50),
    @Password NVARCHAR(255),
    @Role NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if login already exists
        IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @Username AND type = 'S')
        BEGIN
            -- Create the login if it does not exist
            DECLARE @CreateLoginSQL NVARCHAR(500)
            SET @CreateLoginSQL = 'CREATE LOGIN ' + QUOTENAME(@Username) + ' WITH PASSWORD = ''' + @Password + ''';'
            EXEC sp_executesql @CreateLoginSQL;
        END

        -- Check if user already exists in the database
        IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Username AND type = 'S')
        BEGIN
            -- Create the user if it does not exist
            DECLARE @CreateUserSQL NVARCHAR(500)
            SET @CreateUserSQL = 'CREATE USER ' + QUOTENAME(@Username) + ' FOR LOGIN ' + QUOTENAME(@Username) + ';'
            EXEC sp_executesql @CreateUserSQL;
        END

        -- Assign role to the user
        DECLARE @AssignRoleSQL NVARCHAR(500)
        SET @AssignRoleSQL = 'ALTER ROLE ' + QUOTENAME(@Role) + ' ADD MEMBER ' + QUOTENAME(@Username) + ';'
        
        -- First remove user from all roles except the 'public' role to avoid duplicate membership
        DECLARE @RemoveRolesSQL NVARCHAR(MAX) = '';
        SELECT @RemoveRolesSQL = @RemoveRolesSQL + 
               'ALTER ROLE ' + QUOTENAME(name) + ' DROP MEMBER ' + QUOTENAME(@Username) + ';'
        FROM sys.database_principals 
        WHERE type = 'R' 
          AND is_fixed_role = 0 -- Exclude fixed roles like db_owner
          AND name <> 'public'; -- Exclude the 'public' role
        
        IF LEN(@RemoveRolesSQL) > 0
            EXEC sp_executesql @RemoveRolesSQL;
            
        EXEC sp_executesql @AssignRoleSQL;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        THROW; -- Re-throw the error
    END CATCH
END;
GO
----------------------------------------------------------------------
-- Grant permission to execute CreateUserAndAssignRole procedure for DBA & UPD & ADT roles
----------------------------------------------------------------------

use DAMS;
GRANT CREATE USER TO ADT;
GRANT ALTER ANY ROLE TO ADT;
GRANT CREATE USER TO DBA;
GRANT ALTER ANY ROLE TO DBA;
GRANT CREATE USER TO UPD;
GRANT ALTER ANY ROLE TO UPD;

GRANT EXECUTE ON CreateUserAndAssignRole TO DBA;
GRANT EXECUTE ON CreateUserAndAssignRole TO UPD;
GRANT EXECUTE ON CreateUserAndAssignRole TO ADT;


--------------------------------------------------------------------
--2.3.1.1 -- Call the procedure to create a new user
--------------------------------------------------------------------
--Lecturer said each Role should have 3 users login
EXEC CreateUserAndAssignRole 'agent1', 'agent123', 'AGT';
EXEC CreateUserAndAssignRole 'agent2', 'agent234', 'AGT';
EXEC CreateUserAndAssignRole 'agent3', 'agent345', 'AGT';
EXEC CreateUserAndAssignRole 'agent4', 'agent456', 'AGT';
EXEC CreateUserAndAssignRole 'agent5', 'agent567', 'AGT';

EXEC CreateUserAndAssignRole 'admin1', 'admin123', 'DBA';
EXEC CreateUserAndAssignRole 'admin2', 'admin234', 'DBA';
EXEC CreateUserAndAssignRole 'admin3', 'admin345', 'DBA';

EXEC CreateUserAndAssignRole 'marketing1', 'marketing123', 'MKT';
EXEC CreateUserAndAssignRole 'marketing2', 'marketing234', 'MKT';
EXEC CreateUserAndAssignRole 'marketing3', 'marketing345', 'MKT';

EXEC CreateUserAndAssignRole 'userportal1', 'userportal123', 'UPD';
EXEC CreateUserAndAssignRole 'userportal2', 'userportal234', 'UPD';
EXEC CreateUserAndAssignRole 'userportal3', 'userportal345', 'UPD';

EXEC CreateUserAndAssignRole 'analyst1', 'analyst123', 'ANL';
EXEC CreateUserAndAssignRole 'analyst2', 'analyst234', 'ANL';
EXEC CreateUserAndAssignRole 'analyst3', 'analyst345', 'ANL';

EXEC CreateUserAndAssignRole 'auditor1', 'auditor123', 'ADT';
EXEC CreateUserAndAssignRole 'auditor2', 'auditor234', 'ADT';
EXEC CreateUserAndAssignRole 'auditor3', 'auditor345', 'ADT';

EXEC CreateUserAndAssignRole 'user1', 'user123', 'USR';
EXEC CreateUserAndAssignRole 'user2', 'user234', 'USR';
EXEC CreateUserAndAssignRole 'user3', 'user345', 'USR';


--use master grant
use master;
GRANT ALTER ANY LOGIN TO admin1;
GRANT ALTER ANY LOGIN TO admin2;
GRANT ALTER ANY LOGIN TO admin3;

GRANT ALTER ANY LOGIN TO userportal1;
GRANT ALTER ANY LOGIN TO userportal2;
GRANT ALTER ANY LOGIN TO userportal3;

GRANT ALTER ANY LOGIN TO auditor1;
GRANT ALTER ANY LOGIN TO auditor2;
GRANT ALTER ANY LOGIN TO auditor3;


----------------------------------------------------------------------
--2.3.2 Insert Dummy Data （Agent) + 3.2 CLE
----------------------------------------------------------------------
--Step 1
--DROP MASTER KEY;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'HPOCLE123@Encryption';

--DROP CERTIFICATE ICDataCert;
CREATE CERTIFICATE ICDataCert
WITH SUBJECT = 'Certificate to protect IdentificationNo symmetric key';

--DROP SYMMETRIC KEY ICSymKey;
CREATE SYMMETRIC KEY ICSymKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE ICDataCert;

--Grant Permission
GRANT CONTROL ON CERTIFICATE::ICDataCert TO DBA;
GRANT VIEW DEFINITION ON SYMMETRIC KEY::ICSymKey TO DBA;
GRANT CONTROL ON SYMMETRIC KEY::ICSymKey TO DBA;

GRANT CONTROL ON CERTIFICATE::ICDataCert TO ADT;
GRANT VIEW DEFINITION ON SYMMETRIC KEY::ICSymKey TO ADT;
GRANT CONTROL ON SYMMETRIC KEY::ICSymKey TO ADT;

--Step 2
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;

--Step 3
use DAMS;
INSERT INTO Agents (Name, Email, IdentificationNO, Phone, Address, Status)
VALUES 
('Alice Tan',
 'alice.tan@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('900101145678', 7, 0, '-'), 10, 0, '-'))),
 '012-3456789',
 '123 Jalan Mawar, Kuala Lumpur',
 'Active'),

('Brian Lee',
 'brian.lee@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('880505223344', 7, 0, '-'), 10, 0, '-'))),
 '013-2223344',
 '45 Jalan Teratai, Penang',
 'Inactive'),

('Chong Mei Lin',
 'mei.lin@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('850909987654', 7, 0, '-'), 10, 0, '-'))),
 '016-9876543',
 '88 Jalan Bunga Raya, Johor Bahru',
 'Active'),

('David Ong',
 'david.ong@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('820101876543', 7, 0, '-'), 10, 0, '-'))),
 '019-8765432',
 '12 Jalan Kenanga, Ipoh',
 'Active'),

('Elina Chan',
 'elina.chan@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('910707123456', 7, 0, '-'), 10, 0, '-'))),
 '011-2345678',
 '76 Jalan Melati, Kota Kinabalu',
 'Active');

INSERT INTO Users (IdentificationNO, Username, Password, Role)
VALUES 
(
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(NVARCHAR(20), STUFF(STUFF('900101145678', 7, 0, '-'), 10, 0, '-'))),
    'Alice',
    HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'Password123!')),
    'User'
),
(
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(NVARCHAR(20), STUFF(STUFF('880505223344', 7, 0, '-'), 10, 0, '-'))),
    'Brian',
    HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'SecretPwd456')),
    'User'
),
(
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(NVARCHAR(20), STUFF(STUFF('850909987654', 7, 0, '-'), 10, 0, '-'))),
    'Mei Lin',
    HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'TestPwd789')),
    'User'
);

CLOSE SYMMETRIC KEY ICSymKey;

INSERT INTO Sales (AgentID, ProductID, Quantity, TotalAmount)
VALUES 
	(1, 2, 10, 50.00),
	(2, 1, 5, 22.50),
	(3, 4, 8, 49.60),
	(4, 3, 7, 26.60),
	(5, 5, 4, 16.00);

INSERT INTO Commission (AgentID, SaleID, CommissionRate, CommissionAmount)
VALUES 
	(1, 1, 5.00, 2.50),
	(2, 2, 4.50, 1.01),
	(3, 3, 6.00, 2.98),
	(4, 4, 4.00, 1.06),
	(5, 5, 5.50, 0.88);




SELECT * FROM Agents;
SELECT * FROM Products;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users;
SELECT * FROM Notifications;
SELECT * FROM MKT_campaigns;

----------------------------------------------------------------------
--2.3.2 S.P.2 Stored Procedure : Drop User
----------------------------------------------------------------------
--DROP PROCEDURE IF EXISTS DeleteUserAndLogin;

CREATE PROCEDURE DeleteUserAndLogin
    @Username NVARCHAR(50)
AS
BEGIN
    -- Check if the user exists in the Users table and delete if exists
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        -- Delete the user from the Users table
        DELETE FROM Users WHERE Username = @Username;
    END

    -- Check if the user exists in the database
    IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Username)
    BEGIN
        -- Drop the user from the database if it exists
        DECLARE @DropUserSQL NVARCHAR(500)
        SET @DropUserSQL = 'DROP USER ' + QUOTENAME(@Username) + ';';
        EXEC sp_executesql @DropUserSQL;
    END

    -- Check if the login exists on the server
    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @Username AND type = 'S')
    BEGIN
        -- Drop the login if it exists
        DECLARE @DropLoginSQL NVARCHAR(500)
        SET @DropLoginSQL = 'DROP LOGIN ' + QUOTENAME(@Username) + ';';
        EXEC sp_executesql @DropLoginSQL;
    END
END;
GO

-- Grant permission to execute DeleteUserAndLogin procedure for DBA & UPD & ADT roles
GRANT EXECUTE ON DeleteUserAndLogin TO DBA;
GRANT EXECUTE ON DeleteUserAndLogin TO UPD;
GRANT EXECUTE ON DeleteUserAndLogin TO ADT;


--TEST CASE --> SUCCESS
EXECUTE AS LOGIN='admin1'
EXEC CreateUserAndAssignRole 'admin4', 'admin444', 'DBA';
REVERT

EXECUTE AS LOGIN='userportal1'
EXEC DeleteUserAndLogin 'admin4';
REVERT

EXECUTE AS LOGIN='auditor1'
EXEC CreateUserAndAssignRole 'admin5', 'admin555', 'DBA';
REVERT


--TEST CASE --> FAIL AS EXPECTED (because AGT & MKT & ANL & USR cannot add / delete user)
EXECUTE AS LOGIN='agent1'
EXEC CreateUserAndAssignRole 'admin4', 'admin444', 'DBA';
EXEC DeleteUserAndLogin 'admin3';
REVERT



------------------------------------------------------------------------
----2.4 Implement RLS  (With insert & update)
------------------------------------------------------------------------
CREATE SCHEMA Security;

------ Drop security policies first (must be dropped before the functions)
----DROP SECURITY POLICY IF EXISTS Security.CommissionSecurityPolicy;
----DROP SECURITY POLICY IF EXISTS Security.SalesSecurityPolicy;
----DROP SECURITY POLICY IF EXISTS Security.AgentsSecurityPolicy;
----DROP SECURITY POLICY IF EXISTS Security.UsersSecurityPolicy;
----DROP SECURITY POLICY IF EXISTS Security.NotificationsSecurityPolicy;

------ Drop security predicate functions
----DROP FUNCTION IF EXISTS Security.fn_CommissionSelfPredicate;
----DROP FUNCTION IF EXISTS Security.fn_SalesSelfPredicate;
----DROP FUNCTION IF EXISTS Security.fn_AgentsSelfPredicate;
----DROP FUNCTION IF EXISTS Security.fn_UsersSelfPredicate;
----DROP FUNCTION IF EXISTS Security.fn_NotificationsSelfPredicate;

------------------------------------------------------------------------
-- 2.4.1. Users table predicate
------------------------------------------------------------------------
CREATE OR ALTER FUNCTION Security.fn_UsersSelfPredicate(@UserID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_SecurityPredicateResult
    WHERE
        -- Admin roles can see all users
		(IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('db_owner') = 1)
        OR IS_MEMBER('DBA') = 1
        OR IS_MEMBER('UPD') = 1
        OR IS_MEMBER('ADT') = 1
        -- Each user sees their own row
        OR (
            USER_NAME() LIKE 'user%' AND
            TRY_CAST(SUBSTRING(USER_NAME(), 5, LEN(USER_NAME())) AS INT) = @UserID
        );

------------------------------------------------------------------------
-- 2.4.2. Sales table predicate
------------------------------------------------------------------------
CREATE OR ALTER FUNCTION Security.fn_SalesSelfPredicate(@AgentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_SecurityPredicateResult
    WHERE
        -- Full access for admin/analyst roles
		(IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('db_owner') = 1)
        OR IS_MEMBER('DBA') = 1
        OR IS_MEMBER('UPD') = 1
        OR IS_MEMBER('ANL') = 1
        OR IS_MEMBER('ADT') = 1
        OR IS_MEMBER('MKT') = 1
        -- Agent-level access to own sales
        OR (
            USER_NAME() LIKE 'agent%' AND
            TRY_CAST(SUBSTRING(USER_NAME(), 6, LEN(USER_NAME())) AS INT) = @AgentID
        );

------------------------------------------------------------------------
-- 2.4.3. Agents table predicate
------------------------------------------------------------------------
CREATE OR ALTER FUNCTION Security.fn_AgentsSelfPredicate(@AgentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_SecurityPredicateResult
    WHERE 
        -- Admin-level access via roles
        (IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('db_owner') = 1)
        OR IS_MEMBER('DBA') = 1
        OR IS_MEMBER('UPD') = 1
        OR IS_MEMBER('ADT') = 1
        -- AGT can only see their own agent row
        OR (
            USER_NAME() LIKE 'agent%' AND 
            TRY_CAST(SUBSTRING(USER_NAME(), 6, LEN(USER_NAME())) AS INT) = @AgentID
        );

-----------------------------------------------------------------------
-- 2.4.4. Commission table predicate
------------------------------------------------------------------------
CREATE OR ALTER FUNCTION Security.fn_CommissionSelfPredicate(@AgentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_SecurityPredicateResult
    WHERE
        -- Full access for admin/analyst roles
        (IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('db_owner') = 1)
        OR IS_MEMBER('DBA') = 1
        OR IS_MEMBER('UPD') = 1
        OR IS_MEMBER('ANL') = 1
        OR IS_MEMBER('ADT') = 1
        -- Agent-level access to own commissions
        OR (
            USER_NAME() LIKE 'agent%' AND
            TRY_CAST(SUBSTRING(USER_NAME(), 6, LEN(USER_NAME())) AS INT) = @AgentID
        );

------------------------------------------------------------------------
-- 2.4.5. Notifications table predicate
------------------------------------------------------------------------
CREATE OR ALTER FUNCTION Security.fn_NotificationSelfPredicate(@Target NVARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_SecurityPredicateResult
    WHERE 
        -- Admin roles bypass RLS
        IS_SRVROLEMEMBER('sysadmin') = 1 OR
        IS_MEMBER('db_owner') = 1 OR
        IS_MEMBER('DBA') = 1 OR
        IS_MEMBER('UPD') = 1 OR
		IS_MEMBER('ANL') = 1 OR
        IS_MEMBER('ADT') = 1
        -- Show notification if it matches current user
        OR USER_NAME() = @Target
        -- Show general (non-targeted) notifications
        OR @Target IS NULL;

------------------------------------------------------------------------
-- 2.4.6 Create security policies for each table
------------------------------------------------------------------------
--Step 1
-- For Users table
CREATE SECURITY POLICY Security.UsersSecurityPolicy
ADD FILTER PREDICATE Security.fn_UsersSelfPredicate(UserID) ON dbo.Users
WITH (STATE = ON);

-- For Sales table
CREATE SECURITY POLICY Security.SalesSecurityPolicy
ADD FILTER PREDICATE Security.fn_SalesSelfPredicate(AgentID) ON dbo.Sales
WITH (STATE = ON);

-- For Agents table
CREATE SECURITY POLICY Security.AgentsSecurityPolicy
ADD FILTER PREDICATE Security.fn_AgentsSelfPredicate(AgentID) ON dbo.Agents
WITH (STATE = ON);

-- For Commission table
CREATE SECURITY POLICY Security.CommissionSecurityPolicy
ADD FILTER PREDICATE Security.fn_CommissionSelfPredicate(AgentID) ON dbo.Commission
WITH (STATE = ON);

-- For Notifications table
CREATE SECURITY POLICY Security.NotificationsSecurityPolicy
ADD FILTER PREDICATE Security.fn_NotificationSelfPredicate(Target) ON dbo.Notifications
WITH (STATE = ON);

--Step 2
--Grant Permission to DBA ADT UPD
GRANT ALTER ANY SECURITY POLICY TO DBA;
GRANT ALTER ANY SECURITY POLICY TO ADT;
GRANT ALTER ANY SECURITY POLICY TO UPD;

GRANT CONTROL ON SCHEMA::Security TO DBA;
GRANT CONTROL ON SCHEMA::Security TO UPD;
GRANT CONTROL ON SCHEMA::Security TO ADT;

----------------------------------------------------------------------
--TEST CASE --> RLS
----------------------------------------------------------------------
--ORIGINAL
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;

--SUCCESS
--see own rows
EXECUTE AS LOGIN='agent1'
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Users;
REVERT

--SUCCESS
--see own rows
EXECUTE AS LOGIN='user2'
SELECT * FROM Users;
REVERT

--SUCCESS
--see all
EXECUTE AS LOGIN='admin1'
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Users;
REVERT

--SUCCESS
--see all
EXECUTE AS LOGIN='userportal1'
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Users;
REVERT

--SUCCESS
--see all
EXECUTE AS LOGIN='auditor1'
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Users;
REVERT

--FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
REVERT



----------------------------------------------------------------------
--2.5 View (Restrict Column View of Table & Masking)
----------------------------------------------------------------------
--DROP VIEW Security.vw_Notifications_Limited 
----------------------------------------------------------------------
--2.5.1 Notification (USR)
----------------------------------------------------------------------
-- View for Notifications with restricted access
--DROP VIEW Security.vw_Notifications_User
CREATE VIEW Security.vw_Notifications_User AS
SELECT 
    Title,
    Message,
    CreatedAt
FROM dbo.Notifications
GO

-- Grant permissions to User roles
GRANT SELECT ON Security.vw_Notifications_User TO USR;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM Notifications;

--User can only view their notifications --> SUCCESS
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Notifications_User; 
REVERT

--Agent cannot view user's notifications --> FAIL AS EXPECTED
EXECUTE AS LOGIN='agent1'
SELECT * FROM Security.vw_Notifications_User; 
REVERT


----------------------------------------------------------------------
--2.5.1.2 Notification (ANL & ADT)
----------------------------------------------------------------------
-- View for Notifications with restricted access
--DROP VIEW Security.vw_Notifications_Limited
CREATE OR ALTER VIEW Security.vw_Notifications_Limited AS
SELECT 
    Title,
    Message,
    -- Always mask TargetRole
    'Restricted' AS TargetRole,
    CreatedAt,
    -- Mask CreatedBy only if it is 'Admin'
    CASE 
        WHEN CreatedBy = 'Admin' THEN 'System'
        ELSE CreatedBy
    END AS CreatedBy

FROM dbo.Notifications;
GO


-- Grant permissions to ANL & ADT
GRANT SELECT ON Security.vw_Notifications_Limited TO ANL;
GRANT SELECT ON Security.vw_Notifications_Limited TO ADT;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM Notifications;

--Analyst & Auditor can view all notifications and some column are masked successfully --> SUCCESS
EXECUTE AS LOGIN='analyst1'
SELECT * FROM Security.vw_Notifications_Limited; 
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM Security.vw_Notifications_Limited; 
REVERT

--User cannot use this view (vw_Notifications_Limited) to view their notifications --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Notifications_Limited; 
REVERT



----------------------------------------------------------------------
--2.5.2 MKT_campaigns (USR)
----------------------------------------------------------------------
-- View for MKT_campaigns with restricted access
CREATE VIEW Security.vw_MKTCampaigns_User AS
SELECT 
    Title,
    Description,
    EndDate
FROM dbo.MKT_campaigns
WHERE Status = 'Implementing';
GO

-- Grant permissions to User roles
GRANT SELECT ON Security.vw_MKTCampaigns_User TO USR;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM MKT_campaigns;

--SUCCESS
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_MKTCampaigns_User; 
REVERT

--Agent cannot use this view (vw_MKTCampaigns_User) to view the marketing campaigns --> FAIL AS EXPERCTED
EXECUTE AS LOGIN='agent1'
SELECT * FROM Security.vw_MKTCampaigns_User; 
REVERT



----------------------------------------------------------------------
--2.5.2.1 MKT_campaigns (AGT & UPD)
----------------------------------------------------------------------
-- View for MKT_campaigns with restricted access
--DROP VIEW Security.vw_MKTCampaigns_Limited;
CREATE VIEW Security.vw_MKTCampaigns_Limited AS
SELECT 
	CampaignID,			
    Title,
    Description,
    'XXXX-XX-XX' AS StartDate,      -- Masked with default date text
    'XXXX-XX-XX' AS EndDate,        -- Masked with default date text
    0.00 AS Budget,                 -- Masked with default budget
    'REDACTED' AS Status,           -- Masked with default status
    'Anonymous' AS CreatedBy,       -- Masked with default name
    '1900-01-01' AS CreatedAt       -- Masked with placeholder date
FROM dbo.MKT_campaigns
WHERE Status = 'Implementing';
GO


-- Grant permissions to AGT and UPD roles
GRANT SELECT ON Security.vw_MKTCampaigns_Limited TO AGT;
GRANT SELECT ON Security.vw_MKTCampaigns_Limited TO UPD;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM MKT_campaigns;

--SUCCESS
EXECUTE AS LOGIN='agent1'
SELECT * FROM Security.vw_MKTCampaigns_Limited; 
REVERT

EXECUTE AS LOGIN='userportal1'
SELECT * FROM Security.vw_MKTCampaigns_Limited; 
REVERT

--FAIL AS EXPECTED
EXECUTE AS LOGIN='marketing1'
SELECT * FROM Security.vw_MKTCampaigns_Limited; 
REVERT




----------------------------------------------------------------------
--2.5.3 Sales (MKT & ANL)
----------------------------------------------------------------------
--DROP VIEW Security.vw_Sales_Restricted 
-- View for Sales with Restricted Access
CREATE VIEW Security.vw_Sales_Restricted AS
SELECT 
    ProductID,
    Quantity,
    TotalAmount,
    SaleDate
FROM Sales;

-- Grant permissions to MKT and ANL roles
GRANT SELECT ON Security.vw_Sales_Restricted TO MKT;
GRANT SELECT ON Security.vw_Sales_Restricted TO ANL;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM Sales;

--SUCCESS
EXECUTE AS LOGIN='marketing1'
SELECT * FROM Security.vw_Sales_Restricted; 
REVERT

EXECUTE AS LOGIN='analyst1'
SELECT * FROM Security.vw_Sales_Restricted; 
REVERT

--User cannot view sales data --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Sales_Restricted; 
REVERT



----------------------------------------------------------------------
--2.5.4 Sales (ANL) (With extra insight)
---------------------------------------------------------------------
CREATE OR ALTER VIEW Security.vw_MonthlyProductSales AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    YEAR(s.SaleDate) AS SaleYear,
    MONTH(s.SaleDate) AS SaleMonth,
    COUNT(s.SaleID) AS TotalSalesCount,
    SUM(s.Quantity) AS TotalQuantitySold,
    SUM(s.TotalAmount) AS TotalSalesAmount
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductID, p.Name, YEAR(s.SaleDate), MONTH(s.SaleDate);

-- Grant permissions to ANL roles
GRANT SELECT ON Security.vw_MonthlyProductSales TO ANL;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM Sales;

--SUCCESS
EXECUTE AS LOGIN='analyst1'
SELECT * FROM Security.vw_MonthlyProductSales; 
REVERT


--User cannot view sales data --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Sales_Restricted; 
REVERT



----------------------------------------------------------------------
--2.5.5 Product 
----------------------------------------------------------------------
--DROP VIEW Security.vw_Product_User;
-- View for Product with Restricted Access for USR
CREATE OR ALTER VIEW Security.vw_Product_User AS
SELECT 
	Name,		
    Description,
    Price
FROM Products;

-- Grant permissions to User roles
GRANT SELECT ON Security.vw_Product_User TO USR;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM Products;

--SUCCESS
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Product_User; 
REVERT



----------------------------------------------------------------------
--2.5.6 User 
----------------------------------------------------------------------
--DROP PROCEDURE Security.usp_GetDecryptedUsers;
-- View for Users with Restricted Access for USR
CREATE OR ALTER PROCEDURE Security.usp_GetDecryptedUsers
WITH EXECUTE AS OWNER
AS
BEGIN
    OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;

    SELECT 
        UserID,
        CONVERT(NVARCHAR(20), DecryptByKey(IdentificationNo)) AS IdentificationNo,
        Username,
        Password,
        CreatedAt
    FROM Users;

    CLOSE SYMMETRIC KEY ICSymKey;
END;
GO

-- Grant permissions to User roles
GRANT EXECUTE ON Security.usp_GetDecryptedUsers TO ADT;

----------------------------------------------------------------------
--TEST CASE 
----------------------------------------------------------------------
--Original
SELECT * FROM Users;

--SUCCESS
EXECUTE AS LOGIN='auditor1'
EXECUTE Security.usp_GetDecryptedUsers; 
REVERT


----------------------------------------------------------------------
--2.6 S.P.3 Stored Procedure : Check Membership (ONLY CAN EXECUTED BY DBA & UPD & ADT)
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE CheckRoleMembership
    @RoleName NVARCHAR(50)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        roles.[name] AS role_name, 
        members.[name] AS user_name
    FROM 
        sys.database_role_members AS drm
    INNER JOIN 
        sys.database_principals AS roles 
        ON drm.role_principal_id = roles.principal_id
    INNER JOIN 
        sys.database_principals AS members 
        ON drm.member_principal_id = members.principal_id
    WHERE 
        roles.name = @RoleName;
END;
GO

GRANT EXECUTE ON CheckRoleMembership TO DBA;
GRANT EXECUTE ON CheckRoleMembership TO UPD;
GRANT EXECUTE ON CheckRoleMembership TO ADT;


--TEST CASE 
--Admin can check the member for all role --> SUCCESS
EXECUTE AS LOGIN ='admin1';
Select * from Agents

EXEC CheckRoleMembership 'DBA';
EXEC CheckRoleMembership 'AGT';
EXEC CheckRoleMembership 'MKT';
EXEC CheckRoleMembership 'UPD';
EXEC CheckRoleMembership 'ANL';
EXEC CheckRoleMembership 'ADT';
EXEC CheckRoleMembership 'USR';
REVERT;

--User Portal Developer can check the member for all role --> SUCCESS
EXECUTE AS LOGIN ='userportal1';
EXEC CheckRoleMembership 'DBA';
EXEC CheckRoleMembership 'AGT';
EXEC CheckRoleMembership 'MKT';
EXEC CheckRoleMembership 'UPD';
EXEC CheckRoleMembership 'ANL';
EXEC CheckRoleMembership 'ADT';
EXEC CheckRoleMembership 'USR';
REVERT;

--Auditor can check the member for all role --> SUCCESS
EXECUTE AS LOGIN ='auditor1';
EXEC CheckRoleMembership 'DBA';
EXEC CheckRoleMembership 'AGT';
EXEC CheckRoleMembership 'MKT';
EXEC CheckRoleMembership 'UPD';
EXEC CheckRoleMembership 'ANL';
EXEC CheckRoleMembership 'ADT';
EXEC CheckRoleMembership 'USR';
REVERT;

-- Agent / Markerting / Analyst / End User cannot execute this stored procedure to check the member for all role --> FAIL AS EXPECTED
EXECUTE AS LOGIN ='agent1';
EXEC CheckRoleMembership 'DBA';
EXEC CheckRoleMembership 'AGT';
EXEC CheckRoleMembership 'MKT';
EXEC CheckRoleMembership 'UPD';
EXEC CheckRoleMembership 'ANL';
EXEC CheckRoleMembership 'ADT';
EXEC CheckRoleMembership 'USR';
REVERT;


----------------------------------------------------------------------
--2.7 Checking Granted Access 
----------------------------------------------------------------------
SELECT dp.NAME      AS SubjectName,
       dp.TYPE_DESC AS SubjectType,
       o.NAME       AS ObjectName,
       o.type_desc as ObjectType,
       p.PERMISSION_NAME as Permission,
       p.STATE_DESC AS PermissionType
FROM sys.database_permissions p
     LEFT OUTER JOIN sys.all_objects o
          ON p.MAJOR_ID = o.OBJECT_ID
     INNER JOIN sys.database_principals dp
          ON p.GRANTEE_PRINCIPAL_ID = dp.PRINCIPAL_ID
and dp.is_fixed_role=0
and dp.Name NOT in ('public','dbo')




----------------------------------------------------------------------
--3.0 Data Protection
----------------------------------------------------------------------

--3.1 Database TDE

--DROP MASTER KEY;
--CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'HPOstrong123@';
CREATE CERTIFICATE HPO_TDE WITH SUBJECT = 'CertForTDE';

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE HPO_TDE;

ALTER DATABASE DAMS SET ENCRYPTION ON;

BACKUP CERTIFICATE HPO_TDE
TO FILE = 'C:\Backups\HPO_TDE_Cert.cer'
WITH PRIVATE KEY (
    FILE = 'C:\Backups\HPO_TDE_Key.pvk',
    ENCRYPTION BY PASSWORD = 'BackupStrongP@ssw0rd!'
);

--3.2 Masking
--Step 1
ALTER TABLE Agents  
ALTER COLUMN Phone ADD MASKED WITH (FUNCTION = 'partial(4,"XXX-XXX",0)');

ALTER TABLE Agents  
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE Agents  
ALTER COLUMN Address ADD MASKED WITH (FUNCTION = 'partial(0,"[REDACTED]",0)');

--Step 2
GRANT UNMASK TO AGT;


--3.3 Backups
----------------------------------------------------------------------
--3.3.1 Copy-Only Backup (for any important updates or request)
----------------------------------------------------------------------

BACKUP DATABASE DAMS
--Change File Path
TO DISK = 'D:\CS DA Y3S2\DBS Database Security\Backup\DAMS_CopyOnly.bak'
WITH COPY_ONLY,
     INIT, 
     COMPRESSION,
     CHECKSUM,
     NAME = 'DAMS Copy-Only Backup',
     MEDIANAME = 'DAMSDevCopy';

----------------------------------------------------------------------
--3.3.2 System Backups (after any important updates if need to run manually)
----------------------------------------------------------------------
BACKUP DATABASE master
TO DISK = 'D:\CS DA Y3S2\DBS Database Security\Backup\master.bak'
WITH INIT, COMPRESSION, CHECKSUM, NAME = 'Master DB Backup';
BACKUP DATABASE msdb
TO DISK = 'D:\CS DA Y3S2\DBS Database Security\Backup\msdb.bak'
WITH INIT, COMPRESSION, CHECKSUM, NAME = 'MSDB Backup';
BACKUP DATABASE model
TO DISK = 'D:\CS DA Y3S2\DBS Database Security\Backup\model.bak'
WITH INIT, COMPRESSION, CHECKSUM, NAME = 'Model DB Backup';

----------------------------------------------------------------------
--3.3.3 SQL Agent System Backups
----------------------------------------------------------------------
-- Full Backup Code
-- 1. Create the job
USE msdb;
EXEC sp_add_job
    @job_name = N'DAMS_Full_T',
    @enabled = 1,
    @description = N'Full Backup',
    @start_step_id = 1;
GO

-- 2. Add a job step
EXEC sp_add_jobstep
    @job_name = N'DAMS_Full_T',
    @step_name = N'Full_Backup',
    @subsystem = N'TSQL',
    @command = N'PRINT ''BACKUP DATABASE DAMS TO DISK = ''D:\APU Assignments\Y3S2\DBS\Backups\DAMS_Full.bak''
MIRROR TO DISK = ''C:\Backups\DAMS_Full_Mirror.bak''
WITH FORMAT, INIT, COMPRESSION, CHECKSUM,
     NAME = ''Full Backup with Mirror'',
     MEDIANAME = ''DAMSBackupDisk'';',
    @retry_attempts = 0,
    @retry_interval = 0,
    @on_success_action = 1,  -- Go to the next step
    @on_fail_action = 2;     -- Quit with failure
GO

-- 3. Add a schedule
EXEC sp_add_schedule
    @schedule_name = N'Every_2AM',
    @enabled = 1,
    @freq_type = 4,  -- Daily
    @freq_interval = 1,
	@active_start_date = 20250804,  -- Start date: 4-Aug-2025
    @active_end_date = 20250808,   -- End date: 8-Aug-2025
    @active_start_time = 020000;  -- 9:00 AM
GO

-- 4. Attach the schedule to the job
EXEC sp_attach_schedule
    @job_name = N'DAMS_Full_T',
    @schedule_name = N'Every_2AM';
GO

-- 5. Add the job to the SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'DAMS_Full_T';
GO

-- Differential Backup Code
-- 1. Create the job
EXEC sp_add_job
    @job_name = N'DAMS_Differential_T',
    @enabled = 1,
    @description = N'Differential Backup',
    @start_step_id = 1;
GO

-- 2. Add a job step
EXEC sp_add_jobstep
    @job_name = N'DAMS_Differential_T',
    @step_name = N'Differential_Backup',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE DAMS
TO DISK = ''D:\APU Assignments\Y3S2\DBS\Backups\DAMS_Diff.bak''
WITH FORMAT, DIFFERENTIAL, INIT, COMPRESSION, CHECKSUM,
     NAME = ''Differential Backup'', 
     MEDIANAME = ''DAMSBackupDisk'';',
    @retry_attempts = 0,
    @retry_interval = 0,
    @on_success_action = 1,  -- Go to the next step
    @on_fail_action = 2;     -- Quit with failure
GO

-- 3. Add a schedule
EXEC sp_add_schedule
    @schedule_name = N'Every_4Hours_Daily',
    @enabled = 1,
    @freq_type = 4,  -- Daily
    @freq_interval = 1,  -- Every day
    @freq_subday_type = 8,  -- Hours
    @freq_subday_interval = 4,  -- Every 4 hours
    @active_start_date = 20250804,  -- Start date: 4-Aug-2025
    @active_end_date = 20250808,   -- End date: 8-Aug-2025
    @active_start_time = 060000,  -- Start at midnight
    @active_end_time = 235959;    -- End at 11:59:59 PM
GO

-- 4. Attach the schedule to the job
EXEC sp_attach_schedule
    @job_name = N'DAMS_Differential_T',
    @schedule_name = N'Every_4Hours';
GO

-- 5. Add the job to the SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'DAMS_Differential_T';
GO

-- Transactional Backup Code
-- 1. Create the job
EXEC sp_add_job
    @job_name = N'DAMS_Transactional_Log',
    @enabled = 1,
    @description = N'Transactional Log Backup',
    @start_step_id = 1;
GO

-- 2. Add a job step
EXEC sp_add_jobstep
    @job_name = N'DAMS_Transactional_Log',
    @step_name = N'Transactional_Backup',
    @subsystem = N'TSQL',
    @command = N'BACKUP LOG DAMS
TO DISK = ''D:\APU Assignments\Y3S2\DBS\Backups\DAMS_Log.trn''
WITH FORMAT, INIT, COMPRESSION, CHECKSUM,
     NAME = ''DAMS Transaction Log Backup'';',
    @retry_attempts = 0,
    @retry_interval = 0,
    @on_success_action = 1,  -- Go to the next step
    @on_fail_action = 2;     -- Quit with failure
GO

-- 3. Add a schedule
EXEC sp_add_schedule
    @schedule_name = N'Every_15Mins_next',
    @enabled = 1,
    @freq_type = 4,  -- Daily
    @freq_interval = 1,
    @freq_subday_type = 4,  -- Minutes
    @freq_subday_interval = 15,  -- Every 15 minutes
    @active_start_date = 20250804,
    @active_end_date = 20250808,
    @active_start_time = 000000,  -- 12:00 AM
    @active_end_time = 015900;    -- 1:59 AM
GO

EXEC sp_add_schedule
    @schedule_name = N'Every_15Min',
    @enabled = 1,
    @freq_type = 4,  -- Daily
    @freq_interval = 1,
    @freq_subday_type = 4,  -- Minutes
    @freq_subday_interval = 15,  -- Every 15 minutes
    @active_start_date = 20250804,
    @active_end_date = 20250808,
    @active_start_time = 021500,  -- 2:15 AM
    @active_end_time = 235959;    -- 11:59 PM
GO


-- 4. Attach the schedule to the job
EXEC sp_attach_schedule
    @job_name = N'DAMS_Transactional_Log',
    @schedule_name = N'Every_15Mins_next';
GO
EXEC sp_attach_schedule
    @job_name = N'DAMS_Transactional_Log',
    @schedule_name = N'Every_15Mins';
GO

-- 5. Add the job to the SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'DAMS_Transactional_Log';
GO

-- Weekly System DB Backup
EXEC sp_add_job
    @job_name = N'Weekly_System_DB_Backup',
    @enabled = 1,
    @description = N'Weekly backup of system databases (master, model, msdb) every Sunday at 3 AM.';
GO

-- Step 1: Backup master
EXEC sp_add_jobstep
    @job_name = N'Weekly_System_DB_Backup',
    @step_name = N'Backup master',
	@step_id = 1,
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE master
TO DISK = ''D:\APU Assignments\Y3S2\DBS\System Backups\master.bak''
WITH FORMAT, INIT, COMPRESSION, CHECKSUM, NAME = ''Master DB Backup'';',
    @on_success_action = 3,  -- Go to next step
	@on_success_step_id = 2,  -- Go to Step 2
    @on_fail_action = 2;     -- Quit with failure
GO

-- Step 2: Backup model
EXEC sp_add_jobstep
    @job_name = N'Weekly_System_DB_Backup',
    @step_name = N'Backup model',
	@step_id = 2,
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE model
TO DISK = ''D:\APU Assignments\Y3S2\DBS\System Backups\model.bak''
WITH FORMAT, INIT, COMPRESSION, CHECKSUM, NAME = ''Model DB Backup'';',
    @on_success_action = 3,
	@on_success_step_id = 3,  -- Go to Step 3
    @on_fail_action = 2;
GO

-- Step 3: Backup msdb
EXEC sp_add_jobstep
    @job_name = N'Weekly_System_DB_Backup',
    @step_name = N'Backup msdb',
	@step_id = 3,
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE msdb
TO DISK = ''D:\APU Assignments\Y3S2\DBS\System Backups\msdb.bak''
WITH FORMAT, INIT, COMPRESSION, CHECKSUM, NAME = ''MSDB Backup'';',
    @on_success_action = 1,
    @on_fail_action = 2;
GO

EXEC sp_add_schedule
    @schedule_name = N'Sunday_3AM_Weekly',
    @enabled = 1,
    @freq_type = 8,  -- Weekly
    @freq_interval = 1,  -- Sunday
	@freq_recurrence_factor = 1,  -- Every 1 week
    @active_start_time = 030000,  -- 3:00 AM
    @active_start_date = 20250804,  -- Start from Aug 4, 2025 or today's date
	@active_end_date = 20250814;
GO

EXEC sp_attach_schedule
    @job_name = N'Weekly_System_DB_Backup',
    @schedule_name = N'Sunday_3AM_Weekly';
GO

EXEC sp_add_jobserver
    @job_name = N'Weekly_System_DB_Backup';
GO

USE DAMS;

----------------------------------------------------------------------
--4.0 Auditing
----------------------------------------------------------------------
----------------------------------------------------------------------
--4.1 AFTER TRIGGER
----------------------------------------------------------------------
----------------------------------------------------------------------
--4.1.1 Agents Audit Log
----------------------------------------------------------------------
CREATE OR ALTER TRIGGER Agents_AuditTrigger
ON Agents
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    -- INSERT action
    INSERT INTO Agents_AuditLog (
        Action, AgentID, IdentificationNo, Name, Email, Phone, 
        Address, Status, CreatedAt, ActionDate, PerformedBy
    )
    SELECT 
        'INSERT', AgentID, IdentificationNo, Name, Email, Phone, 
        Address, Status, CreatedAt, GETDATE(), SYSTEM_USER
    FROM inserted
    WHERE NOT EXISTS (SELECT 1 FROM deleted);
    
    -- DELETE action
    INSERT INTO Agents_AuditLog (
        Action, AgentID, IdentificationNo, Name, Email, Phone, 
        Address, Status, CreatedAt, ActionDate, PerformedBy
    )
    SELECT 
        'DELETE', AgentID, IdentificationNo, Name, Email, Phone, 
        Address, Status, CreatedAt, GETDATE(), SYSTEM_USER
    FROM deleted
    WHERE NOT EXISTS (SELECT 1 FROM inserted);
    
    -- UPDATE action
    INSERT INTO Agents_AuditLog (
        Action, AgentID, IdentificationNo, Name, Email, Phone, 
        Address, Status, CreatedAt, ActionDate, PerformedBy
    )
    SELECT 
        'UPDATE', i.AgentID, i.IdentificationNo, i.Name, i.Email, i.Phone, 
        i.Address, i.Status, i.CreatedAt, GETDATE(), SYSTEM_USER
    FROM inserted i
    JOIN deleted d ON i.AgentID = d.AgentID
    WHERE 
        ISNULL(i.IdentificationNo, 0x) != ISNULL(d.IdentificationNo, 0x) OR
        i.Name != d.Name OR 
        ISNULL(i.Email, '') != ISNULL(d.Email, '') OR 
        ISNULL(i.Phone, '') != ISNULL(d.Phone, '') OR 
        ISNULL(i.Address, '') != ISNULL(d.Address, '') OR 
        i.Status != d.Status OR 
        i.CreatedAt != d.CreatedAt;
END;
GO
----------------------------------------------------------------------
--TEST CASE-- Agents Audit Log
----------------------------------------------------------------------
--Step1
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;

--Step 2
INSERT INTO Agents (Name, Email, IdentificationNO, Phone, Address, Status)
VALUES 
('Jenny',
 'jenny.tan@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('900101145678', 7, 0, '-'), 10, 0, '-'))),
 '011-3456789',
 '123 Jalan Mawar, Kuala Lumpur',
 'Active')

DELETE FROM dbo.Agents
WHERE Name = 'Jenny' AND Email = 'jenny.tan@example.com';


--Step3
 CLOSE SYMMETRIC KEY ICSymKey;

--Step4
SELECT * FROM Agents;
SELECT * FROM Agents_AuditLog;


----------------------------------------------------------------------
--4.1.2 Sales Audit Log
----------------------------------------------------------------------
CREATE OR ALTER TRIGGER Sales_AuditTrigger
ON Sales
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    -- INSERT action
    INSERT INTO Sales_AuditLog (Action, SaleID, AgentID, ProductID, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
    SELECT 'INSERT', SaleID, AgentID, ProductID, Quantity, TotalAmount, SaleDate, GETDATE(), SYSTEM_USER
    FROM inserted;

    -- DELETE action
    INSERT INTO Sales_AuditLog (Action, SaleID, AgentID, ProductID, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
    SELECT 'DELETE', SaleID, AgentID, ProductID, Quantity, TotalAmount, SaleDate, GETDATE(), SYSTEM_USER
    FROM deleted;

    -- UPDATE action
    INSERT INTO Sales_AuditLog (Action, SaleID, AgentID, ProductID, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
    SELECT 'UPDATE', i.SaleID, i.AgentID, i.ProductID, i.Quantity, i.TotalAmount, i.SaleDate, GETDATE(), SYSTEM_USER
    FROM inserted i
    JOIN deleted d ON i.SaleID = d.SaleID
    WHERE i.Quantity != d.Quantity OR i.TotalAmount != d.TotalAmount OR i.SaleDate != d.SaleDate;
END;
GO

----------------------------------------------------------------------
--TEST CASE-- Sales Audit Log
----------------------------------------------------------------------
--Step1
INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 5, 27.50, GETDATE());

DELETE FROM dbo.Sales
WHERE SaleID = 5;

--Step2
SELECT * FROM Sales;
SELECT * FROM Sales_AuditLog;

--Step3
--Approve/Reject from auditor

--Step4
SELECT * FROM Sales;
SELECT * FROM Sales_AuditLog;

----------------------------------------------------------------------
--4.1.3 Commission Audit Log
----------------------------------------------------------------------
CREATE OR ALTER TRIGGER Commission_AuditTrigger
ON Commission
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    -- INSERT action
    INSERT INTO Commission_AuditLog (Action, CommissionID, AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
    SELECT 'INSERT', CommissionID, AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt, GETDATE(), SYSTEM_USER
    FROM inserted;

    -- DELETE action
    INSERT INTO Commission_AuditLog (Action, CommissionID, AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
    SELECT 'DELETE', CommissionID, AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt, GETDATE(), SYSTEM_USER
    FROM deleted;

    -- UPDATE action
    INSERT INTO Commission_AuditLog (Action, CommissionID, AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
    SELECT 'UPDATE', i.CommissionID, i.AgentID, i.SaleID, i.CommissionRate, i.CommissionAmount, i.CreatedAt, GETDATE(), SYSTEM_USER
    FROM inserted i
    JOIN deleted d ON i.CommissionID = d.CommissionID
    WHERE i.CommissionRate != d.CommissionRate OR i.CommissionAmount != d.CommissionAmount OR i.CreatedAt != d.CreatedAt;
END;
GO
----------------------------------------------------------------------
--TEST CASE-- Commission Audit Log
----------------------------------------------------------------------
--Step1
INSERT INTO Commission (AgentID, SaleID, CommissionRate, CommissionAmount)
VALUES 
	(1, 1, 5.00, 2.50)

DELETE FROM dbo.Commission
WHERE CommissionID = 6 ;

--Step2
SELECT * FROM Commission;
SELECT * FROM Commission_AuditLog;


------------------------------------------------------------------------
----4.2 Auditing Server
------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- DROP AUDIT
--ALTER SERVER AUDIT SPECIFICATION[TrackDDLChanges]
--WITH (STATE = OFF);
--GO
--ALTER SERVER AUDIT [TrackDDLChanges]
--WITH (STATE = OFF);
--GO
--DROP SERVER AUDIT SPECIFICATION [TrackDDLChanges]
--DROP SERVER AUDIT [TrackDDLChanges]
--use MASTER

------------------------------------------------------------------------
----4.2.1 Track DCL Change
------------------------------------------------------------------------
use master;

CREATE SERVER AUDIT [TrackDCLChanges]
TO FILE (FILEPATH = 'D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\DCL_CHANGES\')

ALTER SERVER AUDIT [TrackDCLChanges]
WITH (STATE = ON);

CREATE SERVER AUDIT SPECIFICATION [TrackDCLChanges]
FOR SERVER AUDIT [TrackDCLChanges]
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP),
ADD (DATABASE_OWNERSHIP_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (USER_CHANGE_PASSWORD_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP)
WITH (STATE = ON);

------------------------------------------------------------------------
----4.2.2 Track DDL Change
------------------------------------------------------------------------
CREATE SERVER AUDIT [TrackDDLChanges]
TO FILE (FILEPATH = 'D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\DDL_CHANGES\')

ALTER SERVER AUDIT [TrackDDLChanges]
WITH (STATE = ON);

CREATE SERVER AUDIT SPECIFICATION [TrackDDLChanges]
FOR SERVER AUDIT [TrackDDLChanges]
ADD (DATABASE_OPERATION_GROUP),
ADD (DATABASE_CHANGE_GROUP),
ADD (DDL_EVENTS),
ADD (DATABASE_OBJECT_CHANGE_GROUP),
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP),
ADD (SERVER_OBJECT_CHANGE_GROUP)
WITH (STATE = ON);

------------------------------------------------------------------------
----4.2.3 Track DML Change
------------------------------------------------------------------------
CREATE SERVER AUDIT [TrackDMLChanges]
TO FILE (FILEPATH = 'D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\DML_CHANGES\')
GO

ALTER SERVER AUDIT [TrackDMLChanges]
WITH (STATE = ON);
GO

USE DAMS;
CREATE DATABASE AUDIT SPECIFICATION DAMSDMLChanges
FOR SERVER AUDIT TrackDMLChanges
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_ACCESS_GROUP),
ADD (INSERT, UPDATE, DELETE, SELECT
    ON DATABASE::DAMS BY public)
WITH (STATE = ON);
GO

------------------------------------------------------------------------
----4.2.4 Track Login
------------------------------------------------------------------------
use master;

CREATE SERVER AUDIT [TrackLogin]
TO FILE (FILEPATH = 'D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\LOGIN_ATTEMPT\')
GO

ALTER SERVER AUDIT [TrackLogin]
WITH (STATE = ON);
GO

CREATE SERVER AUDIT SPECIFICATION [TrackLoginAttempt]
FOR SERVER AUDIT [TrackLogin]
ADD (FAILED_LOGIN_GROUP),
ADD (LOGIN_CHANGE_PASSWORD_GROUP),
ADD (LOGOUT_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON);


------------------------------------------------------------------------
----4.2.5 View Audit Logs
------------------------------------------------------------------------
-- To wiew audit logs from each category
-- Using View

--LOGIN_ATTEMPT
CREATE VIEW vw_Audit_Login_Activity AS
SELECT 
    DATEADD(HOUR, 8, event_time) AS LocalEventTime,
    action_id,
    succeeded,
    session_id,
    server_principal_name AS [login_name],
    client_ip,
    application_name,
    CASE action_id
        WHEN 'LG' THEN 'Logout'
        WHEN 'LGI' THEN 'Login'
        WHEN 'LGF' THEN 'Failed Login'
        WHEN 'CP' THEN 'Password Change'
        ELSE action_id
    END AS action_type
FROM sys.fn_get_audit_file('D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\LOGIN_ATTEMPT\*', NULL, NULL)
GO

--DCL_CHANGES
CREATE VIEW vw_Audit_DCL_Changes AS
SELECT 
    DATEADD(HOUR, 8, event_time) AS LocalEventTime,
    action_id,
    succeeded,
    session_id,
    server_principal_name AS [user],
    database_name,
    object_name,
    statement
FROM sys.fn_get_audit_file('D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\DCL_CHANGES\*', NULL, NULL)
WHERE action_id IN ('GPD', 'DPD', 'RPD') -- GRANT/DENY/REVOKE permissions
GO

--DDL_CHANGES
CREATE VIEW vw_Audit_DDL_Changes AS
SELECT 
    DATEADD(HOUR, 8, event_time) AS LocalEventTime,
    action_id,
    succeeded,
    session_id,
    server_principal_name AS [user],
    database_name,
    object_name,
    statement,
    CASE action_id
        WHEN 'CR' THEN 'CREATE'
        WHEN 'AL' THEN 'ALTER'
        WHEN 'DR' THEN 'DROP'
        ELSE action_id
    END AS action_type
FROM sys.fn_get_audit_file('D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\DDL_CHANGES\*', NULL, NULL)
WHERE action_id IN ('CR', 'AL', 'DR', 'SL') -- CREATE/ALTER/DROP/SELECT (for objects)
GO

--DML_CHANGES
CREATE VIEW vw_Audit_DML_Changes AS
SELECT 
    DATEADD(HOUR, 8, event_time) AS LocalEventTime,
    action_id,
    succeeded,
    session_id,
    server_principal_name AS [user],
    database_name,
    schema_name,
    object_name,
    statement,
    CASE action_id
        WHEN 'IN' THEN 'INSERT'
        WHEN 'DL' THEN 'DELETE'
        WHEN 'UP' THEN 'UPDATE'
        WHEN 'SL' THEN 'SELECT'
        ELSE action_id
    END AS action_type
FROM sys.fn_get_audit_file('D:\CS DA Y3S2\DBS Database Security\SQL_SERVER_LOG\DML_CHANGES\*', NULL, NULL)
WHERE action_id IN ('IN', 'DL', 'UP', 'SL') -- INSERT/DELETE/UPDATE/SELECT
GO

--Grant Permission to Role ADT
GRANT SELECT ON vw_Audit_Login_Activity TO ADT;
GRANT SELECT ON vw_Audit_DCL_Changes TO ADT;
GRANT SELECT ON vw_Audit_DDL_Changes TO ADT;
GRANT SELECT ON vw_Audit_DML_Changes TO ADT;

--VIEW
SELECT * FROM vw_Audit_Login_Activity 
SELECT * FROM vw_Audit_DCL_Changes
SELECT * FROM vw_Audit_DDL_Changes 
SELECT * FROM vw_Audit_DML_Changes 


--Using SELECT *

---- View login events:
--SELECT * FROM sys.fn_get_audit_file('D:\APU Assignments\Y3S2\DBS\Audits\Login\*.sqlaudit', NULL, NULL);

---- View DDL changes:
--SELECT * FROM sys.fn_get_audit_file('D:\APU Assignments\Y3S2\DBS\Audits\DDL\*.sqlaudit', NULL, NULL);

---- View DCL activity:
--SELECT * FROM sys.fn_get_audit_file('D:\APU Assignments\Y3S2\DBS\Audits\DCL\*.sqlaudit', NULL, NULL);

---- View all DML operations (raw format)
--SELECT * 
--FROM sys.fn_get_audit_file(
--    'D:\APU Assignments\Y3S2\DBS\Audits\DML\*.sqlaudit', 
--    NULL, 
--    NULL
--)
--WHERE action_id IN ('IN', 'UP', 'DL', 'SL')  -- INSERT/UPDATE/DELETE/SELECT
--ORDER BY event_time DESC;




----------------------------------------------------------------------
--4.3 Logon Triggers 
----------------------------------------------------------------------
CREATE SERVER ROLE DBA;
----------------------------------------------------------------------
--4.3.1 Limiting the Number of Sessions for a Specific Login
----------------------------------------------------------------------
CREATE OR ALTER TRIGGER Logon_Limit_Sessions
ON ALL SERVER
WITH EXECUTE AS 'sa'  -- Or any login that has permission to evaluate the session
FOR LOGON
AS
BEGIN
    DECLARE @login SYSNAME = ORIGINAL_LOGIN();

	-- Enforce only if login is NOT 'admin1' AND NOT 'admin2'
	IF @login NOT IN ('admin1', 'admin2', 'sa', 'LAPTOP-013DINEP\HP', 'NT SERVICE\SQLSERVERAGENT', 'NT SERVICE\SQLAgent$MSSQLSERVER03')
		AND (
			SELECT COUNT(*) 
			FROM sys.dm_exec_sessions 
			WHERE is_user_process = 1 
			AND original_login_name = @login
		) > 3
		BEGIN
			PRINT 'Login attempt blocked: You already have more than 1 active session.';
			ROLLBACK;
		END
	END;
GO

----------------------------------------------------------------------
--4.3.2 Limiting the Hours SQL Server Can Be Accessed
----------------------------------------------------------------------

--Limit with Username
CREATE OR ALTER TRIGGER Logon_Limit_Hours
ON ALL SERVER
WITH EXECUTE AS 'sa'  -- Ensure this login has proper permissions
FOR LOGON
AS
BEGIN
    DECLARE @login SYSNAME = ORIGINAL_LOGIN();
    DECLARE @currentTime TIME = CAST(GETDATE() AS TIME);

    -- Enforce only for users NOT in the DBA role
    IF @login NOT IN ('admin1', 'admin2', 'userportal1', 'userportal2', 'sa', 'LAPTOP-013DINEP\HP', 'NT SERVICE\SQLSERVERAGENT', 'NT SERVICE\SQLAgent$MSSQLSERVER03')
    AND (@currentTime < '09:00' OR @currentTime > '18:00')
    BEGIN
        PRINT 'Login attempt blocked: Logins are only allowed between 9 AM and 5 PM.';
        ROLLBACK;
    END
END;
GO

--DROP TRIGGER Logon_Limit_Sessions ON ALL SERVER;
--GO

SELECT 
    name AS TriggerName,
    parent_class_desc AS Scope,
    is_disabled,
    create_date,
    modify_date,
    is_ms_shipped
FROM sys.server_triggers;

SELECT ORIGINAL_LOGIN() AS OriginalLogin, SYSTEM_USER AS SystemUser;
SELECT IS_SRVROLEMEMBER('DBA') AS IsDBA;
SELECT original_login_name, COUNT(*) AS SessionCount
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
GROUP BY original_login_name;

SELECT session_id, original_login_name
FROM sys.dm_exec_sessions;

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += 'KILL ' + CAST(session_id AS NVARCHAR) + ';'
FROM sys.dm_exec_sessions
WHERE login_name IN ('agent1', 'auditor1', 'marketing1', 'user1');

PRINT @sql; -- optional: see what you're about to run
EXEC sp_executesql @sql;


----------------------------------------------------------------------
--4.4 Temporal Tables (For Users, Agents, and Product)
----------------------------------------------------------------------
--ALTER TABLE dbo.Users
--SET (SYSTEM_VERSIONING = OFF);
--DROP TABLE Users;
--Drop Table UsersHistory;

ALTER TABLE dbo.Users
ADD ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START 
    DEFAULT GETUTCDATE(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END 
    DEFAULT '9999-12-31 23:59:59.9999999',
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);

ALTER TABLE dbo.Users
SET   ( SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UsersHistory))

ALTER TABLE dbo.Agents
ADD ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START 
    DEFAULT GETUTCDATE(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END 
    DEFAULT '9999-12-31 23:59:59.9999999',
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);

ALTER TABLE dbo.Agents
SET   ( SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.AgentsHistory))

ALTER TABLE dbo.Products
ADD ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START 
    DEFAULT GETUTCDATE(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END 
    DEFAULT '9999-12-31 23:59:59.9999999',
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);

ALTER TABLE dbo.Products
SET   ( SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ProductsHistory))




-- 4.5 Test Case
SELECT name, temporal_type_desc FROM sys.tables;

SELECT * from users;

INSERT INTO Users (IdentificationNO, Username, Password, Role)
VALUES 
(
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(NVARCHAR(20), STUFF(STUFF('902101145678', 7, 0, '-'), 10, 0, '-'))),
    'Meh',
    HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'Password1245!')),
    'User'
)

UPDATE dbo.Users
SET Username = 'updateduser'
WHERE UserID = '2';

-- Check updated
SELECT * FROM dbo.UsersHistory WHERE UserID = '2';

-- Check version
SELECT * FROM dbo.Users FOR SYSTEM_TIME ALL WHERE UserID = '2';

-- Check version (MYT)
SELECT 
    UserID, Username,
    DATEADD(HOUR, 8, ValidFrom) AS ValidFrom_MYT,
    CASE 
        WHEN ValidTo < '9999-12-31' 
        THEN DATEADD(HOUR, 8, ValidTo)
        ELSE ValidTo
    END AS ValidTo_MYT
FROM dbo.Users
FOR SYSTEM_TIME ALL
WHERE UserID = '2';
  