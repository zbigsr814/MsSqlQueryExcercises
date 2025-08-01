SELECT * FROM dbo.device;

-- 1
SELECT d.* FROM dbo.device d
WHERE 
	d.id_distributor = 3
	AND (d.id_device_state_type % 2) = 1;		-- nieparzysta liczba - Ok

-- 2
SELECT d.* FROM dbo.device d
INNER JOIN dbo.location_equipment le ON d.serial_nbr = le.serial_nbr
WHERE 
	d.id_distributor = 3
	AND le.end_time IS NULL;		-- wci¹¿ zamontowane device

-- 3
SELECT COUNT(l.id_location) FROM dbo.location l
WHERE 
	l.id_distributor = 3;
	
-- 4
SELECT l.* FROM dbo.location l
INNER JOIN dbo.location_equipment le ON l.id_location = le.id_location
WHERE 
	l.id_distributor = 3
	AND le.serial_nbr IS NULL;

-- 5
WITH ranked_devices AS (
    SELECT
        l.id_location,
        d.serial_nbr,
        d.id_device_type,
        le.start_time,
        ROW_NUMBER() OVER (PARTITION BY l.id_location ORDER BY le.start_time DESC) AS rn	-- funkcja okna rank dla devices wg daty
    FROM dbo.location l
    INNER JOIN dbo.location_equipment le ON l.id_location = le.id_location
    INNER JOIN dbo.device d ON le.serial_nbr = d.serial_nbr
)
SELECT
    id_location,
    serial_nbr,
    id_device_type
FROM ranked_devices
WHERE rn = 1
ORDER BY id_location;

-- 6
SELECT DISTINCT l.id_location FROM dbo.location l
INNER JOIN dbo.location_equipment le ON l.id_location = le.id_location
INNER JOIN dbo.device d ON le.serial_nbr = d.serial_nbr
WHERE
	d.id_device_type = 14
GROUP BY
	l.id_location
HAVING
	COUNT(l.id_location) >= 2;

-- 7
SELECT DISTINCT l.* FROM dbo.location l
INNER JOIN dbo.location_equipment le ON l.id_location = le.id_location
INNER JOIN dbo.device d ON le.serial_nbr = d.serial_nbr
WHERE
	l.id_distributor = 29
	AND (d.id_device_type = 14 OR d.id_device_type = 15);

-- 8
WITH localizated_distributor AS (
	SELECT DISTINCT l.id_location FROM dbo.location l
	INNER JOIN dbo.location_equipment le ON l.id_location = le.id_location
	INNER JOIN dbo.device d ON le.serial_nbr = d.serial_nbr
	WHERE
		l.id_distributor = 29
		AND YEAR(le.start_time) = 2013
		AND DATEDIFF(DAY, le.start_time, ISNULL(le.end_time, GETDATE())) >= 7
)
SELECT DISTINCT d.serial_nbr FROM dbo.location l
INNER JOIN dbo.location_equipment le ON l.id_location = le.id_location
INNER JOIN dbo.device d ON le.serial_nbr = d.serial_nbr
WHERE
	l.id_location IN (SELECT ld.id_location FROM localizated_distributor ld);

-- 10
WITH broken_devices AS (
	SELECT d.serial_nbr FROM dbo.location l
	INNER JOIN dbo.location_equipment le ON l.id_location = le.id_location
	INNER JOIN dbo.device d ON le.serial_nbr = d.serial_nbr
	WHERE
		(d.id_device_state_type % 2) = 0		-- parzysta liczba - Niesprawny
		AND d.id_device_type = 14				-- typ 14
		AND d.id_distributor = 29				-- dystrybutor 29
		AND d.id_distributor != l.id_distributor	-- inny dystrybutor ni¿ lokalizacja
)
UPDATE le
SET le.end_time = GETDATE()
FROM dbo.location_equipment le
INNER JOIN broken_devices bd ON bd.serial_nbr = le.serial_nbr;
	