CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

CREATE TABLE department (
    department_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20),
    phone VARCHAR(30),
    email VARCHAR(100),
    chairman_doctor_id INT,
    chairman_start_date DATE,
    PRIMARY KEY (department_id)
);

CREATE TABLE doctor (
    doctor_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ssn VARCHAR(20) NOT NULL UNIQUE,
    gender ENUM('Male','Female') NOT NULL,
    birthdate DATE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    specialization VARCHAR(100),
    degree VARCHAR(100),
    major_scientific_area VARCHAR(100),
    license_number VARCHAR(50) NOT NULL UNIQUE,
    salary DECIMAL(10,2),
    join_date DATE,
    department_id INT,
    PRIMARY KEY (doctor_id),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

ALTER TABLE department
ADD CONSTRAINT fk_department_chairman
FOREIGN KEY (chairman_doctor_id)
REFERENCES doctor(doctor_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

CREATE TABLE department_location (
    location_id INT NOT NULL AUTO_INCREMENT,
    department_id INT,
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    floor INT,
    PRIMARY KEY (location_id),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE nurse (
    nurse_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ssn VARCHAR(20) NOT NULL UNIQUE,
    gender ENUM('Male','Female') NOT NULL,
    birthdate DATE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    role_type ENUM('Scrub','Circulating','Recovery') NOT NULL,
    salary DECIMAL(10,2),
    shift_type VARCHAR(30),
    join_date DATE,
    department_id INT,
    PRIMARY KEY (nurse_id),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE patient (
    patient_id INT NOT NULL AUTO_INCREMENT,
    patient_number VARCHAR(30) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ssn VARCHAR(20) NOT NULL UNIQUE,
    gender ENUM('Male','Female') NOT NULL,
    birthdate DATE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    blood_type ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    allergies TEXT,
    weight_kg DECIMAL(5,2),
    height_cm DECIMAL(5,2),
    blood_pressure VARCHAR(20),
    heart_rate INT,
    temperature DECIMAL(4,1),
    medical_history TEXT,
    admission_date DATE,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(30),
    PRIMARY KEY (patient_id)
);

CREATE TABLE operation_room (
    room_id INT NOT NULL AUTO_INCREMENT,
    department_id INT,
    room_number VARCHAR(20),
    room_type ENUM('Major','Minor','Emergency','Hybrid','Endoscopy'),
    building VARCHAR(100),
    floor_number INT,
    capacity INT,
    status ENUM('Available','In-Use','Cleaning','Maintenance','Reserved'),
    PRIMARY KEY (room_id),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE appointment (
    appointment_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    scheduled_at DATETIME NOT NULL,
    reason TEXT,
    status ENUM('Pending','Confirmed','Cancelled','Completed','No-Show') NOT NULL,
    fee DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Unpaid','Paid','Refunded','Partially Refunded') NOT NULL,
    payment_date DATETIME,
    cancelled_at DATETIME,
    cancellation_reason TEXT,
    refund_amount DECIMAL(10,2),
    refund_date DATETIME,
    PRIMARY KEY (appointment_id),
    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id)
        REFERENCES doctor(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE surgery (
    surgery_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT,
    appointment_id INT,
    lead_surgeon_dr_id INT,
    room_id INT,
    recovery_room_id INT,
    surgery_type VARCHAR(100),
    surgery_category ENUM('Elective','Urgent','Emergency'),
    diagnosis TEXT,
    anesthesia_type VARCHAR(50),
    risk_level ENUM('Low','Moderate','High','Critical'),
    consent_signed BOOLEAN,
    fasting_confirmed BOOLEAN,
    scheduled_start DATETIME,
    scheduled_end DATETIME,
    actual_start DATETIME,
    actual_end DATETIME,
    surgery_status ENUM('Scheduled','In-Progress','Completed','Cancelled','Postponed'),
    complications TEXT,
    recovery_notes TEXT,
    pain_level ENUM('No Pain','Mild','Moderate','Severe','Extreme'),
    discharge_status VARCHAR(30),
    outcome ENUM('Successful','Complication','Failed','Patient Deceased'),
    PRIMARY KEY (surgery_id),
    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (appointment_id)
        REFERENCES appointment(appointment_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (lead_surgeon_dr_id)
        REFERENCES doctor(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (room_id)
        REFERENCES operation_room(room_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
	FOREIGN KEY (recovery_room_id)
		REFERENCES operation_room(room_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

CREATE TABLE surgical_team (
    team_id INT NOT NULL AUTO_INCREMENT,
    surgery_id INT,
    doctor_id INT,
    nurse_id INT,
    member_type ENUM('Lead Surgeon','Assistant Surgeon','Anesthesiologist','Scrub Nurse','Circulating Nurse','Technician'),
    role_in_surgery VARCHAR(50),
    assigned_at DATETIME,
    PRIMARY KEY (team_id),
    FOREIGN KEY (surgery_id)
        REFERENCES surgery(surgery_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id)
        REFERENCES doctor(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (nurse_id)
        REFERENCES nurse(nurse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE equipment (
    equipment_id INT NOT NULL AUTO_INCREMENT,
    room_id INT,
    name VARCHAR(100),
    equipment_type ENUM('Surgical Instrument','Anesthesia Device','Monitoring Device','Sterilization Device','Imaging Device'),
    status ENUM('Available','In-Use','Sterilizing','Under Maintenance'),
    purchase_date DATE,
    last_maintained_date DATE,
    PRIMARY KEY (equipment_id),
    FOREIGN KEY (room_id)
        REFERENCES operation_room(room_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE surgery_equipment (
    id INT NOT NULL AUTO_INCREMENT,
    surgery_id INT,
    equipment_id INT,
    used_at DATETIME,
    returned_at DATETIME,
    condition_after ENUM('Good','Damaged','Needs Repair'),
    PRIMARY KEY (id),
    UNIQUE KEY (surgery_id, equipment_id),
    FOREIGN KEY (surgery_id)
        REFERENCES surgery(surgery_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (equipment_id)
        REFERENCES equipment(equipment_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE medication (
    medication_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    PRIMARY KEY (medication_id)
);

CREATE TABLE prescription (
    prescription_id INT NOT NULL AUTO_INCREMENT,
    doctor_id INT,
    patient_id INT,
    surgery_id INT,
    prescription_date DATE,
    PRIMARY KEY (prescription_id),
    FOREIGN KEY (doctor_id)
        REFERENCES doctor(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (surgery_id)
        REFERENCES surgery(surgery_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE prescription_medication (
    id INT NOT NULL AUTO_INCREMENT,
    prescription_id INT,
    medication_id INT,
    times_per_day INT,
    dose_mg DECIMAL(8,2),
    directions TEXT,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (id),
    UNIQUE KEY (prescription_id, medication_id),
    FOREIGN KEY (prescription_id)
        REFERENCES prescription(prescription_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (medication_id)
        REFERENCES medication(medication_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE scan_file (
    scan_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT,
    uploaded_by_doctor_id INT,
    surgery_id INT,
    file_path VARCHAR(500),
    file_type VARCHAR(50),
    scan_date DATE,
    description TEXT,
    uploaded_at DATETIME,
    PRIMARY KEY (scan_id),
    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (uploaded_by_doctor_id)
        REFERENCES doctor(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (surgery_id)
        REFERENCES surgery(surgery_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE examination (
    exam_id INT NOT NULL AUTO_INCREMENT,
    doctor_id INT,
    patient_id INT,
    exam_date DATETIME,
    hours_per_week INT,
    notes TEXT,
    PRIMARY KEY (exam_id),
    FOREIGN KEY (doctor_id)
        REFERENCES doctor(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE contact_form (
    contact_id INT NOT NULL AUTO_INCREMENT,
    status ENUM('New','Read','Responded','Archived'),
    full_name VARCHAR(100),
    email VARCHAR(100),
    subject VARCHAR(200),
    message TEXT,
    submitted_at DATETIME,
    PRIMARY KEY (contact_id)
);

CREATE TABLE user_account (
    user_id INT NOT NULL AUTO_INCREMENT,
    is_active BOOLEAN,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Doctor','Patient','Nurse','Admin'),
    linked_id INT,
    created_at DATETIME,
    last_login DATETIME,
    PRIMARY KEY (user_id)
);
CREATE TABLE hospital (
    hospital_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(30),
    email VARCHAR(100),
    PRIMARY KEY (hospital_id)
);
ALTER TABLE department
ADD hospital_id INT;

ALTER TABLE department
ADD FOREIGN KEY (hospital_id)
REFERENCES hospital(hospital_id)
ON DELETE SET NULL
ON UPDATE CASCADE;
ALTER TABLE operation_room
ADD hospital_id INT;

ALTER TABLE operation_room
ADD FOREIGN KEY (hospital_id)
REFERENCES hospital(hospital_id)
ON DELETE SET NULL
ON UPDATE CASCADE;
INSERT INTO hospital (name, address, phone, email)
VALUES
('Cairo General Hospital', 'Downtown Cairo', '0223456789', 'info@cairohospital.com');

INSERT INTO department (hospital_id, name, code, phone, email)
VALUES 
(1, 'Cardiology', 'CRD', '0100000001', 'cardio@hospital.com'),
(1, 'Neurology', 'NEU', '0100000002', 'neuro@hospital.com');

INSERT INTO doctor (
    first_name,
    last_name,
    ssn,
    gender,
    birthdate,
    phone,
    email,
    specialization,
    license_number,
    department_id
)
VALUES
('Ahmed', 'Hassan', '123456789', 'Male', '1980-05-10', '0111111111', 'ahmed@hospital.com', 'Cardiologist', 'LIC001', 1),
('Sara', 'Mohamed', '987654321', 'Female', '1985-08-20', '0111111112', 'sara@hospital.com', 'Neurologist', 'LIC002', 2);

UPDATE department
SET chairman_doctor_id = 1
WHERE department_id = 1;

UPDATE department
SET chairman_doctor_id = 2
WHERE department_id = 2;

INSERT INTO nurse (
    first_name,
    last_name,
    ssn,
    gender,
    birthdate,
    phone,
    role_type,
    department_id
)
VALUES
('Mona', 'Ali', '111222333', 'Female', '1990-02-10', '0122222222', 'Scrub', 1),
('Omar', 'Khaled', '444555666', 'Male', '1992-07-15', '0122222223', 'Circulating', 2);

INSERT INTO patient (
    patient_number,
    first_name,
    last_name,
    ssn,
    gender,
    birthdate,
    phone,
    blood_type
)
VALUES
('P001', 'Youssef', 'Ali', '555666777', 'Male', '2000-01-01', '0109999999', 'A+'),
('P002', 'Nour', 'Ahmed', '888999000', 'Female', '1998-03-15', '0108888888', 'O-');

INSERT INTO operation_room (
    hospital_id,
    department_id,
    room_number,
    room_type,
    building,
    floor_number,
    capacity,
    status
)
VALUES
(1, 1, 'OR-101', 'Major', 'A', 1, 2, 'Available'),
(1, 2, 'OR-202', 'Emergency', 'B', 2, 1, 'In-Use');

INSERT INTO appointment (
    patient_id,
    doctor_id,
    scheduled_at,
    reason,
    status,
    fee,
    payment_status
)
VALUES
(1, 1, '2026-05-20 10:00:00', 'Checkup', 'Confirmed', 500, 'Paid'),
(2, 2, '2026-05-21 11:00:00', 'Headache', 'Pending', 300, 'Unpaid');

INSERT INTO surgery (
    patient_id,
    appointment_id,
    lead_surgeon_dr_id,
    room_id,
    recovery_room_id,
    surgery_type,
    surgery_category,
    surgery_status,
    risk_level,
    outcome
)
VALUES
(1, 1, 1, 1, NULL, 'Heart Surgery', 'Elective', 'Scheduled', 'High', 'Successful');

INSERT INTO surgical_team (
    surgery_id,
    doctor_id,
    nurse_id,
    member_type,
    role_in_surgery
)
VALUES
(1, 1, NULL, 'Lead Surgeon', 'Main Operator'),
(1, NULL, 1, 'Scrub Nurse', 'Assisting');

INSERT INTO equipment (
    room_id,
    name,
    equipment_type,
    status
)
VALUES
(1, 'ECG Machine', 'Monitoring Device', 'Available'),
(2, 'Ventilator', 'Anesthesia Device', 'In-Use');

INSERT INTO surgery_equipment (
    surgery_id,
    equipment_id,
    condition_after
)
VALUES
(1, 1, 'Good');

INSERT INTO medication (
    name,
    category,
    description
)
VALUES
('Paracetamol', 'Painkiller', 'Used for pain relief'),
('Amoxicillin', 'Antibiotic', 'Treats infections');

INSERT INTO prescription (
    doctor_id,
    patient_id,
    surgery_id,
    prescription_date
)
VALUES
(1, 1, 1, '2026-05-19');

INSERT INTO prescription_medication (
    prescription_id,
    medication_id,
    times_per_day,
    dose_mg,
    directions,
    start_date,
    end_date
)
VALUES
(1, 1, 3, 500, 'After meals', '2026-05-19', '2026-05-25');

INSERT INTO scan_file (
    patient_id,
    uploaded_by_doctor_id,
    surgery_id,
    file_path,
    file_type,
    scan_date
)
VALUES
(1, 1, 1, '/scans/xray1.jpg', 'X-Ray', '2026-05-19');

INSERT INTO examination (
    doctor_id,
    patient_id,
    exam_date,
    hours_per_week,
    notes
)
VALUES
(1, 1, '2026-05-19 09:00:00', 40, 'Routine check');

INSERT INTO contact_form (
    status,
    full_name,
    email,
    subject,
    message,
    submitted_at
)
VALUES
('New', 'Test User', 'test@mail.com', 'Inquiry', 'Need appointment', '2026-05-19 08:00:00');

INSERT INTO user_account (
    is_active,
    username,
    email,
    password_hash,
    role,
    linked_id
)
VALUES
(TRUE, 'doctor1', 'doc1@hospital.com', 'hash123', 'Doctor', 1),
(TRUE, 'patient1', 'pat1@hospital.com', 'hash456', 'Patient', 1);