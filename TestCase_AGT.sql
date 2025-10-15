----------------------------------------------------------------------
-- Test Case for Agent Role
----------------------------------------------------------------------
----------------------------------------------------------------------
-- 1.1 Test SELECT   -- SUCESSS
----------------------------------------------------------------------
EXECUTE AS Login='agent1'
REVERT
--Agents agent1 only can SELECT agent1(own) row in Agents & Sales & Commission Tables
--Agents can SELECT ALL Products
SELECT * FROM Agents;
SELECT * FROM Products;
SELECT * FROM Sales;
SELECT * FROM Commission;


----------------------------------------------------------------------
-- 1.2 Test SELECT   -- FAIL AS EXPECTED
----------------------------------------------------------------------
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;
SELECT * FROM Notifications;
SELECT * FROM MKT_campaigns;
SELECT * FROM Users;


----------------------------------------------------------------------
-- 1.3 Test View   -- SUCCESS
----------------------------------------------------------------------
--Agent can have Restrict View on Notifications & MKT_campaigns
SELECT * FROM Security.vw_Notifications_Limited;
SELECT * FROM Security.vw_MKTCampaigns_Limited;


----------------------------------------------------------------------
-- 2.1 Test INSERT    -- SUCCESS
----------------------------------------------------------------------
--Will Record to Audit Log Once Auditor Approve then write into Sales tables
INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 5, 27.50, GETDATE());

----------------------------------------------------------------------
-- 2.2 Test INSERT    -- FAIL EXPECTED
----------------------------------------------------------------------
INSERT INTO dbo.Agents (Name, Email, Phone, Address, Status, CreatedAt)
VALUES ('John Doe', 'john.doe@example.com', '0123456789', '123 Example St, Kuala Lumpur', 'Active', GETDATE());

INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (2, 1, 5, 27.50, GETDATE());

INSERT INTO dbo.Products (Name, Description, Price, CreatedAt)
VALUES ('Organic Broccoli', 'Fresh organic broccoli 500g pack', 5.50, GETDATE());

INSERT INTO dbo.Commission (AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt)
VALUES (1, 1, 5.00, 1.38, GETDATE());

INSERT INTO dbo.Notifications (Title, Message, TargetRole, CreatedAt, CreatedBy)
VALUES ('New Sale Recorded', 'A new sale has been recorded for Agent John Doe.', 'All', GETDATE(), 'admin_user1');

INSERT INTO dbo.MKT_Campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy, CreatedAt)
VALUES ('Summer Sale Campaign', 'Promote all summer fruits.', '2025-06-01', '2025-06-30', 10000.00, 'Planned', 'admin_user1', GETDATE());

--Add User Login
EXEC CreateUserAndAssignRole 'user5', 'user567', 'USR';

INSERT INTO Users_AuditLog (UserID, Action, Username, Password, Role, CreatedAt, PerformedBy)
VALUES (1, 'INSERT', 'john_doe', 'password123', 'AGT', GETDATE(), 'admin_user');

INSERT INTO Agents_AuditLog (AgentID, UserID, Action, Name, Email, Phone, Address, Status, CreatedAt, PerformedBy)
VALUES (1, 1, 'INSERT', 'John Doe', 'john@example.com', '1234567890', '123 Main St', 'Active', GETDATE(), 'admin_user');

INSERT INTO Sales_AuditLog (SaleID, AgentID, ProductID, Action, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 10, 100.00, GETDATE(), GETDATE(), 'admin_user');

INSERT INTO Commission_AuditLog (CommissionID, AgentID, SaleID, Action, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 5.00, 5.00, GETDATE(), GETDATE(), 'admin_user');


----------------------------------------------------------------------
-- 3.1 Test UPDATE    -- SUCCESS  
---------------------------------------------------------------------

-- Update agent1's user account (can only change username and password)
UPDATE Users
SET 
    Username = 'agent1',
    Password = 'agent123'
WHERE UserID = 1;


--SUCCESS
UPDATE dbo.Agents
SET 
	Name = 'Kelly',
	Email = 'kelly.updated@example.com',
	Phone = '0987654321',
	Address = '456 New St, Kuala Lumpur',
	Status = 'Active',  
	CreatedAt = GETDATE() 
WHERE AgentID = 2; 


-- Update agent1's sale (SaleID = 1) SUCCESS
UPDATE Sales
SET 
    Quantity = 15,
    TotalAmount = 75.00  
WHERE SaleID = 1 
AND AgentID = 1;  -- Ensure the sale belongs to agent1





----------------------------------------------------------------------
-- 3.1 Test UPDATE    -- FAIL AS EXPECTED
----------------------------------------------------------------------
--Cannot Update others Agents row
UPDATE dbo.Agents
SET 
	Name = 'John Doe New',
	Email = 'john.doe.updated@example.com',
	Phone = '0987654321',
	Address = '456 New St, Kuala Lumpur',
	Status = 'Inactive',  -- Changing status to 'Inactive'
	CreatedAt = GETDATE() -- Updates the CreatedAt field to current date
WHERE AgentID = 2; 

UPDATE dbo.Products
SET 
	Name = 'Organic Broccoli New',
	Description = 'Fresh organic broccoli 600g pack',
	Price = 6.00,  -- Updated price
	CreatedAt = GETDATE()  -- Updates the CreatedAt field to current date
WHERE Name = 'Organic Broccoli';  


UPDATE dbo.Commission
SET 
	CommissionRate = 1.00,  -- Updated commission rate
	CommissionAmount = 2.75,  -- Updated commission amount
	CreatedAt = GETDATE()  -- Updates the CreatedAt field to current date
WHERE CommissionID = 1;  

UPDATE dbo.Notifications
SET 
	Title = 'Updated Sale Recorded',
	Message = 'An updated sale has been recorded for Agent John Doe.',
	TargetRole = 'All',
	CreatedAt = GETDATE(),  -- Updates the CreatedAt field to current date
	CreatedBy = 'admin1_updated'  -- Updated CreatedBy
WHERE Title = 'Sale Recorded';  

UPDATE dbo.MKT_campaigns
SET 
	Title = 'Updated Summer Sale Campaign',
	Description = 'Promote all summer fruits with additional discounts.',
	StartDate = '2025-06-01',
	EndDate = '2025-07-31',  -- Extended campaign end date
	Budget = 15000.00,  -- Increased budget
	Status = 'Ongoing',  -- Changed status to ongoing
	CreatedBy = 'admin_user1_updated',  -- Updated CreatedBy
	CreatedAt = GETDATE()  -- Updates the CreatedAt field to current date
WHERE Title = 'Summer Sale Campaign';  

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


----------------------------------------------------------------------
-- 4.2 Test DELETE    -- FAIL AS EXPECTED (Don't have Permission)
----------------------------------------------------------------------
-- Delete from SELF Agents table
DELETE FROM dbo.Agents
WHERE AgentID =1 ;

-- Delete from Agents table
DELETE FROM dbo.Agents
WHERE Name = 'John Doe New' AND Email = 'john.doe.updated@example.com';

-- Delete from Products table
DELETE FROM dbo.Products
WHERE Name = 'Organic Broccoli New' AND Description = 'Fresh organic broccoli 600g pack';

-- Delete from Sales table
DELETE FROM dbo.Sales
WHERE SaleID = 6;

-- Delete from Commission table
DELETE FROM dbo.Commission
WHERE CommissionID = 6 ;

-- Delete from Notifications table
DELETE FROM dbo.Notifications
WHERE Title = 'Updated Sale Recorded' AND Message = 'An updated sale has been recorded for Agent John Doe.';

-- Delete from MKT_Campaigns table
DELETE FROM dbo.MKT_Campaigns
WHERE Title = 'Updated Summer Sale Campaign' AND Status = 'Ongoing';

-- Delete User Login
EXEC DeleteUserAndLogin 'user3';


DELETE FROM Users_AuditLog WHERE U_AuditLogID = 1;

DELETE FROM Agents_AuditLog WHERE A_AuditLogID = 1;

DELETE FROM Sales_AuditLog WHERE S_AuditLogID = 1;

DELETE FROM Commission_AuditLog WHERE C_AuditLogID = 1;





--TEST CASE SUMMARIZE FOR RESTRICTED COLUMN VIEW (vw_MKTCampaigns_Limited)
--Original
SELECT * FROM MKT_campaigns;

--SUCCESS
EXECUTE AS LOGIN='agent1'
SELECT * FROM Security.vw_MKTCampaigns_Limited; 
REVERT

--SUCCESS
EXECUTE AS LOGIN='userportal1'
SELECT * FROM Security.vw_MKTCampaigns_Limited; 
REVERT

--FAIL AS EXPECTED
EXECUTE AS LOGIN='marketing1'
SELECT * FROM Security.vw_MKTCampaigns_Limited; 
REVERT