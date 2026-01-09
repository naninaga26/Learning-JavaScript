# Online Salon Booking System - Database Design

## System Overview
A salon booking system with 3 service providers offering various services with different durations. The system should handle real-time slot availability, bookings, and cancellations.

## Database Schema

### 1. Users Table
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('customer', 'admin', 'provider') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_phone (phone)
);
```

### 2. Service Providers Table
```sql
CREATE TABLE service_providers (
    provider_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(255),
    experience_years INT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_available (is_available)
);
```

### 3. Services Table
```sql
CREATE TABLE services (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category ENUM('haircut', 'grooming', 'spa', 'styling', 'coloring') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_active (is_active)
);
```

### 4. Service Menu (Sample Data)
```sql
-- Sample services to insert
INSERT INTO services (service_name, description, duration_minutes, price, category) VALUES
('Haircut', 'Professional haircut with styling', 30, 25.00, 'haircut'),
('Trimming', 'Beard trimming and shaping', 15, 12.00, 'grooming'),
('Hair Wash & Blow Dry', 'Complete hair wash and blow dry', 20, 15.00, 'styling'),
('Facial', 'Deep cleansing facial treatment', 45, 40.00, 'spa'),
('Hair Coloring', 'Full hair coloring service', 90, 80.00, 'coloring'),
('Beard Grooming', 'Full beard grooming with oil treatment', 25, 18.00, 'grooming'),
('Hair Spa', 'Relaxing hair spa treatment', 60, 50.00, 'spa'),
('Kids Haircut', 'Haircut for children under 12', 20, 15.00, 'haircut'),
('Head Massage', 'Relaxing head and scalp massage', 15, 10.00, 'spa'),
('Shaving', 'Traditional shaving service', 20, 15.00, 'grooming');
```

### 5. Provider Services (Junction Table)
```sql
CREATE TABLE provider_services (
    provider_service_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_id INT NOT NULL,
    service_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES service_providers(provider_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE,
    UNIQUE KEY unique_provider_service (provider_id, service_id),
    INDEX idx_provider (provider_id),
    INDEX idx_service (service_id)
);
```

### 6. Working Hours Table
```sql
CREATE TABLE working_hours (
    working_hour_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_working BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES service_providers(provider_id) ON DELETE CASCADE,
    UNIQUE KEY unique_provider_day (provider_id, day_of_week),
    INDEX idx_provider_day (provider_id, day_of_week)
);
```

### 7. Bookings Table (Core Table)
```sql
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    service_id INT NOT NULL,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled', 'no_show') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES service_providers(provider_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE,
    INDEX idx_provider_date (provider_id, booking_date),
    INDEX idx_user_date (user_id, booking_date),
    INDEX idx_status (status),
    INDEX idx_booking_datetime (booking_date, start_time, end_time)
);
```

### 8. Time Slots Table (For Pre-defined Slots)
```sql
CREATE TABLE time_slots (
    slot_id INT PRIMARY KEY AUTO_INCREMENT,
    slot_time TIME NOT NULL,
    slot_label VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_slot_time (slot_time),
    INDEX idx_slot_time (slot_time)
);

-- Sample time slots (9 AM to 8 PM, 15-minute intervals)
INSERT INTO time_slots (slot_time, slot_label) VALUES
('09:00:00', '09:00 AM'), ('09:15:00', '09:15 AM'), ('09:30:00', '09:30 AM'), ('09:45:00', '09:45 AM'),
('10:00:00', '10:00 AM'), ('10:15:00', '10:15 AM'), ('10:30:00', '10:30 AM'), ('10:45:00', '10:45 AM'),
('11:00:00', '11:00 AM'), ('11:15:00', '11:15 AM'), ('11:30:00', '11:30 AM'), ('11:45:00', '11:45 AM'),
('12:00:00', '12:00 PM'), ('12:15:00', '12:15 PM'), ('12:30:00', '12:30 PM'), ('12:45:00', '12:45 PM'),
('01:00:00', '01:00 PM'), ('01:15:00', '01:15 PM'), ('01:30:00', '01:30 PM'), ('01:45:00', '01:45 PM'),
('02:00:00', '02:00 PM'), ('02:15:00', '02:15 PM'), ('02:30:00', '02:30 PM'), ('02:45:00', '02:45 PM'),
('03:00:00', '03:00 PM'), ('03:15:00', '03:15 PM'), ('03:30:00', '03:30 PM'), ('03:45:00', '03:45 PM'),
('04:00:00', '04:00 PM'), ('04:15:00', '04:15 PM'), ('04:30:00', '04:30 PM'), ('04:45:00', '04:45 PM'),
('05:00:00', '05:00 PM'), ('05:15:00', '05:15 PM'), ('05:30:00', '05:30 PM'), ('05:45:00', '05:45 PM'),
('06:00:00', '06:00 PM'), ('06:15:00', '06:15 PM'), ('06:30:00', '06:30 PM'), ('06:45:00', '06:45 PM'),
('07:00:00', '07:00 PM'), ('07:15:00', '07:15 PM'), ('07:30:00', '07:30 PM'), ('07:45:00', '07:45 PM'),
('08:00:00', '08:00 PM');
```

### 9. Reviews Table
```sql
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES service_providers(provider_id) ON DELETE CASCADE,
    UNIQUE KEY unique_booking_review (booking_id),
    INDEX idx_provider (provider_id),
    INDEX idx_rating (rating)
);
```

### 10. Notifications Table
```sql
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    booking_id INT,
    notification_type ENUM('booking_confirmed', 'booking_reminder', 'booking_cancelled', 'review_request') NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_sent_at (sent_at)
);
```

---

## Key SQL Queries for Slot Availability

### 1. Get Available Slots for a Provider on a Specific Date
```sql
-- This query returns available time slots for a provider on a given date
-- considering their working hours and existing bookings

WITH RECURSIVE all_slots AS (
    SELECT
        slot_time,
        slot_label
    FROM time_slots
    WHERE is_active = TRUE
),
provider_working_time AS (
    SELECT
        start_time,
        end_time
    FROM working_hours
    WHERE provider_id = :provider_id
    AND day_of_week = DAYNAME(:booking_date)
    AND is_working = TRUE
),
booked_slots AS (
    SELECT
        start_time,
        end_time
    FROM bookings
    WHERE provider_id = :provider_id
    AND booking_date = :booking_date
    AND status NOT IN ('cancelled', 'no_show')
)
SELECT
    a.slot_time,
    a.slot_label,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM booked_slots b
            WHERE a.slot_time >= b.start_time
            AND a.slot_time < b.end_time
        ) THEN FALSE
        ELSE TRUE
    END AS is_available
FROM all_slots a
CROSS JOIN provider_working_time p
WHERE a.slot_time >= p.start_time
AND a.slot_time < p.end_time
AND ADDTIME(a.slot_time, SEC_TO_TIME(:service_duration_minutes * 60)) <= p.end_time
ORDER BY a.slot_time;
```

### 2. Check if Slot is Available Before Booking
```sql
-- Check if the selected time slot is available for booking
SELECT
    CASE
        WHEN COUNT(*) > 0 THEN FALSE
        ELSE TRUE
    END AS is_slot_available
FROM bookings
WHERE provider_id = :provider_id
AND booking_date = :booking_date
AND status NOT IN ('cancelled', 'no_show')
AND (
    -- Check if new booking overlaps with existing bookings
    (start_time < :new_end_time AND end_time > :new_start_time)
);
```

### 3. Get All Available Providers for a Service at a Given Time
```sql
-- Find which providers are available for a specific service at a given date/time
SELECT
    sp.provider_id,
    sp.full_name,
    sp.rating,
    sp.experience_years
FROM service_providers sp
INNER JOIN provider_services ps ON sp.provider_id = ps.provider_id
INNER JOIN working_hours wh ON sp.provider_id = wh.provider_id
WHERE ps.service_id = :service_id
AND sp.is_available = TRUE
AND wh.day_of_week = DAYNAME(:booking_date)
AND wh.is_working = TRUE
AND :start_time >= wh.start_time
AND :end_time <= wh.end_time
AND sp.provider_id NOT IN (
    SELECT provider_id
    FROM bookings
    WHERE booking_date = :booking_date
    AND status NOT IN ('cancelled', 'no_show')
    AND (start_time < :end_time AND end_time > :start_time)
)
ORDER BY sp.rating DESC, sp.experience_years DESC;
```

### 4. Create a New Booking
```sql
-- Insert a new booking (use within a transaction)
START TRANSACTION;

-- Lock the provider's schedule for the date to prevent double-booking
SELECT provider_id
FROM service_providers
WHERE provider_id = :provider_id
FOR UPDATE;

-- Verify slot is still available
SET @slot_available = (
    SELECT COUNT(*) = 0
    FROM bookings
    WHERE provider_id = :provider_id
    AND booking_date = :booking_date
    AND status NOT IN ('cancelled', 'no_show')
    AND (start_time < :end_time AND end_time > :start_time)
);

-- Insert booking if available
INSERT INTO bookings (
    user_id,
    provider_id,
    service_id,
    booking_date,
    start_time,
    end_time,
    status,
    total_amount
)
SELECT
    :user_id,
    :provider_id,
    :service_id,
    :booking_date,
    :start_time,
    :end_time,
    'confirmed',
    s.price
FROM services s
WHERE s.service_id = :service_id
AND @slot_available = 1;

COMMIT;
```

### 5. Cancel a Booking and Free Up the Slot
```sql
-- Cancel an existing booking
UPDATE bookings
SET
    status = 'cancelled',
    cancellation_reason = :reason,
    cancelled_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE booking_id = :booking_id
AND user_id = :user_id
AND status NOT IN ('cancelled', 'completed')
AND CONCAT(booking_date, ' ', start_time) > NOW();
```

### 6. Get User's Booking History
```sql
SELECT
    b.booking_id,
    b.booking_date,
    b.start_time,
    b.end_time,
    b.status,
    b.total_amount,
    s.service_name,
    s.duration_minutes,
    sp.full_name AS provider_name,
    r.rating,
    r.comment
FROM bookings b
INNER JOIN services s ON b.service_id = s.service_id
INNER JOIN service_providers sp ON b.provider_id = sp.provider_id
LEFT JOIN reviews r ON b.booking_id = r.booking_id
WHERE b.user_id = :user_id
ORDER BY b.booking_date DESC, b.start_time DESC;
```

---

## Entity Relationship Diagram (ERD)

```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│   users     │◄────────│service_providers │────────►│   services  │
└─────────────┘         └──────────────────┘         └─────────────┘
      │                         │                            │
      │                         │                            │
      │                         └────────────┬───────────────┘
      │                                      │
      │                              ┌───────▼──────────┐
      │                              │provider_services │
      │                              └──────────────────┘
      │
      │                  ┌──────────────────┐
      └──────────────────┤    bookings      │
                         └──────────────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
              ┌─────▼─────┐ ┌────▼──────┐ ┌───▼──────────┐
              │  reviews  │ │notifications│ │working_hours │
              └───────────┘ └────────────┘ └──────────────┘
```

---

## Business Logic Rules

### Booking Rules:
1. **Slot Duration**: Each service has a fixed duration (haircut: 30 min, trimming: 15 min, etc.)
2. **No Overlapping**: A provider cannot have overlapping bookings
3. **Working Hours**: Bookings must fall within provider's working hours
4. **Cancellation**: Users can cancel bookings, which immediately frees up the slot
5. **Buffer Time**: Consider adding 5-minute buffer between appointments for cleanup

### Slot Availability:
- **Real-time Check**: Always verify slot availability before confirming booking
- **Locking**: Use database transactions with row-level locking to prevent race conditions
- **Cancelled Slots**: Immediately show cancelled slots as available
- **Status Filter**: Only consider 'pending' and 'confirmed' bookings when checking availability

### Constraints:
- Maximum 3 providers (enforced at application level)
- Minimum booking duration: 15 minutes
- Bookings can only be made for future dates/times
- Cannot book more than 30 days in advance (configurable)

---

## Indexes for Performance

Key indexes have been added to optimize:
1. **Slot availability queries**: `idx_provider_date`, `idx_booking_datetime`
2. **User lookups**: `idx_email`, `idx_phone`
3. **Provider availability**: `idx_available`, `idx_provider_day`
4. **Booking status filtering**: `idx_status`

---

## Sample API Endpoints (Reference)

```
GET    /api/services                          # List all services
GET    /api/providers                         # List all providers
GET    /api/providers/:id/services           # Get services offered by provider
GET    /api/availability                      # Get available slots
       ?provider_id=1&date=2026-01-15&service_id=1
POST   /api/bookings                          # Create new booking
GET    /api/bookings                          # Get user's bookings
PATCH  /api/bookings/:id/cancel              # Cancel booking
POST   /api/reviews                           # Submit review
GET    /api/providers/:id/reviews            # Get provider reviews
```

---

## Notes

- Use **UTC timezone** for all timestamps, convert to local timezone in application layer
- Implement **rate limiting** to prevent slot-checking spam
- Add **optimistic locking** (version field) to prevent concurrent booking conflicts
- Consider **caching** available slots for frequently queried dates/times
- Implement **notification system** for booking confirmations and reminders
- Add **audit trail** for booking modifications if needed for compliance
