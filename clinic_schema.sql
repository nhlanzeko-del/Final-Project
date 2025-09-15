-- Create the database
CREATE DATABASE IF NOT EXISTS clinic_db;
USE clinic_db;

-- Table: patients
CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Table: appointments
CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATETIME NOT NULL,
    reason VARCHAR(255),
    patient_id INT NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id)
);
