----------------------------------------------------------------------
-- Test Case for Marketing Role
----------------------------------------------------------------------

----------------------------------------------------------------------
-- 1.1 Test SELECT   -- SUCESSS
----------------------------------------------------------------------
--Marketing marketing1 only can SELECT OWN Users Row
-- Can SELECT Products & MKT_campaigns 

SELECT * FROM Products;
SELECT * FROM Users;
SELECT * FROM MKT_campaigns;

----------------------------------------------------------------------
-- 1.2 Test SELECT   -- FAIL AS EXPECTED
----------------------------------------------------------------------
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;
SELECT * FROM Notifications;


----------------------------------------------------------------------
-- 1.3 Test View   -- SUCCESS
----------------------------------------------------------------------
--MKT can have Restrict View on Notifications & Sales
SELECT * FROM Security.vw_Notifications_Limited;
SELECT * FROM Security.vw_Sales_Restricted;


----------------------------------------------------------------------
-- 2.1 Test INSERT    -- SUCCESS
----------------------------------------------------------------------
-- MKT can Insert into Products & MKT_campaign Tables
INSERT INTO dbo.Products (Name, Description, Price, CreatedAt)
VALUES ('Organic Broccoli', 'Fresh organic broccoli 500g pack', 5.50, GETDATE());

INSERT INTO dbo.MKT_Campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy, CreatedAt)
VALUES ('Summer Sale Campaign', 'Promote all summer fruits.', '2025-06-01', '2025-06-30', 10000.00, 'Implementing', 'admin_user1', GETDATE());


----------------------------------------------------------------------
-- 2.2 Test INSERT    -- FAIL AS EXPECTED
----------------------------------------------------------------------
INSERT INTO dbo.Agents (Name, Email, Phone, Address, Status, CreatedAt, UserID)
VALUES ('John Doe', 'john.doe@example.com', '0123456789', '123 Example St, Kuala Lumpur', 'Active', GETDATE(),6);

INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 5, 27.50, GETDATE());

INSERT INTO dbo.Commission (AgentID, SaleID, CommissionRate, CommissionAmount, CreatedAt)
VALUES (1, 1, 5.00, 1.38, GETDATE());

INSERT INTO dbo.Notifications (Title, Message, TargetRole, CreatedAt, CreatedBy)
VALUES ('New Sale Recorded', 'A new sale has been recorded for Agent John Doe.', 'All', GETDATE(), 'admin_user1');

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
--MKT can update User(SELF)
-- Update user account (can only change username and password)
UPDATE Users
SET 
    Username = 'marketing1',
    Password = 'new_secure_password123'
WHERE Username = 'marketing1';



--MKT can update Products & Marketing_campaigms
UPDATE dbo.Products
SET 
	Name = 'Organic Broccoli New',
	Description = 'Fresh organic broccoli 600g pack',
	Price = 6.00,  -- Updated price
	CreatedAt = GETDATE()  -- Updates the CreatedAt field to current date
WHERE Name = 'Organic Broccoli';  

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


----------------------------------------------------------------------
-- 3.1 Test UPDATE    -- FAIL AS EXPECTED
----------------------------------------------------------------------
--Cannot Update others users row
UPDATE Users
SET 
    Username = 'marketing2',
    Password = 'new_secure_password123'
WHERE Username = 'marketing2';

UPDATE dbo.Agents
SET 
	Name = 'John Doe New',
	Email = 'john.doe.updated@example.com',
	Phone = '0987654321',
	Address = '456 New St, Kuala Lumpur',
	Status = 'Inactive',  -- Changing status to 'Inactive'
	CreatedAt = GETDATE() -- Updates the CreatedAt field to current date
WHERE Name = 'John Doe'; 

UPDATE dbo.Sales
SET 
	Quantity = 11,  -- Updated quantity
	TotalAmount = 55.00,  -- Updated total amount
	SaleDate = GETDATE()  -- Updates the SaleDate to current date
WHERE SaleID = 1;  

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
-- 4.1 Test DELETE    -- SUCCESS 
----------------------------------------------------------------------
--MKT can DELETE Products & Marketing_campaigms

-- Delete from Products table
DELETE FROM dbo.Products
WHERE Name = 'Organic Broccoli New' AND Description = 'Fresh organic broccoli 600g pack';

-- Delete from MKT_Campaigns table
DELETE FROM dbo.MKT_Campaigns
WHERE Title = 'Updated Summer Sale Campaign' AND Status = 'Ongoing';

----------------------------------------------------------------------
-- 4.2 Test DELETE    -- FAIL AS EXPECTED (Don't have Permission)
----------------------------------------------------------------------
-- Delete from Agents table
DELETE FROM dbo.Agents
WHERE Name = 'John Doe New' AND Email = 'john.doe.updated@example.com';

-- Delete from Sales table
DELETE FROM dbo.Sales
WHERE SaleID = 6;

-- Delete from Commission table
DELETE FROM dbo.Commission
WHERE CommissionID = 6 ;

-- Delete from Notifications table
DELETE FROM dbo.Notifications
WHERE Title = 'Updated Sale Recorded' AND Message = 'An updated sale has been recorded for Agent John Doe.';

-- Delete User Login
EXEC DeleteUserAndLogin 'user3';


DELETE FROM Users_AuditLog WHERE U_AuditLogID = 1;

DELETE FROM Agents_AuditLog WHERE A_AuditLogID = 1;

DELETE FROM Sales_AuditLog WHERE S_AuditLogID = 1;

DELETE FROM Commission_AuditLog WHERE C_AuditLogID = 1;






--TEST CASE SUMMARIZE FOR RESTRICTED COLUMN VIEW (vw_Sales_Restricted)
--Original
SELECT * FROM Sales;

--SUCCESS
EXECUTE AS LOGIN='marketing1'
SELECT * FROM Security.vw_Sales_Restricted; 
REVERT

--SUCCESS
EXECUTE AS LOGIN='analyst1'
SELECT * FROM Security.vw_Sales_Restricted; 
REVERT

--User cannot view sales data --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM Security.vw_Sales_Restricted; 
REVERT