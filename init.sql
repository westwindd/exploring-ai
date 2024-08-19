-- Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('guest', 'admin') DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hotels Table
CREATE TABLE hotels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    rating DECIMAL(2, 1) CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rooms Table
CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT,
    room_number VARCHAR(10) NOT NULL,
    type ENUM('single', 'double', 'suite') NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id)
);

-- Bookings Table
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    room_id INT,
    check_in_date DATE,
    check_out_date DATE,
    status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);

-- Payments Table
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'debit_card', 'paypal'),
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- Amenities Table
CREATE TABLE amenities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    amenity_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);

-- Seed some data for testing

-- Insert into Hotels
INSERT INTO hotels (name, location, rating) VALUES
('Grand Plaza', 'New York, NY', 4.5),
('Ocean View', 'Miami, FL', 4.7),
('Mountain Retreat', 'Denver, CO', 4.3);

-- Insert into Rooms
INSERT INTO rooms (hotel_id, room_number, type, price_per_night, is_available) VALUES
(1, '101', 'single', 100.00, TRUE),
(1, '102', 'double', 150.00, TRUE),
(2, '201', 'suite', 300.00, TRUE),
(2, '202', 'single', 120.00, TRUE),
(3, '301', 'double', 180.00, TRUE);

-- Insert into Users
INSERT INTO users (username, email, password, role) VALUES
('john_doe', 'john@example.com', 'hashed_password_here', 'guest'),
('admin_user', 'admin@example.com', 'hashed_password_here', 'admin');

-- Insert into Bookings
INSERT INTO bookings (user_id, room_id, check_in_date, check_out_date, status) VALUES
(1, 1, '2024-08-20', '2024-08-22', 'confirmed'),
(1, 3, '2024-09-01', '2024-09-05', 'pending');

-- Insert into Payments
INSERT INTO payments (booking_id, amount, payment_method, payment_status) VALUES
(1, 200.00, 'credit_card', 'completed'),
(2, 600.00, 'paypal', 'pending');

-- Insert into Amenities
INSERT INTO amenities (room_id, amenity_name) VALUES
(1, 'Wi-Fi'),
(1, 'TV'),
(2, 'Mini-bar'),
(3, 'Air Conditioning'),
(3, 'Room Service');
