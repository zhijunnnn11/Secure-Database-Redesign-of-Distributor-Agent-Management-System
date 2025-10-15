----------------------------------------------------------------------
-- Test Case for Auditor Role (ADT) - Shortened Version
----------------------------------------------------------------------
-- Execute as auditor1 login
-- Remember to use REVERT once finished
EXECUTE AS LOGIN='auditor1'

----------------------------------------------------------------------
-- 1.1 Test SELECT - SUCCESS (ADT can view most tables)
----------------------------------------------------------------------
-- ADT Auditor can SELECT All Audit Log & Products & Users & Agents & Sales & Commission Tables
SELECT * FROM Users;
SELECT * FROM Products;
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Notifications;
SELECT * FROM MKT_campaigns;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;

----------------------------------------------------------------------
-- 1.2 Test View - SUCCESS
----------------------------------------------------------------------
-- ADT can access audit-specific views
SELECT * FROM vw_Audit_Login_Activity;
SELECT * FROM vw_Audit_DCL_Changes;
SELECT * FROM vw_Audit_DDL_Changes;
SELECT * FROM vw_Audit_DML_Changes;
SELECT * FROM Security.vw_Notifications_Limited;

----------------------------------------------------------------------
-- 2.1 Test INSERT - SUCCESS (ADT can insert into operational tables)
----------------------------------------------------------------------
-- ADT can insert into Agents, Sales, Commission, Users
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;

INSERT INTO Agents (Name, Email, IdentificationNO, Phone, Address, Status)
VALUES 
('Audit Test Agent',
 'audit.test@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('950505123456', 7, 0, '-'), 10, 0, '-'))),
 '012-9876543',
 '789 Audit Street, Kuala Lumpur',
 'Active');

INSERT INTO Users (IdentificationNO, Username, Password, Role)
VALUES 
(
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(NVARCHAR(20), STUFF(STUFF('950505123456', 7, 0, '-'), 10, 0, '-'))),
    'audituser1',
    HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'AuditSecure123!')),
    'USR'
);

CLOSE SYMMETRIC KEY ICSymKey;

INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 3, 16.50, GETDATE());

INSERT INTO dbo.Commission (AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt)
VALUES (1, (SELECT MAX(SaleID) FROM Sales), 4.50, 0.74, GETDATE());

----------------------------------------------------------------------
-- 2.2 Test INSERT - FAIL AS EXPECTED (Audit logs cannot be modified)
----------------------------------------------------------------------
-- ADT cannot insert into audit log tables (these are managed by triggers)
INSERT INTO Users_AuditLog (UserID, Action, Username, Password, Role, CreatedAt, PerformedBy)
VALUES (1, 'INSERT', 'test_user', 'password123', 'USR', GETDATE(), 'auditor1');

INSERT INTO Agents_AuditLog (AgentID, Action, Name, Email, Phone, Address, Status, CreatedAt, PerformedBy)
VALUES (1, 'INSERT', 'Test Agent', 'test@example.com', '1234567890', '123 Test St', 'Active', GETDATE(), 'auditor1');

INSERT INTO Sales_AuditLog (SaleID, AgentID, ProductID, Action, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 10, 100.00, GETDATE(), GETDATE(), 'auditor1');

INSERT INTO Commission_AuditLog (CommissionID, AgentID, SaleID, Action, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 5.00, 5.00, GETDATE(), GETDATE(), 'auditor1');

-- ADT cannot insert into Products, Notifications, MKT_campaigns
INSERT INTO dbo.Products (Name, Description, Price, CreatedAt)
VALUES ('Audit Product', 'Test product for audit', 9.99, GETDATE());

INSERT INTO dbo.Notifications (Title, Message, TargetRole, CreatedAt, CreatedBy)
VALUES ('Audit Notification', 'Test notification from auditor.', 'All', GETDATE(), 'auditor1');

INSERT INTO dbo.MKT_Campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy, CreatedAt)
VALUES ('Audit Campaign', 'Test campaign for audit purposes.', '2025-08-01', '2025-08-31', 5000.00, 'Planned', 'auditor1', GETDATE());

----------------------------------------------------------------------
-- 3.1 Test UPDATE - SUCCESS (ADT can update operational tables)
----------------------------------------------------------------------
-- ADT can update Agents, Sales, Commission, Users
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;

UPDATE Agents
SET Phone = '012-1111111',
    Address = 'Updated Audit Address'
WHERE Name = 'Audit Test Agent';

CLOSE SYMMETRIC KEY ICSymKey;

UPDATE dbo.Sales
SET Quantity = 5,
    TotalAmount = 27.50
WHERE AgentID = 1 AND ProductID = 1 AND Quantity = 3;

UPDATE dbo.Commission
SET CommissionRate = 5.00,
    CommissionAmount = 1.38
WHERE AgentID = 1 AND CommissionRate = 4.50;

-- ADT can update user records
UPDATE Users
SET Username = 'auditor1_updated'
WHERE Username = 'audituser1';

----------------------------------------------------------------------
-- 3.2 Test UPDATE - FAIL AS EXPECTED (ADT cannot update audit logs/restricted tables)
----------------------------------------------------------------------
-- ADT cannot update audit log tables
UPDATE Users_AuditLog 
SET Role = 'MKT', Password = 'updatedpass1'
WHERE U_AuditLogID = 1;

UPDATE Agents_AuditLog 
SET Status = 'Inactive', Phone = '555-5678'
WHERE A_AuditLogID = 1;

UPDATE Sales_AuditLog 
SET Quantity = 6, TotalAmount = 1500.60
WHERE S_AuditLogID = 1;

UPDATE Commission_AuditLog 
SET CommissionRate = 0.20, CommissionAmount = 250.12
WHERE C_AuditLogID = 1;

-- ADT cannot update Products, Notifications, MKT_campaigns
UPDATE dbo.Products
SET Name = 'Updated Product Name',
    Price = 15.99
WHERE Name = 'Organic Spinach';

UPDATE dbo.Notifications
SET Title = 'Updated Notification',
    Message = 'Updated notification message'
WHERE Title = 'Welcome!';

UPDATE dbo.MKT_campaigns
SET Budget = 20000.00,
    Status = 'Ongoing'
WHERE Title = 'Eat Green Campaign';

----------------------------------------------------------------------
-- 4.1 Test DELETE - SUCCESS (ADT can delete from operational tables)
----------------------------------------------------------------------
-- ADT can delete from Agents, Sales, Commission, Users
DELETE FROM dbo.Commission
WHERE AgentID = 1 AND CommissionRate = 5.00 AND CommissionAmount = 1.38;

DELETE FROM dbo.Sales
WHERE AgentID = 1 AND ProductID = 1 AND Quantity = 5;

DELETE FROM dbo.Agents
WHERE Name = 'Audit Test Agent';

DELETE FROM Users
WHERE Username = 'auditor1_updated';

----------------------------------------------------------------------
-- 4.2 Test DELETE - FAIL AS EXPECTED (ADT cannot delete from audit logs/restricted tables)
----------------------------------------------------------------------
-- ADT cannot delete from audit log tables
DELETE FROM Users_AuditLog WHERE U_AuditLogID = 1;
DELETE FROM Agents_AuditLog WHERE A_AuditLogID = 1;
DELETE FROM Sales_AuditLog WHERE S_AuditLogID = 1;
DELETE FROM Commission_AuditLog WHERE C_AuditLogID = 1;

-- ADT cannot delete from Products, Notifications, MKT_campaigns
DELETE FROM dbo.Products
WHERE Name = 'Organic Spinach';

DELETE FROM dbo.Notifications
WHERE Title = 'Welcome!';

DELETE FROM dbo.MKT_Campaigns
WHERE Title = 'Eat Green Campaign';

----------------------------------------------------------------------
-- 5. Test Stored Procedures - SUCCESS (ADT has user management permissions)
----------------------------------------------------------------------
-- ADT can create and delete users
EXEC CreateUserAndAssignRole 'testuser_adt', 'testpass123', 'USR';
EXEC CheckRoleMembership 'DBA';
EXEC CheckRoleMembership 'ADT';

-- ADT can view decrypted user data
EXECUTE Security.usp_GetDecryptedUsers;

-- Clean up test user
EXEC DeleteUserAndLogin 'testuser_adt';

----------------------------------------------------------------------
-- 6. Test Encryption Access - SUCCESS (ADT has encryption permissions)
----------------------------------------------------------------------
-- ADT can work with encrypted data
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;

-- Verify encrypted data can be decrypted
SELECT 
    'Decryption Test' AS Test_Type,
    AgentID,
    Name,
    Email,
    CONVERT(NVARCHAR(20), DecryptByKey(IdentificationNO)) AS DecryptedID,
    Phone,
    Address,
    Status
FROM Agents 
WHERE AgentID <= 3;

CLOSE SYMMETRIC KEY ICSymKey;

REVERT

----------------------------------------------------------------------
-- TEST CASE SUMMARIZE FOR ADT SPECIFIC VIEWS
----------------------------------------------------------------------
-- Original audit data access
SELECT * FROM vw_Audit_Login_Activity;

-- SUCCESS - ADT can view all audit views
EXECUTE AS LOGIN='auditor1'
SELECT * FROM vw_Audit_Login_Activity; 
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM vw_Audit_DCL_Changes; 
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM vw_Audit_DDL_Changes; 
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM vw_Audit_DML_Changes; 
REVERT

-- Regular user cannot access audit views --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM vw_Audit_Login_Activity;
REVERT