CREATE TABLE location (
	id_location INT IDENTITY(1, 1) PRIMARY KEY,
	id_distributor INT NOT NULL,		-- FK
	id_location_type INT NOT NULL,
	id_zone INT NOT NULL,
	id_subzone INT NOT NULL,
	id_region INT NOT NULL
);

CREATE TABLE device (
	serial_nbr VARCHAR(50) PRIMARY KEY,
	id_device_type INT NOT NULL,		-- typ urz¹dzenia (np. 14 – poziomowskaz, 15 – koncentrator)
	id_distributor INT NOT NULL,		-- FK
	id_device_state_type INT NOT NULL	-- stan urz¹dzenia (np. 1 = sprawne, 0 = niesprawne)
);

CREATE TABLE location_equipment (
	id_location_equipment INT IDENTITY(1, 1) PRIMARY KEY,
	id_location INT NOT NULL,		-- FK do location
	io_meter INT NOT NULL,
	serial_nbr VARCHAR(50) NOT NULL,	
	start_time DATETIME NOT NULL,
	end_time DATETIME NULL,		-- null oznacza projekt niezakoñczony
	CONSTRAINT fk_id_location FOREIGN KEY (id_location)
		REFERENCES location(id_location),
	CONSTRAINT fk_serial_nbr FOREIGN KEY (serial_nbr)
		REFERENCES device(serial_nbr)
);