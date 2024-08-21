-- Create Roles Table
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Create Hotels Table
CREATE TABLE hotels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    rating DECIMAL(2, 1) CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Room Types Table
CREATE TABLE room_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Create Rooms Table
CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT,
    room_type_id INT,
    room_number VARCHAR(10) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id),
    FOREIGN KEY (room_type_id) REFERENCES room_types(id)
);

-- Create Bookings Table
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    room_id INT,
    check_in_date DATE,
    check_out_date DATE,
    status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending',
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);

-- Create Payments Table
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer'),
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- Create Reviews Table
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    hotel_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (hotel_id) REFERENCES hotels(id)
);

-- Create Amenities Table
CREATE TABLE amenities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Room Amenities Table (Many-to-Many Relationship)
CREATE TABLE room_amenities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    amenity_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (amenity_id) REFERENCES amenities(id)
);

-- Create Room Availability Table
CREATE TABLE room_availability (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    available_date DATE,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);

-- Seed Initial Data

-- Insert Roles
INSERT INTO roles (role_name) VALUES ('guest'), ('admin');

-- Insert Sample Users
INSERT INTO users (username, email, password, role_id) VALUES
('john_doe', 'john@example.com', 'hashed_password_here', 1),
('admin_user', 'admin@example.com', 'hashed_password_here', 2);

-- Insert Sample Hotels
INSERT INTO hotels (name, location, rating) VALUES
('Grand Plaza', 'New York, NY', 4.5),
('Ocean View', 'Miami, FL', 4.7),
('Mountain Retreat', 'Denver, CO', 4.3);

-- Insert Room Types
INSERT INTO room_types (type_name, description) VALUES
('single', 'A single room with basic amenities'),
('double', 'A double room with standard amenities'),
('suite', 'A luxurious suite with premium amenities');

-- Insert Sample Rooms
INSERT INTO rooms (hotel_id, room_type_id, room_number, price_per_night) VALUES
(1, 1, '101', 100.00),
(1, 2, '102', 150.00),
(2, 3, '201', 300.00),
(3, 2, '301', 180.00);

-- Insert Sample Amenities
INSERT INTO amenities (amenity_name) VALUES
('Wi-Fi'), ('TV'), ('Mini-bar'), ('Air Conditioning'), ('Room Service');

-- Assign Amenities to Rooms
INSERT INTO room_amenities (room_id, amenity_id) VALUES
(1, 1), (1, 2), -- Wi-Fi, TV for room 101
(2, 3), -- Mini-bar for room 102
(3, 4), (3, 5); -- Air Conditioning, Room Service for room 201

-- Insert Room Availability
INSERT INTO room_availability (room_id, available_date, is_available) VALUES
(1, '2024-09-01', TRUE),
(1, '2024-09-02', FALSE),
(2, '2024-09-01', TRUE),
(3, '2024-09-01', TRUE);

-- Insert Sample Bookings
INSERT INTO bookings (user_id, room_id, check_in_date, check_out_date, status, total_price) VALUES
(1, 1, '2024-09-01', '2024-09-03', 'confirmed', 200.00),
(1, 3, '2024-09-05', '2024-09-10', 'pending', 900.00);

-- Insert Sample Payments
INSERT INTO payments (booking_id, amount, payment_method, payment_status) VALUES
(1, 200.00, 'credit_card', 'completed'),
(2, 900.00, 'paypal', 'pending');

-- Insert Sample Reviews
INSERT INTO reviews (user_id, hotel_id, rating, review_text) VALUES
(1, 1, 5, 'Great stay at the Grand Plaza!'),
(1, 2, 4, 'Nice view at Ocean View, but a bit pricey.');
