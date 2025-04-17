-- Create Attendance table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Attendance')
BEGIN
    CREATE TABLE Attendance (
        AttendanceID INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID INT NOT NULL,
        AttendanceDate DATE NOT NULL,
        TimeIn TIME,
        TimeOut TIME,
        Status VARCHAR(20) DEFAULT 'Present',
        Notes VARCHAR(255),
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
        CONSTRAINT UC_Attendance UNIQUE (EmployeeID, AttendanceDate)
    )
END
GO

-- Stored procedure to get attendance records for a specific date
CREATE OR ALTER PROCEDURE GetAttendanceByDate
    @Date DATE
AS
BEGIN
    SELECT a.AttendanceID, a.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, 
           a.AttendanceDate, a.TimeIn, a.TimeOut, a.Status, a.Notes
    FROM Attendance a
    INNER JOIN Employees e ON a.EmployeeID = e.EmployeeID
    WHERE a.AttendanceDate = @Date
    ORDER BY e.FirstName, e.LastName
END
GO

-- Stored procedure to check if attendance record exists
CREATE OR ALTER PROCEDURE CheckAttendanceExists
    @EmployeeID INT,
    @Date DATE,
    @Exists BIT OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Attendance WHERE EmployeeID = @EmployeeID AND AttendanceDate = @Date)
        SET @Exists = 1
    ELSE
        SET @Exists = 0
END
GO

-- Stored procedure to add new attendance record
CREATE OR ALTER PROCEDURE AddAttendanceRecord
    @EmployeeID INT,
    @Date DATE,
    @TimeIn TIME,
    @TimeOut TIME,
    @Status VARCHAR(20),
    @Notes VARCHAR(255),
    @NewAttendanceID INT OUTPUT
AS
BEGIN
    INSERT INTO Attendance (EmployeeID, AttendanceDate, TimeIn, TimeOut, Status, Notes)
    VALUES (@EmployeeID, @Date, @TimeIn, @TimeOut, @Status, @Notes)
    
    SET @NewAttendanceID = SCOPE_IDENTITY()
END
GO

-- Stored procedure to update existing attendance record
CREATE OR ALTER PROCEDURE UpdateAttendanceRecord
    @AttendanceID INT,
    @TimeIn TIME,
    @TimeOut TIME,
    @Status VARCHAR(20),
    @Notes VARCHAR(255)
AS
BEGIN
    UPDATE Attendance
    SET TimeIn = @TimeIn,
        TimeOut = @TimeOut,
        Status = @Status,
        Notes = @Notes
    WHERE AttendanceID = @AttendanceID
END
GO

-- Stored procedure to get active employees for auto-fill
CREATE OR ALTER PROCEDURE GetActiveEmployeesForAttendance
AS
BEGIN
    SELECT EmployeeID, FirstName + ' ' + LastName AS EmployeeName
    FROM Employees
    WHERE Status = 'Active'
    ORDER BY FirstName, LastName
END
GO

-- Stored procedure to generate attendance report for a date range
CREATE OR ALTER PROCEDURE GenerateAttendanceReport
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, 
           a.AttendanceDate, a.TimeIn, a.TimeOut, a.Status,
           CASE 
               WHEN a.TimeIn IS NULL OR a.TimeOut IS NULL THEN 0
               ELSE DATEDIFF(MINUTE, a.TimeIn, a.TimeOut) / 60.0
           END AS HoursWorked
    FROM Employees e
    LEFT JOIN Attendance a ON e.EmployeeID = a.EmployeeID AND a.AttendanceDate BETWEEN @StartDate AND @EndDate
    WHERE e.Status = 'Active'
    ORDER BY e.FirstName, e.LastName, a.AttendanceDate
END
GO 