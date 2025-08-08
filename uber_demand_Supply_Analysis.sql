CREATE DATABASE IF NOT EXISTS uber_analysis;
USE uber_analysis;

CREATE TABLE IF NOT EXISTS uber_requests (
    Request_id INT,
    Pickup_point VARCHAR(50),
    Status VARCHAR(50),
    Driver_id INT,
    Trip_duration_minutes FLOAT,
    Demand_Supply_Gap INT,
    Day_of_week VARCHAR(50),
    Hour_of_day INT,
    Time_slot VARCHAR(50)
);

SELECT * FROM uber_requests; 


-- Total number of requests from each pickup point
SELECT pickup_point, COUNT(*) AS total_requests
FROM uber_requests
GROUP BY pickup_point;

-- View all requests made on Friday
SELECT * 
FROM uber_requests
WHERE Day_of_week = 'Monday'
ORDER BY Hour_of_day;

-- Average trip duration per pickup point
SELECT Pickup_point, AVG(Trip_duration_minutes) AS avg_trip_duration
FROM uber_requests
GROUP BY Pickup_point;

-- Total demand-supply gap per day
SELECT Day_of_week, SUM(Demand_Supply_Gap) AS total_gap
FROM uber_requests
GROUP BY Day_of_week
ORDER BY total_gap DESC;

-- Top 5 hours with the highest demand-supply gap
SELECT Hour_of_day, SUM(Demand_Supply_Gap) AS total_gap
FROM uber_requests
GROUP BY Hour_of_day
ORDER BY total_gap DESC
LIMIT 5;

CREATE TABLE IF NOT EXISTS drivers (
    Driver_id INT,
    Name VARCHAR(100),
    Rating FLOAT
);

INSERT INTO uber_analysis.drivers(Driver_id, Name, Rating) VALUES
(1, 'Ravi Kumar', 4.8),
(12, 'Anjali Mehta', 4.5),
(3, 'Mohammed Imran', 4.2),
(14, 'Sneha Roy', 4.9),
(51, 'Rahul Sharma', 4.0),
(60, 'Priya Das', 4.6),
(78, 'Arjun Verma', 4.3),
(18, 'Neha Singh', 4.7),
(29, 'Vikram Patel', 4.1),
(11, 'Divya Nair', 4.4);

-- Join request data with driver ratings
SELECT 
    ur.Request_id,
    ur.Pickup_point,
    d.Name AS Driver_Name,
    d.Rating,
    ur.Trip_duration_minutes
FROM uber_requests ur
INNER JOIN drivers d ON ur.Driver_id = d.Driver_id
WHERE ur.Status = 'Trip Completed';


-- Time slot-based analysis
CREATE INDEX idx_time_slot ON uber_requests(Time_slot);

-- Time slot with the highest average demand-supply gap
SELECT Time_slot, ROUND(AVG(Demand_Supply_Gap), 2) AS avg_gap
FROM uber_requests
GROUP BY Time_slot
HAVING ROUND(avg_gap, 2) = (
    SELECT MAX(rounded_gap)
    FROM (
        SELECT ROUND(AVG(Demand_Supply_Gap), 2) AS rounded_gap
        FROM uber_requests
        GROUP BY Time_slot
    ) AS gaps
);

-- DROP TABLE IF EXISTS time_slot_summary; if it’s a table instead
DROP VIEW IF EXISTS time_slot_summary;

-- Create View as time_slot_summary
CREATE VIEW time_slot_summary AS
SELECT 
    Day_of_week,
    Time_slot,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN Status = 'No Cars Available' THEN 1 ELSE 0 END) AS no_cars,
    SUM(Demand_Supply_Gap) AS total_gap
FROM uber_requests
GROUP BY Day_of_week, Time_slot;

SELECT * FROM time_slot_summary;








