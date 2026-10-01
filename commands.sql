-- PostgreSQL Backup, Recovery and Streaming Replication
-- Commands and SQL used during the practical assignment

-- ============================================================
-- 1. LOGICAL BACKUP
-- ============================================================

-- Create a custom-format logical backup
pg_dump -Fc -f ~/backups/bootcamp.dump bootcamp;

-- List backup contents
pg_restore --list ~/backups/bootcamp.dump;


-- ============================================================
-- 2. LOGICAL RESTORE
-- ============================================================

-- Restore the backup into a test database
createdb bootcamp_check;

pg_restore -d bootcamp_check ~/backups/bootcamp.dump;

-- Verify restored students
SELECT count(*) AS student_count
FROM students;


-- ============================================================
-- 3. WAL ARCHIVING
-- ============================================================

-- PostgreSQL configuration
-- wal_level = replica
-- archive_mode = on
-- archive_command = copy /Y "%p" "C:\Users\KONZA-VDI\backups\wal\%f"

-- Force a WAL switch
SELECT pg_switch_wal();


-- ============================================================
-- 4. PHYSICAL BASE BACKUP
-- ============================================================

pg_basebackup -U postgres ^
-D "%USERPROFILE%\backups\base" ^
-Ft -z -Xs -P;


-- ============================================================
-- 5. POINT-IN-TIME RECOVERY
-- ============================================================

-- Example target-time query
SELECT now();

-- Recovery configuration
-- restore_command = 'cmd /c copy /Y "C:/Users/KONZA-VDI/backups/wal/%f" "%p"'
-- recovery_target_time = 'TARGET_TIMESTAMP'
-- recovery_target_action = 'promote'

-- Verify recovered data
SELECT count(*) AS student_count
FROM students;


-- ============================================================
-- 6. CREATE REPLICATION USER
-- ============================================================

CREATE ROLE replicator
WITH REPLICATION LOGIN PASSWORD 'reppass';


-- ============================================================
-- 7. REPLICATION ACCESS
-- ============================================================

-- pg_hba.conf entry:
-- host    replication    replicator    127.0.0.1/32    scram-sha-256


-- ============================================================
-- 8. CREATE STREAMING STANDBY
-- ============================================================

pg_basebackup -h 127.0.0.1 ^
-U replicator ^
-D "%USERPROFILE%\standby" ^
-R -P;


-- ============================================================
-- 9. VERIFY STANDBY
-- ============================================================

SELECT pg_is_in_recovery();


-- ============================================================
-- 10. CHECK REPLICATION HEALTH
-- ============================================================

SELECT application_name,
       client_addr,
       state,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;


-- ============================================================
-- 11. REPLICATION TEST
-- ============================================================

CREATE TABLE replication_test (
    id SERIAL PRIMARY KEY,
    message TEXT
);

INSERT INTO replication_test (message)
VALUES ('Streaming replication works');

-- Run on standby:
SELECT *
FROM replication_test;