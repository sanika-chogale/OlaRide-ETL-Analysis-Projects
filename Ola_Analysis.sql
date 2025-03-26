--------- DATA ANALYSIS ----------

----- How many total bookings are recorded in the dataset? -----

SELECT COUNT(*) AS Total_Bookings FROM bookings;


----- How many rides were completed, canceled, or marked as incomplete? ----- 

SELECT Booking_Status, COUNT(*) AS Total 
FROM bookings 
GROUP BY Booking_Status;

--  Total Canceled Rides (By Customer & Driver)

SELECT 
    COUNT(*) AS Total_Canceled_Rides,
    SUM(CASE WHEN Canceled_Rides_by_Customer IS NOT NULL THEN 1 ELSE 0 END) AS Canceled_By_Customer,
    SUM(CASE WHEN Canceled_Rides_by_Driver IS NOT NULL THEN 1 ELSE 0 END) AS Canceled_By_Driver
FROM bookings
WHERE Booking_Status  LIKE '%Canceled%';


-- Which customers have the most canceled rides?

SELECT Customer_ID, COUNT(*) AS Canceled_Rides
FROM bookings
WHERE Booking_Status LIKE '%Canceled%'
GROUP BY Customer_ID
ORDER BY Canceled_Rides DESC
LIMIT 10;


-- What percentage of total rides were canceled compared to completed?

SELECT 
    Booking_Status,
    COUNT(*) AS Total_Rides,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bookings)), 2) AS Percentage
FROM bookings
GROUP BY Booking_Status;


-- Who are the top 10 customers with the highest number of rides?

SELECT Customer_ID, COUNT(Booking_ID) AS Total_Rides
FROM bookings
GROUP BY Customer_ID
ORDER BY Total_Rides DESC
LIMIT 10;


-- Average Spending Per Customer 

SELECT c.Customer_ID, ROUND(AVG(b.Booking_Value), 2) AS Avg_Spending
FROM bookings b
JOIN customers c ON b.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID
ORDER BY Avg_Spending DESC
LIMIT 10;


-- What is the Average Driver Rating --

SELECT ROUND(AVG(Driver_Ratings), 2) AS Avg_Driver_Rating FROM bookings;


-- Which vehicle type is the most frequently booked for long-distance rides?

SELECT v.Vehicle_Type, ROUND(AVG(b.Ride_Distance), 2) AS Avg_Distance, COUNT(*) AS Total_Rides
FROM bookings b
JOIN vehicles v ON b.Vehicle_ID = v.Vehicle_ID
GROUP BY v.Vehicle_Type
ORDER BY Avg_Distance DESC
LIMIT 1;


--  Most Popular Payment Method

SET SQL_SAFE_UPDATES = 0;

UPDATE bookings  
SET Payment_Method = 'Unknown'  
WHERE Payment_Method = '' OR Payment_Method IS NULL;

SET SQL_SAFE_UPDATES = 1; 

SELECT Payment_Method, SUM(Booking_Value) AS Total_Revenue  
FROM bookings  
GROUP BY Payment_Method  
ORDER BY Total_Revenue DESC  
LIMIT 1;


--  Which are the top 10 most popular pickup locations based on ride frequency?

SELECT l.Location_Name, COUNT(*) AS Pickup_Count
FROM bookings b
JOIN locations l ON b.Pickup_Location_ID = l.Location_ID
GROUP BY l.Location_Name
ORDER BY Pickup_Count DESC
LIMIT 10;


--  Which are the top 10 most popular Drop locations based on ride frequency?

SELECT l.Location_Name, COUNT(*) AS Drop_Count
FROM bookings b
JOIN locations l ON b.Drop_Location_ID = l.Location_ID
GROUP BY l.Location_Name
ORDER BY Drop_Count DESC
LIMIT 10;


-- What is the monthly revenue trend for each year?

SELECT YEAR(Booking_Date) AS Year,  
       MONTH(Booking_Date) AS Month,  
       SUM(Booking_Value) AS Total_Revenue  
FROM bookings  
GROUP BY Year, Month  
ORDER BY Year, Month;


-- What is the total revenue generated from all bookings?

SELECT SUM(Booking_Value) AS Total_Revenue
FROM bookings
WHERE Booking_Status NOT LIKE '%Canceled%';


-- Who are Highest Revenue Generating Customers

SELECT Customer_ID, SUM(Booking_Value) AS Total_Spent
FROM bookings
GROUP BY Customer_ID
ORDER BY Total_Spent DESC
LIMIT 10;


-- Which are the Highest Revenue Generating Locations

SELECT l.Location_Name, SUM(b.Booking_Value) AS Total_Revenue
FROM bookings b
JOIN locations l ON b.Pickup_Location_ID = l.Location_ID
GROUP BY l.Location_Name
ORDER BY Total_Revenue DESC
LIMIT 10;


-- When did each customer take their first and last ride?

SELECT 
    Customer_ID,
    MIN(Booking_Date) AS First_Ride,                      -- Earliest booking date
    MAX(Booking_Date) AS Last_Ride                        -- Latest booking date
FROM bookings
GROUP BY Customer_ID;


-- Which customers have the longest gap between their first and last ride?

SELECT 
    Customer_ID, 
    MIN(Booking_Date) AS First_Ride, 
    MAX(Booking_Date) AS Last_Ride,
    DATEDIFF(MAX(Booking_Date), MIN(Booking_Date)) AS Ride_Gap_Days
FROM bookings
GROUP BY Customer_ID
ORDER BY Ride_Gap_Days DESC;


-- What are the top 10 highest and lowest booking values?

(SELECT * FROM bookings ORDER BY Booking_Value DESC LIMIT 10)
UNION
(SELECT * FROM bookings ORDER BY Booking_Value ASC LIMIT 10)
ORDER BY Booking_Value DESC;


-- How can we segment customers based on ride frequency and spending behavior for targeted marketing?

SELECT 
    Customer_ID, 
    COUNT(Booking_ID) AS Total_Rides,
    SUM(Booking_Value) AS Total_Spending,
    ROUND(AVG(Booking_Value), 2) AS Avg_Spending_Per_Ride,
    CASE 
        WHEN COUNT(Booking_ID) >= 50 THEN 'High-Frequency User'
        WHEN COUNT(Booking_ID) BETWEEN 20 AND 49 THEN 'Moderate User'
        ELSE 'Low-Frequency User'
    END AS Customer_Type
FROM bookings
GROUP BY Customer_ID;


