-- Tạo cơ sở dữ liệu HRManagement
CREATE DATABASE HRManagement;
GO

USE HRManagement;
GO

-- Tạo bảng Users để lưu thông tin đăng nhập
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    IsAdmin BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Tạo bảng Departments để lưu thông tin phòng ban
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Tạo bảng Positions để lưu thông tin vị trí công việc
CREATE TABLE Positions (
    PositionID INT PRIMARY KEY IDENTITY(1,1),
    PositionName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Tạo bảng Employees để lưu thông tin nhân viên
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NVARCHAR(10) CHECK (Gender IN (N'Nam', N'Nữ', N'Khác')),
    BirthDate DATE,
    Address NVARCHAR(255),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    PositionID INT FOREIGN KEY REFERENCES Positions(PositionID),
    HireDate DATE DEFAULT GETDATE(),
    Salary DECIMAL(18,2) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT N'Đang làm việc',
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME
);
GO

-- Tạo bảng Attendance để lưu thông tin chấm công
CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    AttendanceDate DATE NOT NULL,
    TimeIn TIME,
    TimeOut TIME,
    Status NVARCHAR(50) CHECK (Status IN (N'Đi làm', N'Đi muộn', N'Về sớm', N'Vắng mặt', N'Nghỉ phép', N'Nghỉ lễ')),
    WorkingHours DECIMAL(5,2),
    Note NVARCHAR(255),
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME
);
GO

-- Tạo chỉ mục cho bảng Attendance
CREATE UNIQUE INDEX IX_Attendance_Employee_Date ON Attendance(EmployeeID, AttendanceDate);
GO

-- Chèn dữ liệu mẫu vào bảng Users
INSERT INTO Users (Username, Password, FullName, Email, IsAdmin)
VALUES 
('admin', 'admin123', N'Administrator', 'admin@example.com', 1),
('user', 'user123', N'User Test', 'user@example.com', 0);
GO

-- Chèn dữ liệu mẫu vào bảng Departments
INSERT INTO Departments (DepartmentName, Description)
VALUES 
(N'Nhân sự', N'Phòng quản lý nhân sự'),
(N'Kế toán', N'Phòng kế toán'),
(N'IT', N'Phòng công nghệ thông tin'),
(N'Marketing', N'Phòng marketing'),
(N'Kinh doanh', N'Phòng kinh doanh');
GO

-- Chèn dữ liệu mẫu vào bảng Positions
INSERT INTO Positions (PositionName, Description)
VALUES 
(N'Giám đốc', N'Giám đốc điều hành'),
(N'Trưởng phòng', N'Quản lý phòng ban'),
(N'Nhân viên', N'Nhân viên thường'),
(N'Thực tập sinh', N'Thực tập sinh');
GO

-- Chèn dữ liệu mẫu vào bảng Employees
INSERT INTO Employees (FirstName, LastName, Gender, BirthDate, Address, Phone, Email, DepartmentID, PositionID, HireDate, Salary)
VALUES 
(N'Nguyễn', N'Văn A', N'Nam', '1990-01-01', N'Hà Nội', '0123456789', 'nguyenvana@example.com', 1, 2, '2020-01-01', 15000000),
(N'Trần', N'Thị B', N'Nữ', '1992-05-10', N'TP. Hồ Chí Minh', '0987654321', 'tranthib@example.com', 2, 3, '2020-02-15', 10000000),
(N'Lê', N'Văn C', N'Nam', '1995-07-20', N'Đà Nẵng', '0123456788', 'levanc@example.com', 3, 3, '2021-03-10', 12000000),
(N'Phạm', N'Thị D', N'Nữ', '1991-12-25', N'Hà Nội', '0987654322', 'phamthid@example.com', 4, 3, '2019-06-01', 11000000),
(N'Hoàng', N'Văn E', N'Nam', '1988-08-18', N'TP. Hồ Chí Minh', '0123456787', 'hoangvane@example.com', 5, 2, '2018-01-01', 18000000);
GO

-- Chèn dữ liệu mẫu vào bảng Attendance (thêm dữ liệu chấm công cho 30 ngày gần nhất)
DECLARE @StartDate DATE = DATEADD(DAY, -30, GETDATE())
DECLARE @EndDate DATE = GETDATE()
DECLARE @CurrentDate DATE = @StartDate
DECLARE @EmployeeID INT = 1

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Bỏ qua ngày cuối tuần (thứ 7, chủ nhật)
    IF DATEPART(WEEKDAY, @CurrentDate) NOT IN (1, 7) -- 1 = Chủ Nhật, 7 = Thứ 7 (SQL Server)
    BEGIN
        SET @EmployeeID = 1
        WHILE @EmployeeID <= 5 -- Có 5 nhân viên mẫu
        BEGIN
            -- Tạo dữ liệu chấm công ngẫu nhiên
            DECLARE @Status NVARCHAR(50) = 
                CASE 
                    WHEN RAND() < 0.8 THEN N'Đi làm' 
                    WHEN RAND() < 0.9 THEN N'Đi muộn' 
                    ELSE N'Nghỉ phép' 
                END
            
            DECLARE @TimeIn TIME = 
                CASE 
                    WHEN @Status = N'Đi làm' THEN '08:00:00' 
                    WHEN @Status = N'Đi muộn' THEN '08:30:00' 
                    ELSE NULL 
                END
            
            DECLARE @TimeOut TIME = 
                CASE 
                    WHEN @Status IN (N'Đi làm', N'Đi muộn') THEN '17:30:00' 
                    ELSE NULL 
                END
            
            DECLARE @WorkingHours DECIMAL(5,2) = 
                CASE 
                    WHEN @Status = N'Đi làm' THEN 8.0 
                    WHEN @Status = N'Đi muộn' THEN 7.0 
                    ELSE 0.0 
                END
            
            -- Thêm dữ liệu vào bảng Attendance
            INSERT INTO Attendance (EmployeeID, AttendanceDate, TimeIn, TimeOut, Status, WorkingHours, Note, CreatedBy)
            VALUES (@EmployeeID, @CurrentDate, @TimeIn, @TimeOut, @Status, @WorkingHours, NULL, 1)
            
            SET @EmployeeID = @EmployeeID + 1
        END
    END
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
END
GO 