# Online Salon Booking System - User Journey & Availability Logic

## Table of Contents
1. [User Journey Overview](#user-journey-overview)
2. [Detailed User Flow](#detailed-user-flow)
3. [Provider Availability Checking](#provider-availability-checking)
4. [Time Slot Availability Algorithm](#time-slot-availability-algorithm)
5. [Cancellation & Re-availability](#cancellation--re-availability)
6. [Edge Cases & Validations](#edge-cases--validations)

---

## User Journey Overview

```
┌─────────────┐
│   Customer  │
│   Visits    │
│   Website   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Browse Services                                     │
│  View all available services with descriptions & prices      │
│  - Haircut (30 min) - $25                                   │
│  - Trimming (15 min) - $12                                  │
│  - Facial (45 min) - $40                                    │
│  - Hair Coloring (90 min) - $80                             │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Select Service                                      │
│  Customer clicks on desired service (e.g., "Haircut")       │
│  System notes: duration = 30 minutes                         │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Choose Date                                         │
│  Customer selects booking date from calendar                 │
│  (e.g., January 15, 2026)                                   │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: View Available Providers                           │
│  System shows which providers are:                           │
│  ✅ Offering this service                                   │
│  ✅ Working on this day                                     │
│  ✅ Available for booking                                   │
│                                                              │
│  Example Display:                                            │
│  ┌──────────────────────────────────────────┐              │
│  │ Provider 1: John Smith    ⭐ 4.8 (120)   │              │
│  │ Specialization: Hair Styling              │              │
│  │ [View Time Slots]                         │              │
│  └──────────────────────────────────────────┘              │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 5: Select Provider                                     │
│  Customer chooses preferred provider                         │
│  OR can choose "Any Available Provider"                      │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 6: View Available Time Slots                          │
│  System displays available time slots:                       │
│                                                              │
│  ⏰ Available Slots for John Smith - Jan 15, 2026          │
│  ┌──────┬──────┬──────┬──────┬──────┐                     │
│  │09:00 │09:30 │10:00 │      │11:00 │ Morning             │
│  └──────┴──────┴──────┴──────┴──────┘                     │
│  ┌──────┬──────┬──────┬──────┐                             │
│  │02:00 │02:30 │      │03:30 │ Afternoon                   │
│  └──────┴──────┴──────┴──────┘                             │
│  ┌──────┬──────┬──────┐                                     │
│  │05:00 │06:00 │07:00 │ Evening                            │
│  └──────┴──────┴──────┘                                     │
│                                                              │
│  ⚠️ Grayed out slots are already booked                    │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 7: Select Time Slot                                    │
│  Customer clicks on available time slot (e.g., 02:00 PM)    │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 8: Confirm Booking Details                            │
│  ┌────────────────────────────────────────────┐            │
│  │ Booking Summary                             │            │
│  │ ──────────────────────────────────────────│            │
│  │ Service:     Haircut                        │            │
│  │ Duration:    30 minutes                     │            │
│  │ Provider:    John Smith                     │            │
│  │ Date:        January 15, 2026               │            │
│  │ Time:        02:00 PM - 02:30 PM           │            │
│  │ Price:       $25.00                         │            │
│  │                                             │            │
│  │ [Confirm Booking] [Cancel]                 │            │
│  └────────────────────────────────────────────┘            │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 9: System Validates & Creates Booking                 │
│  🔄 Real-time validation:                                   │
│     1. Check slot still available (prevent race condition)  │
│     2. Lock database row for this provider's schedule       │
│     3. Verify no conflicting bookings                       │
│     4. Create booking record                                │
│     5. Send confirmation notification                       │
└──────┬──────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 10: Booking Confirmed! 🎉                             │
│  ┌────────────────────────────────────────────┐            │
│  │ ✅ Booking Confirmed!                      │            │
│  │                                             │            │
│  │ Booking ID: #BK-12345                      │            │
│  │ Confirmation sent to: user@email.com       │            │
│  │                                             │            │
│  │ [View Booking] [Add to Calendar]           │            │
│  └────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

---

## Detailed User Flow

### 1️⃣ **Landing Page - Browse Services**

**What User Sees:**
```
┌──────────────────────────────────────────────────────────────┐
│                     SALON SERVICES                            │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ✂️  HAIRCUT                                    30 min  $25  │
│      Professional haircut with styling                        │
│      [Book Now]                                               │
│                                                               │
│  💈  TRIMMING                                   15 min  $12  │
│      Beard trimming and shaping                               │
│      [Book Now]                                               │
│                                                               │
│  🧖  FACIAL                                     45 min  $40  │
│      Deep cleansing facial treatment                          │
│      [Book Now]                                               │
│                                                               │
│  🎨  HAIR COLORING                              90 min  $80  │
│      Full hair coloring service                               │
│      [Book Now]                                               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

**Backend Query:**
```sql
-- Get all active services
SELECT
    service_id,
    service_name,
    description,
    duration_minutes,
    price,
    category
FROM services
WHERE is_active = TRUE
ORDER BY category, service_name;
```

---

### 2️⃣ **Select Service - "Haircut"**

**User Action:** Clicks "Book Now" on Haircut

**System Captures:**
- `service_id = 1`
- `duration_minutes = 30`
- `price = 25.00`

---

### 3️⃣ **Choose Date**

**What User Sees:**
```
┌──────────────────────────────────────┐
│      📅 Select Booking Date          │
├──────────────────────────────────────┤
│                                       │
│    January 2026                       │
│  Su Mo Tu We Th Fr Sa                │
│            1  2  3  4                │
│   5  6  7  8  9 10 11                │
│  12 13 14 [15] 16 17 18              │
│  19 20 21 22 23 24 25                │
│  26 27 28 29 30 31                   │
│                                       │
│  Selected: Wednesday, Jan 15, 2026   │
│                                       │
│  [Next: Choose Provider]             │
└──────────────────────────────────────┘
```

**System Validates:**
- Date is not in the past
- Date is within booking window (e.g., max 30 days ahead)

---

### 4️⃣ **View Available Providers for This Service**

**Backend Query:**
```sql
-- Get providers who offer "Haircut" service
SELECT
    sp.provider_id,
    sp.full_name,
    sp.specialization,
    sp.experience_years,
    sp.rating,
    sp.total_reviews
FROM service_providers sp
INNER JOIN provider_services ps
    ON sp.provider_id = ps.provider_id
INNER JOIN working_hours wh
    ON sp.provider_id = wh.provider_id
WHERE ps.service_id = 1  -- Haircut service
    AND sp.is_available = TRUE
    AND wh.day_of_week = 'Wednesday'  -- Jan 15 is Wednesday
    AND wh.is_working = TRUE
ORDER BY sp.rating DESC, sp.experience_years DESC;
```

**What User Sees:**
```
┌────────────────────────────────────────────────────────┐
│  Available Providers for Haircut - Jan 15, 2026       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✅ Provider 1: John Smith           ⭐ 4.8 (120)     │
│     Specialization: Hair Styling & Cuts                │
│     Experience: 8 years                                 │
│     [View Available Times]                              │
│                                                         │
│  ✅ Provider 2: Sarah Johnson        ⭐ 4.9 (145)     │
│     Specialization: Modern Hair Design                  │
│     Experience: 10 years                                │
│     [View Available Times]                              │
│                                                         │
│  ✅ Provider 3: Mike Williams        ⭐ 4.7 (98)      │
│     Specialization: Classic Cuts                        │
│     Experience: 5 years                                 │
│     [View Available Times]                              │
│                                                         │
│  💡 OR: [Show me first available across all providers] │
└────────────────────────────────────────────────────────┘
```

---

### 5️⃣ **Select Provider - "John Smith"**

**User Action:** Clicks "View Available Times" for John Smith

**System Captures:**
- `provider_id = 1`
- `booking_date = 2026-01-15`
- `service_duration = 30 minutes`

---

### 6️⃣ **View Available Time Slots (MOST IMPORTANT STEP)**

This is where the **core availability algorithm** runs!

**Backend Query - Get Available Slots:**
```sql
WITH
-- Step 1: Get all time slots
all_slots AS (
    SELECT
        slot_id,
        slot_time,
        slot_label
    FROM time_slots
    WHERE is_active = TRUE
),

-- Step 2: Get provider's working hours for Wednesday
provider_hours AS (
    SELECT
        start_time,
        end_time
    FROM working_hours
    WHERE provider_id = 1  -- John Smith
        AND day_of_week = 'Wednesday'
        AND is_working = TRUE
),

-- Step 3: Get all booked slots for this provider on this date
booked_slots AS (
    SELECT
        booking_id,
        start_time,
        end_time
    FROM bookings
    WHERE provider_id = 1
        AND booking_date = '2026-01-15'
        AND status IN ('pending', 'confirmed')  -- Only active bookings
)

-- Step 4: Calculate available slots
SELECT
    s.slot_time,
    s.slot_label,
    -- Check if this slot is available
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM booked_slots b
            WHERE s.slot_time >= b.start_time
                AND s.slot_time < b.end_time
        ) THEN FALSE
        -- Also check if service duration fits before next booking
        WHEN EXISTS (
            SELECT 1
            FROM booked_slots b
            WHERE s.slot_time < b.start_time
                AND ADDTIME(s.slot_time, '00:30:00') > b.start_time
        ) THEN FALSE
        ELSE TRUE
    END AS is_available,
    -- Calculate end time for this service
    ADDTIME(s.slot_time, '00:30:00') AS would_end_at
FROM all_slots s
CROSS JOIN provider_hours ph
WHERE
    -- Slot is within working hours
    s.slot_time >= ph.start_time
    AND s.slot_time < ph.end_time
    -- Service can complete before working hours end
    AND ADDTIME(s.slot_time, '00:30:00') <= ph.end_time
ORDER BY s.slot_time;
```

**Result Example:**
```
slot_time  | slot_label | is_available | would_end_at
-----------|------------|--------------|-------------
09:00:00   | 09:00 AM   | TRUE         | 09:30:00
09:15:00   | 09:15 AM   | TRUE         | 09:45:00
09:30:00   | 09:30 AM   | TRUE         | 10:00:00
09:45:00   | 09:45 AM   | FALSE        | 10:15:00  ← Conflicts with 10:00 booking
10:00:00   | 10:00 AM   | FALSE        | 10:30:00  ← Already booked
10:15:00   | 10:15 AM   | FALSE        | 10:45:00  ← Within existing booking
10:30:00   | 10:30 AM   | TRUE         | 11:00:00
11:00:00   | 11:00 AM   | TRUE         | 11:30:00
...
```

**What User Sees:**
```
┌──────────────────────────────────────────────────────────┐
│  📅 Available Times - John Smith - Jan 15, 2026          │
│  Service: Haircut (30 minutes)                            │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  🌅 MORNING                                              │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐           │
│  │ 09:00  │ │ 09:15  │ │ 09:30  │ │ 10:30  │           │
│  │   AM   │ │   AM   │ │   AM   │ │   AM   │           │
│  └────────┘ └────────┘ └────────┘ └────────┘           │
│                                                           │
│  ⊗ 09:45 AM  ⊗ 10:00 AM  ⊗ 10:15 AM  ← Already Booked  │
│                                                           │
│  🌞 AFTERNOON                                            │
│  ┌────────┐ ┌────────┐ ┌────────┐                       │
│  │ 02:00  │ │ 02:30  │ │ 03:30  │                       │
│  │   PM   │ │   PM   │ │   PM   │                       │
│  └────────┘ └────────┘ └────────┘                       │
│                                                           │
│  ⊗ 03:00 PM  ← Already Booked                           │
│                                                           │
│  🌙 EVENING                                              │
│  ┌────────┐ ┌────────┐ ┌────────┐                       │
│  │ 05:00  │ │ 06:00  │ │ 07:00  │                       │
│  │   PM   │ │   PM   │ │   PM   │                       │
│  └────────┘ └────────┘ └────────┘                       │
│                                                           │
│  💡 Click on any available time slot to book             │
└──────────────────────────────────────────────────────────┘
```

---

### 7️⃣ **User Selects Time Slot - "02:00 PM"**

**User Action:** Clicks on "02:00 PM" slot

**System Calculates:**
- `start_time = 14:00:00` (02:00 PM)
- `end_time = 14:30:00` (02:30 PM)  [start + 30 minutes]

**System Shows Confirmation Screen**

---

### 8️⃣ **Booking Confirmation Screen**

```
┌──────────────────────────────────────────────────────────┐
│  📋 Confirm Your Booking                                  │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  Service:         ✂️ Haircut                            │
│  Duration:        30 minutes                              │
│  Provider:        John Smith ⭐ 4.8                      │
│  Date:            Wednesday, January 15, 2026            │
│  Time:            02:00 PM - 02:30 PM                    │
│  Price:           $25.00                                  │
│                                                           │
│  ─────────────────────────────────────────────────────  │
│                                                           │
│  Customer Details:                                        │
│  Name:     Mike Johnson                                   │
│  Email:    mike@email.com                                 │
│  Phone:    (555) 123-4567                                │
│                                                           │
│  ─────────────────────────────────────────────────────  │
│                                                           │
│  ⚠️  Cancellation Policy:                                │
│      Free cancellation up to 2 hours before appointment  │
│                                                           │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │ Confirm Booking  │  │      Cancel      │            │
│  └──────────────────┘  └──────────────────┘            │
└──────────────────────────────────────────────────────────┘
```

---

### 9️⃣ **System Creates Booking (Critical Transaction)**

When user clicks "Confirm Booking", this happens:

**Backend Process with Transaction:**
```sql
-- Start transaction to prevent race conditions
START TRANSACTION;

-- Step 1: Lock the provider's row to prevent concurrent bookings
SELECT provider_id
FROM service_providers
WHERE provider_id = 1
FOR UPDATE;

-- Step 2: Double-check slot is still available (race condition check)
SET @is_available = (
    SELECT COUNT(*) = 0
    FROM bookings
    WHERE provider_id = 1
        AND booking_date = '2026-01-15'
        AND status IN ('pending', 'confirmed')
        AND (
            -- Check for any time overlap
            (start_time < '14:30:00' AND end_time > '14:00:00')
        )
);

-- Step 3: If available, create the booking
INSERT INTO bookings (
    user_id,
    provider_id,
    service_id,
    booking_date,
    start_time,
    end_time,
    status,
    total_amount,
    created_at
)
SELECT
    12,  -- Customer's user_id
    1,   -- John Smith's provider_id
    1,   -- Haircut service_id
    '2026-01-15',
    '14:00:00',
    '14:30:00',
    'confirmed',
    25.00,
    NOW()
WHERE @is_available = 1;  -- Only insert if still available

-- Step 4: Get the booking ID
SET @booking_id = LAST_INSERT_ID();

-- Step 5: Create notification
INSERT INTO notifications (
    user_id,
    booking_id,
    notification_type,
    message,
    is_read,
    sent_at
)
VALUES (
    12,
    @booking_id,
    'booking_confirmed',
    'Your booking with John Smith on Jan 15, 2026 at 02:00 PM has been confirmed!',
    FALSE,
    NOW()
);

-- Commit the transaction
COMMIT;
```

**What Happens:**
1. ✅ **Database Lock:** Provider's schedule is locked during transaction
2. ✅ **Availability Re-check:** System verifies slot is STILL available
3. ✅ **Booking Creation:** If available, booking record is created
4. ✅ **Notification:** User receives confirmation
5. ❌ **Rollback:** If someone else booked the slot simultaneously, transaction fails and user is notified

---

### 🔟 **Booking Confirmed!**

```
┌──────────────────────────────────────────────────────────┐
│  ✅ Booking Confirmed Successfully!                       │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  📧 Confirmation email sent to: mike@email.com           │
│  📱 SMS reminder will be sent 2 hours before             │
│                                                           │
│  ─────────────────────────────────────────────────────  │
│                                                           │
│  Booking Details:                                         │
│  Booking ID:      #BK-12345                              │
│  Service:         Haircut                                 │
│  Provider:        John Smith                              │
│  Date:            Wednesday, Jan 15, 2026                │
│  Time:            02:00 PM - 02:30 PM                    │
│  Amount Paid:     $25.00                                  │
│                                                           │
│  ─────────────────────────────────────────────────────  │
│                                                           │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │ Add to Calendar  │  │ View My Bookings │            │
│  └──────────────────┘  └──────────────────┘            │
│                                                           │
│  Need to cancel? You can cancel up to 2 hours before.   │
│  [Cancel Booking]                                         │
└──────────────────────────────────────────────────────────┘
```

---

## Provider Availability Checking

### How System Determines Provider Availability

```
┌─────────────────────────────────────────────────────────┐
│        PROVIDER AVAILABILITY CHECK FLOWCHART             │
└─────────────────────────────────────────────────────────┘

Input: service_id, date, time_slot

        ┌──────────────────────────┐
        │  Find Providers Who      │
        │  Offer This Service      │
        └────────────┬─────────────┘
                     │
                     ▼
        ┌──────────────────────────┐
        │  Filter by Working Day   │
        │  (Is provider working    │
        │   on this day?)          │
        └────────────┬─────────────┘
                     │
                     ▼
        ┌──────────────────────────┐
        │  Check Working Hours     │
        │  (Is time slot within    │
        │   working hours?)        │
        └────────────┬─────────────┘
                     │
                     ▼
        ┌──────────────────────────┐
        │  Check Existing Bookings │
        │  (Is there a conflict?)  │
        └────────────┬─────────────┘
                     │
                     ▼
        ┌──────────────────────────┐
        │  Verify Service Duration │
        │  (Does service fit       │
        │   before next booking?)  │
        └────────────┬─────────────┘
                     │
                     ▼
        ┌──────────────────────────┐
        │  Return Available        │
        │  Providers               │
        └──────────────────────────┘
```

---

## Time Slot Availability Algorithm

### Visual Example: How Slots Are Calculated

**Scenario:**
- **Service:** Haircut (30 minutes)
- **Provider:** John Smith
- **Date:** January 15, 2026 (Wednesday)
- **Working Hours:** 9:00 AM - 8:00 PM

**Step-by-Step Calculation:**

#### Step 1: Generate All Possible Time Slots
```
Time Slots (15-min intervals):
09:00, 09:15, 09:30, 09:45, 10:00, 10:15, 10:30, 10:45, 11:00, ...
```

#### Step 2: Filter by Working Hours
```
Working Hours: 09:00 - 20:00

Valid Slots:
✅ 09:00 - within working hours
✅ 09:15 - within working hours
...
✅ 19:30 - within working hours (ends at 20:00)
❌ 19:45 - would end at 20:15 (outside working hours)
```

#### Step 3: Check Existing Bookings
```
Existing Bookings for John Smith on Jan 15:
┌─────────┬──────────┬──────────┐
│Booking  │Start Time│ End Time │
├─────────┼──────────┼──────────┤
│Booking A│ 10:00 AM │ 10:30 AM │
│Booking B│ 03:00 PM │ 03:45 PM │
│Booking C│ 06:00 PM │ 07:00 PM │
└─────────┴──────────┴──────────┘
```

#### Step 4: Visual Timeline
```
Timeline for Jan 15, 2026:
─────────────────────────────────────────────────────────────

09:00 ████ Available (30 min) → ends 09:30 ✅
09:15 ████ Available (30 min) → ends 09:45 ✅
09:30 ████ Available (30 min) → ends 10:00 ✅
09:45 ⊗⊗⊗⊗ BLOCKED → would end at 10:15, conflicts with 10:00 booking ❌
10:00 ████ BOOKED (Booking A) ❌
10:15 ⊗⊗⊗⊗ BLOCKED (within Booking A) ❌
10:30 ████ Available (30 min) → ends 11:00 ✅
11:00 ████ Available (30 min) → ends 11:30 ✅
...
14:00 ████ Available (30 min) → ends 14:30 ✅
14:30 ████ Available (30 min) → ends 15:00 ✅
15:00 ████ BOOKED (Booking B) ❌
15:15 ⊗⊗⊗⊗ BLOCKED (within Booking B) ❌
15:30 ⊗⊗⊗⊗ BLOCKED (within Booking B) ❌
15:45 ████ Available (30 min) → ends 16:15 ✅
...
17:30 ████ Available (30 min) → ends 18:00 ✅
17:45 ⊗⊗⊗⊗ BLOCKED → would end at 18:15, conflicts with 18:00 booking ❌
18:00 ████ BOOKED (Booking C) ❌
18:15 ⊗⊗⊗⊗ BLOCKED (within Booking C) ❌
...
19:00 ████ Available (30 min) → ends 19:30 ✅
19:30 ████ Available (30 min) → ends 20:00 ✅
19:45 ⊗⊗⊗⊗ BLOCKED → would end at 20:15 (after working hours) ❌
```

#### Step 5: Available Slots Result
```
✅ AVAILABLE TIME SLOTS:
Morning:    09:00, 09:15, 09:30, 10:30, 11:00, 11:15, ...
Afternoon:  14:00, 14:30, 15:45, 16:00, 16:15, ...
Evening:    17:00, 17:15, 17:30, 19:00, 19:30
```

---

## Cancellation & Re-availability

### What Happens When a Booking is Cancelled

**User Initiates Cancellation:**

```
┌──────────────────────────────────────────────────────────┐
│  My Bookings                                              │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  📅 Upcoming Booking                                     │
│  ─────────────────────────────────────────────────────  │
│  Service:    Haircut                                      │
│  Provider:   John Smith                                   │
│  Date:       Jan 15, 2026                                │
│  Time:       03:00 PM - 03:30 PM                         │
│  Status:     Confirmed                                    │
│                                                           │
│  [Cancel This Booking]                                    │
└──────────────────────────────────────────────────────────┘
```

**Backend Process:**
```sql
-- Cancel booking
UPDATE bookings
SET
    status = 'cancelled',
    cancellation_reason = 'Customer requested cancellation',
    cancelled_at = NOW(),
    updated_at = NOW()
WHERE booking_id = 12345
    AND user_id = 12
    AND status IN ('pending', 'confirmed');

-- Verify it was updated
SELECT * FROM bookings WHERE booking_id = 12345;
```

**Result:**
```
booking_id: 12345
status: 'cancelled'  ← Changed from 'confirmed' to 'cancelled'
cancelled_at: 2026-01-10 10:30:00
```

**Immediate Effect on Availability:**

When the availability query runs again:
```sql
-- This booking is now EXCLUDED from conflict check
SELECT *
FROM bookings
WHERE provider_id = 1
    AND booking_date = '2026-01-15'
    AND status IN ('pending', 'confirmed')  ← 'cancelled' is excluded!
```

**Timeline Before Cancellation:**
```
03:00 PM ████ BOOKED ❌
03:15 PM ⊗⊗⊗⊗ BLOCKED ❌
03:30 PM ████ Available ✅
```

**Timeline After Cancellation:**
```
03:00 PM ████ Available ✅  ← Now available!
03:15 PM ████ Available ✅  ← Now available!
03:30 PM ████ Available ✅
```

**Real-time Update:**
The moment cancellation is processed:
1. ✅ Slot becomes immediately available
2. ✅ Other users can now book this time
3. ✅ Original user receives cancellation confirmation
4. ✅ Provider receives cancellation notification

---

## Edge Cases & Validations

### 1. **Simultaneous Booking (Race Condition)**

**Scenario:**
Two users try to book the same slot at the exact same time.

```
User A: Selects 03:00 PM → Clicks "Confirm"
User B: Selects 03:00 PM → Clicks "Confirm"
              ↓
        Who gets the slot?
```

**Solution: Database Transaction with Row Locking**

```sql
-- User A's transaction starts first
START TRANSACTION;
SELECT provider_id FROM service_providers
WHERE provider_id = 1 FOR UPDATE;  -- 🔒 Locks the row

-- Check availability
-- Create booking
COMMIT;  -- 🔓 Releases lock

-- User B's transaction waits for lock
-- When lock is released, User B's check fails
-- User B sees: "Sorry, this slot was just booked!"
```

**Result:**
- ✅ User A: Booking confirmed
- ❌ User B: "This time slot is no longer available. Please select another time."

---

### 2. **Booking Longer Services (e.g., Hair Coloring - 90 min)**

**Challenge:**
Ensure 90-minute service doesn't conflict with any bookings in the next 90 minutes.

**Example:**
```
User wants to book Hair Coloring (90 min) at 02:00 PM

Timeline:
02:00 PM ────┐
02:15 PM     │
02:30 PM     │ 90 minutes
02:45 PM     │
03:00 PM     │
03:15 PM     │
03:30 PM ────┘ Would end here

Existing booking at 03:15 PM?
❌ CONFLICT! Cannot book 02:00 PM slot.

No bookings until 03:30 PM?
✅ AVAILABLE! Can book 02:00 PM slot.
```

**Query Logic:**
```sql
-- Check if 90-minute service fits
WHERE ADDTIME(slot_time, '01:30:00') <= end_of_working_hours
    AND NOT EXISTS (
        SELECT 1 FROM bookings
        WHERE start_time < ADDTIME(slot_time, '01:30:00')
            AND end_time > slot_time
    )
```

---

### 3. **Booking Outside Working Hours**

**Scenario:**
User tries to book at 07:30 PM, but working hours end at 08:00 PM.
Service duration: 45 minutes (Facial)

```
07:30 PM ────┐
             │ 45 minutes
08:15 PM ────┘ Would end here

Working hours end: 08:00 PM ❌

Result: Slot not shown as available
```

**Validation:**
```sql
-- Only show slots where service completes within working hours
WHERE ADDTIME(slot_time, SEC_TO_TIME(duration_minutes * 60)) <= working_end_time
```

---

### 4. **Provider Not Working on Selected Day**

**Scenario:**
User selects Sunday, but provider doesn't work on Sundays.

**Query Result:**
```sql
SELECT * FROM working_hours
WHERE provider_id = 1
    AND day_of_week = 'Sunday'
    AND is_working = TRUE;

-- Returns: 0 rows
```

**User Sees:**
```
┌──────────────────────────────────────────────────────────┐
│  ⚠️  Provider Not Available                              │
│                                                           │
│  John Smith is not working on Sundays.                   │
│                                                           │
│  Please select another day or choose a different         │
│  provider.                                                │
│                                                           │
│  [Choose Another Day] [View Other Providers]            │
└──────────────────────────────────────────────────────────┘
```

---

### 5. **Last-Minute Cancellation & Rebooking**

**Scenario:**
User cancels booking at 02:50 PM for a 03:00 PM appointment.

**System Behavior:**
```
02:50 PM: Cancellation processed
          ↓
03:00 PM slot becomes available
          ↓
Another user can book immediately
          ↓
Even for the same 03:00 PM time slot!
```

**Real-world Consideration:**
Some salons may want a "buffer period" after cancellation.

**Optional Implementation:**
```sql
-- Add buffer: Don't allow rebooking within 15 minutes of cancellation
WHERE NOT EXISTS (
    SELECT 1 FROM bookings
    WHERE status = 'cancelled'
        AND TIMESTAMPDIFF(MINUTE, cancelled_at, NOW()) < 15
        AND start_time = :requested_start_time
)
```

---

### 6. **Multiple Services in One Booking**

**Future Enhancement:**
User wants both Haircut (30 min) + Beard Grooming (25 min) = 55 minutes total

**Implementation:**
```sql
-- Calculate total duration
SET @total_duration = (
    SELECT SUM(duration_minutes)
    FROM services
    WHERE service_id IN (1, 6)  -- Haircut + Beard Grooming
);

-- Check availability for 55-minute block
WHERE ADDTIME(slot_time, SEC_TO_TIME(@total_duration * 60)) <= ...
```

---

## Summary: Complete Flow Diagram

```
┌────────────────────────────────────────────────────────────┐
│                   BOOKING SYSTEM FLOW                       │
└────────────────────────────────────────────────────────────┘

1. USER BROWSES SERVICES
   ↓
2. SELECTS SERVICE (captures duration)
   ↓
3. CHOOSES DATE
   ↓
4. SYSTEM QUERIES:
   ├─ Which providers offer this service?
   ├─ Which providers work on this day?
   └─ Shows available providers with ratings
   ↓
5. USER SELECTS PROVIDER
   ↓
6. SYSTEM CALCULATES AVAILABLE SLOTS:
   ├─ Get all time slots
   ├─ Filter by working hours
   ├─ Exclude booked slots
   ├─ Check service duration fits
   └─ Return available slots
   ↓
7. USER SELECTS TIME SLOT
   ↓
8. SYSTEM SHOWS CONFIRMATION SCREEN
   ↓
9. USER CONFIRMS
   ↓
10. SYSTEM CREATES BOOKING:
    ├─ Start transaction
    ├─ Lock provider row
    ├─ Recheck availability
    ├─ Insert booking record
    ├─ Send notification
    └─ Commit transaction
    ↓
11. BOOKING CONFIRMED! ✅
    ↓
12. IF USER CANCELS:
    ├─ Update status to 'cancelled'
    └─ Slot becomes immediately available
```

---

## Key Takeaways

✅ **Real-time Availability:** System checks availability dynamically based on:
   - Service duration
   - Provider working hours
   - Existing bookings
   - Time slot intervals

✅ **No Double Booking:** Transaction-based booking with row-level locking prevents conflicts

✅ **Immediate Re-availability:** Cancelled bookings immediately show as available

✅ **Smart Scheduling:** System ensures service duration fits before next booking

✅ **User-Friendly:** Visual time slot selection with clear availability indicators

---

## Technical Implementation Notes

**Performance Optimization:**
- Index on `(provider_id, booking_date, start_time, end_time)`
- Index on `(booking_date, status)`
- Cache frequently accessed provider working hours
- Use connection pooling for concurrent bookings

**Scalability:**
- Consider Redis for real-time slot caching
- Use message queue for notifications
- Implement optimistic locking as alternative to row locks
- Add read replicas for availability queries

**Security:**
- Validate user permissions before cancellation
- Prevent booking manipulation via API
- Rate limit slot-checking requests
- Sanitize all user inputs

---

🎉 **End of User Journey Documentation**
