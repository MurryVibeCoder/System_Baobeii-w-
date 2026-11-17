-- Database for "Lily & Lotus Dates" (index.html)
-- Requires MySQL 8.0.16+ (for the CHECK constraint)

CREATE DATABASE IF NOT EXISTS lily_lotus
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE lily_lotus;

-- ------------------------------------------------------------
-- 1. Accounts: one "her" and one "him" (same as the two login panes)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS accounts (
  id            TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role          ENUM('her', 'him') NOT NULL UNIQUE,   -- only one account per side
  name          VARCHAR(24)  NOT NULL,                -- maxlength 24 in the form
  password_hash VARCHAR(255) NOT NULL,                -- store a bcrypt/argon2 hash, never the passcode
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 2. Events (the dates shown on the calendar)
--    Fields match the app: id, title, date, cat, start, end, place, notes, done
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS events (
  id         VARCHAR(32)  PRIMARY KEY,                -- the app generates string ids like 'lx3k9a2b'
  title      VARCHAR(80)  NOT NULL,
  event_date DATE         NOT NULL,
  category   ENUM('date', 'family', 'work', 'care', 'other') NOT NULL DEFAULT 'date',
  start_time TIME NULL,
  end_time   TIME NULL,
  place      VARCHAR(80)  NOT NULL DEFAULT '',
  notes      TEXT NULL,
  done       BOOLEAN      NOT NULL DEFAULT FALSE,
  created_by TINYINT UNSIGNED NULL,                   -- which account created it (optional)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_times CHECK (start_time IS NULL OR end_time IS NULL OR end_time > start_time),
  CONSTRAINT fk_events_account FOREIGN KEY (created_by)
    REFERENCES accounts(id) ON DELETE SET NULL,

  INDEX idx_date (event_date, start_time),            -- calendar and agenda sorting
  INDEX idx_category (category)                       -- category filter chips
);

-- ------------------------------------------------------------
-- 3. Optional sample data
-- ------------------------------------------------------------
INSERT INTO events (id, title, event_date, category, start_time, end_time, place, notes) VALUES
  ('demo0001', 'Dinner under the lanterns', CURDATE() + INTERVAL 2 DAY, 'date',   '18:00', '20:00', 'Riverside Cafe', 'Wear the blue dress'),
  ('demo0002', 'Sunday lunch with family',  CURDATE() + INTERVAL 5 DAY, 'family', '12:00', '14:00', 'Mom''s house',    'Bring dessert'),
  ('demo0003', 'Spa afternoon',             CURDATE() + INTERVAL 7 DAY, 'care',   '15:00', '17:00', 'Lotus Spa',       NULL);

-- ------------------------------------------------------------
-- 4. Limited user for your backend (don't use root)
--    Change the password, and replace '%' with your server's IP if you can.
-- ------------------------------------------------------------
CREATE USER IF NOT EXISTS 'lily_app'@'%' IDENTIFIED BY 'your_strong_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON lily_lotus.* TO 'lily_app'@'%';
FLUSH PRIVILEGES;

-- Quick check
SELECT id, title, event_date, category, start_time, end_time FROM events ORDER BY event_date, start_time;