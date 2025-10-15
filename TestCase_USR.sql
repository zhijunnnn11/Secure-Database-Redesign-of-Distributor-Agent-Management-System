----------------------------------------------------------------------
-- Test Case for User Role (USR) - Shortened Version
----------------------------------------------------------------------
-- Execute as user1 login
-- Remember to use REVERT once finished
EXECUTE AS LOGIN='user1'

----------------------------------------------------------------------
-- 1.1 Test SELECT - FAIL AS EXPECTED (USR cannot access any base tables)
----------------------------------------------------------------------
-- User cannot select from any base tables
SELECT * FROM Agents;
SELECT * FROM Products;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;
SELECT * FROM Notifications;
SELECT * FROM MKT_campaigns;
SELECT * FROM Users;

----------------------------------------------------------------------
-- 1.2 Test View - SUCCESS (USR can access restricted user views)
----------------------------------------------------------------------
-- User can have Restricted View on Notifications & MKT_campaigns & Users (own)
SELECT * FROM Security.vw_Notifications_User;
SELECT * FROM Security.vw_MKTCampaigns_User;
SELECT * FROM Security.vw_Users_User;

----------------------------------------------------------------------
-- 1.3 Test View Access - FAIL AS EXPECTED
----------------------------------------------------------------------
-- USR cannot access other restricted views
SELECT * FROM Security.vw_Sales_ANL;
SELECT * FROM Security.vw_MonthlyProductSales;
SELECT * FROM Security.vw_Notifications_Limited;
SELECT * FROM vw_Audit_Login_Activity;
SELECT * FROM vw_Audit_DCL_Changes;
SELECT * FROM vw_Audit_DDL_Changes;
SELECT * FROM vw_Audit_DML_Changes;

----------------------------------------------------------------------
-- 2.1 Test INSERT - FAIL AS EXPECTED (USR cannot insert into any tables)
----------------------------------------------------------------------
-- User cannot insert into any base tables
INSERT INTO dbo.Products (Name, Description, Price, CreatedAt)
VALUES ('User Product', 'Should not be allowed', 99.99, GETDATE());

INSERT INTO dbo.Agents (Name, Email, Phone, Address, Status, CreatedAt, UserID)
VALUES ('User Agent', 'user@fake.com', '0123456789', 'Fake Address', 'Active', GETDATE(), 1);

INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 5, 25.00, GETDATE());

INSERT INTO dbo.Commission (AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt)
VALUES (1, 1, 5.00, 1.25, GETDATE());

INSERT INTO dbo.Notifications (Title, Message, TargetRole, CreatedAt, CreatedBy)
VALUES ('User Notification', 'Should not be allowed', 'All', GETDATE(), 'user1');

INSERT INTO dbo.MKT_Campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy, CreatedAt)
VALUES ('User Campaign', 'Should not be allowed', '2025-09-01', '2025-09-30', 1000.00, 'Planned', 'user1', GETDATE());

INSERT INTO dbo.Users (Username, Password, Role, CreatedAt)
VALUES ('user_created_account', HASHBYTES('SHA2_256', 'password'), 'DBA', GETDATE());

-- User cannot insert into audit logs
INSERT INTO Users_AuditLog (UserID, Action, Username, Password, Role, CreatedAt, PerformedBy)
VALUES (1, 'INSERT', 'fake_user', 'password123', 'USR', GETDATE(), 'user1');

INSERT INTO Agents_AuditLog (AgentID, UserID, Action, Name, Email, Phone, Address, Status, CreatedAt, PerformedBy)
VALUES (1, 1, 'INSERT', 'Fake Agent', 'fake@example.com', '1234567890', 'Fake Address', 'Active', GETDATE(), 'user1');

INSERT INTO Sales_AuditLog (SaleID, AgentID, ProductID, Action, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 10, 100.00, GETDATE(), GETDATE(), 'user1');

INSERT INTO Commission_AuditLog (CommissionID, AgentID, SaleID, Action, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 5.00, 5.00, GETDATE(), GETDATE(), 'user1');

----------------------------------------------------------------------
-- 3.1 Test UPDATE - LIMITED SUCCESS (USR can only update own profile)
----------------------------------------------------------------------
-- User can update their own profile (username and password only)
UPDATE Users
SET 
    Username = 'user1_updated',
    Password = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'NewUserPassword123!'))
WHERE Username = 'user1';

-- User can update their password
UPDATE Users
SET Password = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'AnotherNewPassword123!'))
WHERE Username = 'user1_updated';

----------------------------------------------------------------------
-- 3.2 Test UPDATE - FAIL AS EXPECTED (USR cannot update other data)
----------------------------------------------------------------------
-- User cannot change their own role
UPDATE Users
SET Role = 'DBA'
WHERE Username = 'user1_updated';

-- User cannot update any other tables
UPDATE dbo.Products
SET Price = 0.01
WHERE ProductID = 1;

UPDATE dbo.Agents
SET Status = 'Inactive'
WHERE AgentID = 1;

UPDATE dbo.Sales
SET TotalAmount = 999999.99
WHERE SaleID = 1;

UPDATE dbo.Commission
SET CommissionAmount = 999999.99
WHERE CommissionID = 1;

UPDATE dbo.Notifications
SET Message = 'Hacked message'
WHERE NotificationID = 1;

UPDATE dbo.MKT_campaigns
SET Budget = 999999.99
WHERE CampaignID = 1;

-- User cannot update other users' accounts
UPDATE Users
SET Role = 'DBA', Username = 'admin_compromised'
WHERE UserID = 1;

-- User cannot update audit logs
UPDATE Users_AuditLog 
SET Role = 'DBA'
WHERE U_AuditLogID = 1;

UPDATE Agents_AuditLog 
SET Status = 'Compromised'
WHERE A_AuditLogID = 1;

UPDATE Sales_AuditLog 
SET TotalAmount = 999999.99
WHERE S_AuditLogID = 1;

UPDATE Commission_AuditLog 
SET CommissionAmount = 999999.99
WHERE C_AuditLogID = 1;

----------------------------------------------------------------------
-- 4.1 Test DELETE - FAIL AS EXPECTED (USR cannot delete anything)
----------------------------------------------------------------------
-- User cannot delete from any tables
DELETE FROM dbo.Products WHERE ProductID = 1;
DELETE FROM dbo.Agents WHERE AgentID = 1;
DELETE FROM dbo.Sales WHERE SaleID = 1;
DELETE FROM dbo.Commission WHERE CommissionID = 1;
DELETE FROM dbo.Notifications WHERE NotificationID = 1;
DELETE FROM dbo.MKT_campaigns WHERE CampaignID = 1;

-- User cannot delete other users
DELETE FROM Users WHERE UserID = 1;

-- User cannot delete their own account
DELETE FROM Users WHERE Username = 'user1_updated';

-- User cannot delete from audit logs
DELETE FROM Users_AuditLog WHERE U_AuditLogID = 1;
DELETE FROM Agents_AuditLog WHERE A_AuditLogID = 1;
DELETE FROM Sales_AuditLog WHERE S_AuditLogID = 1;
DELETE FROM Commission_AuditLog WHERE C_AuditLogID = 1;

----------------------------------------------------------------------
-- 5. Test Stored Procedures - FAIL AS EXPECTED (USR has no admin permissions)
----------------------------------------------------------------------
-- User cannot use administrative stored procedures
EXEC CreateUserAndAssignRole 'user_created_user', 'password123', 'USR';
EXEC DeleteUserAndLogin 'someuser';
EXEC CheckRoleMembership 'DBA';
EXEC CheckRoleMembership 'USR';

-- User cannot access encrypted/decrypted user data
EXECUTE Security.usp_GetDecryptedUsers;

----------------------------------------------------------------------
-- 6. Test Encryption Access - FAIL AS EXPECTED
----------------------------------------------------------------------
-- User cannot open symmetric keys
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;

-- User cannot work with encrypted data
INSERT INTO Users (IdentificationNO, Username, Password, Role)
VALUES 
(
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(NVARCHAR(20), STUFF(STUFF('950505123456', 7, 0, '-'), 10, 0, '-'))),
    'encrypted_user',
    HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'TestPassword123!')),
    'USR'
);

CLOSE SYMMETRIC KEY ICSymKey;

----------------------------------------------------------------------
-- 7. Test Schema Access - FAIL AS EXPECTED
----------------------------------------------------------------------
-- User cannot view system/schema information
SELECT * FROM sys.tables;
SELECT * FROM sys.columns;
SELECT * FROM sys.views;
SELECT * FROM sys.procedures;
SELECT * FROM sys.database_permissions;
SELECT * FROM sys.database_principals;
SELECT * FROM sys.database_role_members;

-- User cannot view information schema
SELECT * FROM INFORMATION_SCHEMA.TABLES;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;
SELECT * FROM INFORMATION_SCHEMA.VIEWS;
SELECT * FROM INFORMATION_SCHEMA.ROUTINES;

REVERT

----------------------------------------------------------------------
-- TEST CASE SUMMARIZE FOR USR SPECIFIC VIEWS
----------------------------------------------------------------------
-- Original data that USR cannot access
SELECT * FROM Products;
SELECT * FROM MKT_campaigns;

-- SUCCESS - USR can view data through their specific views only
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Notifications_User; 
REVERT

EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_MKTCampaigns_User; 
REVERT

EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Users_User; 
REVERT

-- Marketing user cannot access USR specific functions --> FAIL AS EXPECTED
EXECUTE AS LOGIN='marketing1'
SELECT * FROM Security.vw_Users_User;
REVERT