CREATE DATABASE Ola;
USE Ola;

select * from ola_raid ;

--- change the data type ---
ALTER TABLE ola_raid
MODIFY  Booking_Date DATE ,
MODIFY  Booking_Time TIME  ,
MODIFY  Booking_ID VARCHAR(50)  ,
MODIFY  Booking_Status VARCHAR(50)  ,
MODIFY  Customer_ID VARCHAR(50)  ,
MODIFY  Vehicle_Type VARCHAR(50)  ,
MODIFY  Pickup_Location VARCHAR(255) ,
MODIFY  Drop_Location VARCHAR(255)  ,
MODIFY  Canceled_Rides_by_Customer VARCHAR(255)  ,
MODIFY  Canceled_Rides_by_Driver VARCHAR(255) , 
MODIFY  Incomplete_Rides_Reason VARCHAR(255) ,
MODIFY  Booking_Value INT ,
MODIFY  Payment_Method VARCHAR(50) ,
MODIFY  Ride_Distance DECIMAL(3,1), 
MODIFY  Driver_Ratings DECIMAL(3,1)
;


--- Data Modeling – Convert to 3NF ---

--- Customers Table ---

CREATE TABLE Customers (
    Customer_ID VARCHAR(50) NOT NULL PRIMARY KEY,
    Customer_Rating DECIMAL(2,1) NULL
);

INSERT INTO Customers (Customer_ID, Customer_Rating)
SELECT Customer_ID, Customer_Rating 
FROM ola_raid
GROUP BY Customer_ID;

SELECT * FROM Customers;


--- vehicles Table ---
CREATE TABLE vehicles (
    Vehicle_ID INT AUTO_INCREMENT PRIMARY KEY,
    Vehicle_Type VARCHAR(50) UNIQUE
);

INSERT INTO vehicles (Vehicle_Type)
SELECT DISTINCT Vehicle_Type FROM ola_raid;

SELECT * FROM vehicles;

--- locations Table (Pickup & Drop Locations) ---
CREATE TABLE locations (
    Location_ID INT AUTO_INCREMENT PRIMARY KEY,
    Location_Name VARCHAR(255) UNIQUE NOT NULL
);

INSERT INTO locations (Location_Name)
SELECT DISTINCT Pickup_Location FROM ola_raid
UNION
SELECT DISTINCT Drop_Location FROM ola_raid;

SELECT * FROM locations;

UPDATE ola_raid
SET V_TAT = NULL
WHERE V_TAT = '' OR V_TAT IS NULL;

UPDATE ola_raid
SET C_TAT = NULL
WHERE C_TAT = '' OR C_TAT IS NULL;

ALTER TABLE ola_raid
MODIFY  V_TAT INT,
MODIFY C_TAT INT;

--- Check for missing references before inserting into bookings
SELECT * 
FROM ola_raid
WHERE Customer_ID NOT IN (SELECT Customer_ID FROM customers)
   OR Vehicle_Type NOT IN (SELECT Vehicle_Type FROM vehicles)
   OR Pickup_Location NOT IN (SELECT Location_Name FROM locations)
   OR Drop_Location NOT IN (SELECT Location_Name FROM locations);

--- create Bookings Table ---
  
CREATE TABLE bookings (
    Booking_ID VARCHAR(50) PRIMARY KEY,
    Booking_Date DATE ,
    Booking_Time TIME ,
    Customer_ID VARCHAR(50),
    Vehicle_ID INT,
    Pickup_Location_ID INT,
	Drop_Location_ID INT,
    Booking_Status VARCHAR(50) ,
    Booking_Value INT NULL,
    Payment_Method VARCHAR(50) ,
    V_TAT INT,
    C_TAT INT,
    Canceled_Rides_by_Customer VARCHAR(255) NULL ,
	Canceled_Rides_by_Driver VARCHAR(255) NULL, 
	Incomplete_Rides TEXT,
	Incomplete_Rides_Reason VARCHAR(255) NULL,
    Ride_Distance DECIMAL(3,1),
    Driver_Ratings DECIMAL(3,1),
    FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID),
    FOREIGN KEY (Vehicle_ID) REFERENCES vehicles(Vehicle_ID),
    FOREIGN KEY (Pickup_Location_ID) REFERENCES locations(Location_ID),
    FOREIGN KEY (Drop_Location_ID) REFERENCES locations(Location_ID)
);

INSERT INTO bookings (
    Booking_ID, Booking_Date, Booking_Time, Customer_ID, Vehicle_ID, 
    Pickup_Location_ID, Drop_Location_ID, 
    Booking_Status, Booking_Value, Payment_Method, V_TAT, C_TAT, 
    Canceled_Rides_by_Customer, Canceled_Rides_by_Driver, Incomplete_Rides, 
    Incomplete_Rides_Reason, Ride_Distance, Driver_Ratings
)
SELECT 
    o.Booking_ID, o.Booking_Date, o.Booking_Time, 
    c.Customer_ID,  
    v.Vehicle_ID, 
    pl.Location_ID AS Pickup_Location_ID, 
    dl.Location_ID AS Drop_Location_ID, 
    o.Booking_Status, o.Booking_Value, o.Payment_Method, o.V_TAT, o.C_TAT, 
    o.Canceled_Rides_by_Customer, o.Canceled_Rides_by_Driver, o.Incomplete_Rides, 
    o.Incomplete_Rides_Reason,
    o.Ride_Distance, o.Driver_Ratings
FROM ola_raid o                                                   -- 'o' is an alias for 'ola_raid table'
LEFT JOIN customers c ON o.Customer_ID = c.Customer_ID            -- 'c' is an alias for 'Customer table'
LEFT JOIN vehicles v ON o.Vehicle_Type = v.Vehicle_Type           -- 'v' is an alias for 'vehicles table'
LEFT JOIN locations pl ON o.Pickup_Location = pl.Location_Name    -- 'pl' is an alias for 'locations table' (Pickup)
LEFT JOIN locations dl ON o.Drop_Location = dl.Location_Name;     -- 'dl' is an alias for 'locations table' (Drop)

SELECT * FROM bookings;

SELECT 
    SUM(CASE WHEN Booking_Date IS NULL THEN 1 ELSE 0 END) AS missing_dates,
    SUM(CASE WHEN Booking_Time IS NULL THEN 1 ELSE 0 END) AS missing_times,
    SUM(CASE WHEN Booking_Status IS NULL THEN 1 ELSE 0 END) AS missing_booking_status
FROM ola_raid;