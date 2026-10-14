-- SQL Challenge: Stornierungsrate von Fahrten für nicht-gesperrte Nutzer (LeetCode Hard)

DROP TABLE IF EXISTS #Trips;
DROP TABLE IF EXISTS #Users;

CREATE TABLE #Users (UsersID INT PRIMARY KEY, Banned VARCHAR(3), [Role] VARCHAR(10));
CREATE TABLE #Trips (TripID INT PRIMARY KEY, ClientID INT, DriverID INT, [Status] VARCHAR(30), RequestDate DATE);

INSERT INTO #Users VALUES 
(1, 'No', 'client'), (2, 'Yes', 'client'), (3, 'No', 'client'),
(10, 'No', 'driver'), (11, 'No', 'driver');

INSERT INTO #Trips VALUES
(101, 1, 10, 'completed', '2026-10-01'),
(102, 2, 11, 'cancelled_by_driver', '2026-10-01'), -- Client 2 ist gesperrt (Banned)
(103, 3, 10, 'cancelled_by_client', '2026-10-01'),
(104, 1, 10, 'completed', '2026-10-02');

SELECT 
    t.RequestDate,
    ROUND(
        SUM(CASE WHEN t.[Status] LIKE 'cancelled%' THEN 1.0 ELSE 0.0 END) / COUNT(*),
        2
    ) AS CancellationRate
FROM #Trips t
INNER JOIN #Users c ON t.ClientID = c.UsersID AND c.Banned = 'No'
INNER JOIN #Users d ON t.DriverID = d.UsersID AND d.Banned = 'No'
GROUP BY t.RequestDate;
