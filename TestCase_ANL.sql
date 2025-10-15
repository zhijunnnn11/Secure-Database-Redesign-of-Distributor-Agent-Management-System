----------------------------------------------------------------------
-- Test Case for Analyst Role (ANL) - Shortened Version
----------------------------------------------------------------------
-- Execute as analyst1 login
-- Remember to use REVERT once finished
EXECUTE AS LOGIN='analyst1'

----------------------------------------------------------------------
-- 1.1 Test SELECT - SUCCESS (ANL can view analytical tables)
----------------------------------------------------------------------
-- ANL Analyst can SELECT from Products, MKT_campaigns, Users for analysis
SELECT * FROM Products;
SELECT * FROM MKT_campaigns;
SELECT * FROM Users;

----------------------------------------------------------------------
-- 1.2 Test SELECT - FAIL AS EXPECTED (ANL cannot view operational tables)
----------------------------------------------------------------------
-- ANL cannot access sensitive operational data
SELECT * FROM Agents;
SELECT * FROM Commission;
SELECT * FROM Sales;
SELECT * FROM Notifications;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;

----------------------------------------------------------------------
-- 1.3 Test View - SUCCESS
----------------------------------------------------------------------
-- ANL can access analytical views with restricted/aggregated data
SELECT * FROM Security.vw_Sales_ANL;
SELECT * FROM Security.vw_MonthlyProductSales;
SELECT * FROM Security.vw_Notifications_Limited;

----------------------------------------------------------------------
-- 2.1 Test INSERT - FAIL AS EXPECTED (ANL has read-only access)
----------------------------------------------------------------------
-- ANL cannot insert into any operational tables
INSERT INTO dbo.Products (Name, Description, Price, CreatedAt)
VALUES ('Analyst Product', 'Unauthorized product creation', 99.99, GETDATE());

INSERT INTO dbo.MKT_Campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy, CreatedAt)
VALUES ('Unauthorized Campaign', 'Should not be allowed.', '2025-09-01', '2025-09-30', 5000.00, 'Planned', 'analyst1', GETDATE());

INSERT INTO dbo.Agents (Name, Email, Phone, Address, Status, CreatedAt, UserID)
VALUES ('Unauthorized Agent', 'fake@example.com', '0123456789', 'Fake Address', 'Active', GETDATE(), 1);

INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 999, 9999.99, GETDATE());

INSERT INTO dbo.Commission (AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt)
VALUES (1, 1, 50.00, 999.99, GETDATE());

INSERT INTO dbo.Notifications (Title, Message, TargetRole, CreatedAt, CreatedBy)
VALUES ('Unauthorized Notification', 'Should not be allowed', 'All', GETDATE(), 'analyst1');

-- ANL cannot use user management stored procedures
EXEC CreateUserAndAssignRole 'analyst_created_user', 'password123', 'DBA';

INSERT INTO Users_AuditLog (UserID, Action, Username, Password, Role, CreatedAt, PerformedBy)
VALUES (1, 'INSERT', 'fake_user', 'password123', 'DBA', GETDATE(), 'analyst1');

INSERT INTO Agents_AuditLog (AgentID, UserID, Action, Name, Email, Phone, Address, Status, CreatedAt, PerformedBy)
VALUES (1, 1, 'INSERT', 'Fake Agent', 'fake@example.com', '1234567890', 'Fake Address', 'Active', GETDATE(), 'analyst1');

INSERT INTO Sales_AuditLog (SaleID, AgentID, ProductID, Action, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 999, 9999.99, GETDATE(), GETDATE(), 'analyst1');

INSERT INTO Commission_AuditLog (CommissionID, AgentID, SaleID, Action, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 50.00, 999.99, GETDATE(), GETDATE(), 'analyst1');

----------------------------------------------------------------------
-- 3.1 Test UPDATE - SUCCESS (ANL can update own profile)
----------------------------------------------------------------------
-- ANL can update their own user account
UPDATE Users
SET 
    Username = 'analyst1_updated',
    Password = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(255), 'NewAnalystPass123!'))
WHERE Username = 'analyst1' AND Role = 'ANL';

----------------------------------------------------------------------
-- 3.2 Test UPDATE - FAIL AS EXPECTED (ANL cannot update operational data)
----------------------------------------------------------------------
-- ANL cannot update other users
UPDATE Users
SET Username = 'hacked_user'
WHERE UserID = 1;

-- ANL cannot update Products
UPDATE dbo.Products
SET 
    Name = 'Updated Product Name',
    Price = 15.99
WHERE ProductID = 1;

-- ANL cannot update MKT_campaigns  
UPDATE dbo.MKT_campaigns
SET 
    Budget = 20000.00,
    Status = 'Updated'
WHERE Title = 'Eat Green Campaign';

-- ANL cannot update operational tables
UPDATE dbo.Agents
SET Status = 'Inactive'
WHERE AgentID = 1;

UPDATE dbo.Sales
SET Quantity = 999
WHERE SaleID = 1;

UPDATE dbo.Commission
SET CommissionAmount = 9999.99
WHERE CommissionID = 1;

UPDATE dbo.Notifications
SET Message = 'Unauthorized update'
WHERE NotificationID = 1;

-- ANL cannot update audit logs
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
-- 4.1 Test DELETE - FAIL AS EXPECTED (ANL cannot delete data)
----------------------------------------------------------------------
-- ANL cannot delete from any tables
DELETE FROM dbo.Products WHERE ProductID = 1;
DELETE FROM dbo.MKT_campaigns WHERE CampaignID = 1;
DELETE FROM dbo.Users WHERE UserID = 1;
DELETE FROM dbo.Agents WHERE AgentID = 1;
DELETE FROM dbo.Sales WHERE SaleID = 1;
DELETE FROM dbo.Commission WHERE CommissionID = 1;
DELETE FROM dbo.Notifications WHERE NotificationID = 1;

-- ANL cannot delete from audit logs
DELETE FROM Users_AuditLog WHERE U_AuditLogID = 1;
DELETE FROM Agents_AuditLog WHERE A_AuditLogID = 1;
DELETE FROM Sales_AuditLog WHERE S_AuditLogID = 1;
DELETE FROM Commission_AuditLog WHERE C_AuditLogID = 1;

-- ANL cannot use delete procedures
EXEC DeleteUserAndLogin 'testuser123';

REVERT

----------------------------------------------------------------------
-- TEST CASE SUMMARIZE FOR ANL SPECIFIC VIEWS
----------------------------------------------------------------------
-- Original Sales data
SELECT * FROM Sales;

-- SUCCESS - ANL can view sales through their specific view
EXECUTE AS LOGIN='analyst1'
SELECT * FROM Security.vw_Sales_ANL; 
REVERT

-- SUCCESS - ANL can view monthly product sales
EXECUTE AS LOGIN='analyst1'
SELECT * FROM Security.vw_MonthlyProductSales; 
REVERT

-- User cannot view ANL specific data --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Sales_ANL; 
REVERT