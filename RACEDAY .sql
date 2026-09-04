-- ========================================================
-- PROG6212 POE PART 1 
-- ========================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RaceDayDB')
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO 
USE RaceDayDB; 
GO

DROP TABLE IF EXISTS Payments; 
DROP TABLE IF EXISTS Results;
DROP TABLE IF EXISTS Enrolments;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Users;
GO

CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    Email VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE Events (
    EventId INT PRIMARY KEY IDENTITY(1,1),
    OrganiserId INT NOT NULL,
    Title VARCHAR(150) NOT NULL,
    Description VARCHAR(500) NULL,
    EventDate DATETIME NOT NULL,
    Location VARCHAR(200) NOT NULL,
    ImageUrl VARCHAR(500) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId) 
        REFERENCES Users(UserId) ON DELETE CASCADE
);
GO

CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY IDENTITY(1,1),
    EventId INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    DistanceKm DECIMAL(5,2) NOT NULL CHECK (DistanceKm > 0),
    EntryFee DECIMAL(8,2) NOT NULL CHECK (EntryFee >= 0),
    StartTime DATETIME NOT NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) 
        REFERENCES Events(EventId) ON DELETE CASCADE
);
GO

-- FIXED: Changed CASCADE to NO ACTION to avoid multiple paths
CREATE TABLE Enrolments (
    EnrolmentId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status VARCHAR(20) NOT NULL DEFAULT 'Confirmed' 
        CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (UserId) 
        REFERENCES Users(UserId) ON DELETE NO ACTION,
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) 
        REFERENCES Categories(CategoryId) ON DELETE NO ACTION,
    CONSTRAINT UQ_User_Category UNIQUE (UserId, CategoryId)
);
GO

CREATE TABLE Results (
    ResultId INT PRIMARY KEY IDENTITY(1,1),
    EnrolmentId INT NOT NULL UNIQUE,
    FinishTime TIME NULL,
    Position INT NULL CHECK (Position > 0),
    IsDNF BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) 
        REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE
);
GO

CREATE TABLE Payments (
    PaymentId INT PRIMARY KEY IDENTITY(1,1),
    EnrolmentId INT NOT NULL UNIQUE,
    Amount DECIMAL(8,2) NOT NULL CHECK (Amount >= 0),
    PaymentDate DATETIME NOT NULL DEFAULT GETDATE(),
    PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Paid' 
        CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    PaymentMethod VARCHAR(50) NOT NULL 
        CHECK (PaymentMethod IN ('PayFast', 'EFT', 'CreditCard', 'Cash')),
    CONSTRAINT FK_Payments_Enrolments FOREIGN KEY (EnrolmentId) 
        REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE
);
GO

-- SAMPLE DATA
INSERT INTO Users (Email, PasswordHash, FullName, Role) VALUES
('organiser@raceday.co.za', 'hashed_password_123', 'Thabo Race Organiser', 'Organiser'),
('thabo.runner@gmail.com', 'hashed_password_456', 'Thabo Nkosi', 'Participant'),
('lerato.runner@gmail.com', 'hashed_password_789', 'Lerato Molefe', 'Participant');

INSERT INTO Events (OrganiserId, Title, Description, EventDate, Location) VALUES
(1, 'Comrades Marathon 2026', 'Ultimate human race', '2026-06-14 05:00:00', 'KZN'),
(1, 'Cape Town Cycle Tour 2026', 'Worlds largest timed bike race', '2026-03-08 06:00:00', 'Cape Town');

INSERT INTO Categories (EventId, Name, DistanceKm, EntryFee, StartTime) VALUES
(1, 'Comrades Up Run - Elite', 89.20, 600.00, '2026-06-14 05:30:00'),
(1, 'Comrades Up Run - Open', 89.20, 500.00, '2026-06-14 06:00:00'),
(2, '109km Cycle Tour', 109.00, 550.00, '2026-03-08 06:15:00');

INSERT INTO Enrolments (UserId, CategoryId, Status) VALUES (2, 2, 'Confirmed'), (3, 2, 'Confirmed');
INSERT INTO Results (EnrolmentId, FinishTime, Position, IsDNF) VALUES (1, '06:30:15', 250, 0), (2, '07:15:30', 890, 0);
INSERT INTO Payments (EnrolmentId, Amount, PaymentStatus, PaymentMethod) VALUES (1, 500.00, 'Paid', 'PayFast'), (2, 500.00, 'Paid', 'CreditCard');
GO

SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Enrolments;
SELECT * FROM Results;
SELECT * FROM Payments;
