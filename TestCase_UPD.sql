----------------------------------------------------------------------
-- Test Case for User Portal Role (UPD) - Shortened Version
----------------------------------------------------------------------
-- Execute as userportal1 login
-- Remember to use REVERT once finished
EXECUTE AS LOGIN='userportal1'

----------------------------------------------------------------------
-- 1.1 Test SELECT - SUCCESS (UPD can access specific tables)
----------------------------------------------------------------------
-- User Portal userportal1 only can SELECT OWN row in Users Tables
-- UPD can SELECT Products & Notifications
SELECT * FROM Products;
SELECT * FROM Users;
SELECT * FROM Notifications;
SELECT * FROM Users_AuditLog;

----------------------------------------------------------------------
-- 1.2 Test SELECT - FAIL AS EXPECTED (UPD cannot access operational tables)
----------------------------------------------------------------------
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;
SELECT * FROM MKT_campaigns;

----------------------------------------------------------------------
-- 1.3 Test View - SUCCESS
----------------------------------------------------------------------
-- UPD can access limited views
SELECT * FROM Security.vw_MKTCampaigns_Limited;
SELECT * FROM Security.vw_Notifications_Limited;
SELECT * FROM Security.vw_Users_User;

----------------------------------------------------------------------
-- 2.1 Test INSERT - SUCCESS (UPD can insert notifications)
----------------------------------------------------------------------
-- UPD can insert into Notifications
INSERT INTO dbo.Notifications (Title, Message, TargetRole, CreatedAt, CreatedBy)
VALUES ('Portal Notification', 'Test notification from user portal.', 'USR', GETDATE(), 'userportal1');

INSERT INTO dbo.Notifications (Title, Message, TargetRole, CreatedAt, CreatedBy)
VALUES ('System Announcement', 'System maintenance scheduled for tonight.', 'All', GETDATE(), 'userportal1');

-- UPD can create new users through stored procedure
ALTER SECURITY POLICY Security.UsersSecurityPolicy WITH (STATE = OFF);
EXEC CreateUserAndAssignRole 'testuser_upd1', 'testpass123', 'USR';
ALTER SECURITY POLICY Security.UsersSecurityPolicy WITH (STATE = ON);

----------------------------------------------------------------------
-- 2.2 Test INSERT - FAIL AS EXPECTED (UPD cannot insert into operational tables)
----------------------------------------------------------------------
-- UPD cannot insert into Products
INSERT INTO dbo.Products (Name, Description, Price, CreatedAt)
VALUES ('Portal Product', 'Should not be allowed', 99.99, GETDATE());

-- UPD cannot insert into operational tables
INSERT INTO dbo.Agents (Name, Email, Phone, Address, Status, CreatedAt, UserID)
VALUES ('Portal Agent', 'portal@fake.com', '0123456789', 'Fake Address', 'Active', GETDATE(), 1);

INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 5, 25.00, GETDATE());

INSERT INTO dbo.Commission (AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt)
VALUES (1, 1, 5.00, 1.25, GETDATE());

INSERT INTO dbo.MKT_Campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy, CreatedAt)
VALUES ('Portal Campaign', 'Should not be allowed', '2025-09-01', '2025-09-30', 1000.00, 'Planned', 'userportal1', GETDATE());

-- UPD cannot insert into audit logs
INSERT INTO Users_AuditLog (UserID, Action, Username, Password, Role, CreatedAt, PerformedBy)
VALUES (1, 'INSERT', 'fake_user', 'password123', 'USR', GETDATE(), 'userportal1');

INSERT INTO Agents_AuditLog (AgentID, UserID, Action, Name, Email, Phone, Address, Status, CreatedAt, PerformedBy)
VALUES (1, 1, 'INSERT', 'Fake Agent', 'fake@example.com', '1234567890', 'Fake Address', 'Active', GETDATE(), 'userportal1');

INSERT INTO Sales_AuditLog (SaleID, AgentID, ProductID, Action, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 10, 100.00, GETDATE(), GETDATE(), 'userportal1');

INSERT INTO Commission_AuditLog (CommissionID, AgentID, SaleID, Action, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 5.00, 5.00, GETDATE(), GETDATE(), 'userportal1');

----------------------------------------------------------------------
-- 3.1 Test UPDATE - SUCCESS (UPD can update users and notifications)
----------------------------------------------------------------------
-- UPD can update their own user account
UPDATE Users
SET 
    Username = 'userportal1_updated',
    Password = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'NewPortalPass123!'))
WHERE Username = 'userportal1';

-- UPD can update other users they manage
UPDATE Users
SET 
    Username = 'testuser_upd1_updated',
    Password = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'UpdatedPass123!'))
WHERE Username = 'testuser_upd1';

-- UPD can update Notifications
UPDATE dbo.Notifications
SET 
    Title = 'Updated Portal Notification',
    Message = 'Updated notification message from user portal.',
    TargetRole = 'All'
WHERE Title = 'Portal Notification' AND CreatedBy = 'userportal1';

----------------------------------------------------------------------
-- 3.2 Test UPDATE - FAIL AS EXPECTED (UPD cannot update operational data)
----------------------------------------------------------------------
-- UPD cannot update Products
UPDATE dbo.Products
SET 
    Name = 'Updated Product Name',
    Price = 15.99
WHERE ProductID = 1;

-- UPD cannot update operational tables
UPDATE dbo.Agents
SET Status = 'Inactive'
WHERE AgentID = 1;

UPDATE dbo.Sales
SET 
    Quantity = 999,
    TotalAmount = 9999.99
WHERE SaleID = 1;

UPDATE dbo.Commission
SET 
    CommissionRate = 50.00,
    CommissionAmount = 999.99
WHERE CommissionID = 1;

UPDATE dbo.MKT_campaigns
SET 
    Budget = 999999.99,
    Status = 'Hacked'
WHERE CampaignID = 1;

-- UPD cannot update audit logs
UPDATE Users_AuditLog 
SET Role = 'DBA', Password = 'hacked'
WHERE U_AuditLogID = 1;

UPDATE Agents_AuditLog 
SET Status = 'Compromised', Phone = '000-0000'
WHERE A_AuditLogID = 1;

UPDATE Sales_AuditLog 
SET Quantity = 999, TotalAmount = 999999.99
WHERE S_AuditLogID = 1;

UPDATE Commission_AuditLog 
SET CommissionRate = 100.00, CommissionAmount = 999999.99
WHERE C_AuditLogID = 1;

----------------------------------------------------------------------
-- 4.1 Test DELETE - SUCCESS (UPD can delete notifications and users)
----------------------------------------------------------------------
-- UPD can delete from Notifications
DELETE FROM dbo.Notifications
WHERE Title = 'Updated Portal Notification' AND CreatedBy = 'userportal1';

DELETE FROM dbo.Notifications
WHERE Title = 'System Announcement' AND CreatedBy = 'userportal1';

-- UPD can delete users they manage
EXEC DeleteUserAndLogin 'testuser_upd1_updated';

----------------------------------------------------------------------
-- 4.2 Test DELETE - FAIL AS EXPECTED (UPD cannot delete from operational tables)
----------------------------------------------------------------------
-- UPD cannot delete from Products
DELETE FROM dbo.Products
WHERE ProductID = 1;

-- UPD cannot delete from operational tables
DELETE FROM dbo.Agents
WHERE AgentID = 1;

DELETE FROM dbo.Sales
WHERE SaleID = 1;

DELETE FROM dbo.Commission
WHERE CommissionID = 1;

DELETE FROM dbo.MKT_campaigns
WHERE CampaignID = 1;

-- UPD cannot delete from audit logs
DELETE FROM Users_AuditLog WHERE U_AuditLogID = 1;
DELETE FROM Agents_AuditLog WHERE A_AuditLogID = 1;
DELETE FROM Sales_AuditLog WHERE S_AuditLogID = 1;
DELETE FROM Commission_AuditLog WHERE C_AuditLogID = 1;

----------------------------------------------------------------------
-- 5. Test Stored Procedures - SUCCESS
----------------------------------------------------------------------
-- UPD can use user management stored procedures
EXEC CreateUserAndAssignRole 'testuser_portal', 'password123', 'USR';
EXEC CheckRoleMembership 'USR';
EXEC CheckRoleMembership 'UPD';

-- Clean up test user
EXEC DeleteUserAndLogin 'testuser_portal';

REVERT

----------------------------------------------------------------------
-- TEST CASE SUMMARIZE FOR UPD SPECIFIC VIEWS
----------------------------------------------------------------------
-- Original data access tests
SELECT * FROM MKT_campaigns;

-- SUCCESS - UPD can view marketing campaigns through their limited view
EXECUTE AS LOGIN='userportal1'
SELECT * FROM Security.vw_MKTCampaigns_Limited; 
REVERT

-- SUCCESS - UPD can view user data through their specific view
EXECUTE AS LOGIN='userportal1'
SELECT * FROM Security.vw_Users_User; 
REVERT

-- Regular user cannot access UPD specific functions --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
EXEC CreateUserAndAssignRole 'unauthorized_user', 'password123', 'USR';
REVERT