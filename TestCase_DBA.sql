----------------------------------------------------------------------
-- Test Case for DBA Role
----------------------------------------------------------------------
--Pretend u login as admin1
--Remember use --REVERT once u finsh
EXECUTE AS LOGIN='admin1'

----------------------------------------------------------------------
-- [1] Test SELECT   -- SUCESSS
----------------------------------------------------------------------
-- DBA admin1 can SELECT All Tables **SUCCESS**
SELECT * FROM Agents;
SELECT * FROM Products;
SELECT * FROM Sales;
SELECT * FROM Commission;
SELECT * FROM Commission_AuditLog;
SELECT * FROM Users_AuditLog;
SELECT * FROM Agents_AuditLog;
SELECT * FROM Sales_AuditLog;
SELECT * FROM Users;
SELECT * FROM Notifications;
SELECT * FROM MKT_campaigns;


----------------------------------------------------------------------
-- [2] Test INSERT    -- SUCESSS
----------------------------------------------------------------------
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;
INSERT INTO Agents (Name, Email, IdentificationNO, Phone, Address, Status)
VALUES 
('Jenny',
 'jenny.tan@example.com',
 EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, STUFF(STUFF('900101145678', 7, 0, '-'), 10, 0, '-'))),
 '011-3456789',
 '123 Jalan Mawar, Kuala Lumpur',
 'Active')
CLOSE SYMMETRIC KEY ICSymKey;

OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;
INSERT INTO Users (IdentificationNo, Username, Password, Role)
VALUES (
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, '900101145678')),  -- IdentificationNo
    'john.doe',                                                               -- Username
    EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, 'SecurePass123')), -- Password
    'DBA'                                                                     -- Role
);
CLOSE SYMMETRIC KEY ICSymKey;


INSERT INTO dbo.Products (Name, Description, Price, CreatedAt)
VALUES ('Organic Broccoli', 'Fresh organic broccoli 500g pack', 5.50, GETDATE());

INSERT INTO dbo.Sales (AgentID, ProductID, Quantity, TotalAmount, SaleDate)
VALUES (1, 1, 5, 27.50, GETDATE());

INSERT INTO Commission (AgentID, SaleID, CommissionRate, CommissionAmount)
VALUES 
	(1, 1, 5.00, 2.50)


INSERT INTO dbo.Notifications (Title, Message, Target, CreatedAt, CreatedBy)
VALUES ('New Sale Recorded', 'A new sale has been recorded for Agent John Doe.', 'All', GETDATE(), 'admin_user1');

INSERT INTO dbo.MKT_Campaigns (Title, Description, StartDate, EndDate, Budget, Status, CreatedBy, CreatedAt)
VALUES ('Summer Sale Campaign', 'Promote all summer fruits.', '2025-06-01', '2025-06-30', 10000.00, 'Planned', 'admin_user1', GETDATE());


--Add User Login
ALTER SECURITY POLICY Security.UsersSecurityPolicy WITH (STATE = OFF);
EXEC CreateUserAndAssignRole 'user4', 'user456', 'USR';
ALTER SECURITY POLICY Security.UsersSecurityPolicy WITH (STATE = ON);


----------------------------------------------------------------------
-- [2.1] Test INSERT    -- FAIL AS EXPECTED (Audit_Log cannot be modified)
----------------------------------------------------------------------
INSERT INTO Users_AuditLog (UserID, Action, Username, Password, Role, CreatedAt, PerformedBy)
VALUES (1, 'INSERT', 'john_doe', 'password123', 'AGT', GETDATE(), 'admin_user');

INSERT INTO Agents_AuditLog (AgentID, UserID, Action, Name, Email, Phone, Address, Status, CreatedAt, PerformedBy)
VALUES (1, 1, 'INSERT', 'John Doe', 'john@example.com', '1234567890', '123 Main St', 'Active', GETDATE(), 'admin_user');

INSERT INTO Sales_AuditLog (SaleID, AgentID, ProductID, Action, Quantity, TotalAmount, SaleDate, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 10, 100.00, GETDATE(), GETDATE(), 'admin_user');

INSERT INTO Commission_AuditLog (CommissionID, AgentID, SaleID, Action, CommissionRate, CommissionAmount, CreatedAt, ActionDate, PerformedBy)
VALUES (1, 1, 1, 'INSERT', 5.00, 5.00, GETDATE(), GETDATE(), 'admin_user');


----------------------------------------------------------------------
-- [3] Test UPDATE    -- SUCESSS
----------------------------------------------------------------------
OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;
UPDATE Agents
SET IdentificationNO = EncryptByKey(
        Key_GUID('ICSymKey'), 
        CONVERT(VARBINARY, STUFF(STUFF('900101145678', 7, 0, '-'), 10, 0, '-'))
    )
WHERE Name = 'Jenny';
CLOSE SYMMETRIC KEY ICSymKey;

OPEN SYMMETRIC KEY ICSymKey DECRYPTION BY CERTIFICATE ICDataCert;
UPDATE Users
SET 
    Password = EncryptByKey(Key_GUID('ICSymKey'), CONVERT(VARBINARY, 'NewPass456')),
    Role = 'UPD'
WHERE Username = 'john.doe';
CLOSE SYMMETRIC KEY ICSymKey;

UPDATE dbo.Products
SET 
	Name = 'Organic Broccoli New',
	Description = 'Fresh organic broccoli 600g pack',
	Price = 6.00,  -- Updated price
	CreatedAt = GETDATE()  -- Updates the CreatedAt field to current date
WHERE Name = 'Organic Broccoli';  

UPDATE dbo.Sales
SET 
	Quantity = 10,  -- Updated quantity
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
	Target = 'All',
	CreatedAt = GETDATE(),  -- Updates the CreatedAt field to current date
	CreatedBy = 'admin1_updated'  -- Updated CreatedBy
WHERE Title = 'New Sale Recorded';  

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
-- [3.1] Test UPDATE    -- FAIL AS EXPECTED (Audit_Log cannot be modified)
----------------------------------------------------------------------
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
-- [4] Test DELETE    -- SUCESSS
----------------------------------------------------------------------
-- Delete from Agents table
DELETE FROM dbo.Agents
WHERE Name = 'Jenny';

DELETE FROM Users
WHERE Username = 'john.doe';

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


----------------------------------------------------------------------
-- [4.1] Test DELETE    -- FAIL AS EXPECTED (Audit_Log cannot be modified & deleted)
----------------------------------------------------------------------
DELETE FROM Users_AuditLog WHERE U_AuditLogID = 1;

DELETE FROM Agents_AuditLog WHERE A_AuditLogID = 1;

DELETE FROM Sales_AuditLog WHERE S_AuditLogID = 1;

DELETE FROM Commission_AuditLog WHERE C_AuditLogID = 1;

--REMEMBER USE THIS ONCE FINISH
REVERT;


----------------------------------------------------------------------
-- [5] Row Level Security
----------------------------------------------------------------------
-- [5.1] Users Table Predicate
--ORIGINAL
SELECT * FROM Users;

--User can only see their own data --> SUCCESS
EXECUTE AS LOGIN='user1'
SELECT * FROM Users;
REVERT

--Admin(DBA) & User Protal Developer(UPD) & Auditor(ADT) can see all users --> SUCCESS
EXECUTE AS LOGIN='admin1'
SELECT * FROM Users;
REVERT

EXECUTE AS LOGIN='userportal1'
SELECT * FROM Users;
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM Users;
REVERT


--[5.2] Sales Table Predicate
--ORIGINAL
SELECT * FROM Sales;

--Agent can only see their own sales data --> SUCCESS
EXECUTE AS LOGIN='agent1'
SELECT * FROM Sales;
REVERT

--Admin(DBA) & User Protal Developer(UPD) & Auditor(ADT) can see all sales data --> SUCCESS
EXECUTE AS LOGIN='admin1'
SELECT * FROM Sales;
REVERT

EXECUTE AS LOGIN='userportal1'
SELECT * FROM Sales;
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM Sales;
REVERT


--[5.3] Agents Table Predicate
--ORIGINAL
SELECT * FROM Agents;

--Agent can only see their own data --> SUCCESS
EXECUTE AS LOGIN='agent1'
SELECT * FROM Agents;
REVERT

--Admin(DBA) & User Protal Developer(UPD) & Auditor(ADT) can see all agents data --> SUCCESS
EXECUTE AS LOGIN='admin1'
SELECT * FROM Agents;
REVERT

EXECUTE AS LOGIN='userportal1'
SELECT * FROM Agents;
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM Agents;
REVERT


--[5.4] Commission Table Predicate
--ORIGINAL
SELECT * FROM Commission;

--Agent can only see their own commission data --> SUCCESS
EXECUTE AS LOGIN='agent1'
SELECT * FROM Commission;
REVERT

--Admin(DBA) & User Protal Developer(UPD) & Auditor(ADT) can see all commission data --> SUCCESS
EXECUTE AS LOGIN='admin1'
SELECT * FROM Commission;
REVERT

EXECUTE AS LOGIN='userportal1'
SELECT * FROM Commission;
REVERT

EXECUTE AS LOGIN='auditor1'
SELECT * FROM Commission;
REVERT


--SUMMARIZE OF RLS
--User(USR) cannot view any Agents / Sales / Commission... Tables --> FAIL AS EXPECTED
EXECUTE AS LOGIN='user1'
SELECT * FROM Agents;
SELECT * FROM Sales;
SELECT * FROM Commission;
REVERT



--TEST CASE SUMMARIZE FOR STORED PROCEDURE (CreateUserAndAssignRole & DeleteUserAndLogin & CheckRoleMembership) --> INCLUDE ALL ROLES, NOT ONLY DBA
--SUCCESS
EXECUTE AS LOGIN='admin1'
EXEC CreateUserAndAssignRole 'admin4', 'admin444', 'DBA';
REVERT

--SUCCESS
EXECUTE AS LOGIN='userportal1'
EXEC DeleteUserAndLogin 'admin4';
REVERT

--SUCCESS
EXECUTE AS LOGIN='auditor1'
EXEC CreateUserAndAssignRole 'admin5', 'admin555', 'DBA';
REVERT

--FAIL AS EXPECTED (because AGT & MKT & ANL & USR cannot add / delete user)
EXECUTE AS LOGIN='agent1'
EXEC CreateUserAndAssignRole 'admin4', 'admin444', 'DBA';
EXEC DeleteUserAndLogin 'admin3';
REVERT

--Admin can check the member for all role --> SUCCESS
EXECUTE AS LOGIN ='admin1';
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